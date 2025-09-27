// lib/data/repositories/food_repository.dart
// REFACTORED VERSION - Now uses FoodStorageService and ImageStorageService
import 'dart:io';
import 'dart:async';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/food_storage_service.dart';
import '../services/image_storage_service.dart';  // NEW: Use image service
import '../storage/local_storage.dart';
import '../../config/constants/app_constants.dart';

/// Repository for managing food data from API and local storage
/// Acts as a single access point for all food-related operations
/// REFACTORED: Now delegates storage operations to specialized services
class FoodRepository {
  final FoodApiService _apiService = FoodApiService();
  final FoodStorageService _storageService = FoodStorageService();
  final ImageStorageService _imageService = ImageStorageService();  // NEW: Use image service
  final LocalStorage _storage = LocalStorage();  // Still used for search/favorites temporarily

  // Storage keys for search and favorites (TODO: Move to FoodSearchService)
  static const String _recentSearchesKey = 'recent_food_searches';
  static const String _favoriteFoodsKey = 'favorite_foods';

  /// Recognize food from an image and return results
  /// Takes an image file and meal type (breakfast, lunch, dinner, snack)
  /// Returns a list of recognized food items
  Future<List<FoodItem>> recognizeFood(File imageFile, String mealType) async {
    try {
      // Call the API to analyze the image
      final analysisResult = await _apiService.analyzeImage(imageFile);

      // Save the image file for reference using ImageStorageService
      final savedImagePath = await _imageService.saveImageFile(imageFile);

      // Process the results
      final List<FoodItem> recognizedItems = [];

      // Process response based on structure
      if (analysisResult.containsKey('category')) {
        // Single food item recognized (typical case)
        final item = FoodItem.fromApiAnalysis(analysisResult, mealType)
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
                mealType: mealType,
                timestamp: DateTime.now(),
                servingSize: AppConstants.defaultServingSize,
                servingUnit: AppConstants.servingUnits[0], // 'serving'
                imagePath: savedImagePath,
              );

              recognizedItems.add(item);
            }
          } catch (e) {
            // Continue with other annotations if one fails
            continue;
          }
        }
      }

      return recognizedItems;
    } catch (e) {
      throw Exception('Failed to recognize food: $e');
    }
  }

  /// Extract a specific nutrient value from API response
  double? _extractNutrientValue(Map<String, dynamic> foodInfo, String nutrientName) {
    try {
      // Check if there's a nutrition section
      if (foodInfo.containsKey('nutrition')) {
        final nutrition = foodInfo['nutrition'];

        // Direct property format (e.g., nutrition.calories)
        if (nutrition.containsKey(nutrientName)) {
          final value = nutrition[nutrientName];
          if (value is num) {
            return value.toDouble();
          } else if (value is String) {
            final numValue = double.tryParse(value);
            if (numValue != null) {
              return numValue.toDouble();
            }
          }
        }

        // Nutrients array format
        if (nutrition.containsKey('nutrients') &&
            nutrition['nutrients'] is List) {
          for (var nutrient in nutrition['nutrients']) {
            // Case-insensitive comparison
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

  // === DELEGATED STORAGE OPERATIONS ===
  // These methods delegate to FoodStorageService

  /// Save a food entry to local storage
  Future<bool> saveFoodEntry(FoodItem item) async {
    return await _storageService.saveFoodEntry(item);
  }

  /// Save multiple food entries at once
  Future<bool> saveFoodEntries(List<FoodItem> items) async {
    return await _storageService.saveFoodEntries(items);
  }

  /// Get food entries for a specific date
  Future<List<FoodItem>> getFoodEntries(DateTime timestamp) async {
    return await _storageService.getFoodEntries(timestamp);
  }

  /// Get food entries for a specific date
  Future<List<FoodItem>> getFoodEntriesForDate(DateTime date) async {
    return await _storageService.getFoodEntriesForDate(date);
  }

  /// Get all food entries across all dates
  Future<List<FoodItem>> getAllFoodEntries() async {
    return await _storageService.getAllFoodEntries();
  }

  /// Update an existing food entry
  Future<bool> updateFoodEntry(FoodItem item) async {
    return await _storageService.updateFoodEntry(item);
  }

  /// Delete a food entry
  Future<bool> deleteFoodEntry(String id, DateTime timestamp) async {
    return await _storageService.deleteFoodEntry(id, timestamp);
  }

  /// Get food entries for a specific meal type on a date
  Future<List<FoodItem>> getFoodEntriesForMeal(DateTime date, String mealType) async {
    return await _storageService.getFoodEntriesForMeal(date, mealType);
  }

  /// Get food entries for a date range
  Future<List<FoodItem>> getFoodEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    return await _storageService.getFoodEntriesForDateRange(startDate, endDate);
  }

  /// Get recent food entries (last N days)
  Future<List<FoodItem>> getRecentFoodEntries({int days = 7}) async {
    return await _storageService.getRecentFoodEntries(days: days);
  }

  /// Get frequently consumed foods
  Future<List<FoodItem>> getFrequentFoods({int limit = 10}) async {
    return await _storageService.getFrequentFoods(limit: limit);
  }

  /// Get statistics for a date range
  Future<Map<String, dynamic>> getFoodStatistics(DateTime startDate, DateTime endDate) async {
    return await _storageService.getFoodStatistics(startDate, endDate);
  }

  // === DELEGATED IMAGE OPERATIONS ===
  // These methods delegate to ImageStorageService

  /// Get an image file from storage
  Future<File?> getImageFile(String imagePath) async {
    return await _imageService.getImageFile(imagePath);
  }

  /// Check if an image file exists
  Future<bool> imageExists(String imagePath) async {
    return await _imageService.imageExists(imagePath);
  }

  /// Delete an image file from storage
  Future<bool> deleteImageFile(String imagePath) async {
    return await _imageService.deleteImageFile(imagePath);
  }

  /// Get all food image files from storage
  Future<List<File>> getAllFoodImages() async {
    return await _imageService.getAllFoodImages();
  }

  /// Clean up old image files (older than specified days)
  Future<int> cleanupOldImages({int olderThanDays = 30}) async {
    return await _imageService.cleanupOldImages(olderThanDays: olderThanDays);
  }

  /// Get total storage used by food images in bytes
  Future<int> getTotalImageStorageUsed() async {
    return await _imageService.getTotalImageStorageUsed();
  }

  /// Format storage size for display
  String formatStorageSize(int bytes) {
    return _imageService.formatStorageSize(bytes);
  }

  /// Clear all food images from storage
  Future<int> clearAllImages() async {
    return await _imageService.clearAllImages();
  }

  // === SEARCH AND FAVORITES OPERATIONS ===
  // TODO: Move these to FoodSearchService in next refactor

  /// Search for foods by name using the API
  Future<List<FoodItem>> searchFoods(String query, String mealType) async {
    try {
      if (query.trim().isEmpty) return [];

      // Add to recent searches
      await _addToRecentSearches(query);

      // Use the API service to search for foods
      final results = await _apiService.searchFoods(query);
      
      final List<FoodItem> foodItems = [];

      for (final result in results) {
        try {
          // Get detailed nutrition information
          final foodInfo = await _apiService.getFoodInformation(result['name']);
          
          foodItems.add(FoodItem(
            id: '${DateTime.now().millisecondsSinceEpoch}_${result['name']}',
            name: result['name'] ?? 'Unknown Food',
            calories: _extractNutrientValue(foodInfo, 'calories') ?? 0.0,
            proteins: _extractNutrientValue(foodInfo, 'protein') ?? 0.0,
            carbs: _extractNutrientValue(foodInfo, 'carbs') ?? 0.0,
            fats: _extractNutrientValue(foodInfo, 'fat') ?? 0.0,
            mealType: mealType,
            timestamp: DateTime.now(),
            servingSize: AppConstants.defaultServingSize,
            servingUnit: AppConstants.servingUnits[0], // 'serving'
          ));
        } catch (e) {
          // Add with limited information if detailed lookup fails
          foodItems.add(FoodItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            name: result['name'] ?? 'Unknown Food',
            calories: 0.0,
            proteins: 0.0,
            carbs: 0.0,
            fats: 0.0,
            mealType: mealType,
            timestamp: DateTime.now(),
            servingSize: AppConstants.defaultServingSize,
            servingUnit: AppConstants.servingUnits[0], // 'serving'
          ));
        }
      }

      return foodItems;
    } catch (e) {
      throw Exception('Failed to search foods: $e');
    }
  }

  /// Add a search query to recent searches
  Future<void> _addToRecentSearches(String query) async {
    try {
      final recentSearches = await getRecentSearches();
      
      // Remove if already exists to avoid duplicates
      recentSearches.removeWhere((search) => search.toLowerCase() == query.toLowerCase());
      
      // Add to beginning
      recentSearches.insert(0, query);
      
      // Keep only the most recent searches
      if (recentSearches.length > AppConstants.maxRecentSearches) {
        recentSearches.removeRange(AppConstants.maxRecentSearches, recentSearches.length);
      }
      
      await _storage.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      // Fail silently for recent searches
    }
  }

  /// Get recent search queries
  Future<List<String>> getRecentSearches() async {
    try {
      return await _storage.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _storage.remove(_recentSearchesKey);
    } catch (e) {
      // Fail silently
    }
  }

  /// Add a food item to favorites
  Future<bool> addToFavorites(FoodItem item) async {
    try {
      final favorites = await getFavorites();
      
      // Check if already in favorites (by name)
      final exists = favorites.any((fav) => fav.name.toLowerCase() == item.name.toLowerCase());
      if (exists) return true; // Already in favorites
      
      favorites.add(item);
      
      // Convert to maps for storage
      final favoritesData = favorites.map((item) => item.toMap()).toList();
      
      return await _storage.setObjectList(_favoriteFoodsKey, favoritesData);
    } catch (e) {
      return false;
    }
  }

  /// Remove a food item from favorites
  Future<bool> removeFromFavorites(String foodName) async {
    try {
      final favorites = await getFavorites();
      
      // Remove items with matching name (case-insensitive)
      final originalLength = favorites.length;
      favorites.removeWhere((item) => item.name.toLowerCase() == foodName.toLowerCase());
      
      if (favorites.length < originalLength) {
        // Convert to maps for storage
        final favoritesData = favorites.map((item) => item.toMap()).toList();
        return await _storage.setObjectList(_favoriteFoodsKey, favoritesData);
      }
      
      return false; // Nothing was removed
    } catch (e) {
      return false;
    }
  }

  /// Get favorite food items
  Future<List<FoodItem>> getFavorites() async {
    try {
      final favoritesData = await _storage.getObjectList(_favoriteFoodsKey);
      
      if (favoritesData == null) return [];
      
      return favoritesData.map((data) => FoodItem.fromMap(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if a food item is in favorites
  Future<bool> isFavorite(String foodName) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((item) => item.name.toLowerCase() == foodName.toLowerCase());
    } catch (e) {
      return false;
    }
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      await _storage.remove(_favoriteFoodsKey);
      return true;
    } catch (e) {
      return false;
    }
  }
  
}