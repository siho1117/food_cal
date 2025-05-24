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
      _selectedDate = date;
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

  // Change selected date
  void changeDate(DateTime newDate) {
    if (_selectedDate != newDate) {
      loadData(date: newDate);
    }
  }

  // Navigate to previous day
  void previousDay() {
    changeDate(_selectedDate.subtract(const Duration(days: 1)));
  }

  // Navigate to next day
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

  // Refresh data (e.g., after adding food)
  Future<void> refreshData() async {
    await loadData();
  }

  // Check if viewing today
  bool get isToday {
    final now = DateTime.now();
    return _selectedDate.year == now.year &&
        _selectedDate.month == now.month &&
        _selectedDate.day == now.day;
  }

  // Check if can navigate to next day
  bool get canGoToNextDay {
    return !isToday;
  }
}