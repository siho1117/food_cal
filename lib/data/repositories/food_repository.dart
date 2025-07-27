// lib/data/repositories/food_repository.dart
import 'dart:io';
import 'dart:async';
import '../models/food_item.dart';
import '../services/api_service.dart';
import '../storage/local_storage.dart';

/// Repository for managing food data from API and local storage
/// Acts as a single access point for all food-related operations
class FoodRepository {
  final FoodApiService _apiService = FoodApiService();
  final LocalStorage _storage = LocalStorage();

  // Storage keys
  static const String _foodEntriesKey = 'food_entries';
  static const String _tempImageFolderKey = 'food_images';
  static const String _recentSearchesKey = 'recent_food_searches';
  static const String _favoriteFoodsKey = 'favorite_foods';

  // Maximum number of recent searches to store
  static const int _maxRecentSearches = 10;

  /// Recognize food from an image and return results
  /// Takes an image file and meal type (breakfast, lunch, dinner, snack)
  /// Returns a list of recognized food items
  Future<List<FoodItem>> recognizeFood(File imageFile, String mealType) async {
    try {
      // Call the API to analyze the image
      final analysisResult = await _apiService.analyzeImage(imageFile);

      // Save the image file for reference
      final savedImagePath = await _saveImageFile(imageFile);

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
                id: DateTime.now().millisecondsSinceEpoch.toString() +
                    '_${annotation['name']}',
                name: annotation['name'] ?? 'Unknown Food',
                calories: _extractNutrientValue(foodInfo, 'calories') ?? 0.0,
                proteins: _extractNutrientValue(foodInfo, 'protein') ?? 0.0,
                carbs: _extractNutrientValue(foodInfo, 'carbs') ?? 0.0,
                fats: _extractNutrientValue(foodInfo, 'fat') ?? 0.0,
                mealType: mealType,
                timestamp: DateTime.now(),
                servingSize: 1.0,
                servingUnit: 'serving',
                imagePath: savedImagePath,
              );
              recognizedItems.add(item);
            }
          } catch (e) {
            print('Error processing annotation: $e');
            continue;
          }
        }
      }

      return recognizedItems;
    } catch (e) {
      print('Error recognizing food: $e');
      rethrow;
    }
  }

  /// Extract nutrient value from food information response
  double? _extractNutrientValue(Map<String, dynamic> foodInfo, String nutrientName) {
    try {
      // Check different possible structures
      if (foodInfo.containsKey('nutrition')) {
        final nutrition = foodInfo['nutrition'];

        // Direct value format
        if (nutrition.containsKey(nutrientName)) {
          final value = nutrition[nutrientName];
          if (value is num) {
            return value.toDouble();
          }

          // String with unit format (e.g., "250 kcal")
          if (value is String) {
            final RegExp numberRegex = RegExp(r'\d+\.?\d*');
            final match = numberRegex.firstMatch(value);
            if (match != null) {
              final numValue = double.tryParse(match.group(0)!);
              return numValue?.toDouble();
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

  /// Save the food image file to local storage
  Future<String?> _saveImageFile(File imageFile) async {
    try {
      // Get the app's temporary directory
      final tempDir = await _storage.getTemporaryDirectory();

      // Create a folder for food images if it doesn't exist
      final foodImagesDir = Directory('${tempDir.path}/$_tempImageFolderKey');
      if (!await foodImagesDir.exists()) {
        await foodImagesDir.create(recursive: true);
      }

      // Generate a unique filename based on timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newPath = '${foodImagesDir.path}/food_${timestamp}.jpg';

      // Copy the file to our app's storage
      final savedImage = await imageFile.copy(newPath);

      return savedImage.path;
    } catch (e) {
      return null;
    }
  }

  /// Save a food entry to local storage
  Future<bool> saveFoodEntry(FoodItem item) async {
    try {
      final entries = await getFoodEntries(item.timestamp);
      entries.add(item);
      return _saveFoodEntries(entries);
    } catch (e) {
      return false;
    }
  }

  /// Save multiple food entries at once
  Future<bool> saveFoodEntries(List<FoodItem> items) async {
    try {
      if (items.isEmpty) return true;

      // Group entries by date to ensure we don't overwrite entries from other dates
      final Map<String, List<FoodItem>> entriesByDate = {};

      for (final item in items) {
        final dateKey = _getDateKey(item.timestamp);
        if (!entriesByDate.containsKey(dateKey)) {
          entriesByDate[dateKey] = await _getFoodEntriesForDate(item.timestamp);
        }
        entriesByDate[dateKey]!.add(item);
      }

      // Save entries for each date
      bool allSaved = true;
      for (final date in entriesByDate.keys) {
        final success =
            await _saveFoodEntriesForDate(entriesByDate[date]!, date);
        if (!success) allSaved = false;
      }

      return allSaved;
    } catch (e) {
      return false;
    }
  }

  /// Get all food entries for a specific date
  Future<List<FoodItem>> getFoodEntries(DateTime date) async {
    try {
      final entries = await _getFoodEntriesForDate(date);
      return entries;
    } catch (e) {
      return [];
    }
  }

  /// NEW: Get all food entries for a specific date (HomeProvider compatibility)
  Future<List<FoodItem>> getFoodEntriesForDate(DateTime date) async {
    try {
      // Get all food entries from all dates
      final allEntries = await getAllFoodEntries();
      
      // Filter entries for the specific date
      final dateEntries = allEntries.where((entry) {
        return _isSameDay(entry.timestamp, date);
      }).toList();
      
      // Sort by timestamp (newest first)
      dateEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return dateEntries;
    } catch (e) {
      print('Error getting food entries for date: $e');
      return [];
    }
  }

  /// NEW: Get all food entries from storage
  Future<List<FoodItem>> getAllFoodEntries() async {
    try {
      final List<FoodItem> allItems = [];
      
      // We need to get entries from all stored dates
      // Since we store by date key, we'll need to iterate through possible dates
      // For now, let's get entries for the last 365 days
      final now = DateTime.now();
      for (int i = 0; i < 365; i++) {
        final date = now.subtract(Duration(days: i));
        final entries = await _getFoodEntriesForDate(date);
        allItems.addAll(entries);
      }
      
      return allItems;
    } catch (e) {
      print('Error getting all food entries: $e');
      return [];
    }
  }

  /// Get food entries for a specific date (helper method)
  Future<List<FoodItem>> _getFoodEntriesForDate(DateTime date) async {
    final dateKey = _getDateKey(date);
    final key = '${_foodEntriesKey}_$dateKey';

    final entriesList = await _storage.getObjectList(key);

    if (entriesList == null || entriesList.isEmpty) return [];

    return entriesList.map((map) => FoodItem.fromMap(map)).toList();
  }

  /// Save food entries for a specific date (helper method)
  Future<bool> _saveFoodEntriesForDate(
      List<FoodItem> entries, String dateKey) async {
    try {
      final key = '${_foodEntriesKey}_$dateKey';
      final entriesMaps = entries.map((entry) => entry.toMap()).toList();

      return await _storage.setObjectList(key, entriesMaps);
    } catch (e) {
      return false;
    }
  }

  /// Get date key string from DateTime (YYYY-MM-DD format)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper method for saving food entries (legacy method)
  Future<bool> _saveFoodEntries(List<FoodItem> entries) async {
    if (entries.isEmpty) return true;

    final dateKey = _getDateKey(entries.first.timestamp);
    return _saveFoodEntriesForDate(entries, dateKey);
  }

  /// Update an existing food entry
  Future<bool> updateFoodEntry(FoodItem item) async {
    try {
      final entries = await getFoodEntries(item.timestamp);
      
      // Find and replace the entry with matching ID
      final index = entries.indexWhere((entry) => entry.id == item.id);
      if (index != -1) {
        entries[index] = item;
        return _saveFoodEntries(entries);
      }
      
      return false; // Entry not found
    } catch (e) {
      return false;
    }
  }

  /// Delete a food entry
  Future<bool> deleteFoodEntry(String id, DateTime timestamp) async {
    try {
      final entries = await getFoodEntries(timestamp);
      
      // Remove the entry with matching ID
      final originalLength = entries.length;
      entries.removeWhere((entry) => entry.id == id);
      
      if (entries.length < originalLength) {
        return _saveFoodEntries(entries);
      }
      
      return false; // Entry not found
    } catch (e) {
      return false;
    }
  }

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
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_${result['name']}',
            name: result['name'] ?? 'Unknown Food',
            calories: _extractNutrientValue(foodInfo, 'calories') ?? 0.0,
            proteins: _extractNutrientValue(foodInfo, 'protein') ?? 0.0,
            carbs: _extractNutrientValue(foodInfo, 'carbs') ?? 0.0,
            fats: _extractNutrientValue(foodInfo, 'fat') ?? 0.0,
            mealType: mealType,
            timestamp: DateTime.now(),
            servingSize: 1.0,
            servingUnit: 'serving',
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
            servingSize: 1.0,
            servingUnit: 'serving',
          ));
        }
      }

      return foodItems;
    } catch (e) {
      throw Exception('Failed to search for foods: $e');
    }
  }

  /// Add a search query to recent searches
  Future<bool> _addToRecentSearches(String query) async {
    try {
      final trimmedQuery = query.trim();
      if (trimmedQuery.isEmpty) return false;

      // Get existing recent searches
      List<String> recentSearches =
          await _storage.getStringList(_recentSearchesKey) ?? [];

      // Remove if it already exists (to move it to the front)
      recentSearches.remove(trimmedQuery);

      // Add to the beginning of the list
      recentSearches.insert(0, trimmedQuery);

      // Limit the number of recent searches
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches = recentSearches.sublist(0, _maxRecentSearches);
      }

      // Save updated list
      return await _storage.setStringList(_recentSearchesKey, recentSearches);
    } catch (e) {
      return false;
    }
  }

  /// Get recent food searches
  Future<List<String>> getRecentSearches() async {
    try {
      return await _storage.getStringList(_recentSearchesKey) ?? [];
    } catch (e) {
      return [];
    }
  }

  /// Clear recent searches
  Future<bool> clearRecentSearches() async {
    try {
      return await _storage.remove(_recentSearchesKey);
    } catch (e) {
      return false;
    }
  }

  /// Add a food item to favorites
  Future<bool> addToFavorites(FoodItem item) async {
    try {
      // Get existing favorites
      final favoritesList =
          await _storage.getObjectList(_favoriteFoodsKey) ?? [];

      // Check if it already exists
      final exists = favoritesList.any((favorite) =>
          favorite['id'] == item.id ||
          (favorite['name'] == item.name &&
              favorite['calories'] == item.calories));

      if (exists) return true; // Already a favorite

      // Add to favorites
      favoritesList.add(item.toMap());

      // Save updated list
      return await _storage.setObjectList(_favoriteFoodsKey, favoritesList);
    } catch (e) {
      return false;
    }
  }

  /// Remove a food item from favorites
  Future<bool> removeFromFavorites(String id) async {
    try {
      // Get existing favorites
      final favoritesList =
          await _storage.getObjectList(_favoriteFoodsKey) ?? [];

      // Remove item with matching ID
      final filteredList =
          favoritesList.where((favorite) => favorite['id'] != id).toList();

      if (filteredList.length == favoritesList.length) {
        return false; // No item was removed
      }

      // Save updated list
      return await _storage.setObjectList(_favoriteFoodsKey, filteredList);
    } catch (e) {
      return false;
    }
  }

  /// Get favorite food items
  Future<List<FoodItem>> getFavorites() async {
    try {
      final favoritesList =
          await _storage.getObjectList(_favoriteFoodsKey) ?? [];

      return favoritesList.map((map) => FoodItem.fromMap(map)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Check if a food item is in favorites
  Future<bool> isFavorite(String id) async {
    try {
      final favoritesList =
          await _storage.getObjectList(_favoriteFoodsKey) ?? [];

      return favoritesList.any((favorite) => favorite['id'] == id);
    } catch (e) {
      return false;
    }
  }

  /// Get frequently logged foods (based on occurrence in the last 30 days)
  Future<List<FoodItem>> getFrequentlyLoggedFoods(int limit) async {
    try {
      // Get entries for the last 30 days
      final now = DateTime.now();
      final thirtyDaysAgo = now.subtract(const Duration(days: 30));

      final Map<String, FoodItem> foodMap = {};
      final Map<String, int> countMap = {};

      // Go through each day
      for (var date = thirtyDaysAgo;
          !date.isAfter(now);
          date = date.add(const Duration(days: 1))) {
        final entries = await getFoodEntries(date);

        for (final entry in entries) {
          final key = '${entry.name}_${entry.calories}';

          // Update count
          countMap[key] = (countMap[key] ?? 0) + 1;
          
          // Store the food item (use latest occurrence)
          foodMap[key] = entry;
        }
      }

      // Sort by frequency and return top items
      final sortedEntries = countMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final frequentFoods = <FoodItem>[];
      for (final entry in sortedEntries.take(limit)) {
        final foodItem = foodMap[entry.key];
        if (foodItem != null) {
          frequentFoods.add(foodItem);
        }
      }

      return frequentFoods;
    } catch (e) {
      return [];
    }
  }

  /// NEW: Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// NEW: Get food entries for a specific meal type on a date
  Future<List<FoodItem>> getFoodEntriesForMeal(DateTime date, String mealType) async {
    try {
      final dateEntries = await getFoodEntriesForDate(date);
      
      return dateEntries.where((entry) {
        return entry.mealType.toLowerCase() == mealType.toLowerCase();
      }).toList();
    } catch (e) {
      print('Error getting food entries for meal: $e');
      return [];
    }
  }

  /// NEW: Get food entries for a date range
  Future<List<FoodItem>> getFoodEntriesForDateRange(DateTime startDate, DateTime endDate) async {
    try {
      final allEntries = await getAllFoodEntries();
      
      return allEntries.where((entry) {
        final entryDate = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
        final start = DateTime(startDate.year, startDate.month, startDate.day);
        final end = DateTime(endDate.year, endDate.month, endDate.day);
        
        return (entryDate.isAfter(start) || entryDate.isAtSameMomentAs(start)) &&
               (entryDate.isBefore(end) || entryDate.isAtSameMomentAs(end));
      }).toList();
    } catch (e) {
      print('Error getting food entries for date range: $e');
      return [];
    }
  }

  /// NEW: Get recent food entries (last N days)
  Future<List<FoodItem>> getRecentFoodEntries({int days = 7}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      
      return await getFoodEntriesForDateRange(startDate, now);
    } catch (e) {
      print('Error getting recent food entries: $e');
      return [];
    }
  }
}