// lib/providers/exercise_provider.dart
import 'package:flutter/foundation.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/exercise_entry.dart';
import '../data/storage/local_storage.dart';
import '../utils/formula.dart';

class ExerciseProvider extends ChangeNotifier {
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
      ? (_totalCaloriesBurned / _dailyBurnGoal).clamp(0.0, 1.0)
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
      _burnRecommendation = Formula.calculateRecommendedExerciseBurn(
        monthlyWeightGoal: _userProfile?.monthlyWeightGoal,
        bmr: Formula.calculateBMR(
          weight: _currentWeight,
          height: _userProfile?.height,
          age: _userProfile?.age,
          gender: _userProfile?.gender,
        ),
        activityLevel: _userProfile?.activityLevel,
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
      print('Error in ExerciseProvider.loadData: $e');
    }

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

      notifyListeners();
    } catch (e) {
      print('Error logging exercise: $e');
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

        notifyListeners();
      }
    } catch (e) {
      print('Error updating exercise: $e');
      rethrow;
    }
  }

  /// Delete an exercise entry
  Future<void> deleteExercise(String exerciseId) async {
    // Store backup of original entries
    final originalEntries = List<ExerciseEntry>.from(_exerciseEntries);
    
    try {
      // Find and remove the exercise
      _exerciseEntries.removeWhere((entry) => entry.id == exerciseId);

      // Save to storage
      await _saveExerciseEntriesForDate(_exerciseEntries, _selectedDate);

      // Recalculate totals
      _totalCaloriesBurned = _exerciseEntries.fold(
        0, 
        (sum, entry) => sum + entry.caloriesBurned,
      );

      notifyListeners();
    } catch (e) {
      print('Error deleting exercise: $e');
      // Restore original list if delete failed
      _exerciseEntries = originalEntries;
      rethrow;
    }
  }

  /// Change selected date
  void changeDate(DateTime newDate) {
    if (_selectedDate != newDate) {
      loadData(date: newDate);
    }
  }

  /// Navigate to previous day
  void previousDay() {
    changeDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  /// Navigate to next day
  void nextDay() {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    
    // Don't allow navigating to future dates
    if (tomorrow.year <= now.year && 
        tomorrow.month <= now.month && 
        tomorrow.day <= now.day) {
      changeDate(tomorrow);
    }
  }

  /// Refresh current data
  Future<void> refreshData() async {
    await loadData();
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
      print('Error getting exercise entries for date: $e');
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
      print('Error saving exercise entries: $e');
      rethrow;
    }
  }

  /// Get date key string from DateTime (YYYY-MM-DD format)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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

      // Get entries for each date
      for (final date in dates) {
        final dateKey = _getDateKey(date);
        final entries = await _getExerciseEntriesForDate(date);
        entriesByDate[dateKey] = entries;
      }

      return entriesByDate;
    } catch (e) {
      print('Error getting exercise entries for date range: $e');
      return entriesByDate;
    }
  }

  /// Get total calories burned for a date range
  Future<int> getTotalCaloriesBurnedForRange(
    DateTime startDate, 
    DateTime endDate,
  ) async {
    try {
      final entriesByDate = await getExerciseEntriesForDateRange(startDate, endDate);
      
      int totalBurned = 0;
      for (final entries in entriesByDate.values) {
        totalBurned += entries.fold(0, (sum, entry) => sum + entry.caloriesBurned);
      }
      
      return totalBurned;
    } catch (e) {
      print('Error calculating total calories burned for range: $e');
      return 0;
    }
  }

  /// Clear all exercise entries for a specific date
  Future<bool> clearExerciseEntriesForDate(DateTime date) async {
    try {
      final dateKey = _getDateKey(date);
      final key = '${_exerciseEntriesKey}_$dateKey';
      
      await _storage.remove(key);
      
      // If clearing current date, update the UI
      if (_getDateKey(date) == _getDateKey(_selectedDate)) {
        _exerciseEntries.clear();
        _totalCaloriesBurned = 0;
        notifyListeners();
      }
      
      return true;
    } catch (e) {
      print('Error clearing exercise entries: $e');
      return false;
    }
  }
}