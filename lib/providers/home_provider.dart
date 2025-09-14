// lib/providers/home_provider.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/repositories/food_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/food_item.dart';
import '../data/models/user_profile.dart';
import '../data/models/weight_data.dart';
import '../utils/home_statistics_calculator.dart';

class HomeProvider extends ChangeNotifier {
  final FoodRepository _foodRepository = FoodRepository();
  final UserRepository _userRepository = UserRepository();

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
  Map<String, List<FoodItem>> _entriesByMeal = {
    'breakfast': [],
    'lunch': [],
    'dinner': [],
    'snack': [],
  };
  Map<String, List<FoodItem>> get entriesByMeal => _entriesByMeal;

  // Calorie tracking
  int _calorieGoal = 2000;
  int get calorieGoal => _calorieGoal;

  int _totalCalories = 0;
  int get totalCalories => _totalCalories;

  int get caloriesRemaining => (_calorieGoal - _totalCalories).clamp(0, _calorieGoal);
  bool get isOverBudget => _totalCalories > _calorieGoal;

  // Progress tracking
  double get calorieProgress => _calorieGoal > 0 ? (_totalCalories / _calorieGoal).clamp(0.0, 1.0) : 0.0;
  double get expectedDailyPercentage {
    final now = DateTime.now();
    if (!_isSameDay(now, _selectedDate)) return 1.0; // Past/future dates
    
    final minutesInDay = 24 * 60;
    final currentMinutes = now.hour * 60 + now.minute;
    return (currentMinutes / minutesInDay).clamp(0.0, 1.0);
  }

  // Macronutrient tracking
  Map<String, double> get consumedMacros {
    double protein = 0;
    double carbs = 0;
    double fat = 0;

    for (final mealItems in _entriesByMeal.values) {
      for (final item in mealItems) {
        final nutrition = item.getNutritionForServing();
        protein += nutrition['proteins'] ?? 0;
        carbs += nutrition['carbs'] ?? 0;
        fat += nutrition['fats'] ?? 0;
      }
    }

    return {
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }

  Map<String, int> get targetMacros {
    // Calculate macro targets based on calorie goal
    // Standard ratios: 30% protein, 40% carbs, 30% fat
    final proteinCals = (_calorieGoal * 0.30);
    final carbsCals = (_calorieGoal * 0.40);
    final fatCals = (_calorieGoal * 0.30);

    return {
      'protein': (proteinCals / 4).round(), // 4 calories per gram
      'carbs': (carbsCals / 4).round(),     // 4 calories per gram
      'fat': (fatCals / 9).round(),         // 9 calories per gram
    };
  }

  Map<String, double> get macroProgressPercentages {
    final consumed = consumedMacros;
    final target = targetMacros;

    return {
      'protein': target['protein']! > 0 ? (consumed['protein']! / target['protein']! * 100).clamp(0.0, 100.0) : 0.0,
      'carbs': target['carbs']! > 0 ? (consumed['carbs']! / target['carbs']! * 100).clamp(0.0, 100.0) : 0.0,
      'fat': target['fat']! > 0 ? (consumed['fat']! / target['fat']! * 100).clamp(0.0, 100.0) : 0.0,
    };
  }

  // Cost tracking fields
  double? _dailyFoodBudget;
  double get dailyFoodBudget => _dailyFoodBudget ?? 20.0; // Default $20 budget

  // Calculate total food cost for the selected date
  double get totalFoodCost {
    double total = 0.0;
    
    try {
      // Sum costs from all meals for the selected date
      for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
        final mealItems = _entriesByMeal[mealType] ?? [];
        for (final item in mealItems) {
          // Check if the item is for the selected date
          if (_isSameDay(item.timestamp, _selectedDate)) {
            final itemCost = item.getCostForServing();
            if (itemCost != null && itemCost > 0) {
              total += itemCost;
            }
          }
        }
      }
    } catch (e) {
      print('Error calculating total food cost: $e');
    }
    
    return total;
  }

  // Calculate remaining budget
  double get remainingBudget {
    final remaining = dailyFoodBudget - totalFoodCost;
    return remaining.clamp(0.0, dailyFoodBudget);
  }

  // Check if over food budget
  bool get isOverFoodBudget => totalFoodCost > dailyFoodBudget;

  // Get budget progress (0.0 to 1.0)
  double get budgetProgress {
    if (dailyFoodBudget <= 0) return 0.0;
    return (totalFoodCost / dailyFoodBudget).clamp(0.0, 1.0);
  }

  // Get weekly cost total
  double get weeklyFoodCost {
    double total = 0.0;
    
    try {
      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      
      for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
        final mealItems = _entriesByMeal[mealType] ?? [];
        for (final item in mealItems) {
          if (item.timestamp.isAfter(startOfWeek) || _isSameDay(item.timestamp, startOfWeek)) {
            final itemCost = item.getCostForServing();
            if (itemCost != null && itemCost > 0) {
              total += itemCost;
            }
          }
        }
      }
    } catch (e) {
      print('Error calculating weekly food cost: $e');
    }
    
    return total;
  }

  // Get monthly cost total
  double get monthlyFoodCost {
    double total = 0.0;
    
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      
      for (final mealType in ['breakfast', 'lunch', 'dinner', 'snack']) {
        final mealItems = _entriesByMeal[mealType] ?? [];
        for (final item in mealItems) {
          if (item.timestamp.isAfter(startOfMonth) || _isSameDay(item.timestamp, startOfMonth)) {
            final itemCost = item.getCostForServing();
            if (itemCost != null && itemCost > 0) {
              total += itemCost;
            }
          }
        }
      }
    } catch (e) {
      print('Error calculating monthly food cost: $e');
    }
    
    return total;
  }

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

      // Calculate calorie goal
      _calculateCalorieGoal();

      // Calculate totals
      _calculateTotals();

      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Failed to load data: $e';
      _isLoading = false;
      print('Error in HomeProvider.loadData: $e');
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
      print('Error loading user data: $e');
    }
  }

  /// Load food entries for the selected date
  Future<void> _loadFoodEntries() async {
    try {
      final entries = await _foodRepository.getFoodEntriesForDate(_selectedDate);
      
      // Group entries by meal type
      _entriesByMeal = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snack': [],
      };

      for (final entry in entries) {
        final mealType = entry.mealType.toLowerCase();
        if (_entriesByMeal.containsKey(mealType)) {
          _entriesByMeal[mealType]!.add(entry);
        }
      }

      // Sort each meal by timestamp
      for (final mealType in _entriesByMeal.keys) {
        _entriesByMeal[mealType]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      }
    } catch (e) {
      print('Error loading food entries: $e');
    }
  }

  /// Calculate calorie goal based on user profile
  void _calculateCalorieGoal() {
    if (_userProfile != null && _currentWeight != null) {
      _calorieGoal = HomeStatisticsCalculator.calculateCalorieGoal(
        userProfile: _userProfile,
        currentWeight: _currentWeight,
      );
    } else {
      _calorieGoal = 2000; // Default goal
    }
  }

  /// Calculate total calories consumed
  void _calculateTotals() {
    _totalCalories = 0;

    for (final mealItems in _entriesByMeal.values) {
      for (final item in mealItems) {
        final itemCalories = (item.calories * item.servingSize).round();
        _totalCalories += itemCalories;
      }
    }
  }

  /// Load daily food budget from preferences
  Future<void> loadFoodBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyFoodBudget = prefs.getDouble('daily_food_budget');
    } catch (e) {
      print('Error loading food budget: $e');
    }
  }

  /// Save daily food budget to preferences
  Future<void> setDailyFoodBudget(double budget) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('daily_food_budget', budget);
      _dailyFoodBudget = budget;
      notifyListeners();
    } catch (e) {
      print('Error saving food budget: $e');
      rethrow;
    }
  }

  /// Get cost statistics for display
  Map<String, double> get costStatistics {
    return {
      'today': totalFoodCost,
      'week': weeklyFoodCost,
      'month': monthlyFoodCost,
      'budget': dailyFoodBudget,
      'remaining': remainingBudget,
    };
  }

  /// Format cost for display
  String formatCost(double cost) {
    return '\$${cost.toStringAsFixed(2)}';
  }

  /// Get cost status message
  String getCostStatusMessage() {
    final progress = budgetProgress;
    
    if (isOverFoodBudget) {
      return '🚨 Over your daily budget!';
    }
    
    if (progress >= 0.9) {
      return '⚠️ Approaching your budget limit!';
    }
    
    if (progress >= 0.7) {
      return '📊 On track with your budget!';
    }
    
    if (progress >= 0.4) {
      return '💡 Great spending discipline!';
    }
    
    return '🎯 Excellent budget management!';
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Helper method to check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Get all food items for the selected date
  List<FoodItem> get allFoodItems {
    final items = <FoodItem>[];
    for (final mealItems in _entriesByMeal.values) {
      items.addAll(mealItems);
    }
    return items;
  }

  /// Get food items count for the selected date
  int get totalFoodItems {
    return allFoodItems.length;
  }

  /// Get meals count for the selected date
  int get mealsCount {
    return _entriesByMeal.values.where((list) => list.isNotEmpty).length;
  }

  /// Check if today is selected
  bool get isToday {
    final now = DateTime.now();
    return _isSameDay(_selectedDate, now);
  }

  /// Check if can go to next day (not future)
  bool get canGoToNextDay {
    final tomorrow = _selectedDate.add(const Duration(days: 1));
    final now = DateTime.now();
    return tomorrow.isBefore(now) || _isSameDay(tomorrow, now);
  }

  /// Navigate to previous day
  Future<void> goToPreviousDay() async {
    final previousDay = _selectedDate.subtract(const Duration(days: 1));
    await changeDate(previousDay);
  }

  /// Navigate to next day
  Future<void> goToNextDay() async {
    if (canGoToNextDay) {
      final nextDay = _selectedDate.add(const Duration(days: 1));
      await changeDate(nextDay);
    }
  }

  /// Navigate to today
  Future<void> goToToday() async {
    if (!isToday) {
      await changeDate(DateTime.now());
    }
  }

  // ADD THESE METHODS FOR FOOD OPERATIONS

  /// Add food item to a meal
  Future<void> addFoodItem(FoodItem item) async {
    try {
      // Save to repository
      await _foodRepository.saveFoodEntry(item);
      
      // Add to local state if it's for the selected date
      if (_isSameDay(item.timestamp, _selectedDate)) {
        final mealType = item.mealType.toLowerCase();
        if (_entriesByMeal.containsKey(mealType)) {
          _entriesByMeal[mealType]!.add(item);
          _entriesByMeal[mealType]!.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          
          // Recalculate totals
          _calculateTotals();
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error adding food item: $e');
      rethrow;
    }
  }

  /// Update existing food item
  Future<void> updateFoodItem(FoodItem updatedItem) async {
    try {
      // Update in repository
      await _foodRepository.updateFoodEntry(updatedItem);
      
      // Update in local state if it's for the selected date
      if (_isSameDay(updatedItem.timestamp, _selectedDate)) {
        final mealType = updatedItem.mealType.toLowerCase();
        if (_entriesByMeal.containsKey(mealType)) {
          final items = _entriesByMeal[mealType]!;
          final index = items.indexWhere((item) => item.id == updatedItem.id);
          
          if (index != -1) {
            items[index] = updatedItem;
            
            // Recalculate totals
            _calculateTotals();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      print('Error updating food item: $e');
      rethrow;
    }
  }

  /// Delete food item
  Future<void> deleteFoodItem(String itemId) async {
    try {
      // Find the item first to get its timestamp
      FoodItem? itemToDelete;
      for (final mealType in _entriesByMeal.keys) {
        final items = _entriesByMeal[mealType]!;
        for (final item in items) {
          if (item.id == itemId) {
            itemToDelete = item;
            break;
          }
        }
        if (itemToDelete != null) break;
      }

      if (itemToDelete != null) {
        // Delete from repository with both id and timestamp
        await _foodRepository.deleteFoodEntry(itemId, itemToDelete.timestamp);
        
        // Remove from local state
        for (final mealType in _entriesByMeal.keys) {
          _entriesByMeal[mealType]!.removeWhere((item) => item.id == itemId);
        }
        
        // Recalculate totals
        _calculateTotals();
        notifyListeners();
      }
    } catch (e) {
      print('Error deleting food item: $e');
      rethrow;
    }
  }
}