// lib/utils/cost_calculator.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/food_repository.dart';
import '../../data/models/food_item.dart';

/// Utility class for calculating food costs over different time ranges
///
/// This calculator properly queries ALL food entries across date ranges,
/// not just the currently selected date, to provide accurate cost summaries.
class CostCalculator {
  // Private constructor to prevent instantiation
  CostCalculator._();

  /// Calculate total cost for a specific date range
  ///
  /// Example:
  /// ```dart
  /// final cost = await CostCalculator.calculateCostForDateRange(
  ///   repository: foodRepository,
  ///   startDate: DateTime(2024, 1, 1),
  ///   endDate: DateTime(2024, 1, 7),
  /// );
  /// // Returns: 125.50 (total spent from Jan 1-7)
  /// ```
  static Future<double> calculateCostForDateRange({
    required FoodRepository repository,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      // Query ALL food entries in the date range (not just selected date!)
      final entries = await repository.getFoodEntriesForDateRange(startDate, endDate);

      double total = 0.0;
      for (final item in entries) {
        final cost = item.getCostForServing();
        if (cost != null && cost > 0) {
          total += cost;
        }
      }

      return total;
    } catch (e) {
      debugPrint('Error calculating cost for date range: $e');
      return 0.0;
    }
  }

  /// Calculate total cost for the current week (Monday to today)
  ///
  /// Example:
  /// ```dart
  /// final weeklyCost = await CostCalculator.calculateWeeklyCost(foodRepository);
  /// // Returns: 87.50 (spent this week so far)
  /// ```
  static Future<double> calculateWeeklyCost(FoodRepository repository) async {
    final now = DateTime.now();
    final startOfWeek = _getStartOfWeek(now);

    return calculateCostForDateRange(
      repository: repository,
      startDate: startOfWeek,
      endDate: now,
    );
  }

  /// Calculate total cost for the current month (1st to today)
  ///
  /// Example:
  /// ```dart
  /// final monthlyCost = await CostCalculator.calculateMonthlyCost(foodRepository);
  /// // Returns: 342.75 (spent this month so far)
  /// ```
  static Future<double> calculateMonthlyCost(FoodRepository repository) async {
    final now = DateTime.now();
    final startOfMonth = _getStartOfMonth(now);

    return calculateCostForDateRange(
      repository: repository,
      startDate: startOfMonth,
      endDate: now,
    );
  }

  /// Calculate total cost for a specific day
  ///
  /// Useful for getting daily totals without filtering from a list.
  ///
  /// Example:
  /// ```dart
  /// final dailyCost = await CostCalculator.calculateDailyCost(
  ///   repository: foodRepository,
  ///   date: DateTime(2024, 11, 7),
  /// );
  /// // Returns: 18.50 (spent on Nov 7)
  /// ```
  static Future<double> calculateDailyCost({
    required FoodRepository repository,
    required DateTime date,
  }) async {
    try {
      final entries = await repository.getFoodEntriesForDate(date);

      double total = 0.0;
      for (final item in entries) {
        final cost = item.getCostForServing();
        if (cost != null && cost > 0) {
          total += cost;
        }
      }

      return total;
    } catch (e) {
      debugPrint('Error calculating daily cost: $e');
      return 0.0;
    }
  }

  /// Calculate total cost from a list of food items
  ///
  /// This is useful when you already have a list of entries in memory
  /// and don't need to query the repository.
  ///
  /// Example:
  /// ```dart
  /// final cost = CostCalculator.calculateCostFromList(foodEntries);
  /// // Returns: 23.50
  /// ```
  static double calculateCostFromList(List<FoodItem> items) {
    double total = 0.0;

    for (final item in items) {
      final cost = item.getCostForServing();
      if (cost != null && cost > 0) {
        total += cost;
      }
    }

    return total;
  }

  /// Get the start of the week (Monday) for a given date
  ///
  /// Example: If today is Wednesday Nov 7, returns Monday Nov 5
  static DateTime _getStartOfWeek(DateTime date) {
    // weekday: 1 = Monday, 7 = Sunday
    final daysToSubtract = date.weekday - 1;
    return DateTime(date.year, date.month, date.day).subtract(
      Duration(days: daysToSubtract),
    );
  }

  /// Get the start of the month (1st day) for a given date
  ///
  /// Example: If today is Nov 7, returns Nov 1
  static DateTime _getStartOfMonth(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }

  /// Format cost as currency string
  ///
  /// Example:
  /// ```dart
  /// CostCalculator.formatCost(18.5);  // Returns: "$18.50"
  /// CostCalculator.formatCost(0);     // Returns: "$0.00"
  /// ```
  static String formatCost(double cost) {
    return '\$${cost.toStringAsFixed(2)}';
  }

  /// Get cost statistics for a date range
  ///
  /// Returns a map with useful statistics:
  /// - total: Total cost
  /// - average: Average daily cost
  /// - days: Number of days in range
  /// - entries: Number of food entries
  ///
  /// Example:
  /// ```dart
  /// final stats = await CostCalculator.getCostStatistics(
  ///   repository: foodRepository,
  ///   startDate: DateTime(2024, 11, 1),
  ///   endDate: DateTime(2024, 11, 7),
  /// );
  /// // Returns: {
  /// //   'total': 87.50,
  /// //   'average': 12.50,
  /// //   'days': 7,
  /// //   'entries': 21
  /// // }
  /// ```
  static Future<Map<String, dynamic>> getCostStatistics({
    required FoodRepository repository,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final entries = await repository.getFoodEntriesForDateRange(startDate, endDate);

      double total = 0.0;
      int entriesWithCost = 0;

      for (final item in entries) {
        final cost = item.getCostForServing();
        if (cost != null && cost > 0) {
          total += cost;
          entriesWithCost++;
        }
      }

      // Calculate number of days in range
      final days = endDate.difference(startDate).inDays + 1;
      final averageDailyCost = days > 0 ? total / days : 0.0;

      return {
        'total': total,
        'average': averageDailyCost,
        'days': days,
        'entries': entries.length,
        'entries_with_cost': entriesWithCost,
      };
    } catch (e) {
      debugPrint('Error getting cost statistics: $e');
      return {
        'total': 0.0,
        'average': 0.0,
        'days': 0,
        'entries': 0,
        'entries_with_cost': 0,
      };
    }
  }
}
