// lib/utils/summary_data_calculator.dart
import '../providers/home_provider.dart';
import '../providers/exercise_provider.dart';
import '../data/models/exercise_entry.dart';
import '../widgets/summary/summary_controls_widget.dart';

class SummaryDataCalculator {
  // Private constructor to prevent instantiation
  SummaryDataCalculator._();

  /// Calculate key metrics for the top row display
  static Map<String, String> calculateKeyMetrics(
    SummaryPeriod period,
    HomeProvider homeProvider,
    ExerciseProvider exerciseProvider,
  ) {
    // For now, show daily data for all periods to avoid misleading multiplication
    // TODO: Implement actual weekly/monthly data aggregation in providers
    return {
      'calories': homeProvider.totalCalories.toString(),
      'cost': '\$${homeProvider.totalFoodCost.toStringAsFixed(2)}',
      'burned': exerciseProvider.totalCaloriesBurned.toString(),
    };
  }

  /// Calculate progress data for progress bars
  static Map<String, Map<String, dynamic>> calculateProgressData(
    SummaryPeriod period,
    HomeProvider homeProvider,
    ExerciseProvider exerciseProvider,
  ) {
    return {
      'calories': {
        'label': 'Calories Consumed',
        'value': homeProvider.totalCalories.toDouble(),
        'target': homeProvider.calorieGoal.toDouble(),
        'progress': homeProvider.calorieProgress,
        'unit': '',
      },
      'exercise': {
        'label': 'Exercise Burned',
        'value': exerciseProvider.totalCaloriesBurned.toDouble(),
        'target': exerciseProvider.dailyBurnGoal.toDouble(),
        'progress': exerciseProvider.burnProgress,
        'unit': '',
      },
      'budget': {
        'label': 'Budget',
        'value': homeProvider.totalFoodCost,
        'target': homeProvider.dailyFoodBudget,
        'progress': homeProvider.budgetProgress,
        'unit': '\$',
      },
    };
  }

  /// Calculate nutrition breakdown data
  static Map<String, Map<String, dynamic>> calculateNutritionData(
    HomeProvider homeProvider,
  ) {
    final consumed = homeProvider.consumedMacros;
    final targets = homeProvider.targetMacros;

    return {
      'protein': {
        'icon': '🍳',
        'name': 'Protein',
        'consumed': consumed['protein']!.round(),
        'target': targets['protein']!,
        'progress': targets['protein']! > 0 
            ? (consumed['protein']! / targets['protein']!).clamp(0.0, 1.0) 
            : 0.0,
      },
      'carbs': {
        'icon': '🍞',
        'name': 'Carbs',
        'consumed': consumed['carbs']!.round(),
        'target': targets['carbs']!,
        'progress': targets['carbs']! > 0 
            ? (consumed['carbs']! / targets['carbs']!).clamp(0.0, 1.0) 
            : 0.0,
      },
      'fat': {
        'icon': '🥑',
        'name': 'Fat',
        'consumed': consumed['fat']!.round(),
        'target': targets['fat']!,
        'progress': targets['fat']! > 0 
            ? (consumed['fat']! / targets['fat']!).clamp(0.0, 1.0) 
            : 0.0,
      },
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
      'mealsLogged': homeProvider.mealsCount.toString(),
      'avgPerMeal': homeProvider.mealsCount > 0 
          ? '\$${(homeProvider.totalFoodCost / homeProvider.mealsCount).toStringAsFixed(2)}'
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

  /// Format date for display
  static String formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format month for display
  static String formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  /// Get period display title
  static String getPeriodTitle(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'DAILY SUMMARY';
      case SummaryPeriod.weekly:
        return 'WEEKLY SUMMARY';
      case SummaryPeriod.monthly:
        return 'MONTHLY SUMMARY';
    }
  }

  /// Get period subtitle with date range
  static String getPeriodSubtitle(SummaryPeriod period) {
    final now = DateTime.now();
    
    switch (period) {
      case SummaryPeriod.daily:
        return formatDate(now);
      case SummaryPeriod.weekly:
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        return '${formatDate(startOfWeek)} - ${formatDate(endOfWeek)}';
      case SummaryPeriod.monthly:
        return formatMonth(now);
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