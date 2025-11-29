// lib/utils/home/exercise_bonus_calculator.dart

/// Calculator for exercise calorie bonus
///
/// Implements the 35% credit with 400 cal cap formula for calculating
/// bonus calories earned from excess exercise beyond the daily goal.
///
/// Formula: Bonus = min(excess × 0.35, 400)
/// where excess = max(0, totalBurned - burnGoal)
class ExerciseBonusCalculator {
  // Private constructor - utility class
  ExerciseBonusCalculator._();

  /// Credit rate: 35% of excess calories earned as bonus
  ///
  /// Conservative rate that accounts for:
  /// - 20-50% overestimation in exercise calorie calculations
  /// - User tendency to overestimate exercise intensity
  /// - Fitness tracker generosity
  /// - Preserves 65% of exercise benefit for weight loss
  static const double creditRate = 0.35;

  /// Maximum bonus calories per day: 400 cal
  ///
  /// Cap prevents:
  /// - Excessive calorie rollover that sabotages weight goals
  /// - Gaming the system with inflated exercise logs
  /// - Maintains reasonable daily intake consistency
  static const int maxBonus = 400;

  /// Calculate bonus calories earned from exercise
  ///
  /// Only calories burned BEYOND the daily exercise goal count toward bonus.
  /// The bonus is 35% of the excess, capped at 400 calories.
  ///
  /// Parameters:
  /// - [totalBurned]: Total calories burned from all exercises today
  /// - [burnGoal]: Daily exercise calorie burn goal
  ///
  /// Returns: Bonus calories (0 if no excess, capped at 400)
  ///
  /// Examples:
  /// ```dart
  /// // No excess - no bonus
  /// calculateBonus(totalBurned: 400, burnGoal: 500) // Returns: 0
  ///
  /// // Moderate excess - below cap
  /// calculateBonus(totalBurned: 700, burnGoal: 500) // Returns: 70
  /// // excess = 200, bonus = 200 × 0.35 = 70
  ///
  /// // Large excess - cap kicks in
  /// calculateBonus(totalBurned: 2000, burnGoal: 500) // Returns: 400
  /// // excess = 1500, bonus = 1500 × 0.35 = 525, capped at 400
  /// ```
  static int calculateBonus({
    required int totalBurned,
    required int burnGoal,
  }) {
    // Calculate excess calories (calories burned beyond goal)
    final excess = totalBurned - burnGoal;

    // No bonus if didn't exceed goal
    if (excess <= 0) {
      return 0;
    }

    // Calculate 35% of excess
    final uncappedBonus = (excess * creditRate).round();

    // Apply 400 cal cap
    return uncappedBonus.clamp(0, maxBonus);
  }

  /// Calculate the excess calories (burned beyond goal)
  ///
  /// Useful for displaying breakdown to users.
  ///
  /// Example:
  /// ```dart
  /// final excess = calculateExcess(totalBurned: 700, burnGoal: 500);
  /// // Returns: 200
  /// ```
  static int calculateExcess({
    required int totalBurned,
    required int burnGoal,
  }) {
    return (totalBurned - burnGoal).clamp(0, double.infinity).toInt();
  }

  /// Check if the bonus cap was reached
  ///
  /// Useful for UI indicators (e.g., "Max bonus earned!").
  ///
  /// Example:
  /// ```dart
  /// final isCapped = isBonusCapped(totalBurned: 2000, burnGoal: 500);
  /// // Returns: true (would earn 525 but capped at 400)
  /// ```
  static bool isBonusCapped({
    required int totalBurned,
    required int burnGoal,
  }) {
    final excess = calculateExcess(
      totalBurned: totalBurned,
      burnGoal: burnGoal,
    );

    if (excess == 0) return false;

    final uncappedBonus = (excess * creditRate).round();
    return uncappedBonus > maxBonus;
  }

  /// Get the effective calorie goal (base + bonus)
  ///
  /// Convenience method for calculating the adjusted daily goal.
  ///
  /// Example:
  /// ```dart
  /// final effectiveGoal = calculateEffectiveGoal(
  ///   baseGoal: 2000,
  ///   totalBurned: 700,
  ///   burnGoal: 500,
  /// );
  /// // Returns: 2070 (2000 base + 70 bonus)
  /// ```
  static int calculateEffectiveGoal({
    required int baseGoal,
    required int totalBurned,
    required int burnGoal,
  }) {
    final bonus = calculateBonus(
      totalBurned: totalBurned,
      burnGoal: burnGoal,
    );
    return baseGoal + bonus;
  }

  /// Get a summary of the bonus calculation
  ///
  /// Returns a map with all relevant values for display.
  ///
  /// Example:
  /// ```dart
  /// final summary = getBonusSummary(
  ///   baseGoal: 2000,
  ///   totalBurned: 700,
  ///   burnGoal: 500,
  /// );
  /// // Returns: {
  /// //   'excess': 200,
  /// //   'bonus': 70,
  /// //   'effectiveGoal': 2070,
  /// //   'isCapped': false,
  /// // }
  /// ```
  static Map<String, dynamic> getBonusSummary({
    required int baseGoal,
    required int totalBurned,
    required int burnGoal,
  }) {
    final excess = calculateExcess(
      totalBurned: totalBurned,
      burnGoal: burnGoal,
    );

    final bonus = calculateBonus(
      totalBurned: totalBurned,
      burnGoal: burnGoal,
    );

    final effectiveGoal = baseGoal + bonus;

    final isCapped = isBonusCapped(
      totalBurned: totalBurned,
      burnGoal: burnGoal,
    );

    return {
      'excess': excess,
      'bonus': bonus,
      'effectiveGoal': effectiveGoal,
      'isCapped': isCapped,
    };
  }
}
