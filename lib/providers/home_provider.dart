// lib/providers/home_provider.dart
import 'package:flutter/foundation.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/food_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/food_item.dart';
import '../utils/home_statistics_calculator.dart';

class HomeProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final FoodRepository _foodRepository = FoodRepository();

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // FIXED: Initialize selected date to today at startup
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // User data
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;

  // Food data for the selected date
  Map<String, List<FoodItem>> _entriesByMeal = {};
  Map<String, List<FoodItem>> get entriesByMeal => _entriesByMeal;

  // Calculated values
  int _totalCalories = 0;
  int get totalCalories => _totalCalories;

  int _calorieGoal = 2000;
  int get calorieGoal => _calorieGoal;

  Map<String, double> _consumedMacros = {'protein': 0, 'carbs': 0, 'fat': 0};
  Map<String, double> get consumedMacros => _consumedMacros;

  Map<String, int> _targetMacros = {'protein': 0, 'carbs': 0, 'fat': 0};
  Map<String, int> get targetMacros => _targetMacros;

  // Progress calculations
  int get caloriesRemaining => (_calorieGoal - _totalCalories).clamp(0, _calorieGoal);
  bool get isOverBudget => _totalCalories > _calorieGoal;
  
  // FIXED: Better expected percentage calculation based on time of day
  double get expectedDailyPercentage {
    final now = DateTime.now();
    
    // If viewing a past date, return 1.0 (100% - day is complete)
    if (!_isSameDay(_selectedDate, now)) {
      return 1.0;
    }
    
    // For today, calculate based on current time
    final minutesInDay = 24 * 60;
    final currentMinutes = now.hour * 60 + now.minute;
    return (currentMinutes / minutesInDay).clamp(0.0, 1.0);
  }

  Map<String, double> get macroProgressPercentages {
    return {
      'protein': _targetMacros['protein']! > 0 
          ? (_consumedMacros['protein']! / _targetMacros['protein']! * 100).clamp(0.0, 200.0)
          : 0.0,
      'carbs': _targetMacros['carbs']! > 0 
          ? (_consumedMacros['carbs']! / _targetMacros['carbs']! * 100).clamp(0.0, 200.0)
          : 0.0,
      'fat': _targetMacros['fat']! > 0 
          ? (_consumedMacros['fat']! / _targetMacros['fat']! * 100).clamp(0.0, 200.0)
          : 0.0,
    };
  }

  /// Load all home screen data for the current or specified date
  Future<void> loadData({DateTime? date}) async {
    if (date != null) {
      // FIXED: Better date validation and normalization
      final now = DateTime.now();
      final normalizedNow = DateTime(now.year, now.month, now.day);
      final normalizedDate = DateTime(date.year, date.month, date.day);
      final oneWeekAgo = normalizedNow.subtract(const Duration(days: 7));
      
      // Enforce date limits: not more than 7 days ago, not in the future
      if (normalizedDate.isBefore(oneWeekAgo)) {
        print('Date rejected: too far in the past (${normalizedDate} is before ${oneWeekAgo})');
        _selectedDate = oneWeekAgo;
      } else if (normalizedDate.isAfter(normalizedNow)) {
        print('Date rejected: in the future (${normalizedDate} is after ${normalizedNow})');
        _selectedDate = normalizedNow;
      } else {
        _selectedDate = normalizedDate;
      }
      
      print('Selected date set to: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}');
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load user profile and weight
      _userProfile = await _userRepository.getUserProfile();
      final latestWeight = await _userRepository.getLatestWeightEntry();
      _currentWeight = latestWeight?.weight;

      // Load food entries for the selected date
      _entriesByMeal = await _foodRepository.getFoodEntriesByMeal(_selectedDate);

      // Calculate calorie goal
      _calorieGoal = HomeStatisticsCalculator.calculateCalorieGoal(
        userProfile: _userProfile,
        currentWeight: _currentWeight,
      );

      // Calculate total calories consumed
      _totalCalories = HomeStatisticsCalculator.calculateTotalCalories(_entriesByMeal);

      // Calculate macro targets
      _targetMacros = HomeStatisticsCalculator.calculateMacroTargets(
        userProfile: _userProfile,
        currentWeight: _currentWeight,
        calorieGoal: _calorieGoal,
      );

      // Calculate consumed macros
      _consumedMacros = HomeStatisticsCalculator.calculateConsumedMacros(_entriesByMeal);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading home data: $e');
      _errorMessage = 'Failed to load data. Please try again.';
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIXED: Improved date change method with better validation
  void changeDate(DateTime newDate) {
    final now = DateTime.now();
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedNewDate = DateTime(newDate.year, newDate.month, newDate.day);
    final oneWeekAgo = normalizedNow.subtract(const Duration(days: 7));
    
    print('Attempting to change date to: ${normalizedNewDate.day}/${normalizedNewDate.month}/${normalizedNewDate.year}');
    print('Current date: ${normalizedNow.day}/${normalizedNow.month}/${normalizedNow.year}');
    print('One week ago: ${oneWeekAgo.day}/${oneWeekAgo.month}/${oneWeekAgo.year}');
    
    // Validate date range: must be within last 7 days including today
    if (normalizedNewDate.isBefore(oneWeekAgo)) {
      print('Date change rejected - too far in the past');
      return;
    }
    
    if (normalizedNewDate.isAfter(normalizedNow)) {
      print('Date change rejected - in the future');
      return;
    }
    
    // Only reload data if the date actually changed
    if (!_isSameDay(_selectedDate, normalizedNewDate)) {
      print('Date change accepted, loading data...');
      loadData(date: normalizedNewDate);
    } else {
      print('Date change ignored - same day selected');
    }
  }

  // Navigate to previous day (with week limit)
  void previousDay() {
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    // Only go back if we're not at the week limit
    if (!previousDay.isBefore(oneWeekAgo)) {
      changeDate(previousDay);
    }
  }

  // Navigate to next day (with today limit)
  void nextDay() {
    final nextDay = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    
    // Don't allow navigating to future dates
    if (!nextDay.isAfter(now)) {
      changeDate(nextDay);
    }
  }

  // Refresh data (e.g., after adding food)
  Future<void> refreshData() async {
    await loadData();
  }

  // FIXED: More reliable helper methods
  
  // Check if viewing today
  bool get isToday {
    final now = DateTime.now();
    return _isSameDay(_selectedDate, now);
  }

  // Check if can navigate to next day
  bool get canGoToNextDay {
    final now = DateTime.now();
    final nextDay = _selectedDate.add(const Duration(days: 1));
    final normalizedNext = DateTime(nextDay.year, nextDay.month, nextDay.day);
    final normalizedNow = DateTime(now.year, now.month, now.day);
    return !normalizedNext.isAfter(normalizedNow);
  }

  // Check if can navigate to previous day
  bool get canGoToPreviousDay {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    final normalizedPrevious = DateTime(previousDay.year, previousDay.month, previousDay.day);
    final normalizedWeekAgo = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day);
    return !normalizedPrevious.isBefore(normalizedWeekAgo);
  }

  // FIXED: Consistent same day comparison
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Get the earliest selectable date (one week ago)
  DateTime get earliestSelectableDate {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 7));
  }

  // Get the latest selectable date (today)
  DateTime get latestSelectableDate {
    return DateTime.now();
  }

  // Check if a date is within the selectable range
  bool isDateSelectable(DateTime date) {
    final earliest = earliestSelectableDate;
    final latest = latestSelectableDate;
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedEarliest = DateTime(earliest.year, earliest.month, earliest.day);
    final normalizedLatest = DateTime(latest.year, latest.month, latest.day);
    
    return !normalizedDate.isBefore(normalizedEarliest) && !normalizedDate.isAfter(normalizedLatest);
  }
}