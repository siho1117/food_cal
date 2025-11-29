// lib/data/services/exercise_bonus_service.dart
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing exercise calorie bonus preferences
///
/// Handles the toggle state for the exercise calorie rollover feature,
/// which allows users to earn bonus calories based on excess exercise.
class ExerciseBonusService {
  // Singleton instance
  static final ExerciseBonusService _instance = ExerciseBonusService._internal();
  factory ExerciseBonusService() => _instance;
  ExerciseBonusService._internal();

  // Storage key for exercise bonus enabled state
  static const String _enabledKey = 'exercise_bonus_enabled';

  // Default state (OFF by default - conservative, opt-in)
  static const bool _defaultEnabled = false;

  /// Get the exercise bonus enabled state
  ///
  /// Returns true if the user has enabled the exercise calorie bonus feature,
  /// false otherwise (default is false - opt-in required).
  ///
  /// Example:
  /// ```dart
  /// final isEnabled = await exerciseBonusService.isEnabled();
  /// // Returns: false (or saved value)
  /// ```
  Future<bool> isEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_enabledKey) ?? _defaultEnabled;
    } catch (e) {
      debugPrint('Error getting exercise bonus enabled state: $e');
      return _defaultEnabled;
    }
  }

  /// Update the exercise bonus enabled state
  ///
  /// Saves the new enabled/disabled state to SharedPreferences.
  ///
  /// Example:
  /// ```dart
  /// await exerciseBonusService.setEnabled(true);
  /// // Exercise bonus is now enabled
  /// ```
  ///
  /// Throws an exception if saving fails.
  Future<void> setEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_enabledKey, enabled);
      debugPrint('Exercise bonus ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      debugPrint('Error updating exercise bonus enabled state: $e');
      rethrow;
    }
  }

  /// Toggle the exercise bonus enabled state
  ///
  /// Convenience method that flips the current state.
  /// Returns the new state after toggling.
  ///
  /// Example:
  /// ```dart
  /// final newState = await exerciseBonusService.toggle();
  /// // Returns: true if now enabled, false if now disabled
  /// ```
  Future<bool> toggle() async {
    final currentState = await isEnabled();
    final newState = !currentState;
    await setEnabled(newState);
    return newState;
  }

  /// Reset to default state (disabled)
  ///
  /// Useful for resetting user preferences or during logout.
  ///
  /// Example:
  /// ```dart
  /// await exerciseBonusService.reset();
  /// // Exercise bonus is now disabled (default)
  /// ```
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_enabledKey);
    } catch (e) {
      debugPrint('Error resetting exercise bonus state: $e');
      rethrow;
    }
  }

  /// Get the default enabled state
  ///
  /// Returns the default state for the feature (false - disabled by default).
  ///
  /// Example:
  /// ```dart
  /// final defaultState = ExerciseBonusService.getDefaultEnabled();
  /// // Returns: false
  /// ```
  static bool getDefaultEnabled() => _defaultEnabled;
}
