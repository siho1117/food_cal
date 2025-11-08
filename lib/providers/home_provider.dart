// lib/providers/home_provider.dart
import 'package:flutter/foundation.dart';

import '../data/repositories/food_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/budget_service.dart';
import '../data/models/food_item.dart';
import '../data/models/user_profile.dart';
import '../utils/home/macro_calculator.dart';
import '../utils/home/daily_calorie_calculator.dart';
import '../utils/home/cost_calculator.dart';
import '../utils/progress/progress_calculator.dart';
import '../utils/shared/date_helper.dart';

class HomeProvider extends ChangeNotifier {
  // Direct instantiation - both repositories use singleton services internally
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();
  final BudgetService _budgetService = BudgetService();

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Date selection
  DateTime _selectedDate = DateTime.now();
  DateTime get selectedDate => _selectedDate;

  // User data
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;

  // Food entries
  List<FoodItem> _foodEntries = [];
  List<FoodItem> get foodEntries => _foodEntries;

  // Calorie tracking
  int _calorieGoal = 2000;
  int get calorieGoal => _calorieGoal;

  int _totalCalories = 0;
  int get totalCalories => _totalCalories;

  int get caloriesRemaining => ProgressCalculator.calculateRemaining(
    consumed: _totalCalories.toDouble(),
    target: _calorieGoal.toDouble(),
  ).round();

  bool get isOverBudget => ProgressCalculator.isOverTarget(
    consumed: _totalCalories.toDouble(),
    target: _calorieGoal.toDouble(),
  );

  // Progress tracking
  double get calorieProgress => ProgressCalculator.calculateProgress(
    consumed: _totalCalories.toDouble(),
    target: _calorieGoal.toDouble(),
  );

  double get expectedDailyPercentage => ProgressCalculator.calculateExpectedDailyProgress(
    selectedDate: _selectedDate,
  );

  // Macronutrient tracking
  Map<String, double> get consumedMacros {
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (final item in _foodEntries) {
      final nutrition = item.getNutritionForServing();
      protein += nutrition['proteins'] ?? 0;
      carbs += nutrition['carbs'] ?? 0;
      fat += nutrition['fats'] ?? 0;
    }

    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  // Budget tracking
  double _dailyFoodBudget = 25.0;
  double get dailyFoodBudget => _dailyFoodBudget;

  double _totalFoodCost = 0.0;
  double get totalFoodCost => _totalFoodCost;

  // Cost summaries (cached values loaded from repository)
  double _weeklyFoodCost = 0.0;
  double _monthlyFoodCost = 0.0;

  double get budgetRemaining => ProgressCalculator.calculateRemaining(
    consumed: _totalFoodCost,
    target: _dailyFoodBudget,
  );

  double get budgetProgress => ProgressCalculator.calculateProgress(
    consumed: _totalFoodCost,
    target: _dailyFoodBudget,
  );

  // Macro targets - NOW USING PERSONALIZED CALCULATIONS ✅
  Map<String, int> get targetMacros {
    return MacroCalculator.calculateTargets(
      calorieGoal: _calorieGoal,
      userProfile: _userProfile,
      currentWeight: _currentWeight,
    );
  }

  bool get isOverFoodBudget => ProgressCalculator.isOverTarget(
    consumed: _totalFoodCost,
    target: _dailyFoodBudget,
  );

  Map<String, double> get macroProgressPercentages {
    return ProgressCalculator.calculateMacroProgress(
      consumed: consumedMacros,
      targets: targetMacros,
    );
  }

  int get foodEntriesCount => _foodEntries.length;

  // Weekly and monthly cost getters (return cached values)
  // These are loaded via _loadCostSummaries() during data load
  double get weeklyFoodCost => _weeklyFoodCost;
  double get monthlyFoodCost => _monthlyFoodCost;

  /// Load all data for the home screen
  Future<void> loadData({DateTime? date}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Set the selected date
      if (date != null) {
        _selectedDate = date;
      }

      // Load user data
      await _loadUserData();

      // Load food entries for the selected date
      await _loadFoodEntries();

      // Load food budget
      await loadFoodBudget();

      // Load cost summaries (weekly & monthly) - ✅ FIXED BUG
      await _loadCostSummaries();

      // Calculate calorie goal
      _calculateCalorieGoal();

      // Calculate totals
      _calculateTotals();

      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _isLoading = false;
      debugPrint('Error in HomeProvider.loadData: $e');
    }

    notifyListeners();
  }

  /// Refresh data (for pull-to-refresh)
  Future<void> refreshData() async {
    await loadData(date: _selectedDate);
  }

  /// Change the selected date
  Future<void> changeDate(DateTime newDate) async {
    if (!_isSameDay(_selectedDate, newDate)) {
      await loadData(date: newDate);
    }
  }

  /// Load user profile and current weight
  Future<void> _loadUserData() async {
    try {
      // Load user profile
      _userProfile = await _userRepository.getUserProfile();

      // Load current weight
      final latestWeight = await _userRepository.getLatestWeightEntry();
      _currentWeight = latestWeight?.weight;
    } catch (e) {
      debugPrint('Error loading user data: $e');
      // Don't throw - let the UI handle missing user data gracefully
    }
  }

  /// Load food entries for the selected date
  Future<void> _loadFoodEntries() async {
    try {
      _foodEntries = await _foodRepository.getFoodEntriesForDate(_selectedDate);
    } catch (e) {
      debugPrint('Error loading food entries: $e');
      _foodEntries = [];
    }
  }

  /// Load weekly and monthly cost summaries
  ///
  /// ✅ FIXED: Now properly queries ALL food entries across date ranges
  /// instead of only checking the currently selected date's entries.
  Future<void> _loadCostSummaries() async {
    try {
      // Load weekly cost (Monday to today)
      _weeklyFoodCost = await CostCalculator.calculateWeeklyCost(_foodRepository);

      // Load monthly cost (1st of month to today)
      _monthlyFoodCost = await CostCalculator.calculateMonthlyCost(_foodRepository);
    } catch (e) {
      debugPrint('Error loading cost summaries: $e');
      _weeklyFoodCost = 0.0;
      _monthlyFoodCost = 0.0;
    }
  }

  /// Load food budget from preferences
  Future<void> loadFoodBudget() async {
    try {
      _dailyFoodBudget = await _budgetService.getDailyBudget();
    } catch (e) {
      debugPrint('Error loading food budget: $e');
      _dailyFoodBudget = BudgetService.getDefaultBudget(); // Default fallback
    }
  }

  /// Update daily food budget
  Future<void> updateFoodBudget(double budget) async {
    try {
      await _budgetService.updateDailyBudget(budget);
      _dailyFoodBudget = budget;
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating food budget: $e');
      rethrow;
    }
  }

  /// Calculate calorie goal based on user profile - NOW USING NEW CALCULATOR ✅
  void _calculateCalorieGoal() {
    _calorieGoal = DailyCalorieCalculator.calculateDailyGoal(
      userProfile: _userProfile,
      currentWeight: _currentWeight,
    );
  }

  /// Calculate totals for calories and cost
  void _calculateTotals() {
    _totalCalories = 0;
    _totalFoodCost = 0.0;

    for (final item in _foodEntries) {
      // Calculate calories
      final nutrition = item.getNutritionForServing();
      _totalCalories += (nutrition['calories'] ?? 0).round();

      // Calculate cost
      final cost = item.getCostForServing();
      if (cost != null) {
        _totalFoodCost += cost;
      }
    }
  }

  /// Add a food entry
  Future<void> addFoodEntry(FoodItem entry) async {
    try {
      // Save to storage
      await _foodRepository.saveFoodEntry(entry);

      // If it's for the currently selected date, add to local state
      if (_isSameDay(entry.timestamp, _selectedDate)) {
        _foodEntries.add(entry);

        // Recalculate totals
        _calculateTotals();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error adding food entry: $e');
      rethrow;
    }
  }

  /// Update a food entry
  Future<void> updateFoodEntry(FoodItem updatedItem) async {
    try {
      // Save to storage
      await _foodRepository.updateFoodEntry(updatedItem);

      // Update in local state if it's for the current date
      if (_isSameDay(updatedItem.timestamp, _selectedDate)) {
        final index = _foodEntries.indexWhere((item) => item.id == updatedItem.id);
        if (index != -1) {
          _foodEntries[index] = updatedItem;
          _calculateTotals();
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error updating food entry: $e');
      rethrow;
    }
  }

  /// Delete a food entry
  Future<void> deleteFoodEntry(String entryId) async {
    try {
      // Find the item first to get its timestamp
      final itemToDelete = _foodEntries.firstWhere(
        (item) => item.id == entryId,
        orElse: () => throw Exception('Food entry not found'),
      );

      // Delete from storage with both id and timestamp
      await _foodRepository.deleteFoodEntry(entryId, itemToDelete.timestamp);

      // Remove from local state
      _foodEntries.removeWhere((item) => item.id == entryId);

      // Recalculate totals
      _calculateTotals();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting food entry: $e');
      rethrow;
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) => DateHelper.isSameDay(date1, date2);

  /// Check if the selected date is today
  bool get isToday => DateHelper.isToday(_selectedDate);

  /// Check if the selected date is in the future
  bool get isFutureDate => DateHelper.isFutureDate(_selectedDate);

  /// Get formatted date string for display
  String get formattedSelectedDate => DateHelper.formatRelativeDate(_selectedDate);
}