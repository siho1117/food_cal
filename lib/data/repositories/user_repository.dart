// lib/data/repositories/user_repository.dart
import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../models/weight_data.dart';
import '../storage/local_storage.dart';

class UserRepository {
  static const String _userProfileKey = 'user_profile';
  static const String _weightEntriesKey = 'weight_entries';

  // Direct instantiation - LocalStorage is a singleton
  final LocalStorage _storage = LocalStorage();

  // Get the user profile
  Future<UserProfile?> getUserProfile() async {
    final profileMap = await _storage.getObject(_userProfileKey);

    if (profileMap == null) return null;

    try {
      return UserProfile.fromMap(profileMap);
    } catch (e) {
      debugPrint('Error retrieving user profile: $e');
      return null;
    }
  }

  // Save the user profile
  Future<bool> saveUserProfile(UserProfile profile) async {
    try {
      return await _storage.setObject(_userProfileKey, profile.toMap());
    } catch (e) {
      debugPrint('Error saving user profile: $e');
      return false;
    }
  }

  // Update goal weight
  Future<bool> updateGoalWeight(double goalWeight) async {
    final profile = await getUserProfile();
    if (profile == null) return false;

    final updatedProfile = profile.copyWith(goalWeight: goalWeight);
    return await saveUserProfile(updatedProfile);
  }

  // Get goal weight
  Future<double?> getGoalWeight() async {
    final profile = await getUserProfile();
    return profile?.goalWeight;
  }

  // Add a new weight entry
  Future<bool> addWeightEntry(WeightData entry) async {
    final entries = await getWeightEntries();
    entries.add(entry);
    return _saveWeightEntries(entries);
  }

  // Get all weight entries
  Future<List<WeightData>> getWeightEntries() async {
    final entriesList = await _storage.getObjectList(_weightEntriesKey);

    if (entriesList == null || entriesList.isEmpty) {
      return [];
    }

    try {
      return entriesList.map((map) => WeightData.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error parsing weight entries: $e');
      return [];
    }
  }

  // Get the latest weight entry
  Future<WeightData?> getLatestWeightEntry() async {
    final entries = await getWeightEntries();
    if (entries.isEmpty) return null;

    // Sort by timestamp descending and return the most recent
    entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return entries.first;
  }

  // Save weight entries to storage
  Future<bool> _saveWeightEntries(List<WeightData> entries) async {
    try {
      final entriesMaps = entries.map((entry) => entry.toMap()).toList();
      return await _storage.setObjectList(_weightEntriesKey, entriesMaps);
    } catch (e) {
      debugPrint('Error saving weight entries: $e');
      return false;
    }
  }

  // Delete a specific weight entry
  Future<bool> deleteWeightEntry(String entryId) async {
    try {
      final entries = await getWeightEntries();
      entries.removeWhere((entry) => entry.id == entryId);
      return await _saveWeightEntries(entries);
    } catch (e) {
      debugPrint('Error deleting weight entry: $e');
      return false;
    }
  }

  // Get weight entries for a specific date range
  Future<List<WeightData>> getWeightEntriesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allEntries = await getWeightEntries();
    
    return allEntries.where((entry) {
      return entry.timestamp.isAfter(startDate.subtract(const Duration(days: 1))) &&
             entry.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  // Clear all user data (for testing or reset purposes)
  Future<bool> clearAllUserData() async {
    try {
      await _storage.remove(_userProfileKey);
      await _storage.remove(_weightEntriesKey);
      return true;
    } catch (e) {
      debugPrint('Error clearing user data: $e');
      return false;
    }
  }
}