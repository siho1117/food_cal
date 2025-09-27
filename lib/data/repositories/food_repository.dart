// lib/data/repositories/food_repository.dart
// REFACTORED VERSION - Now uses FoodStorageService and ImageStorageService
// INCLUDES DEBUG METHODS for image storage troubleshooting
import 'dart:io';
import 'dart:async';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../services/food_storage_service.dart';
import '../services/image_storage_service.dart';
import '../storage/local_storage.dart';
import '../../config/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

/// Repository for managing food data from API and local storage
/// Acts as a single access point for all food-related operations
/// REFACTORED: Now delegates storage operations to specialized services
class FoodRepository {
  final FoodApiService _apiService = FoodApiService();
  final FoodStorageService _storageService = FoodStorageService();
  final ImageStorageService _imageService = ImageStorageService();
  final LocalStorage _storage = LocalStorage();

  // Storage keys for search and favorites (TODO: Move to FoodSearchService)
  static const String _recentSearchesKey = 'recent_food_searches';
  static const String _favoriteFoodsKey = 'favorite_foods';

  // === FOOD RECOGNITION AND API OPERATIONS ===

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
            servingUnit: AppConstants.servingUnits[0],
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
            servingUnit: AppConstants.servingUnits[0],
          ));
        }
      }

      return foodItems;
    } catch (e) {
      debugPrint('Error searching foods: $e');
      return [];
    }
  }

  /// Add a search query to recent searches
  Future<void> _addToRecentSearches(String query) async {
    try {
      final recentSearches = await getRecentSearches();
      
      // Remove if already exists
      recentSearches.remove(query);
      
      // Add to beginning
      recentSearches.insert(0, query);
      
      // Keep only last 10 searches
      if (recentSearches.length > 10) {
        recentSearches.removeRange(10, recentSearches.length);
      }
      
      await _storage.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      debugPrint('Error adding to recent searches: $e');
    }
  }

  /// Get recent searches
  Future<List<String>> getRecentSearches() async {
    try {
      return await _storage.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _storage.remove(_recentSearchesKey);
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  /// Add food to favorites
  Future<void> addToFavorites(FoodItem food) async {
    try {
      final favorites = await getFavoriteFoods();
      
      // Check if already in favorites
      final exists = favorites.any((item) => item.name.toLowerCase() == food.name.toLowerCase());
      if (exists) return;
      
      favorites.add(food);
      
      // Convert to Map and save
      final mapList = favorites.map((item) => item.toMap()).toList();
      await _storage.setObjectList(_favoriteFoodsKey, mapList);
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
    }
  }

  /// Remove food from favorites
  Future<void> removeFromFavorites(String foodName) async {
    try {
      final favorites = await getFavoriteFoods();
      favorites.removeWhere((item) => item.name.toLowerCase() == foodName.toLowerCase());
      
      // Convert to Map and save
      final mapList = favorites.map((item) => item.toMap()).toList();
      await _storage.setObjectList(_favoriteFoodsKey, mapList);
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
    }
  }

  /// Get favorite foods
  Future<List<FoodItem>> getFavoriteFoods() async {
    try {
      final mapList = await _storage.getObjectList(_favoriteFoodsKey);
      if (mapList == null) return [];
      
      return mapList.map((map) => FoodItem.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting favorite foods: $e');
      return [];
    }
  }

  /// Check if food is in favorites
  Future<bool> isFavorite(String foodName) async {
    try {
      final favorites = await getFavoriteFoods();
      return favorites.any((item) => item.name.toLowerCase() == foodName.toLowerCase());
    } catch (e) {
      debugPrint('Error checking if favorite: $e');
      return false;
    }
  }

  // === DEBUG METHODS FOR TROUBLESHOOTING ===

  /// DEBUG: Check food item images and their paths
  Future<void> debugFoodItemImages() async {
    try {
      final allEntries = await getAllFoodEntries();
      debugPrint('=== FOOD ITEM IMAGE DEBUG ===');
      debugPrint('Total food entries: ${allEntries.length}');
      
      int entriesWithImages = 0;
      int existingImages = 0;
      int migratedPaths = 0;
      
      for (final entry in allEntries) {
        if (entry.imagePath != null && entry.imagePath!.isNotEmpty) {
          entriesWithImages++;
          
          // Use ImageStorageService to properly check relative paths
          final imageFile = await _imageService.getImageFile(entry.imagePath!);
          final exists = imageFile != null;
          
          debugPrint('Food: ${entry.name}');
          debugPrint('  Image path: ${entry.imagePath}');
          debugPrint('  Image exists: $exists');
          debugPrint('  Timestamp: ${entry.timestamp}');
          
          if (exists) {
            existingImages++;
            final size = await imageFile.length();
            debugPrint('  Image size: $size bytes');
          } else {
            // Try to migrate absolute path to relative
            final relativePath = await _imageService.migrateAbsoluteToRelativePath(entry.imagePath!);
            if (relativePath != null) {
              debugPrint('  MIGRATION: Can migrate to relative path: $relativePath');
              migratedPaths++;
            } else {
              debugPrint('  ERROR: Image file not found and cannot migrate');
            }
          }
          debugPrint('---');
        } else {
          debugPrint('Food: ${entry.name} (NO IMAGE PATH)');
        }
      }
      
      debugPrint('Summary:');
      debugPrint('  Total entries: ${allEntries.length}');
      debugPrint('  Entries with image paths: $entriesWithImages');
      debugPrint('  Images that actually exist: $existingImages');
      debugPrint('  Paths that can be migrated: $migratedPaths');
      debugPrint('=== END FOOD ITEM DEBUG ===');
      
    } catch (e) {
      debugPrint('Error debugging food items: $e');
    }
  }

  /// MIGRATION: Fix all food entries with absolute paths
  Future<void> migrateImagePaths() async {
    try {
      debugPrint('=== STARTING IMAGE PATH MIGRATION ===');
      
      final allEntries = await getAllFoodEntries();
      int migratedCount = 0;
      int failedCount = 0;
      
      for (final entry in allEntries) {
        if (entry.imagePath != null && 
            entry.imagePath!.isNotEmpty && 
            (entry.imagePath!.startsWith('/') || entry.imagePath!.contains('Application'))) {
          
          // Try to migrate this absolute path
          final relativePath = await _imageService.migrateAbsoluteToRelativePath(entry.imagePath!);
          
          if (relativePath != null) {
            // Update the food entry with the relative path
            final updatedEntry = entry.copyWith(imagePath: relativePath);
            final success = await updateFoodEntry(updatedEntry);
            
            if (success) {
              migratedCount++;
              debugPrint('✅ Migrated: ${entry.name} -> $relativePath');
            } else {
              failedCount++;
              debugPrint('❌ Failed to update: ${entry.name}');
            }
          } else {
            failedCount++;
            debugPrint('❌ Cannot migrate: ${entry.name} - image not found');
          }
        }
      }
      
      debugPrint('=== MIGRATION COMPLETE ===');
      debugPrint('Successfully migrated: $migratedCount');
      debugPrint('Failed migrations: $failedCount');
      
    } catch (e) {
      debugPrint('Error during migration: $e');
    }
  }

  /// DEBUG: Test the complete image workflow
  Future<void> debugCompleteImageWorkflow() async {
    try {
      debugPrint('=== COMPLETE IMAGE WORKFLOW DEBUG ===');
      
      // 1. Check image storage - Note: method may not exist yet
      // final imageDebug = await _imageService.debugImageStorage();
      debugPrint('Checking image storage...');
      
      // 2. Check food items
      await debugFoodItemImages();
      
      // 3. Test image service methods
      final allImages = await _imageService.getAllFoodImages();
      debugPrint('Images found by getAllFoodImages(): ${allImages.length}');
      for (final img in allImages) {
        debugPrint('  Image: ${img.path}');
      }
      
      debugPrint('=== END COMPLETE WORKFLOW DEBUG ===');
    } catch (e) {
      debugPrint('Error in complete workflow debug: $e');
    }
  }

  /// DEBUG: Clear all data for testing
  Future<void> debugClearAllData() async {
    try {
      debugPrint('=== CLEARING ALL DEBUG DATA ===');
      
      // Clear food entries
      await _storage.clear();
      
      // Clear images
      final deletedCount = await _imageService.clearAllImages();
      
      debugPrint('Cleared all food entries from storage');
      debugPrint('Deleted $deletedCount image files');
      debugPrint('=== DEBUG CLEAR COMPLETE ===');
    } catch (e) {
      debugPrint('Error clearing debug data: $e');
    }
  }

  /// DEBUG: Create test food entry with image
  Future<void> debugCreateTestFoodWithImage() async {
    try {
      debugPrint('=== CREATING TEST FOOD WITH IMAGE ===');
      
      // Create a test food item (without actual image file)
      final testFood = FoodItem(
        id: 'debug_test_${DateTime.now().millisecondsSinceEpoch}',
        name: 'Debug Test Food',
        calories: 100.0,
        proteins: 5.0,
        carbs: 15.0,
        fats: 2.0,
        mealType: 'snack',
        timestamp: DateTime.now(),
        servingSize: 1.0,
        servingUnit: 'serving',
        imagePath: '/fake/path/to/test/image.jpg', // Fake path for testing
      );
      
      final saved = await saveFoodEntry(testFood);
      debugPrint('Test food saved: $saved');
      debugPrint('Test food image path: ${testFood.imagePath}');
      debugPrint('=== TEST FOOD CREATION COMPLETE ===');
    } catch (e) {
      debugPrint('Error creating test food: $e');
    }
  }
}