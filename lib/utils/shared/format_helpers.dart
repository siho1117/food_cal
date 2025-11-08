// lib/utils/format_helpers.dart

/// Utility class for formatting health and fitness related values
///
/// Provides consistent formatting for displaying measurements like
/// height, weight, and weight goals across the app.
class FormatHelpers {
  // Private constructor to prevent instantiation
  FormatHelpers._();

  /// Format height in centimeters to a display string
  ///
  /// Returns formatted string like "175 cm" or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatHeight(175.5);
  /// // Returns: "175 cm"
  /// ```
  static String formatHeight(double? height) {
    if (height == null) return 'N/A';
    return '${height.round()} cm';
  }

  /// Format weight in kilograms to a display string
  ///
  /// Returns formatted string with 1 decimal place like "70.5 kg"
  /// or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatWeight(70.5);
  /// // Returns: "70.5 kg"
  /// ```
  static String formatWeight(double? weight) {
    if (weight == null) return 'N/A';
    return '${weight.toStringAsFixed(1)} kg';
  }

  /// Format monthly weight goal to a display string
  ///
  /// Calculates monthly goal from weekly goal (kg/week → kg/month).
  /// Returns formatted string like "+2.0 kg/month" or "-2.0 kg/month"
  /// or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatMonthlyWeightGoal(0.5);
  /// // Returns: "+2.0 kg/month" (0.5 kg/week × 4 weeks)
  ///
  /// final formatted2 = FormatHelpers.formatMonthlyWeightGoal(-0.5);
  /// // Returns: "-2.0 kg/month"
  /// ```
  static String formatMonthlyWeightGoal(double? weeklyGoal) {
    if (weeklyGoal == null) return 'N/A';
    final monthlyGoal = weeklyGoal * 4;
    final sign = monthlyGoal >= 0 ? '+' : '';
    return '$sign${monthlyGoal.toStringAsFixed(1)} kg/month';
  }

  /// Format BMI value to a display string
  ///
  /// Returns BMI with 1 decimal place like "22.5" or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatBMI(22.5);
  /// // Returns: "22.5"
  /// ```
  static String formatBMI(double? bmi) {
    if (bmi == null) return 'N/A';
    return bmi.toStringAsFixed(1);
  }

  /// Format body fat percentage to a display string
  ///
  /// Returns body fat with 1 decimal place like "15.5%" or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatBodyFat(15.5);
  /// // Returns: "15.5%"
  /// ```
  static String formatBodyFat(double? bodyFat) {
    if (bodyFat == null) return 'N/A';
    return '${bodyFat.toStringAsFixed(1)}%';
  }

  /// Format calorie value to a display string
  ///
  /// Returns rounded calorie value like "2000 cal" or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatCalories(2000.5);
  /// // Returns: "2000 cal"
  /// ```
  static String formatCalories(double? calories) {
    if (calories == null) return 'N/A';
    return '${calories.round()} cal';
  }

  /// Format weight change to a display string with sign
  ///
  /// Returns weight change with sign like "+2.5 kg" or "-1.3 kg"
  /// or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatWeightChange(2.5);
  /// // Returns: "+2.5 kg"
  ///
  /// final formatted2 = FormatHelpers.formatWeightChange(-1.3);
  /// // Returns: "-1.3 kg"
  /// ```
  static String formatWeightChange(double? change) {
    if (change == null) return 'N/A';
    final sign = change >= 0 ? '+' : '';
    return '$sign${change.toStringAsFixed(1)} kg';
  }

  /// Format macro value (protein, carbs, fat) to a display string
  ///
  /// Returns macro with 1 decimal place like "150.5 g" or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatMacro(150.5);
  /// // Returns: "150.5 g"
  /// ```
  static String formatMacro(double? macro) {
    if (macro == null) return 'N/A';
    return '${macro.toStringAsFixed(1)} g';
  }

  /// Format percentage to a display string
  ///
  /// Returns percentage with 0 decimal places like "75%" or "N/A" if null.
  ///
  /// Example:
  /// ```dart
  /// final formatted = FormatHelpers.formatPercentage(0.75);
  /// // Returns: "75%"
  /// ```
  static String formatPercentage(double? percentage) {
    if (percentage == null) return 'N/A';
    return '${(percentage * 100).round()}%';
  }
}
