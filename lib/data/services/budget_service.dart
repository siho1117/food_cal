// lib/data/services/budget_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user's daily food budget
///
/// Handles loading and updating budget preferences, keeping budget
/// logic separate from the HomeProvider state management.
class BudgetService {
  // Singleton instance
  static final BudgetService _instance = BudgetService._internal();
  factory BudgetService() => _instance;
  BudgetService._internal();

  // Storage key for daily food budget
  static const String _budgetKey = 'daily_food_budget';

  // Default budget when none is set
  static const double _defaultBudget = 25.0;

  /// Get the user's daily food budget
  ///
  /// Returns the saved budget or default value ($25.00) if none is set.
  ///
  /// Example:
  /// ```dart
  /// final budget = await budgetService.getDailyBudget();
  /// // Returns: 25.0 (or saved value)
  /// ```
  Future<double> getDailyBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getDouble(_budgetKey) ?? _defaultBudget;
    } catch (e) {
      debugPrint('Error getting daily budget: $e');
      return _defaultBudget;
    }
  }

  /// Update the user's daily food budget
  ///
  /// Saves the new budget value to SharedPreferences.
  ///
  /// Example:
  /// ```dart
  /// await budgetService.updateDailyBudget(30.0);
  /// // Budget is now $30.00 per day
  /// ```
  ///
  /// Throws an exception if saving fails.
  Future<void> updateDailyBudget(double budget) async {
    try {
      // Validate budget value
      if (budget < 0) {
        throw ArgumentError('Budget cannot be negative');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_budgetKey, budget);
    } catch (e) {
      debugPrint('Error updating daily budget: $e');
      rethrow;
    }
  }

  /// Reset budget to default value
  ///
  /// Useful for resetting user preferences or during logout.
  ///
  /// Example:
  /// ```dart
  /// await budgetService.resetBudget();
  /// // Budget is now $25.00 (default)
  /// ```
  Future<void> resetBudget() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_budgetKey);
    } catch (e) {
      debugPrint('Error resetting budget: $e');
      rethrow;
    }
  }

  /// Check if a budget has been set by the user
  ///
  /// Returns true if user has customized their budget,
  /// false if they're using the default.
  ///
  /// Example:
  /// ```dart
  /// final hasCustomBudget = await budgetService.hasBudgetSet();
  /// if (!hasCustomBudget) {
  ///   // Show budget setup prompt
  /// }
  /// ```
  Future<bool> hasBudgetSet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.containsKey(_budgetKey);
    } catch (e) {
      debugPrint('Error checking if budget is set: $e');
      return false;
    }
  }

  /// Get the default budget value
  ///
  /// Useful for UI hints or reset confirmations.
  ///
  /// Example:
  /// ```dart
  /// final defaultBudget = BudgetService.getDefaultBudget();
  /// // Returns: 25.0
  /// ```
  static double getDefaultBudget() => _defaultBudget;

  /// Format budget as currency string
  ///
  /// Example:
  /// ```dart
  /// final formatted = BudgetService.formatBudget(25.0);
  /// // Returns: "$25.00"
  /// ```
  static String formatBudget(double budget) {
    return '\$${budget.toStringAsFixed(2)}';
  }

  /// Calculate remaining budget for the day
  ///
  /// Simple helper to compute budget - spent.
  ///
  /// Example:
  /// ```dart
  /// final remaining = BudgetService.calculateRemaining(
  ///   budget: 25.0,
  ///   spent: 18.50,
  /// );
  /// // Returns: 6.50
  /// ```
  static double calculateRemaining({
    required double budget,
    required double spent,
  }) {
    return (budget - spent).clamp(0.0, budget);
  }

  /// Calculate budget usage percentage
  ///
  /// Returns value between 0.0 (0%) and 1.0 (100%).
  ///
  /// Example:
  /// ```dart
  /// final progress = BudgetService.calculateProgress(
  ///   budget: 25.0,
  ///   spent: 18.50,
  /// );
  /// // Returns: 0.74 (74%)
  /// ```
  static double calculateProgress({
    required double budget,
    required double spent,
  }) {
    if (budget <= 0) return 0.0;
    return (spent / budget).clamp(0.0, 1.0);
  }

  /// Check if budget has been exceeded
  ///
  /// Example:
  /// ```dart
  /// final overBudget = BudgetService.isOverBudget(
  ///   budget: 25.0,
  ///   spent: 28.50,
  /// );
  /// // Returns: true
  /// ```
  static bool isOverBudget({
    required double budget,
    required double spent,
  }) {
    return spent > budget;
  }
}
