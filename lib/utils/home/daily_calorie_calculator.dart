// lib/utils/daily_calorie_calculator.dart
import '../../data/models/user_profile.dart';
import '../progress/health_metrics.dart';

/// Calculator for daily calorie goals based on BMR baseline and weight goals
///
/// Handles:
/// - BMR calculation via HealthMetrics utility
/// - Baseline using BMR (without activity multiplier)
/// - Monthly weight goal adjustments
/// - Safety caps (minimum 75% of BMR for weight loss)
/// - Fallback defaults when user data is incomplete
///
/// Note: Users should log exercise separately to avoid double-counting.
class DailyCalorieCalculator {
  // Private constructor to prevent instantiation
  DailyCalorieCalculator._();

  /// Calculate daily calorie goal based on user profile and current weight
  ///
  /// Process:
  /// 1. Calculate BMR using HealthMetrics.calculateBMR()
  /// 2. Use BMR as baseline calories (without activity multiplier)
  /// 3. Adjust for monthly weight goal (deficit/surplus)
  /// 4. Apply safety cap (75% of BMR minimum for weight loss)
  ///
  /// Returns 2000 as default if data is insufficient.
  ///
  /// Note: Exercise should be logged separately to avoid double-counting.
  ///
  /// Example:
  /// ```dart
  /// final goal = DailyCalorieCalculator.calculateDailyGoal(
  ///   userProfile: userProfile,
  ///   currentWeight: 75.0,
  /// );
  /// // Returns: 1400 (BMR baseline minus deficit with safety cap applied)
  /// ```
  static int calculateDailyGoal({
    required UserProfile? userProfile,
    required double? currentWeight,
  }) {
    // Return default if essential data is missing
    if (userProfile == null || currentWeight == null) {
      return 2000;
    }

    try {
      // Calculate BMR using HealthMetrics utility
      final bmr = HealthMetrics.calculateBMR(
        weight: currentWeight,
        height: userProfile.height,
        age: userProfile.age,
        gender: userProfile.gender,
      );

      // If BMR calculation fails, return default
      if (bmr == null) {
        return 2000;
      }

      // Calculate baseline calories (BMR without activity multiplier)
      // Users should log exercise separately to avoid double-counting
      final baselineCalories = bmr;

      // Start with maintenance calories (baseline)
      int calorieGoal = baselineCalories.round();

      // Adjust for monthly weight goal if set
      if (userProfile.monthlyWeightGoal != null) {
        // Calculate daily calorie adjustment
        // 1 kg of body fat = approximately 7700 calories
        final dailyWeightChangeKg = userProfile.monthlyWeightGoal! / 30;
        final calorieAdjustment = dailyWeightChangeKg * 7700;

        // Apply adjustment to baseline
        calorieGoal = (baselineCalories + calorieAdjustment).round();

        // SAFETY CHECK: For weight loss, ensure minimum safe calories
        // Never go below 75% of BMR to maintain health and metabolism
        if (userProfile.monthlyWeightGoal! < 0) {
          final minimumSafeCalories = (bmr * 0.75).round();
          if (calorieGoal < minimumSafeCalories) {
            calorieGoal = minimumSafeCalories;
          }
        }
      }

      // Final safety check: ensure positive value
      return calorieGoal > 0 ? calorieGoal : 2000;
    } catch (e) {
      // Return default on any error
      return 2000;
    }
  }

  /// Calculate the expected weekly weight change based on calorie goal
  ///
  /// Useful for UI to show expected progress.
  ///
  /// Returns weight change in kg per week (positive = gain, negative = loss).
  ///
  /// Note: This calculation uses BMR as baseline, not TDEE.
  /// Exercise calories should be logged separately.
  ///
  /// Example:
  /// ```dart
  /// final weeklyChange = DailyCalorieCalculator.calculateExpectedWeeklyChange(
  ///   calorieGoal: 1800,
  ///   userProfile: userProfile,
  ///   currentWeight: 75.0,
  /// );
  /// // Returns: -0.5 (expecting to lose 0.5kg per week)
  /// ```
  static double? calculateExpectedWeeklyChange({
    required int calorieGoal,
    required UserProfile? userProfile,
    required double? currentWeight,
  }) {
    if (userProfile == null || currentWeight == null) {
      return null;
    }

    try {
      // Calculate BMR and baseline
      final bmr = HealthMetrics.calculateBMR(
        weight: currentWeight,
        height: userProfile.height,
        age: userProfile.age,
        gender: userProfile.gender,
      );

      if (bmr == null) return null;

      final baselineCalories = bmr;

      // Calculate weekly deficit/surplus
      final dailyDifference = calorieGoal - baselineCalories;
      final weeklyDifference = dailyDifference * 7;

      // Convert to kg (7700 calories per kg of body fat)
      return weeklyDifference / 7700;
    } catch (e) {
      return null;
    }
  }

  /// Check if the calorie goal was safety-adjusted (capped at 75% BMR)
  /// 
  /// Useful for UI to show a warning message when aggressive weight loss
  /// goals are being automatically adjusted for safety.
  /// 
  /// Example:
  /// ```dart
  /// final wasAdjusted = DailyCalorieCalculator.wasSafetyAdjusted(
  ///   userProfile: userProfile,
  ///   currentWeight: 75.0,
  /// );
  /// if (wasAdjusted) {
  ///   // Show warning: "Your calorie goal has been adjusted for safety"
  /// }
  /// ```
  static bool wasSafetyAdjusted({
    required UserProfile? userProfile,
    required double? currentWeight,
  }) {
    if (userProfile == null ||
        currentWeight == null ||
        userProfile.monthlyWeightGoal == null ||
        userProfile.monthlyWeightGoal! >= 0) {
      return false; // Only relevant for weight loss
    }

    try {
      // Calculate what the goal would be without safety cap
      final bmr = HealthMetrics.calculateBMR(
        weight: currentWeight,
        height: userProfile.height,
        age: userProfile.age,
        gender: userProfile.gender,
      );

      if (bmr == null) return false;

      final baselineCalories = bmr;

      final dailyWeightChangeKg = userProfile.monthlyWeightGoal! / 30;
      final calorieAdjustment = dailyWeightChangeKg * 7700;
      final theoreticalGoal = (baselineCalories + calorieAdjustment).round();

      // Check if it would go below the safety threshold
      final minimumSafeCalories = (bmr * 0.75).round();
      return theoreticalGoal < minimumSafeCalories;
    } catch (e) {
      return false;
    }
  }

  /// Get a description of the current calorie goal strategy
  /// 
  /// Useful for UI to explain the calorie target to the user.
  /// 
  /// Example:
  /// ```dart
  /// final description = DailyCalorieCalculator.getGoalDescription(
  ///   monthlyWeightGoal: -2.0,
  /// );
  /// // Returns: "Weight loss (2.0 kg/month)"
  /// ```
  static String getGoalDescription(double? monthlyWeightGoal) {
    if (monthlyWeightGoal == null || monthlyWeightGoal.abs() < 0.1) {
      return 'Maintenance';
    }

    if (monthlyWeightGoal < -0.1) {
      return 'Weight loss (${monthlyWeightGoal.abs().toStringAsFixed(1)} kg/month)';
    } else {
      return 'Weight gain (${monthlyWeightGoal.toStringAsFixed(1)} kg/month)';
    }
  }

  /// Get the calorie deficit/surplus per day
  /// 
  /// Positive = surplus (for gain), Negative = deficit (for loss)
  /// 
  /// Example:
  /// ```dart
  /// final adjustment = DailyCalorieCalculator.getDailyCalorieAdjustment(
  ///   monthlyWeightGoal: -2.0,
  /// );
  /// // Returns: -513 (daily deficit for losing 2kg/month)
  /// ```
  static int getDailyCalorieAdjustment(double? monthlyWeightGoal) {
    if (monthlyWeightGoal == null) return 0;

    final dailyWeightChangeKg = monthlyWeightGoal / 30;
    final calorieAdjustment = dailyWeightChangeKg * 7700;

    return calorieAdjustment.round();
  }
}