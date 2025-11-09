// lib/data/services/food_storage_service.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_item.dart';
import '../storage/local_storage.dart';
import '../../config/constants/app_constants.dart';

/// Service responsible for local food data persistence
/// Handles saving, loading, updating, and deleting food entries
class FoodStorageService {
  final LocalStorage _storage = LocalStorage();

  // Private constructor for singleton
  FoodStorageService._internal();
  static final FoodStorageService _instance = FoodStorageService._internal();
  factory FoodStorageService() => _instance;

  /// Save a single food entry to local storage
  Future<bool> saveFoodEntry(FoodItem item) async {
    try {
      final entries = await getFoodEntries(item.timestamp);
      entries.add(item);
      return await _saveFoodEntries(entries);
    } catch (e) {
      debugPrint('Error saving food entry: $e');
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
          entriesByDate[dateKey] = await getFoodEntries(item.timestamp);
        }
        entriesByDate[dateKey]!.add(item);
      }

      // Save each date's entries
      bool allSucceeded = true;
      for (final entry in entriesByDate.entries) {
        final success = await _saveFoodEntries(entry.value);
        if (!success) allSucceeded = false;
      }

      return allSucceeded;
    } catch (e) {
      debugPrint('Error saving food entries: $e');
      return false;
    }
  }

  /// Get food entries for a specific date
  Future<List<FoodItem>> getFoodEntries(DateTime date) async {
    try {
      final dateKey = _getDateKey(date);
      final entriesData = await _storage.getObjectList('${AppConstants.foodEntriesKey}_$dateKey');
      
      if (entriesData == null) return [];

      return entriesData.map((data) => FoodItem.fromMap(data)).toList();
    } catch (e) {
      debugPrint('Error getting food entries: $e');
      return [];
    }
  }

  /// Get food entries for a specific date
  /// Deprecated: Use getFoodEntries() instead
  @Deprecated('Use getFoodEntries() instead - same functionality')
  Future<List<FoodItem>> getFoodEntriesForDate(DateTime date) async {
    return await getFoodEntries(date);
  }

  /// Get all food entries across all dates
  Future<List<FoodItem>> getAllFoodEntries() async {
    try {
      final allEntries = <FoodItem>[];
      
      // Get all keys that match our food entries pattern
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(AppConstants.foodEntriesKey)).toList();
      
      for (final key in keys) {
        final entriesData = await _storage.getObjectList(key);
        if (entriesData != null) {
          final entries = entriesData.map((data) => FoodItem.fromMap(data)).toList();
          allEntries.addAll(entries);
        }
      }
      
      // Sort by timestamp (newest first)
      allEntries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      return allEntries;
    } catch (e) {
      debugPrint('Error getting all food entries: $e');
      return [];
    }
  }

  /// Update an existing food entry
  Future<bool> updateFoodEntry(FoodItem item) async {
    try {
      final entries = await getFoodEntries(item.timestamp);
      
      // Find and replace the entry with matching ID
      final index = entries.indexWhere((entry) => entry.id == item.id);
      if (index != -1) {
        entries[index] = item;
        return await _saveFoodEntries(entries);
      }
      
      return false; // Entry not found
    } catch (e) {
      debugPrint('Error updating food entry: $e');
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
        return await _saveFoodEntries(entries);
      }
      
      return false; // Entry not found
    } catch (e) {
      debugPrint('Error deleting food entry: $e');
      return false;
    }
  }

  /// Get food entries for a specific meal type on a date
  Future<List<FoodItem>> getFoodEntriesForMeal(DateTime date, String mealType) async {
    try {
      final dateEntries = await getFoodEntries(date);
      
      return dateEntries.where((entry) {
        return entry.mealType.toLowerCase() == mealType.toLowerCase();
      }).toList();
    } catch (e) {
      debugPrint('Error getting food entries for meal: $e');
      return [];
    }
  }

  /// Get food entries for a date range
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
      debugPrint('Error getting food entries for date range: $e');
      return [];
    }
  }

  /// Get recent food entries (last N days)
  Future<List<FoodItem>> getRecentFoodEntries({int days = 7}) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(Duration(days: days));
      
      return await getFoodEntriesForDateRange(startDate, now);
    } catch (e) {
      debugPrint('Error getting recent food entries: $e');
      return [];
    }
  }

  /// Get frequently consumed foods
  Future<List<FoodItem>> getFrequentFoods({int limit = 10}) async {
    try {
      final allEntries = await getAllFoodEntries();
      
      // Count occurrences by food name (case-insensitive)
      final Map<String, int> countMap = {};
      final Map<String, FoodItem> foodMap = {};

      for (final entry in allEntries) {
        final key = entry.name.toLowerCase().trim();
        countMap[key] = (countMap[key] ?? 0) + 1;
        
        // Store the food item (use latest occurrence)
        foodMap[key] = entry;
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
      debugPrint('Error getting frequent foods: $e');
      return [];
    }
  }

  /// Clear all food entries (for debugging/testing)
  Future<bool> clearAllFoodEntries() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(AppConstants.foodEntriesKey)).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      return true;
    } catch (e) {
      debugPrint('Error clearing food entries: $e');
      return false;
    }
  }

  /// Get statistics for a date range
  Future<Map<String, dynamic>> getFoodStatistics(DateTime startDate, DateTime endDate) async {
    try {
      final entries = await getFoodEntriesForDateRange(startDate, endDate);
      
      double totalCalories = 0;
      double totalProtein = 0;
      double totalCarbs = 0;
      double totalFat = 0;
      double totalCost = 0;
      
      final Map<String, int> mealCounts = {};
      
      for (final entry in entries) {
        totalCalories += entry.calories;
        totalProtein += entry.proteins;
        totalCarbs += entry.carbs;
        totalFat += entry.fats;
        totalCost += entry.cost ?? 0;
        
        final mealType = entry.mealType.toLowerCase();
        mealCounts[mealType] = (mealCounts[mealType] ?? 0) + 1;
      }
      
      return {
        'totalEntries': entries.length,
        'totalCalories': totalCalories,
        'totalProtein': totalProtein,
        'totalCarbs': totalCarbs,
        'totalFat': totalFat,
        'totalCost': totalCost,
        'averageCaloriesPerDay': entries.isEmpty ? 0 : totalCalories / _daysBetween(startDate, endDate),
        'mealCounts': mealCounts,
      };
    } catch (e) {
      debugPrint('Error getting food statistics: $e');
      return {};
    }
  }

  // === PRIVATE HELPER METHODS ===

  /// Save food entries for a specific date
  Future<bool> _saveFoodEntries(List<FoodItem> entries) async {
    try {
      if (entries.isEmpty) return true;
      
      // Group by date
      final Map<String, List<FoodItem>> entriesByDate = {};
      for (final entry in entries) {
        final dateKey = _getDateKey(entry.timestamp);
        if (!entriesByDate.containsKey(dateKey)) {
          entriesByDate[dateKey] = [];
        }
        entriesByDate[dateKey]!.add(entry);
      }
      
      // Save each date separately
      bool allSucceeded = true;
      for (final entry in entriesByDate.entries) {
        final dateKey = entry.key;
        final dateEntries = entry.value;
        
        // Sort by timestamp
        dateEntries.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        
        // Convert to maps for storage
        final entriesData = dateEntries.map((item) => item.toMap()).toList();
        
        final success = await _storage.setObjectList('${AppConstants.foodEntriesKey}_$dateKey', entriesData);
        if (!success) allSucceeded = false;
      }
      
      return allSucceeded;
    } catch (e) {
      debugPrint('Error saving food entries: $e');
      return false;
    }
  }

  /// Generate a date key for storage (YYYY-MM-DD format)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate days between two dates
  int _daysBetween(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.difference(start).inDays + 1;
  }
}