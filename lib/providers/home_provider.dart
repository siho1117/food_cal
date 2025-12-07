// lib/providers/home_provider.dart
import 'package:flutter/foundation.dart';

import '../data/repositories/food_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/services/budget_service.dart';
import '../data/services/exercise_bonus_service.dart';
import '../data/models/food_item.dart';
import '../data/models/user_profile.dart';
import '../utils/home/macro_calculator.dart';
import '../utils/home/daily_calorie_calculator.dart';
import '../utils/home/cost_calculator.dart';
import '../utils/home/exercise_bonus_calculator.dart';
import '../utils/progress/progress_calculator.dart';
import '../utils/shared/date_helper.dart';
import './exercise_provider.dart';

class HomeProvider extends ChangeNotifier {
  // Direct instantiation - both repositories use singleton services internally
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();
  final BudgetService _budgetService = BudgetService();
  final ExerciseBonusService _exerciseBonusService = ExerciseBonusService();

  // Exercise provider reference (injected)
  ExerciseProvider? _exerciseProvider;

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

  // Exercise bonus tracking
  bool _exerciseBonusEnabled = false;
  bool get exerciseBonusEnabled => _exerciseBonusEnabled;

  int _exerciseBonusCalories = 0;
  int get exerciseBonusCalories => _exerciseBonusCalories;

  /// Get the effective calorie goal (base goal + bonus if enabled)
  int get effectiveCalorieGoal => _calorieGoal +
    (_exerciseBonusEnabled ? _exerciseBonusCalories : 0);

  int get caloriesRemaining => ProgressCalculator.calculateRemaining(
    consumed: _totalCalories.toDouble(),
    target: effectiveCalorieGoal.toDouble(),
  ).round();

  bool get isOverBudget => ProgressCalculator.isOverTarget(
    consumed: _totalCalories.toDouble(),
    target: effectiveCalorieGoal.toDouble(),
  );

  // Progress tracking
  double get calorieProgress => ProgressCalculator.calculateProgress(
    consumed: _totalCalories.toDouble(),
    target: effectiveCalorieGoal.toDouble(),
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
  // Uses effectiveCalorieGoal to scale macros when exercise bonus is enabled
  Map<String, int> get targetMacros {
    return MacroCalculator.calculateTargets(
      calorieGoal: effectiveCalorieGoal,  // Use effective goal (includes exercise bonus)
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

      // Load exercise bonus state
      await _loadExerciseBonusState();

      // Calculate calorie goal
      _calculateCalorieGoal();

      // Calculate totals
      _calculateTotals();

      // Calculate exercise bonus (if enabled and provider is set)
      await _calculateExerciseBonus();

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

  /// Refresh only user profile (lightweight, for settings changes)
  Future<void> refreshUserProfile() async {
    try {
      _userProfile = await _userRepository.getUserProfile();
      notifyListeners();
    } catch (e) {
      debugPrint('Error refreshing user profile: $e');
    }
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
      _foodEntries = await _foodRepository.storageService.getFoodEntries(_selectedDate);
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
      await _foodRepository.storageService.saveFoodEntry(entry);

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
      await _foodRepository.storageService.updateFoodEntry(updatedItem);

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
      await _foodRepository.storageService.deleteFoodEntry(entryId, itemToDelete.timestamp);

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

  /// Get food entries for a date range (inclusive)
  ///
  /// Used for weekly/monthly summary aggregation.
  Future<List<FoodItem>> getFoodEntriesForRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final List<FoodItem> allEntries = [];

      // Iterate through each day in the range
      for (var date = startDate;
          !date.isAfter(endDate);
          date = date.add(const Duration(days: 1))) {
        final entries = await _foodRepository.storageService.getFoodEntries(date);
        allEntries.addAll(entries);
      }

      return allEntries;
    } catch (e) {
      debugPrint('Error getting food entries for range: $e');
      return [];
    }
  }

  /// Calculate aggregated nutrition data for a date range
  ///
  /// Returns total calories and macros for the given period.
  Future<Map<String, num>> calculateAggregatedNutrition(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final entries = await getFoodEntriesForRange(startDate, endDate);

    int totalCalories = 0;
    double totalProtein = 0.0;
    double totalCarbs = 0.0;
    double totalFat = 0.0;
    double totalCost = 0.0;

    for (final item in entries) {
      final nutrition = item.getNutritionForServing();
      totalCalories += (nutrition['calories'] ?? 0).round();
      totalProtein += nutrition['proteins'] ?? 0;
      totalCarbs += nutrition['carbs'] ?? 0;
      totalFat += nutrition['fats'] ?? 0;

      final cost = item.getCostForServing();
      if (cost != null) {
        totalCost += cost;
      }
    }

    return {
      'calories': totalCalories,
      'protein': totalProtein,
      'carbs': totalCarbs,
      'fat': totalFat,
      'cost': totalCost,
      'mealCount': entries.length,
    };
  }

  /// Set the exercise provider reference
  ///
  /// This allows HomeProvider to access exercise data for bonus calculations.
  /// Should be called during app initialization.
  void setExerciseProvider(ExerciseProvider provider) {
    _exerciseProvider = provider;
  }

  /// Toggle exercise bonus feature on/off
  ///
  /// Saves the preference and recalculates the effective calorie goal.
  Future<void> toggleExerciseBonus() async {
    try {
      // Toggle the state
      final newState = await _exerciseBonusService.toggle();
      _exerciseBonusEnabled = newState;

      // Recalculate bonus if enabled
      if (_exerciseBonusEnabled) {
        await _calculateExerciseBonus();
      } else {
        _exerciseBonusCalories = 0;
      }

      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling exercise bonus: $e');
      rethrow;
    }
  }

  /// Calculate exercise bonus calories
  ///
  /// Fetches exercise data for the selected date and calculates bonus.
  /// This ensures we use the correct date's data, not whatever date
  /// the ExerciseProvider is currently viewing.
  Future<void> _calculateExerciseBonus() async {
    // If feature is disabled, no bonus
    if (!_exerciseBonusEnabled) {
      _exerciseBonusCalories = 0;
      return;
    }

    // If no exercise provider set, no bonus
    if (_exerciseProvider == null) {
      _exerciseBonusCalories = 0;
      return;
    }

    try {
      // Fetch exercise data for the HOME SCREEN's selected date
      // (not the ExerciseProvider's currently viewed date)
      final exerciseEntries = await _exerciseProvider!.getExerciseEntriesForDateRange(
        _selectedDate,
        _selectedDate,
      );

      // Calculate total calories burned on the selected date
      final dateKey = _getDateKey(_selectedDate);
      final entriesForDate = exerciseEntries[dateKey] ?? [];
      final totalBurned = entriesForDate.fold<int>(
        0,
        (sum, entry) => sum + entry.caloriesBurned,
      );

      // Use the burn goal from ExerciseProvider (user's daily goal)
      // This is a static value that doesn't change by date
      final burnGoal = _exerciseProvider!.dailyBurnGoal;

      _exerciseBonusCalories = ExerciseBonusCalculator.calculateBonus(
        totalBurned: totalBurned,
        burnGoal: burnGoal,
      );
    } catch (e) {
      debugPrint('Error calculating exercise bonus: $e');
      _exerciseBonusCalories = 0;
    }
  }

  /// Get date key string from DateTime (YYYY-MM-DD format)
  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Load exercise bonus enabled state from preferences
  Future<void> _loadExerciseBonusState() async {
    try {
      _exerciseBonusEnabled = await _exerciseBonusService.isEnabled();
    } catch (e) {
      debugPrint('Error loading exercise bonus state: $e');
      _exerciseBonusEnabled = false;
    }
  }
}