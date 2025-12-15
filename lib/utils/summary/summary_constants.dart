// lib/utils/summary/summary_constants.dart

/// Constants used throughout the summary section
class SummaryConstants {
  SummaryConstants._(); // Private constructor to prevent instantiation

  // Period calculations
  static const int daysInWeek = 7;
  static const int daysInMonth = 30;

  // Weight conversions
  static const double kgToLbsRatio = 2.20462;

  // Export settings
  static const double screenshotPixelRatio = 3.0;
  static const Duration imagePreloadDelay = Duration(milliseconds: 300);

  // UI timing
  static const Duration exportSnackbarDuration = Duration(seconds: 2);
  static const Duration errorSnackbarDuration = Duration(seconds: 3);
}
