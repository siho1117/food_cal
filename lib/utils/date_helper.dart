// lib/utils/date_helper.dart

/// Utility class for date-related operations and formatting
///
/// Provides consistent date handling across the app, including
/// date comparisons, relative date formatting, and date utilities.
class DateHelper {
  // Private constructor to prevent instantiation
  DateHelper._();

  /// Check if two dates are the same day (ignoring time)
  ///
  /// Compares year, month, and day only, ignoring hours/minutes/seconds.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 11, 7, 10, 30);
  /// final date2 = DateTime(2024, 11, 7, 15, 45);
  /// final isSame = DateHelper.isSameDay(date1, date2);
  /// // Returns: true (same day, different times)
  /// ```
  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
           date1.month == date2.month &&
           date1.day == date2.day;
  }

  /// Check if a date is today
  ///
  /// Example:
  /// ```dart
  /// final isToday = DateHelper.isToday(DateTime.now());
  /// // Returns: true
  /// ```
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }

  /// Check if a date is yesterday
  ///
  /// Example:
  /// ```dart
  /// final yesterday = DateTime.now().subtract(Duration(days: 1));
  /// final isYesterday = DateHelper.isYesterday(yesterday);
  /// // Returns: true
  /// ```
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }

  /// Check if a date is tomorrow
  ///
  /// Example:
  /// ```dart
  /// final tomorrow = DateTime.now().add(Duration(days: 1));
  /// final isTomorrow = DateHelper.isTomorrow(tomorrow);
  /// // Returns: true
  /// ```
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return isSameDay(date, tomorrow);
  }

  /// Check if a date is in the future (excluding today)
  ///
  /// Example:
  /// ```dart
  /// final future = DateTime.now().add(Duration(days: 2));
  /// final isFuture = DateHelper.isFutureDate(future);
  /// // Returns: true
  /// ```
  static bool isFutureDate(DateTime date) {
    return date.isAfter(DateTime.now()) && !isToday(date);
  }

  /// Check if a date is in the past (excluding today)
  ///
  /// Example:
  /// ```dart
  /// final past = DateTime.now().subtract(Duration(days: 2));
  /// final isPast = DateHelper.isPastDate(past);
  /// // Returns: true
  /// ```
  static bool isPastDate(DateTime date) {
    return date.isBefore(DateTime.now()) && !isToday(date);
  }

  /// Format date as relative string (Today, Yesterday, Tomorrow, or formatted)
  ///
  /// Returns human-readable strings like:
  /// - "Today"
  /// - "Yesterday"
  /// - "Tomorrow"
  /// - "Mon, Nov 7" (for other dates)
  ///
  /// Example:
  /// ```dart
  /// final formatted = DateHelper.formatRelativeDate(DateTime.now());
  /// // Returns: "Today"
  /// ```
  static String formatRelativeDate(DateTime date) {
    if (isToday(date)) return 'Today';
    if (isYesterday(date)) return 'Yesterday';
    if (isTomorrow(date)) return 'Tomorrow';

    // Format as "Mon, Nov 7"
    return _formatCustomDate(date);
  }

  /// Format date as custom "Weekday, Month Day" string
  ///
  /// Example: "Mon, Nov 7"
  ///
  /// Note: This uses hardcoded English strings. For proper i18n,
  /// consider using the intl package with AppLocalizations.
  static String _formatCustomDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    final day = date.day;

    return '$weekday, $month $day';
  }

  /// Get start of day (00:00:00) for a given date
  ///
  /// Useful for date range queries.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 11, 7, 15, 30);
  /// final startOfDay = DateHelper.getStartOfDay(date);
  /// // Returns: DateTime(2024, 11, 7, 0, 0, 0)
  /// ```
  static DateTime getStartOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get end of day (23:59:59.999) for a given date
  ///
  /// Useful for date range queries.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 11, 7, 15, 30);
  /// final endOfDay = DateHelper.getEndOfDay(date);
  /// // Returns: DateTime(2024, 11, 7, 23, 59, 59, 999)
  /// ```
  static DateTime getEndOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999);
  }

  /// Get start of week (Monday) for a given date
  ///
  /// Example:
  /// ```dart
  /// // If today is Wednesday Nov 7
  /// final startOfWeek = DateHelper.getStartOfWeek(DateTime.now());
  /// // Returns: Monday Nov 5
  /// ```
  static DateTime getStartOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysToSubtract = date.weekday - 1;
    return getStartOfDay(date).subtract(Duration(days: daysToSubtract));
  }

  /// Get end of week (Sunday) for a given date
  ///
  /// Example:
  /// ```dart
  /// // If today is Wednesday Nov 7
  /// final endOfWeek = DateHelper.getEndOfWeek(DateTime.now());
  /// // Returns: Sunday Nov 11 (23:59:59)
  /// ```
  static DateTime getEndOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysToAdd = 7 - date.weekday;
    return getEndOfDay(date).add(Duration(days: daysToAdd));
  }

  /// Get start of month (1st day) for a given date
  ///
  /// Example:
  /// ```dart
  /// // If today is Nov 7
  /// final startOfMonth = DateHelper.getStartOfMonth(DateTime.now());
  /// // Returns: Nov 1 (00:00:00)
  /// ```
  static DateTime getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Get end of month (last day) for a given date
  ///
  /// Example:
  /// ```dart
  /// // If today is Nov 7
  /// final endOfMonth = DateHelper.getEndOfMonth(DateTime.now());
  /// // Returns: Nov 30 (23:59:59)
  /// ```
  static DateTime getEndOfMonth(DateTime date) {
    // Get first day of next month, then subtract 1 day
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return getEndOfDay(nextMonth.subtract(const Duration(days: 1)));
  }

  /// Get number of days between two dates
  ///
  /// Returns the absolute difference in days.
  ///
  /// Example:
  /// ```dart
  /// final date1 = DateTime(2024, 11, 1);
  /// final date2 = DateTime(2024, 11, 7);
  /// final days = DateHelper.daysBetween(date1, date2);
  /// // Returns: 6
  /// ```
  static int daysBetween(DateTime date1, DateTime date2) {
    final start = getStartOfDay(date1);
    final end = getStartOfDay(date2);
    return end.difference(start).inDays.abs();
  }

  /// Check if a date is within a date range (inclusive)
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 11, 7);
  /// final start = DateTime(2024, 11, 1);
  /// final end = DateTime(2024, 11, 30);
  /// final isInRange = DateHelper.isInRange(date, start, end);
  /// // Returns: true
  /// ```
  static bool isInRange(DateTime date, DateTime startDate, DateTime endDate) {
    final dateOnly = getStartOfDay(date);
    final startOnly = getStartOfDay(startDate);
    final endOnly = getStartOfDay(endDate);

    return (dateOnly.isAfter(startOnly) || isSameDay(dateOnly, startOnly)) &&
           (dateOnly.isBefore(endOnly) || isSameDay(dateOnly, endOnly));
  }

  /// Get list of dates in a date range
  ///
  /// Returns a list of DateTime objects for each day in the range.
  ///
  /// Example:
  /// ```dart
  /// final start = DateTime(2024, 11, 1);
  /// final end = DateTime(2024, 11, 3);
  /// final dates = DateHelper.getDatesInRange(start, end);
  /// // Returns: [Nov 1, Nov 2, Nov 3]
  /// ```
  static List<DateTime> getDatesInRange(DateTime startDate, DateTime endDate) {
    final dates = <DateTime>[];
    var currentDate = getStartOfDay(startDate);
    final endDateOnly = getStartOfDay(endDate);

    while (currentDate.isBefore(endDateOnly) || isSameDay(currentDate, endDateOnly)) {
      dates.add(currentDate);
      currentDate = currentDate.add(const Duration(days: 1));
    }

    return dates;
  }

  /// Format date as ISO 8601 date string (YYYY-MM-DD)
  ///
  /// Useful for API calls or storage keys.
  ///
  /// Example:
  /// ```dart
  /// final date = DateTime(2024, 11, 7);
  /// final formatted = DateHelper.toIsoDateString(date);
  /// // Returns: "2024-11-07"
  /// ```
  static String toIsoDateString(DateTime date) {
    return date.toIso8601String().split('T')[0];
  }

  /// Parse ISO 8601 date string to DateTime
  ///
  /// Example:
  /// ```dart
  /// final date = DateHelper.fromIsoDateString("2024-11-07");
  /// // Returns: DateTime(2024, 11, 7)
  /// ```
  static DateTime? fromIsoDateString(String dateString) {
    try {
      return DateTime.parse(dateString);
    } catch (e) {
      return null;
    }
  }

  /// Get age from birth date
  ///
  /// Calculates current age in years.
  ///
  /// Example:
  /// ```dart
  /// final birthDate = DateTime(1990, 5, 15);
  /// final age = DateHelper.getAge(birthDate);
  /// // Returns: 34 (if current year is 2024)
  /// ```
  static int getAge(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Adjust if birthday hasn't occurred yet this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return age;
  }
}
