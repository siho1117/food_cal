// lib/utils/summary_data_calculator.dart
import 'package:intl/intl.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import '../../widgets/summary/summary_controls_widget.dart';

class SummaryDataCalculator {
  // Private constructor to prevent instantiation
  SummaryDataCalculator._();

  /// Calculate key metrics for the top row display
  static Future<Map<String, String>> calculateKeyMetrics(
    SummaryPeriod period,
    HomeProvider homeProvider,
    ExerciseProvider exerciseProvider,
  ) async {
    if (period == SummaryPeriod.daily) {
      // Daily: Use current day's data
      final consumedProtein = homeProvider.consumedMacros['protein'] ?? 0.0;

      return {
        'calories': homeProvider.totalCalories.toString(),
        'protein': '${consumedProtein.round()}g',
        'exercise': '${exerciseProvider.totalCaloriesBurned} cal',
      };
    } else if (period == SummaryPeriod.weekly) {
      // Weekly: Aggregate last 7 days
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 6));

      // Get food entries for the week
      final foodEntries = await homeProvider.getFoodEntriesForRange(startDate, now);

      // Calculate total calories and protein
      int totalCalories = 0;
      double totalProtein = 0.0;

      for (final item in foodEntries) {
        final nutrition = item.getNutritionForServing();
        totalCalories += (nutrition['calories'] ?? 0).round();
        totalProtein += nutrition['proteins'] ?? 0;
      }

      // Get exercise data for the week
      final exerciseEntries = await exerciseProvider.getExerciseEntriesForDateRange(startDate, now);
      int totalExerciseCalories = 0;

      for (final dayEntries in exerciseEntries.values) {
        for (final exercise in dayEntries) {
          totalExerciseCalories += exercise.caloriesBurned;
        }
      }

      // Calculate daily averages
      final avgCalories = (totalCalories / 7).round();
      final avgProtein = (totalProtein / 7).round();
      final avgExercise = (totalExerciseCalories / 7).round();

      return {
        'calories': '$totalCalories ($avgCalories/day)',
        'protein': '${totalProtein.round()}g (${avgProtein}g/day)',
        'exercise': '$totalExerciseCalories cal ($avgExercise/day)',
      };
    } else {
      // Monthly: Will be implemented later
      final consumedProtein = homeProvider.consumedMacros['protein'] ?? 0.0;

      return {
        'calories': homeProvider.totalCalories.toString(),
        'protein': '${consumedProtein.round()}g',
        'exercise': '${exerciseProvider.totalCaloriesBurned} cal',
      };
    }
  }

  /// Calculate progress data for status display
  static Map<String, dynamic> calculateProgressData(
    SummaryPeriod period,
    HomeProvider homeProvider,
    ExerciseProvider exerciseProvider,
  ) {
    final calorieProgress = homeProvider.calorieProgress;
    final exerciseProgress = exerciseProvider.burnProgress;

    String status;
    String message;

    // Determine overall status based on calorie and exercise goals
    if (calorieProgress >= 0.9 && calorieProgress <= 1.1 && exerciseProgress >= 0.8) {
      status = 'on_track';
      message = 'Great job! You\'re on track with your nutrition and exercise goals.';
    } else if (calorieProgress > 1.1) {
      status = 'over';
      message = 'You\'ve exceeded your calorie goal. Consider more exercise or adjusting your intake.';
    } else {
      status = 'under';
      message = 'You\'re below your goals. Make sure you\'re eating enough and staying active.';
    }

    return {
      'status': status,
      'message': message,
    };
  }

  /// Calculate nutrition breakdown data
  static Map<String, String> calculateNutritionData(
    HomeProvider homeProvider,
  ) {
    final consumed = homeProvider.consumedMacros;
    final targets = homeProvider.targetMacros;

    return {
      'protein': '${consumed['protein']?.round() ?? 0}g / ${targets['protein']?.round() ?? 0}g',
      'carbs': '${consumed['carbs']?.round() ?? 0}g / ${targets['carbs']?.round() ?? 0}g',
      'fat': '${consumed['fat']?.round() ?? 0}g / ${targets['fat']?.round() ?? 0}g',
    };
  }

  /// Calculate exercise breakdown data
  static Map<String, dynamic> calculateExerciseData(
    SummaryPeriod period,
    ExerciseProvider exerciseProvider,
  ) {
    final exercises = exerciseProvider.exerciseEntries;
    
    return {
      'exercises': exercises,
      'totalTime': getTotalExerciseTime(exercises),
      'isEmpty': exercises.isEmpty,
      'displayCount': exercises.length > 3 ? 3 : exercises.length,
      'extraCount': exercises.length > 3 ? exercises.length - 3 : 0,
      'periodName': period.name,
    };
  }

  /// Calculate summary statistics
  static Map<String, String> calculateSummaryStats(
    HomeProvider homeProvider,
    ExerciseProvider exerciseProvider,
  ) {
    return {
      'mealsLogged': homeProvider.foodEntriesCount.toString(),
      'avgPerMeal': homeProvider.foodEntriesCount > 0
          ? '\$${(homeProvider.totalFoodCost / homeProvider.foodEntriesCount).toStringAsFixed(2)}'
          : '\$0.00',
      'netCalories': (homeProvider.totalCalories - exerciseProvider.totalCaloriesBurned).toString(),
      'exerciseDuration': getTotalExerciseTime(exerciseProvider.exerciseEntries),
    };
  }

  /// Get total exercise time formatted as string
  static String getTotalExerciseTime(List<ExerciseEntry> exercises) {
    final totalMinutes = exercises.fold<int>(
      0,
      (sum, exercise) => sum + exercise.duration,
    );
    
    if (totalMinutes < 60) {
      return '$totalMinutes min';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  /// Format date for display (localized)
  /// Uses intl package for proper internationalization
  /// Examples:
  /// - en_US: "Dec 19, 25"
  /// - zh_CN: "25年12月19日"
  /// - ja_JP: "25年12月19日"
  static String formatDate(DateTime date, [String? locale]) {
    // Use yy for 2-digit year instead of yyyy (4-digit)
    final formatter = DateFormat('MMM d, yy', locale);
    return formatter.format(date);
  }

  /// Format month for display (localized)
  /// Examples:
  /// - en_US: "December 2025"
  /// - zh_CN: "2025年12月"
  /// - ja_JP: "2025年12月"
  static String formatMonth(DateTime date, [String? locale]) {
    return DateFormat.yMMMM(locale).format(date);
  }

  /// Get period display title
  static String getPeriodTitle(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'DAILY SUMMARY';
      case SummaryPeriod.weekly:
        return '7-DAY SUMMARY';
      case SummaryPeriod.monthly:
        return 'MONTHLY SUMMARY';
    }
  }

  /// Get period subtitle with date range (localized)
  static String getPeriodSubtitle(SummaryPeriod period, [String? locale]) {
    final now = DateTime.now();

    switch (period) {
      case SummaryPeriod.daily:
        return formatDate(now, locale);
      case SummaryPeriod.weekly:
        // Last 7 days (rolling window)
        final startDate = now.subtract(const Duration(days: 6));
        return 'Last 7 Days: ${formatDate(startDate, locale)} - ${formatDate(now, locale)}';
      case SummaryPeriod.monthly:
        return formatMonth(now, locale);
    }
  }

  /// Get empty exercise message
  static String getEmptyExerciseMessage(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'No exercises logged today';
      case SummaryPeriod.weekly:
        return 'No exercises logged this week';
      case SummaryPeriod.monthly:
        return 'No exercises logged this month';
    }
  }

  /// Get stats section title
  static String getStatsTitle(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'DAILY STATS';
      case SummaryPeriod.weekly:
        return 'WEEKLY STATS';
      case SummaryPeriod.monthly:
        return 'MONTHLY STATS';
    }
  }
}