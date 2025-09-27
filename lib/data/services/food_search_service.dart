// lib/data/services/food_search_service.dart
import 'package:flutter/foundation.dart';
import '../models/food_item.dart';
import '../storage/local_storage.dart';
import '../../config/constants/app_constants.dart';

/// Service responsible for food search history and favorites management
/// Handles recent searches, favorites, and search-related operations
class FoodSearchService {
  final LocalStorage _storage = LocalStorage();

  // Private constructor for singleton
  FoodSearchService._internal();
  static final FoodSearchService _instance = FoodSearchService._internal();
  factory FoodSearchService() => _instance;

  // === RECENT SEARCHES ===

  /// Add a search query to recent searches
  Future<void> addToRecentSearches(String query) async {
    try {
      if (query.trim().isEmpty) return;
      
      final recentSearches = await getRecentSearches();
      
      // Remove if already exists to avoid duplicates
      recentSearches.removeWhere((search) => search.toLowerCase() == query.toLowerCase());
      
      // Add to beginning
      recentSearches.insert(0, query.trim());
      
      // Keep only the most recent searches
      if (recentSearches.length > AppConstants.maxRecentSearches) {
        recentSearches.removeRange(AppConstants.maxRecentSearches, recentSearches.length);
      }
      
      await _storage.setStringList(AppConstants.recentSearchesKey, recentSearches);
    } catch (e) {
      debugPrint('Error adding to recent searches: $e');
      // Fail silently for recent searches - not critical functionality
    }
  }

  /// Get recent search queries
  Future<List<String>> getRecentSearches() async {
    try {
      return await _storage.getStringList(AppConstants.recentSearchesKey) ?? [];
    } catch (e) {
      debugPrint('Error getting recent searches: $e');
      return [];
    }
  }

  /// Remove a specific search from recent searches
  Future<void> removeFromRecentSearches(String query) async {
    try {
      final recentSearches = await getRecentSearches();
      recentSearches.removeWhere((search) => search.toLowerCase() == query.toLowerCase());
      await _storage.setStringList(AppConstants.recentSearchesKey, recentSearches);
    } catch (e) {
      debugPrint('Error removing from recent searches: $e');
    }
  }

  /// Clear all recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _storage.remove(AppConstants.recentSearchesKey);
    } catch (e) {
      debugPrint('Error clearing recent searches: $e');
    }
  }

  /// Get the most popular search terms (by frequency)
  Future<List<String>> getPopularSearches({int limit = 5}) async {
    try {
      final recentSearches = await getRecentSearches();
      
      // Count occurrences of each search term
      final Map<String, int> searchCounts = {};
      for (final search in recentSearches) {
        final lowerSearch = search.toLowerCase();
        searchCounts[lowerSearch] = (searchCounts[lowerSearch] ?? 0) + 1;
      }
      
      // Sort by frequency and return top searches
      final sortedSearches = searchCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      return sortedSearches
          .take(limit)
          .map((entry) => entry.key)
          .toList();
    } catch (e) {
      debugPrint('Error getting popular searches: $e');
      return [];
    }
  }

  // === FAVORITES ===

  /// Add a food item to favorites
  Future<bool> addToFavorites(FoodItem item) async {
    try {
      final favorites = await getFavorites();
      
      // Check if already in favorites (by name, case-insensitive)
      final exists = favorites.any((fav) => 
        fav.name.toLowerCase().trim() == item.name.toLowerCase().trim());
      if (exists) return true; // Already in favorites
      
      // Create a clean version of the item for favorites (no timestamp, meal type)
      final favoriteItem = item.copyWith(
        timestamp: DateTime.now(), // Use current time for favorites
        mealType: AppConstants.mealTypes[0], // Default to breakfast
      );
      
      favorites.add(favoriteItem);
      
      // Convert to maps for storage
      final favoritesData = favorites.map((item) => item.toMap()).toList();
      
      return await _storage.setObjectList(AppConstants.favoriteFoodsKey, favoritesData);
    } catch (e) {
      debugPrint('Error adding to favorites: $e');
      return false;
    }
  }

  /// Remove a food item from favorites
  Future<bool> removeFromFavorites(String foodName) async {
    try {
      final favorites = await getFavorites();
      
      // Remove items with matching name (case-insensitive)
      final originalLength = favorites.length;
      favorites.removeWhere((item) => 
        item.name.toLowerCase().trim() == foodName.toLowerCase().trim());
      
      if (favorites.length < originalLength) {
        // Convert to maps for storage
        final favoritesData = favorites.map((item) => item.toMap()).toList();
        return await _storage.setObjectList(AppConstants.favoriteFoodsKey, favoritesData);
      }
      
      return false; // Nothing was removed
    } catch (e) {
      debugPrint('Error removing from favorites: $e');
      return false;
    }
  }

  /// Get favorite food items
  Future<List<FoodItem>> getFavorites() async {
    try {
      final favoritesData = await _storage.getObjectList(AppConstants.favoriteFoodsKey);
      
      if (favoritesData == null || favoritesData.isEmpty) return [];
      
      final favorites = favoritesData.map((data) => FoodItem.fromMap(data)).toList();
      
      // Sort favorites alphabetically by name
      favorites.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      
      return favorites;
    } catch (e) {
      debugPrint('Error getting favorites: $e');
      return [];
    }
  }

  /// Check if a food item is in favorites
  Future<bool> isFavorite(String foodName) async {
    try {
      final favorites = await getFavorites();
      return favorites.any((item) => 
        item.name.toLowerCase().trim() == foodName.toLowerCase().trim());
    } catch (e) {
      debugPrint('Error checking if favorite: $e');
      return false;
    }
  }

  /// Get favorites filtered by category/meal type
  Future<List<FoodItem>> getFavoritesByMealType(String mealType) async {
    try {
      final allFavorites = await getFavorites();
      return allFavorites.where((item) => 
        item.mealType.toLowerCase() == mealType.toLowerCase()).toList();
    } catch (e) {
      debugPrint('Error getting favorites by meal type: $e');
      return [];
    }
  }

  /// Search within favorites
  Future<List<FoodItem>> searchFavorites(String query) async {
    try {
      if (query.trim().isEmpty) return await getFavorites();
      
      final favorites = await getFavorites();
      final lowerQuery = query.toLowerCase();
      
      return favorites.where((item) => 
        item.name.toLowerCase().contains(lowerQuery)).toList();
    } catch (e) {
      debugPrint('Error searching favorites: $e');
      return [];
    }
  }

  /// Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      await _storage.remove(AppConstants.favoriteFoodsKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing favorites: $e');
      return false;
    }
  }

  /// Get favorites count
  Future<int> getFavoritesCount() async {
    try {
      final favorites = await getFavorites();
      return favorites.length;
    } catch (e) {
      debugPrint('Error getting favorites count: $e');
      return 0;
    }
  }

  /// Toggle favorite status of a food item
  Future<bool> toggleFavorite(FoodItem item) async {
    try {
      final isCurrentlyFavorite = await isFavorite(item.name);
      
      if (isCurrentlyFavorite) {
        return await removeFromFavorites(item.name);
      } else {
        return await addToFavorites(item);
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
      return false;
    }
  }

  // === SEARCH SUGGESTIONS ===

  /// Get search suggestions based on recent searches and favorites
  Future<List<String>> getSearchSuggestions({String query = '', int limit = 10}) async {
    try {
      final suggestions = <String>[];
      final lowerQuery = query.toLowerCase();
      
      // Get recent searches that match the query
      final recentSearches = await getRecentSearches();
      for (final search in recentSearches) {
        if (query.isEmpty || search.toLowerCase().contains(lowerQuery)) {
          if (!suggestions.contains(search)) {
            suggestions.add(search);
          }
        }
      }
      
      // Get favorite food names that match the query
      final favorites = await getFavorites();
      for (final favorite in favorites) {
        if (query.isEmpty || favorite.name.toLowerCase().contains(lowerQuery)) {
          if (!suggestions.contains(favorite.name)) {
            suggestions.add(favorite.name);
          }
        }
      }
      
      // Limit results and return
      return suggestions.take(limit).toList();
    } catch (e) {
      debugPrint('Error getting search suggestions: $e');
      return [];
    }
  }

  // === ANALYTICS ===

  /// Get search analytics data
  Future<Map<String, dynamic>> getSearchAnalytics() async {
    try {
      final recentSearches = await getRecentSearches();
      final favorites = await getFavorites();
      
      // Calculate search frequency
      final Map<String, int> searchCounts = {};
      for (final search in recentSearches) {
        final lowerSearch = search.toLowerCase();
        searchCounts[lowerSearch] = (searchCounts[lowerSearch] ?? 0) + 1;
      }
      
      // Calculate favorite categories
      final Map<String, int> favoriteMealTypes = {};
      for (final favorite in favorites) {
        final mealType = favorite.mealType.toLowerCase();
        favoriteMealTypes[mealType] = (favoriteMealTypes[mealType] ?? 0) + 1;
      }
      
      return {
        'totalSearches': recentSearches.length,
        'uniqueSearches': searchCounts.length,
        'totalFavorites': favorites.length,
        'searchFrequency': searchCounts,
        'favoriteMealTypes': favoriteMealTypes,
        'mostSearchedTerm': searchCounts.isNotEmpty 
          ? searchCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key
          : null,
      };
    } catch (e) {
      debugPrint('Error getting search analytics: $e');
      return {};
    }
  }

  /// Export favorites data for backup
  Future<List<Map<String, dynamic>>> exportFavorites() async {
    try {
      final favorites = await getFavorites();
      return favorites.map((item) => item.toMap()).toList();
    } catch (e) {
      debugPrint('Error exporting favorites: $e');
      return [];
    }
  }

  /// Import favorites data from backup
  Future<bool> importFavorites(List<Map<String, dynamic>> favoritesData) async {
    try {
      // Validate the data
      final validFavorites = <FoodItem>[];
      for (final data in favoritesData) {
        try {
          final item = FoodItem.fromMap(data);
          validFavorites.add(item);
        } catch (e) {
          // Skip invalid items
          continue;
        }
      }
      
      if (validFavorites.isEmpty) return false;
      
      // Merge with existing favorites (avoid duplicates)
      final existingFavorites = await getFavorites();
      final mergedFavorites = <FoodItem>[...existingFavorites];
      
      for (final newFavorite in validFavorites) {
        final exists = mergedFavorites.any((existing) => 
          existing.name.toLowerCase() == newFavorite.name.toLowerCase());
        if (!exists) {
          mergedFavorites.add(newFavorite);
        }
      }
      
      // Save merged favorites
      final favoritesMapData = mergedFavorites.map((item) => item.toMap()).toList();
      return await _storage.setObjectList(AppConstants.favoriteFoodsKey, favoritesMapData);
    } catch (e) {
      debugPrint('Error importing favorites: $e');
      return false;
    }
  }
}