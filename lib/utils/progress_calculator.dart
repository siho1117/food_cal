// lib/utils/progress_calculator.dart

/// Utility class for calculating progress percentages and metrics
///
/// Provides reusable methods for tracking progress toward goals,
/// including calorie goals, macro targets, budgets, and time-based progress.
class ProgressCalculator {
  // Private constructor to prevent instantiation
  ProgressCalculator._();

  /// Calculate progress percentage for a single metric
  ///
  /// Returns a value between 0.0 (0%) and 1.0 (100%).
  /// If target is 0 or negative, returns 0.0.
  ///
  /// Example:
  /// ```dart
  /// final progress = ProgressCalculator.calculateProgress(
  ///   consumed: 1500.0,
  ///   target: 2000.0,
  /// );
  /// // Returns: 0.75 (75%)
  /// ```
  static double calculateProgress({
    required double consumed,
    required double target,
  }) {
    if (target <= 0) return 0.0;
    return (consumed / target).clamp(0.0, 1.0);
  }

  /// Calculate remaining amount to reach target
  ///
  /// Returns how much is left to consume/spend to reach the target.
  /// Clamped to minimum of 0 (can't go negative).
  ///
  /// Example:
  /// ```dart
  /// final remaining = ProgressCalculator.calculateRemaining(
  ///   consumed: 1500.0,
  ///   target: 2000.0,
  /// );
  /// // Returns: 500.0 (500 remaining)
  /// ```
  static double calculateRemaining({
    required double consumed,
    required double target,
  }) {
    return (target - consumed).clamp(0.0, target);
  }

  /// Check if target has been exceeded
  ///
  /// Returns true if consumed > target.
  ///
  /// Example:
  /// ```dart
  /// final overBudget = ProgressCalculator.isOverTarget(
  ///   consumed: 2100.0,
  ///   target: 2000.0,
  /// );
  /// // Returns: true
  /// ```
  static bool isOverTarget({
    required double consumed,
    required double target,
  }) {
    return consumed > target;
  }

  /// Calculate progress for multiple macronutrients
  ///
  /// Takes consumed and target macros and returns progress percentages
  /// for protein, carbs, and fat.
  ///
  /// Example:
  /// ```dart
  /// final progress = ProgressCalculator.calculateMacroProgress(
  ///   consumed: {'protein': 85.0, 'carbs': 180.0, 'fat': 55.0},
  ///   targets: {'protein': 150, 'carbs': 200, 'fat': 67},
  /// );
  /// // Returns: {'protein': 0.57, 'carbs': 0.90, 'fat': 0.82}
  /// ```
  static Map<String, double> calculateMacroProgress({
    required Map<String, double> consumed,
    required Map<String, int> targets,
  }) {
    return {
      'protein': calculateProgress(
        consumed: consumed['protein'] ?? 0.0,
        target: targets['protein']?.toDouble() ?? 0.0,
      ),
      'carbs': calculateProgress(
        consumed: consumed['carbs'] ?? 0.0,
        target: targets['carbs']?.toDouble() ?? 0.0,
      ),
      'fat': calculateProgress(
        consumed: consumed['fat'] ?? 0.0,
        target: targets['fat']?.toDouble() ?? 0.0,
      ),
    };
  }

  /// Calculate expected progress based on time of day
  ///
  /// Returns how far through the day we are (0.0-1.0) based on current time.
  /// If the selected date is not today, returns 1.0 (100%) for past/future dates.
  ///
  /// Useful for determining if user is "on pace" with their calorie intake.
  ///
  /// Example:
  /// ```dart
  /// // At 6pm (18:00)
  /// final expected = ProgressCalculator.calculateExpectedDailyProgress(
  ///   selectedDate: DateTime.now(),
  /// );
  /// // Returns: 0.75 (75% through the day)
  /// ```
  static double calculateExpectedDailyProgress({
    required DateTime selectedDate,
  }) {
    final now = DateTime.now();

    // If not viewing today, return 100%
    if (!_isSameDay(now, selectedDate)) return 1.0;

    // Calculate minutes elapsed today
    const minutesInDay = 24 * 60;
    final currentMinutes = now.hour * 60 + now.minute;

    return (currentMinutes / minutesInDay).clamp(0.0, 1.0);
  }

  /// Get pace status for calorie consumption
  ///
  /// Compares actual progress vs expected progress to determine if user
  /// is ahead, on pace, or behind schedule.
  ///
  /// Returns:
  /// - "ahead" if consuming faster than expected
  /// - "on_pace" if within 10% of expected
  /// - "behind" if consuming slower than expected
  ///
  /// Example:
  /// ```dart
  /// // At 6pm (75% through day), consumed 1500/2000 cal (75%)
  /// final status = ProgressCalculator.getPaceStatus(
  ///   actualProgress: 0.75,
  ///   expectedProgress: 0.75,
  /// );
  /// // Returns: "on_pace"
  /// ```
  static String getPaceStatus({
    required double actualProgress,
    required double expectedProgress,
  }) {
    // Within 10% tolerance is considered "on pace"
    const tolerance = 0.1;

    if (actualProgress > expectedProgress + tolerance) {
      return 'ahead';
    } else if (actualProgress < expectedProgress - tolerance) {
      return 'behind';
    } else {
      return 'on_pace';
    }
  }

  /// Calculate progress percentage as an integer (0-100)
  ///
  /// Useful for UI display where you want "75%" instead of "0.75".
  ///
  /// Example:
  /// ```dart
  /// final percent = ProgressCalculator.calculateProgressPercent(
  ///   consumed: 1500.0,
  ///   target: 2000.0,
  /// );
  /// // Returns: 75
  /// ```
  static int calculateProgressPercent({
    required double consumed,
    required double target,
  }) {
    final progress = calculateProgress(consumed: consumed, target: target);
    return (progress * 100).round();
  }

  /// Format progress as percentage string
  ///
  /// Example:
  /// ```dart
  /// final formatted = ProgressCalculator.formatProgress(0.75);
  /// // Returns: "75%"
  /// ```
  static String formatProgress(double progress) {
    final percent = (progress * 100).round();
    return '$percent%';
  }

  /// Check if two dates are the same day
  ///
  /// Helper method to compare dates ignoring time.
  static bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Calculate average daily progress over multiple days
  ///
  /// Takes a list of daily progress values and returns the average.
  ///
  /// Example:
  /// ```dart
  /// final avg = ProgressCalculator.calculateAverageDailyProgress([
  ///   0.75,  // Day 1: 75%
  ///   0.80,  // Day 2: 80%
  ///   0.70,  // Day 3: 70%
  /// ]);
  /// // Returns: 0.75 (average 75%)
  /// ```
  static double calculateAverageDailyProgress(List<double> dailyProgress) {
    if (dailyProgress.isEmpty) return 0.0;

    final sum = dailyProgress.reduce((a, b) => a + b);
    return sum / dailyProgress.length;
  }

  /// Get progress color indicator
  ///
  /// Returns a color status based on progress:
  /// - "green" if on track (70-110%)
  /// - "yellow" if slightly off (50-70% or 110-130%)
  /// - "red" if significantly off (<50% or >130%)
  ///
  /// Example:
  /// ```dart
  /// final color = ProgressCalculator.getProgressColor(0.75);
  /// // Returns: "green"
  /// ```
  static String getProgressColor(double progress) {
    if (progress < 0.5) {
      return 'red'; // Way under
    } else if (progress < 0.7) {
      return 'yellow'; // Slightly under
    } else if (progress <= 1.1) {
      return 'green'; // On track or slightly over
    } else if (progress <= 1.3) {
      return 'yellow'; // Moderately over
    } else {
      return 'red'; // Way over
    }
  }

  /// Calculate completion status
  ///
  /// Returns a descriptive status:
  /// - "not_started" if 0%
  /// - "in_progress" if 0-100%
  /// - "completed" if 100%
  /// - "exceeded" if >100%
  ///
  /// Example:
  /// ```dart
  /// final status = ProgressCalculator.getCompletionStatus(0.75);
  /// // Returns: "in_progress"
  /// ```
  static String getCompletionStatus(double progress) {
    if (progress <= 0) {
      return 'not_started';
    } else if (progress < 1.0) {
      return 'in_progress';
    } else if (progress == 1.0) {
      return 'completed';
    } else {
      return 'exceeded';
    }
  }
}
