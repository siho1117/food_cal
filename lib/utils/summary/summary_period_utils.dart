// lib/utils/summary/summary_period_utils.dart
import '../../widgets/summary/summary_controls_widget.dart';
import 'summary_constants.dart';

/// Utility functions for working with summary periods
class SummaryPeriodUtils {
  SummaryPeriodUtils._(); // Private constructor to prevent instantiation

  /// Get the number of days for a given period
  /// Returns 1 for daily, 7 for weekly, 30 for monthly
  static int getPeriodDays(SummaryPeriod? period) {
    if (period == null) return 1;

    switch (period) {
      case SummaryPeriod.daily:
        return 1;
      case SummaryPeriod.weekly:
        return SummaryConstants.daysInWeek;
      case SummaryPeriod.monthly:
        return SummaryConstants.daysInMonth;
    }
  }

  /// Calculate the start date for a given period from now
  static DateTime getStartDateForPeriod(SummaryPeriod period) {
    final now = DateTime.now();

    switch (period) {
      case SummaryPeriod.daily:
        return now;
      case SummaryPeriod.weekly:
        // Last 7 days (including today)
        return now.subtract(Duration(days: SummaryConstants.daysInWeek - 1));
      case SummaryPeriod.monthly:
        // Last 30 days (including today)
        return now.subtract(Duration(days: SummaryConstants.daysInMonth - 1));
    }
  }

  /// Safe division helper that returns 0 if denominator is 0
  static double safeDivide(num numerator, num denominator) {
    if (denominator == 0) return 0.0;
    return numerator / denominator;
  }

  /// Safe division that returns 0 if denominator is 0, otherwise returns rounded int
  static int safeDivideInt(num numerator, num denominator) {
    if (denominator == 0) return 0;
    return (numerator / denominator).round();
  }
}
