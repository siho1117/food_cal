// lib/utils/macro_calculator.dart
import '../../data/models/user_profile.dart';

/// Centralized macronutrient calculation logic
/// 
/// Handles personalized macro ratios and conversions to grams based on:
/// - User profile (age, gender, activity level)
/// - Weight goals (loss, maintenance, gain)
/// - Daily calorie targets
class MacroCalculator {
  // Private constructor to prevent instantiation
  MacroCalculator._();

  /// Calculate macro targets in grams based on calorie goal and user profile
  /// 
  /// Returns a map with protein, carbs, and fat targets in grams.
  /// Uses personalized ratios based on user goals and profile.
  /// 
  /// Example:
  /// ```dart
  /// final targets = MacroCalculator.calculateTargets(
  ///   calorieGoal: 2000,
  ///   userProfile: userProfile,
  ///   currentWeight: 70.0,
  /// );
  /// // Returns: {'protein': 150, 'carbs': 200, 'fat': 67}
  /// ```
  static Map<String, int> calculateTargets({
    required int calorieGoal,
    required UserProfile? userProfile,
    required double? currentWeight,
  }) {
    // Default targets if calculation fails (30% protein, 45% carbs, 25% fat)
    final defaultTargets = {
      'protein': (calorieGoal * 0.30 / 4).round().clamp(1, 9999),
      'carbs': (calorieGoal * 0.45 / 4).round().clamp(1, 9999),
      'fat': (calorieGoal * 0.25 / 9).round().clamp(1, 9999),
    };

    if (userProfile == null || currentWeight == null || calorieGoal <= 0) {
      return defaultTargets;
    }

    try {
      // Get personalized macro ratios
      // TODO: Review how monthly weight goal should impact macro calculations after TDEE cleanup
      final macrosRatio = calculateRatios(
        monthlyWeightGoal: userProfile.monthlyWeightGoal,
        activityLevel: 1.2, // Hardcoded baseline multiplier (BMR × 1.2)
        gender: userProfile.gender,
        age: userProfile.age,
        currentWeight: currentWeight,
      );

      // Extract percentages with safe defaults
      final proteinPercent = macrosRatio['protein_percentage'] as int? ?? 30;
      final carbsPercent = macrosRatio['carbs_percentage'] as int? ?? 45;
      final fatPercent = macrosRatio['fat_percentage'] as int? ?? 25;

      // Convert percentages to grams based on calorie goal
      // Protein and carbs: 4 calories per gram
      // Fat: 9 calories per gram
      final targetProtein = ((calorieGoal * proteinPercent / 100) / 4).round().clamp(1, 9999);
      final targetCarbs = ((calorieGoal * carbsPercent / 100) / 4).round().clamp(1, 9999);
      final targetFat = ((calorieGoal * fatPercent / 100) / 9).round().clamp(1, 9999);

      return {
        'protein': targetProtein,
        'carbs': targetCarbs,
        'fat': targetFat,
      };
    } catch (e) {
      // Return defaults on error
      return defaultTargets;
    }
  }

  /// Calculate personalized macronutrient ratios (percentages)
  ///
  /// Returns a map with:
  /// - protein_percentage: int (e.g., 30)
  /// - carbs_percentage: int (e.g., 45)
  /// - fat_percentage: int (e.g., 25)
  /// - protein_per_kg: double (e.g., 1.8)
  /// - recommended_protein_grams: int (e.g., 126)
  ///
  /// Adjusts ratios based on:
  /// - Weight goal (loss = higher protein, gain = higher carbs)
  /// - Activity level (currently hardcoded to 1.2 baseline)
  /// - Age (older = more protein for muscle preservation)
  ///
  /// Note: activityLevel parameter is kept for API compatibility but
  /// should always be 1.2 (baseline multiplier).
  ///
  /// Example:
  /// ```dart
  /// final ratios = MacroCalculator.calculateRatios(
  ///   monthlyWeightGoal: -2.0, // Losing 2kg/month
  ///   activityLevel: 1.2,
  ///   gender: 'Male',
  ///   age: 30,
  ///   currentWeight: 80.0,
  /// );
  /// // Returns: {'protein_percentage': 35, 'carbs_percentage': 40, 'fat_percentage': 25, ...}
  /// ```
  static Map<String, dynamic> calculateRatios({
    required double? monthlyWeightGoal,
    required double? activityLevel,
    required String? gender,
    required int? age,
    required double? currentWeight,
  }) {
    // Default macros (moderate balanced approach)
    int proteinPercentage = 30;
    int carbsPercentage = 45;
    int fatPercentage = 25;

    // If we don't have enough information, return default values
    if (monthlyWeightGoal == null ||
        activityLevel == null ||
        gender == null ||
        age == null ||
        currentWeight == null) {
      return {
        'protein_percentage': proteinPercentage,
        'carbs_percentage': carbsPercentage,
        'fat_percentage': fatPercentage,
        'protein_per_kg': 1.8,
        'recommended_protein_grams': 0,
      };
    }

    // 1. Adjust based on weight goal (gain/loss)
    if (monthlyWeightGoal < -0.1) {
      // Weight loss - increase protein, reduce carbs
      proteinPercentage += 5;
      carbsPercentage -= 5;
    } else if (monthlyWeightGoal > 0.1) {
      // Weight gain - increase carbs for energy surplus
      carbsPercentage += 5;
      fatPercentage -= 5;
    }

    // 2. Adjust based on activity level
    if (activityLevel < 1.4) {
      // Sedentary - lower carbs
      carbsPercentage -= 5;
      fatPercentage += 5;
    } else if (activityLevel > 1.7) {
      // Very active - higher carbs for energy
      carbsPercentage += 5;
      fatPercentage -= 5;
    }

    // 3. Adjust based on age
    bool isOlder = age > 50;
    if (isOlder) {
      // Older adults need more protein for muscle preservation
      proteinPercentage += 5;
      carbsPercentage -= 5;
    }

    // 4. Make final adjustments to ensure percentages sum to 100%
    int total = proteinPercentage + carbsPercentage + fatPercentage;
    if (total != 100) {
      // Adjust carbs to make total 100%
      carbsPercentage += (100 - total);
    }

    // 5. Calculate protein based on body weight (between 1.6-2.2g per kg)
    double proteinPerKg;
    if (monthlyWeightGoal < -0.1) {
      // Higher protein for weight loss (2.0-2.2g/kg)
      proteinPerKg = 2.0;
    } else if (monthlyWeightGoal > 0.1) {
      // Moderate protein for weight gain (1.6-1.8g/kg)
      proteinPerKg = 1.6;
    } else {
      // Balanced protein for maintenance (1.8g/kg)
      proteinPerKg = 1.8;
    }

    // Adjust protein per kg based on activity level
    if (activityLevel > 1.7) {
      proteinPerKg += 0.2; // More active = more protein
    }

    // Calculate daily protein in grams
    int proteinGrams = (currentWeight * proteinPerKg).round();

    return {
      'protein_percentage': proteinPercentage,
      'carbs_percentage': carbsPercentage,
      'fat_percentage': fatPercentage,
      'protein_per_kg': proteinPerKg,
      'recommended_protein_grams': proteinGrams,
    };
  }

  /// Get a description of the macro split strategy being used
  /// 
  /// Useful for UI to explain why certain ratios are recommended.
  /// 
  /// Example:
  /// ```dart
  /// final description = MacroCalculator.getStrategyDescription(
  ///   monthlyWeightGoal: -2.0,
  ///   activityLevel: 1.55,
  /// );
  /// // Returns: "Higher protein for weight loss, moderate carbs for active lifestyle"
  /// ```
  static String getStrategyDescription({
    required double? monthlyWeightGoal,
    required double? activityLevel,
  }) {
    if (monthlyWeightGoal == null || activityLevel == null) {
      return 'Balanced macro distribution';
    }

    final goalPart = monthlyWeightGoal < -0.1
        ? 'Higher protein for weight loss'
        : monthlyWeightGoal > 0.1
            ? 'Higher carbs for weight gain'
            : 'Balanced macros for maintenance';

    final activityPart = activityLevel < 1.4
        ? 'lower carbs for sedentary lifestyle'
        : activityLevel > 1.7
            ? 'higher carbs for active lifestyle'
            : 'moderate carbs';

    return '$goalPart, $activityPart';
  }
}