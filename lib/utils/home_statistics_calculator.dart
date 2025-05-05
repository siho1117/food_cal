// lib/utils/home_statistics_calculator.dart
import '../data/models/user_profile.dart';
import '../data/models/weight_entry.dart';
import '../data/models/food_item.dart';
import '../utils/formula.dart';

/// A utility class that handles all calculations for home screen widgets
/// Separates business logic from UI components
class HomeStatisticsCalculator {
  // Private constructor to prevent instantiation
  HomeStatisticsCalculator._();

  /// Calculate calorie goal based on user profile and weight
  static int calculateCalorieGoal({
    required UserProfile? userProfile,
    required double? currentWeight,
  }) {
    if (userProfile == null || currentWeight == null) {
      return 2000; // Default value if data is missing
    }

    try {
      // Calculate BMR
      double? bmr;
      
      if (userProfile.gender == 'Male') {
        bmr = (10 * currentWeight) +
            (6.25 * (userProfile.height ?? 170)) -
            (5 * (userProfile.age ?? 30)) +
            5;
      } else if (userProfile.gender == 'Female') {
        bmr = (10 * currentWeight) +
            (6.25 * (userProfile.height ?? 170)) -
            (5 * (userProfile.age ?? 30)) -
            161;
      } else {
        // Average of male and female formulas
        final maleBMR = (10 * currentWeight) +
            (6.25 * (userProfile.height ?? 170)) -
            (5 * (userProfile.age ?? 30)) +
            5;
        final femaleBMR = (10 * currentWeight) +
            (6.25 * (userProfile.height ?? 170)) -
            (5 * (userProfile.age ?? 30)) -
            161;
        bmr = (maleBMR + femaleBMR) / 2;
      }

      // Calculate TDEE based on activity level
      final activityLevel = userProfile.activityLevel ?? 1.4; // Default to lightly active
      final tdee = bmr * activityLevel;
      
      // Get monthly weight goal adjustment if any
      int calorieGoal = tdee.round();
      if (userProfile.monthlyWeightGoal != null) {
        // Calculate daily calorie adjustment
        final dailyWeightChangeKg = userProfile.monthlyWeightGoal! / 30;
        final calorieAdjustment = dailyWeightChangeKg * 7700; // ~7700 calories per kg
        
        // Set calorie goal with adjustment
        calorieGoal = (tdee + calorieAdjustment).round();
        
        // Ensure minimum safe calories (90% of BMR)
        final minimumCalories = (bmr * 0.9).round();
        if (calorieGoal < minimumCalories) {
          calorieGoal = minimumCalories;
        }
      }
      
      return calorieGoal > 0 ? calorieGoal : 2000; // Ensure positive value
    } catch (e) {
      print('Error calculating calorie goal: $e');
      return 2000; // Default value on error
    }
  }
  
  /// Calculate total calories consumed for a specific date
  static int calculateTotalCalories(Map<String, List<FoodItem>> entriesByMeal) {
    int totalCalories = 0;
    
    try {
      // Process all meals
      for (var mealItems in entriesByMeal.values) {
        for (var item in mealItems) {
          totalCalories += (item.calories * item.servingSize).round();
        }
      }
      
      return totalCalories;
    } catch (e) {
      print('Error calculating total calories: $e');
      return 0;
    }
  }
  
  /// Calculate calories remaining for the day
  static int calculateCaloriesRemaining({
    required int totalCalories,
    required int calorieGoal,
  }) {
    return calorieGoal - totalCalories;
  }
  
  /// Calculate expected daily calorie percentage based on time of day
  static double calculateExpectedDailyPercentage() {
    final now = DateTime.now();
    // Simple linear model based on time of day
    // Assumes calorie distribution: 25% breakfast (8am), 40% lunch (1pm), 35% dinner (7pm)
    final hour = now.hour + (now.minute / 60.0);
    
    if (hour < 8) {
      return 0.0; // Before breakfast
    } else if (hour < 13) {
      // Between breakfast and lunch (8am-1pm)
      return 0.25 * ((hour - 8) / 5);
    } else if (hour < 19) {
      // Between lunch and dinner (1pm-7pm)
      return 0.25 + 0.40 * ((hour - 13) / 6);
    } else {
      // After dinner
      return _min(1.0, 0.65 + 0.35 * ((hour - 19) / 5)); // Cap at 100%
    }
  }
  
  /// Calculate macronutrient targets based on user profile and calorie goal
  static Map<String, int> calculateMacroTargets({
    required UserProfile? userProfile,
    required double? currentWeight,
    required int calorieGoal,
  }) {
    // Default targets if calculation fails
    final defaultTargets = {
      'protein': 50,
      'carbs': 150,
      'fat': 50,
    };
    
    if (userProfile == null || currentWeight == null || calorieGoal <= 0) {
      return defaultTargets;
    }
    
    try {
      // Calculate macronutrient ratios using the Formula utility
      final macrosRatio = Formula.calculateMacronutrientRatio(
        monthlyWeightGoal: userProfile.monthlyWeightGoal,
        activityLevel: userProfile.activityLevel,
        gender: userProfile.gender,
        age: userProfile.age,
        currentWeight: currentWeight,
      );
      
      // Extract percentages with safe defaults
      final proteinPercent = macrosRatio['protein_percentage'] as int? ?? 30;
      final carbsPercent = macrosRatio['carbs_percentage'] as int? ?? 45;
      final fatPercent = macrosRatio['fat_percentage'] as int? ?? 25;
      
      // Convert percentages to grams based on calorie goal
      // Protein and carbs: 4 calories per gram, Fat: 9 calories per gram
      final targetProtein = _max(1, ((calorieGoal * proteinPercent / 100) / 4).round());
      final targetCarbs = _max(1, ((calorieGoal * carbsPercent / 100) / 4).round());
      final targetFat = _max(1, ((calorieGoal * fatPercent / 100) / 9).round());
      
      return {
        'protein': targetProtein,
        'carbs': targetCarbs,
        'fat': targetFat,
      };
    } catch (e) {
      print('Error calculating macro targets: $e');
      return defaultTargets;
    }
  }
  
  /// Calculate consumed macronutrients from food entries
  static Map<String, double> calculateConsumedMacros(Map<String, List<FoodItem>> entriesByMeal) {
    double protein = 0;
    double carbs = 0;
    double fat = 0;
    
    try {
      // Process all meals
      for (var mealItems in entriesByMeal.values) {
        for (var item in mealItems) {
          protein += item.proteins * item.servingSize;
          carbs += item.carbs * item.servingSize;
          fat += item.fats * item.servingSize;
        }
      }
      
      return {
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
    } catch (e) {
      print('Error calculating consumed macros: $e');
      return {
        'protein': 0,
        'carbs': 0,
        'fat': 0,
      };
    }
  }
  
  /// Calculate progress percentages toward macro targets
  static Map<String, double> calculateMacroProgressPercentages({
    required Map<String, double> consumedMacros,
    required Map<String, int> targetMacros,
  }) {
    final progress = {
      'protein': targetMacros['protein']! > 0 
          ? (consumedMacros['protein']! / targetMacros['protein']!).clamp(0.0, 1.0) 
          : 0.0,
      'carbs': targetMacros['carbs']! > 0 
          ? (consumedMacros['carbs']! / targetMacros['carbs']!).clamp(0.0, 1.0) 
          : 0.0,
      'fat': targetMacros['fat']! > 0 
          ? (consumedMacros['fat']! / targetMacros['fat']!).clamp(0.0, 1.0) 
          : 0.0,
    };
    
    return progress;
  }
  
  /// Calculate percentage of daily macro targets achieved
  static Map<String, int> calculateMacroTargetPercentages({
    required Map<String, double> consumedMacros,
    required Map<String, int> targetMacros,
  }) {
    try {
      return {
        'protein': targetMacros['protein']! > 0
            ? (consumedMacros['protein']! / targetMacros['protein']! * 100).round().clamp(0, 999)
            : 0,
        'carbs': targetMacros['carbs']! > 0
            ? (consumedMacros['carbs']! / targetMacros['carbs']! * 100).round().clamp(0, 999)
            : 0,
        'fat': targetMacros['fat']! > 0
            ? (consumedMacros['fat']! / targetMacros['fat']! * 100).round().clamp(0, 999)
            : 0,
      };
    } catch (e) {
      print('Error calculating target percentages: $e');
      return {
        'protein': 0,
        'carbs': 0,
        'fat': 0,
      };
    }
  }
  
  /// Helper function to get minimum of two values
  static double _min(double a, double b) => a < b ? a : b;
  
  /// Helper function to get maximum of two values
  static int _max(int a, int b) => a > b ? a : b;
}