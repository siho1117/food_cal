// lib/utils/calorie_estimator.dart

/// MET-based calorie estimation for exercise activities.
/// 
/// Formula: kcal = MET × 3.5 × weight_kg / 200 × minutes
/// 
/// This is the standard exercise physiology formula used by fitness apps
/// and based on the Compendium of Physical Activities.
class CalorieEstimator {
  CalorieEstimator._(); // Private constructor - utility class

  /// Default weight used when user weight is unknown (kg)
  static const double defaultWeightKg = 70.0;

  /// Minimum/maximum bounds for safety
  static const int minMinutes = 1;
  static const int maxMinutes = 300; // 5 hours
  static const double minWeightKg = 30.0;
  static const double maxWeightKg = 250.0;

  /// Calculate calories burned for an exercise
  /// 
  /// Returns estimated calories as an integer.
  /// Automatically clamps inputs to safe ranges.
  static int estimate({
    required String exerciseName,
    required String intensity,
    required int minutes,
    double? userWeightKg,
  }) {
    // Clamp inputs to safe ranges
    final safeMins = minutes.clamp(minMinutes, maxMinutes);
    final safeWeight = (userWeightKg ?? defaultWeightKg).clamp(minWeightKg, maxWeightKg);

    // Get MET value for this exercise and intensity
    final met = _getMetValue(exerciseName, intensity);

    // Standard formula: MET × 3.5 × weight / 200 × minutes
    final kcal = met * 3.5 * safeWeight / 200.0 * safeMins;

    return kcal.round();
  }

  /// Get MET value based on exercise type and intensity
  /// 
  /// MET values are from the Compendium of Physical Activities
  /// and represent metabolic equivalents (multiples of resting metabolism).
  static double _getMetValue(String exerciseName, String intensity) {
    final exercise = exerciseName.toLowerCase().trim();
    final level = intensity.toLowerCase().trim();

    // Determine exercise type
    if (exercise.contains('run')) {
      return _getRunningMet(level);
    } else if (exercise.contains('walk')) {
      return _getWalkingMet(level);
    } else if (exercise.contains('cycl') || exercise.contains('bike')) {
      return _getCyclingMet(level);
    } else if (exercise.contains('swim')) {
      return _getSwimmingMet(level);
    } else if (exercise.contains('weight') || exercise.contains('strength')) {
      return _getWeightTrainingMet(level);
    } else if (exercise.contains('yoga')) {
      return _getYogaMet(level);
    } else {
      // Unknown exercise - use moderate default
      return 5.0;
    }
  }

  /// Running MET values
  /// Light: ~8 km/h, Moderate: ~10 km/h, Intense: ~12 km/h
  static double _getRunningMet(String intensity) {
    if (intensity.startsWith('light')) return 8.3;
    if (intensity.startsWith('moder')) return 10.0;
    return 12.5; // intense
  }

  /// Walking MET values
  /// Light: ~4 km/h, Moderate: ~5 km/h, Intense: ~6.5 km/h
  static double _getWalkingMet(String intensity) {
    if (intensity.startsWith('light')) return 3.3;
    if (intensity.startsWith('moder')) return 4.0;
    return 5.0; // intense
  }

  /// Cycling MET values
  /// Light: ~15 km/h, Moderate: ~20 km/h, Intense: ~25 km/h
  static double _getCyclingMet(String intensity) {
    if (intensity.startsWith('light')) return 6.8;
    if (intensity.startsWith('moder')) return 8.0;
    return 10.5; // intense
  }

  /// Swimming MET values
  /// Light: leisure, Moderate: steady, Intense: vigorous
  static double _getSwimmingMet(String intensity) {
    if (intensity.startsWith('light')) return 6.0;
    if (intensity.startsWith('moder')) return 8.0;
    return 10.0; // intense
  }

  /// Weight Training MET values
  /// Light: light resistance, Moderate: general, Intense: heavy compound
  static double _getWeightTrainingMet(String intensity) {
    if (intensity.startsWith('light')) return 3.5;
    if (intensity.startsWith('moder')) return 5.0;
    return 6.0; // intense
  }

  /// Yoga MET values
  /// Light: gentle/yin, Moderate: hatha/vinyasa, Intense: power/ashtanga
  static double _getYogaMet(String intensity) {
    if (intensity.startsWith('light')) return 2.5;
    if (intensity.startsWith('moder')) return 3.0;
    return 4.0; // intense
  }
}