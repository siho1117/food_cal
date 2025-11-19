// lib/data/repositories/food_repository.dart
import 'dart:io';
import 'dart:async';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/food_storage_service.dart';
import '../../services/food_image_service.dart';
import '../../config/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

/// Repository for coordinating food recognition workflow
/// Combines API service with storage and image services for the complete flow
class FoodRepository {
  final FoodApiService _apiService = FoodApiService();
  final FoodStorageService _storageService = FoodStorageService();

  /// Recognize food from an image and return results with saved image
  /// This is the main business logic that coordinates API, image storage, and data parsing
  /// Takes an image file and returns a list of recognized food items
  Future<List<FoodItem>> recognizeFood(File imageFile) async {
    try {
      // Call the API to analyze the image
      final analysisResult = await _apiService.analyzeImage(imageFile);

      // Save the image file for reference using FoodImageService
      final savedImagePath = await FoodImageService.saveImageFromFile(imageFile);

      // Process the results
      final List<FoodItem> recognizedItems = [];

      // Process response based on structure
      if (analysisResult.containsKey('category')) {
        // Single food item recognized (typical case)
        final item = FoodItem.fromApiAnalysis(analysisResult)
            .copyWith(imagePath: savedImagePath);
        recognizedItems.add(item);
      } else if (analysisResult.containsKey('annotations') &&
          analysisResult['annotations'] is List &&
          (analysisResult['annotations'] as List).isNotEmpty) {
        // Multiple food items recognized
        for (var annotation in analysisResult['annotations']) {
          try {
            if (annotation.containsKey('name') && annotation['name'] != null) {
              // Get detailed food information using the name
              final foodInfo =
                  await _apiService.getFoodInformation(annotation['name']);

              // Create food item with nutrition details
              final item = FoodItem(
                id: '${DateTime.now().millisecondsSinceEpoch}_${annotation['name']}',
                name: annotation['name'] ?? 'Unknown Food',
                calories: _extractNutrientValue(foodInfo, 'calories') ?? 0.0,
                proteins: _extractNutrientValue(foodInfo, 'protein') ?? 0.0,
                carbs: _extractNutrientValue(foodInfo, 'carbs') ?? 0.0,
                fats: _extractNutrientValue(foodInfo, 'fat') ?? 0.0,
                timestamp: DateTime.now(),
                servingSize: AppConstants.defaultServingSize,
                servingUnit: AppConstants.servingUnits[0],
                imagePath: savedImagePath,
              );
              recognizedItems.add(item);
            }
          } catch (e) {
            debugPrint('Error processing annotation: $e');
          }
        }
      }

      return recognizedItems;
    } catch (e) {
      debugPrint('Error recognizing food: $e');
      rethrow;
    }
  }

  /// Extract nutrient value from API response
  double? _extractNutrientValue(Map<String, dynamic> foodInfo, String nutrientName) {
    try {
      if (foodInfo.containsKey('nutrients') && foodInfo['nutrients'] is List) {
        final nutrients = foodInfo['nutrients'] as List;
        for (var nutrient in nutrients) {
          if (nutrient is Map<String, dynamic> && nutrient.containsKey('name')) {
            final name = nutrient['name']?.toString().toLowerCase() ?? '';
            if (name == nutrientName.toLowerCase()) {
              final amount = nutrient['amount'];
              return amount is num ? amount.toDouble() : null;
            }
          }
        }
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Expose storage service for direct access by UI layer
  /// UI should use this instead of going through repository pass-through methods
  FoodStorageService get storageService => _storageService;
}