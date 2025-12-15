// lib/providers/exercise_provider.dart
import 'package:flutter/foundation.dart';

import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/exercise_entry.dart';
import '../data/storage/local_storage.dart';
import '../utils/progress/health_metrics.dart';

class ExerciseProvider extends ChangeNotifier {
  // Direct instantiation - both are singletons
  final UserRepository _userRepository = UserRepository();
  final LocalStorage _storage = LocalStorage();

  // Storage key for exercise entries
  static const String _exerciseEntriesKey = 'exercise_entries';

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Date being viewed
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // User data
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;

  // Exercise data for the selected date
  List<ExerciseEntry> _exerciseEntries = [];
  List<ExerciseEntry> get exerciseEntries => _exerciseEntries;

  // Calculated values
  int _totalCaloriesBurned = 0;
  int get totalCaloriesBurned => _totalCaloriesBurned;

  int _dailyBurnGoal = 0;
  int get dailyBurnGoal => _dailyBurnGoal;

  // Progress calculations
  double get burnProgress => _dailyBurnGoal > 0
      ? _totalCaloriesBurned / _dailyBurnGoal
      : 0.0;

  int get caloriesRemaining => (_dailyBurnGoal - _totalCaloriesBurned).clamp(0, _dailyBurnGoal);

  bool get isGoalAchieved => _totalCaloriesBurned >= _dailyBurnGoal;

  // Exercise recommendations
  Map<String, dynamic> _burnRecommendation = {};
  Map<String, dynamic> get burnRecommendation => _burnRecommendation;

  // Check if viewing today
  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // Check if can navigate to next day
  bool get canGoToNextDay => !isToday;

  // MARK: - Summary Data Caching
  // Cache for aggregated summary data to avoid repeated calculations
  Map<String, Map<String, num>>? _cachedExerciseData;
  Map<String, List<ExerciseEntry>>? _cachedExerciseEntries;
  String? _lastCacheKey;
  int _cacheVersion = 0; // Increments when cache is invalidated
  int get cacheVersion => _cacheVersion;

  /// Load all exercise data for the current date
  Future<void> loadData({DateTime? date}) async {
    if (date != null) {
      _selectedDate = date;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load user profile and weight
      _userProfile = await _userRepository.getUserProfile();
      final latestWeight = await _userRepository.getLatestWeightEntry();
      _currentWeight = latestWeight?.weight;

      // Load exercise entries for the selected date
      _exerciseEntries = await _getExerciseEntriesForDate(_selectedDate);

      // Calculate total calories burned
      _totalCaloriesBurned = _exerciseEntries.fold(
        0, 
        (sum, entry) => sum + entry.caloriesBurned,
      );

      // Calculate exercise recommendations
      _burnRecommendation = HealthMetrics.calculateRecommendedExerciseBurn(
        monthlyWeightGoal: _userProfile?.monthlyWeightGoal,
        bmr: HealthMetrics.calculateBMR(
          weight: _currentWeight,
          height: _userProfile?.height,
          age: _userProfile?.age,
          gender: _userProfile?.gender,
        ),
        age: _userProfile?.age,
        gender: _userProfile?.gender,
        currentWeight: _currentWeight,
      );

      // Set daily burn goal from recommendations
      _dailyBurnGoal = _burnRecommendation['daily_burn'] as int? ?? 0;

      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading exercise data: $e';
      _isLoading = false;
      debugPrint('Error in ExerciseProvider.loadData: $e');
    }

    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadData(date: _selectedDate);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Add a new exercise entry
  Future<void> logExercise(ExerciseEntry exercise) async {
    try {
      // Add to current list
      _exerciseEntries.add(exercise);

      // Save to storage
      await _saveExerciseEntriesForDate(_exerciseEntries, _selectedDate);

      // Recalculate totals
      _totalCaloriesBurned = _exerciseEntries.fold(
        0,
        (sum, entry) => sum + entry.caloriesBurned,
      );

      // Invalidate cached summary data
      _invalidateSummaryCache();

      notifyListeners();
    } catch (e) {
      debugPrint('Error logging exercise: $e');
      // Remove from list if save failed
      _exerciseEntries.removeWhere((entry) => entry.id == exercise.id);
      rethrow;
    }
  }

  /// Update an existing exercise entry
  Future<void> updateExercise(ExerciseEntry updatedExercise) async {
    try {
      final index = _exerciseEntries.indexWhere(
        (entry) => entry.id == updatedExercise.id,
      );

      if (index != -1) {
        _exerciseEntries[index] = updatedExercise;

        // Save to storage
        await _saveExerciseEntriesForDate(_exerciseEntries, _selectedDate);

        // Recalculate totals
        _totalCaloriesBurned = _exerciseEntries.fold(
          0,
          (sum, entry) => sum + entry.caloriesBurned,
        );

        // Invalidate cached summary data
        _invalidateSummaryCache();

        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating exercise: $e');
      rethrow;
    }
  }

  /// Delete an exercise entry
  Future<void> deleteExercise(String exerciseId) async {
    try {
      // Remove from current list
      _exerciseEntries.removeWhere((entry) => entry.id == exerciseId);

      // Save updated list to storage
      await _saveExerciseEntriesForDate(_exerciseEntries, _selectedDate);

      // Recalculate totals
      _totalCaloriesBurned = _exerciseEntries.fold(
        0,
        (sum, entry) => sum + entry.caloriesBurned,
      );

      // Invalidate cached summary data
      _invalidateSummaryCache();

      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting exercise: $e');
      rethrow;
    }
  }

  /// Change the selected date
  Future<void> changeDate(DateTime newDate) async {
    if (!_isSameDay(_selectedDate, newDate)) {
      await loadData(date: newDate);
    }
  }

  /// Navigate to previous day
  Future<void> previousDay() async {
    final previousDate = _selectedDate.subtract(const Duration(days: 1));
    await changeDate(previousDate);
  }

  /// Navigate to next day
  Future<void> nextDay() async {
    final nextDate = _selectedDate.add(const Duration(days: 1));
    await changeDate(nextDate);
  }

  /// Get exercise entries for a specific date
  Future<List<ExerciseEntry>> _getExerciseEntriesForDate(DateTime date) async {
    try {
      final dateKey = _getDateKey(date);
      final key = '${_exerciseEntriesKey}_$dateKey';
      
      final entriesList = await _storage.getObjectList(key);
      
      if (entriesList == null || entriesList.isEmpty) {
        return [];
      }
      
      return entriesList.map((map) => ExerciseEntry.fromMap(map)).toList();
    } catch (e) {
      debugPrint('Error getting exercise entries for date: $e');
      return [];
    }
  }

  /// Save exercise entries for a specific date
  Future<void> _saveExerciseEntriesForDate(
    List<ExerciseEntry> entries, 
    DateTime date,
  ) async {
    try {
      final dateKey = _getDateKey(date);
      final key = '${_exerciseEntriesKey}_$dateKey';
      
      final entriesMaps = entries.map((entry) => entry.toMap()).toList();
      
      await _storage.setObjectList(key, entriesMaps);
    } catch (e) {
      debugPrint('Error saving exercise entries: $e');
      rethrow;
    }
  }

  /// Get date key string from DateTime (YYYY-MM-DD format)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Get exercise entries for a date range
  Future<Map<String, List<ExerciseEntry>>> getExerciseEntriesForDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final Map<String, List<ExerciseEntry>> entriesByDate = {};

    try {
      // Ensure end date is not before start date
      if (endDate.isBefore(startDate)) {
        final temp = startDate;
        startDate = endDate;
        endDate = temp;
      }

      // Create a list of all dates in the range
      final List<DateTime> dates = [];
      for (var date = startDate;
          !date.isAfter(endDate);
          date = date.add(const Duration(days: 1))) {
        dates.add(date);
      }

      // Load entries for each date
      for (final date in dates) {
        final dateKey = _getDateKey(date);
        final entries = await _getExerciseEntriesForDate(date);
        entriesByDate[dateKey] = entries;
      }

      return entriesByDate;
    } catch (e) {
      debugPrint('Error getting exercise entries for date range: $e');
      return {};
    }
  }

  /// Calculate aggregated exercise data for a date range
  ///
  /// Returns total calories burned and exercise count.
  Future<Map<String, num>> calculateAggregatedExercise(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entriesByDate = await getExerciseEntriesForDateRange(startDate, endDate);

    int totalCaloriesBurned = 0;
    int totalDuration = 0;
    int totalExercises = 0;

    for (final dayEntries in entriesByDate.values) {
      for (final exercise in dayEntries) {
        totalCaloriesBurned += exercise.caloriesBurned;
        totalDuration += exercise.duration;
        totalExercises++;
      }
    }

    return {
      'caloriesBurned': totalCaloriesBurned,
      'duration': totalDuration,
      'exerciseCount': totalExercises,
    };
  }

  /// Get cached aggregated exercise data for a date range
  ///
  /// Returns cached data if available, otherwise calculates and caches it.
  /// This prevents summary page from repeatedly calculating the same data.
  Future<Map<String, num>> getCachedAggregatedExercise(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Create cache key from date range
    final cacheKey = '${_getDateKey(startDate)}_${_getDateKey(endDate)}';

    // Return cached data if available and key matches
    if (_lastCacheKey == cacheKey && _cachedExerciseData != null && _cachedExerciseData!.containsKey(cacheKey)) {
      return _cachedExerciseData![cacheKey]!;
    }

    // Calculate fresh data
    final data = await calculateAggregatedExercise(startDate, endDate);

    // Cache the result
    _cachedExerciseData = {cacheKey: data};
    _lastCacheKey = cacheKey;

    return data;
  }

  /// Get cached exercise entries for a date range
  ///
  /// Returns cached entries if available, otherwise loads and caches them.
  Future<List<ExerciseEntry>> getCachedExerciseEntriesForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    // Create cache key from date range
    final cacheKey = '${_getDateKey(startDate)}_${_getDateKey(endDate)}';

    // Return cached data if available and key matches
    if (_lastCacheKey == cacheKey && _cachedExerciseEntries != null && _cachedExerciseEntries!.containsKey(cacheKey)) {
      return _cachedExerciseEntries![cacheKey]!;
    }

    // Load fresh data
    final entriesByDate = await getExerciseEntriesForDateRange(startDate, endDate);

    // Flatten the map into a single list
    final List<ExerciseEntry> allEntries = [];
    for (final dayEntries in entriesByDate.values) {
      allEntries.addAll(dayEntries);
    }

    // Cache the result
    _cachedExerciseEntries = {cacheKey: allEntries};
    _lastCacheKey = cacheKey;

    return allEntries;
  }

  /// Invalidate cached summary data
  ///
  /// Called when exercise entries are added, updated, or deleted to ensure
  /// summary page gets fresh data on next load.
  void _invalidateSummaryCache() {
    _cachedExerciseData = null;
    _cachedExerciseEntries = null;
    _lastCacheKey = null;
    _cacheVersion++; // Increment version to force UI reload
  }
}