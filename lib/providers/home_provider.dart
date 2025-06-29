// lib/providers/home_provider.dart
import 'package:flutter/foundation.dart';
import '../data/repositories/food_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/food_item.dart';
import '../utils/home_statistics_calculator.dart';

class HomeProvider extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Date being viewed
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // User data
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;
  
  double? _currentWeight;
  double? get currentWeight => _currentWeight;

  // Food entries for the day
  Map<String, List<FoodItem>> _entriesByMeal = {};
  Map<String, List<FoodItem>> get entriesByMeal => _entriesByMeal;

  // Calorie data for CalorieSummaryWidget
  int _totalCalories = 0;
  int get totalCalories => _totalCalories;
  
  int _calorieGoal = 2000; // Default
  int get calorieGoal => _calorieGoal;
  
  int get caloriesRemaining => _calorieGoal - _totalCalories;
  bool get isOverBudget => caloriesRemaining < 0;

  // Macro data for MacronutrientWidget
  Map<String, double> _consumedMacros = {
    'protein': 0,
    'carbs': 0,
    'fat': 0,
  };
  Map<String, double> get consumedMacros => _consumedMacros;
  
  Map<String, int> _targetMacros = {
    'protein': 50,
    'carbs': 150,
    'fat': 50,
  };
  Map<String, int> get targetMacros => _targetMacros;

  // Progress percentages for UI
  Map<String, double> get macroProgressPercentages => 
    HomeStatisticsCalculator.calculateMacroProgressPercentages(
      consumedMacros: _consumedMacros,
      targetMacros: _targetMacros,
    );
  
  Map<String, int> get macroTargetPercentages =>
    HomeStatisticsCalculator.calculateMacroTargetPercentages(
      consumedMacros: _consumedMacros,
      targetMacros: _targetMacros,
    );

  // Expected daily percentage based on time of day
  double get expectedDailyPercentage => 
    HomeStatisticsCalculator.calculateExpectedDailyPercentage();

  // Initialize and load data
  Future<void> loadData({DateTime? date}) async {
    if (date != null) {
      // Enforce one week limit (7 days back + today = 8 total days)
      final now = DateTime.now();
      final oneWeekAgo = now.subtract(const Duration(days: 7)); // Changed from 6 to 7
      
      // Clamp the date to be within the last week
      if (date.isBefore(oneWeekAgo)) {
        _selectedDate = oneWeekAgo;
      } else if (date.isAfter(now)) {
        _selectedDate = now;
      } else {
        _selectedDate = date;
      }
    }

    _isLoading = true;
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
      _isLoading = false;
      notifyListeners();
    }
  }

  // Change selected date with week limit enforcement
  void changeDate(DateTime newDate) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));
    
    // Normalize dates to midnight for comparison (ignore time components)
    final normalizedNewDate = DateTime(newDate.year, newDate.month, newDate.day);
    final normalizedNow = DateTime(now.year, now.month, now.day);
    final normalizedOneWeekAgo = DateTime(oneWeekAgo.year, oneWeekAgo.month, oneWeekAgo.day);
    
    print('Attempting to change date to: ${normalizedNewDate.day}/${normalizedNewDate.month}/${normalizedNewDate.year}');
    print('Current date: ${normalizedNow.day}/${normalizedNow.month}/${normalizedNow.year}');
    print('One week ago: ${normalizedOneWeekAgo.day}/${normalizedOneWeekAgo.month}/${normalizedOneWeekAgo.year}');
    print('Is before one week ago: ${normalizedNewDate.isBefore(normalizedOneWeekAgo)}');
    print('Is after now: ${normalizedNewDate.isAfter(normalizedNow)}');
    
    // Allow dates from one week ago (inclusive) to today (inclusive)
    if (normalizedNewDate.isBefore(normalizedOneWeekAgo) || normalizedNewDate.isAfter(normalizedNow)) {
      print('Date change rejected - outside allowed range');
      return;
    }
    
    if (!_isSameDay(_selectedDate, newDate)) {
      print('Date change accepted, loading data...');
      loadData(date: newDate);
    } else {
      print('Date change ignored - same day selected');
    }
  }

  // Navigate to previous day (with week limit)
  void previousDay() {
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7)); // Changed from 6 to 7
    
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

  // Check if viewing today
  bool get isToday {
    final now = DateTime.now();
    return _isSameDay(_selectedDate, now);
  }

  // Check if can navigate to next day
  bool get canGoToNextDay {
    final now = DateTime.now();
    final nextDay = _selectedDate.add(const Duration(days: 1));
    return !nextDay.isAfter(now);
  }

  // Check if can navigate to previous day
  bool get canGoToPreviousDay {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7)); // Changed from 6 to 7
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    return !previousDay.isBefore(oneWeekAgo);
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  // Get the earliest selectable date (one week ago)
  DateTime get earliestSelectableDate {
    final now = DateTime.now();
    return now.subtract(const Duration(days: 7)); // Changed from 6 to 7
  }

  // Get the latest selectable date (today)
  DateTime get latestSelectableDate {
    return DateTime.now();
  }

  // Check if a date is within the selectable range
  bool isDateSelectable(DateTime date) {
    final earliest = earliestSelectableDate;
    final latest = latestSelectableDate;
    
    return !date.isBefore(earliest) && !date.isAfter(latest);
  }
}