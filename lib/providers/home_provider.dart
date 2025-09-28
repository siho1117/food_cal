// lib/providers/home_provider.dart
// STEP 3: Simple change - use GetIt instead of direct instantiation
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ADD THIS IMPORT for GetIt
import '../config/dependency_injection.dart';

import '../data/repositories/food_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/food_item.dart';
import '../data/models/user_profile.dart';
import '../utils/home_statistics_calculator.dart';

class HomeProvider extends ChangeNotifier {
  // CHANGE ONLY THESE TWO LINES:
  // OLD: final FoodRepository _foodRepository = FoodRepository();
  // OLD: final UserRepository _userRepository = UserRepository();
  
  // NEW: Get from dependency injection container
  final FoodRepository _foodRepository = getIt<FoodRepository>();
  final UserRepository _userRepository = getIt<UserRepository>();

  // === EVERYTHING ELSE STAYS EXACTLY THE SAME ===
  
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

  // Budget tracking
  double _dailyFoodBudget = 25.0;
  double get dailyFoodBudget => _dailyFoodBudget;

  double _totalFoodCost = 0.0;
  double get totalFoodCost => _totalFoodCost;

  double get budgetRemaining => (_dailyFoodBudget - _totalFoodCost).clamp(0.0, _dailyFoodBudget);
  double get budgetProgress => _dailyFoodBudget > 0 ? (_totalFoodCost / _dailyFoodBudget).clamp(0.0, 1.0) : 0.0;

  // Macro targets
  Map<String, int> get targetMacros {
    final calorieGoal = _calorieGoal;
    return {
      'protein': (calorieGoal * 0.30 / 4).round(), // 30% of calories from protein
      'carbs': (calorieGoal * 0.40 / 4).round(),   // 40% of calories from carbs
      'fat': (calorieGoal * 0.30 / 9).round(),     // 30% of calories from fat
    };
  }

  // ADDED: Missing getter for budget status
  bool get isOverFoodBudget => _totalFoodCost > _dailyFoodBudget;

  // ADDED: Missing getter for macro progress percentages
  Map<String, double> get macroProgressPercentages {
    final consumed = consumedMacros;
    final targets = targetMacros;
    
    return {
      'protein': targets['protein']! > 0 ? (consumed['protein']! / targets['protein']!).clamp(0.0, 1.0) : 0.0,
      'carbs': targets['carbs']! > 0 ? (consumed['carbs']! / targets['carbs']!).clamp(0.0, 1.0) : 0.0,
      'fat': targets['fat']! > 0 ? (consumed['fat']! / targets['fat']!).clamp(0.0, 1.0) : 0.0,
    };
  }

  // ADDED: Missing getter for meals count (total number, not map)
  int get mealsCount {
    return (_entriesByMeal['breakfast']?.length ?? 0) +
           (_entriesByMeal['lunch']?.length ?? 0) +
           (_entriesByMeal['dinner']?.length ?? 0) +
           (_entriesByMeal['snack']?.length ?? 0);
  }

  // ADDED: If you need detailed count by meal type, use this getter
  Map<String, int> get mealCountsByType {
    return {
      'breakfast': _entriesByMeal['breakfast']?.length ?? 0,
      'lunch': _entriesByMeal['lunch']?.length ?? 0,
      'dinner': _entriesByMeal['dinner']?.length ?? 0,
      'snack': _entriesByMeal['snack']?.length ?? 0,
    };
  }

  // Weekly cost calculation
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
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error calculating weekly food cost: $e');
    }
    
    return total;
  }

  // Monthly cost calculation
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
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error calculating monthly food cost: $e');
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
      // ✅ FIXED: Replace print with debugPrint
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
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error loading user data: $e');
      // Don't throw - let the UI handle missing user data gracefully
    }
  }

  /// Load food entries for the selected date
  Future<void> _loadFoodEntries() async {
    try {
      final entries = await _foodRepository.getFoodEntriesForDate(_selectedDate);
      
      // Clear existing entries
      _entriesByMeal = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snack': [],
      };

      // Group entries by meal type
      for (final entry in entries) {
        final mealType = entry.mealType.toLowerCase();
        if (_entriesByMeal.containsKey(mealType)) {
          _entriesByMeal[mealType]!.add(entry);
        }
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error loading food entries: $e');
      // Initialize with empty data if loading fails
      _entriesByMeal = {
        'breakfast': [],
        'lunch': [],
        'dinner': [],
        'snack': [],
      };
    }
  }

  /// Load food budget from preferences
  Future<void> loadFoodBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _dailyFoodBudget = prefs.getDouble('daily_food_budget') ?? 25.0;
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error loading food budget: $e');
      _dailyFoodBudget = 25.0; // Default fallback
    }
  }

  /// Update daily food budget
  Future<void> updateFoodBudget(double budget) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('daily_food_budget', budget);
      _dailyFoodBudget = budget;
      notifyListeners();
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error updating food budget: $e');
      rethrow;
    }
  }

  // ADDED: Missing method that your widgets expect
  Future<void> setDailyFoodBudget(double budget) async {
    await updateFoodBudget(budget); // Delegate to existing method
  }

  /// Calculate calorie goal based on user profile
  void _calculateCalorieGoal() {
    _calorieGoal = HomeStatisticsCalculator.calculateCalorieGoal(
      userProfile: _userProfile,
      currentWeight: _currentWeight,
    );
  }

  /// Calculate totals for calories and cost
  void _calculateTotals() {
    _totalCalories = 0;
    _totalFoodCost = 0.0;

    for (final mealItems in _entriesByMeal.values) {
      for (final item in mealItems) {
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
  }

  /// Add a food entry
  Future<void> addFoodEntry(FoodItem entry) async {
    try {
      // Save to storage
      await _foodRepository.saveFoodEntry(entry);
      
      // If it's for the currently selected date, add to local state
      if (_isSameDay(entry.timestamp, _selectedDate)) {
        final mealType = entry.mealType.toLowerCase();
        if (_entriesByMeal.containsKey(mealType)) {
          _entriesByMeal[mealType]!.add(entry);
          
          // Recalculate totals
          _calculateTotals();
          notifyListeners();
        }
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
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
        final mealType = updatedItem.mealType.toLowerCase();
        if (_entriesByMeal.containsKey(mealType)) {
          final items = _entriesByMeal[mealType]!;
          final index = items.indexWhere((item) => item.id == updatedItem.id);
          if (index != -1) {
            items[index] = updatedItem;
            _calculateTotals();
            notifyListeners();
          }
        }
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error updating food entry: $e');
      rethrow;
    }
  }

  /// Delete a food entry
  Future<void> deleteFoodEntry(String entryId) async {
    try {
      // Find the item first to get its timestamp
      FoodItem? itemToDelete;
      for (final mealType in _entriesByMeal.keys) {
        final items = _entriesByMeal[mealType]!;
        for (final item in items) {
          if (item.id == entryId) {
            itemToDelete = item;
            break;
          }
        }
        if (itemToDelete != null) break;
      }

      if (itemToDelete != null) {
        // Delete from storage with both id and timestamp
        await _foodRepository.deleteFoodEntry(entryId, itemToDelete.timestamp);
        
        // Remove from local state
        for (final mealType in _entriesByMeal.keys) {
          _entriesByMeal[mealType]!.removeWhere((item) => item.id == entryId);
        }
        
        // Recalculate totals
        _calculateTotals();
        notifyListeners();
      }
    } catch (e) {
      // ✅ FIXED: Replace print with debugPrint
      debugPrint('Error deleting food entry: $e');
      rethrow;
    }
  }

  /// Check if two dates are the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Get meal items for a specific meal type
  List<FoodItem> getMealItems(String mealType) {
    return _entriesByMeal[mealType.toLowerCase()] ?? [];
  }

  /// Check if the selected date is today
  bool get isToday => _isSameDay(_selectedDate, DateTime.now());

  /// Check if the selected date is in the future
  bool get isFutureDate => _selectedDate.isAfter(DateTime.now()) && !isToday;

  /// Get formatted date string for display
  String get formattedSelectedDate {
    if (isToday) return 'Today';
    
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    if (_isSameDay(_selectedDate, yesterday)) return 'Yesterday';
    
    final tomorrow = now.add(const Duration(days: 1));
    if (_isSameDay(_selectedDate, tomorrow)) return 'Tomorrow';
    
    // Format as "Mon, Dec 25"
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    final weekday = weekdays[_selectedDate.weekday - 1];
    final month = months[_selectedDate.month - 1];
    final day = _selectedDate.day;
    
    return '$weekday, $month $day';
  }
}