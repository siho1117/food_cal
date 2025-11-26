// lib/utils/health_metrics.dart
import '../../data/models/user_profile.dart';
import '../../data/models/weight_data.dart';

/// Centralized class for health and fitness metric calculations
///
/// Contains calculations for:
/// - Body composition (BMI, body fat percentage)
/// - Energy expenditure (BMR, TDEE)
/// - Weight progress tracking
/// - Calorie goals and recommendations
///
/// All methods are static to allow easy access without instantiation
class HealthMetrics {
  // Private constructor to prevent instantiation
  HealthMetrics._();

  // ============================================================================
  // BODY COMPOSITION METRICS
  // ============================================================================

  /// Calculate BMI using the standard formula: weight(kg) / height(m)²
  static double? calculateBMI({
    required double? height, // in cm
    required double? weight, // in kg
  }) {
    if (height == null || weight == null || height <= 0 || weight <= 0) {
      return null;
    }

    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  /// Get BMI classification based on standard ranges
  static String getBMIClassification(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Calculate body fat percentage using the Deurenberg formula
  /// Body Fat % = 1.2 × BMI + 0.23 × age - 10.8 × sex - 5.4
  /// Where sex is 1 for males and 0 for females
  ///
  /// IMPORTANT: This is an estimation with ±4-5% margin of error for Male/Female.
  /// For non-binary genders, uses midpoint (±7-10% margin of error).
  /// Requires BMI, age, and gender - returns null if any are missing.
  /// For more accurate results, consider methods using body measurements.
  static double? calculateBodyFat({
    required double? bmi,
    required int? age,
    required String? gender,
  }) {
    // Require all parameters
    if (bmi == null || age == null || gender == null) {
      return null;
    }

    // Gender factor for the formula
    double genderFactor;
    if (gender == 'Male') {
      genderFactor = 1.0;
    } else if (gender == 'Female') {
      genderFactor = 0.0;
    } else {
      // For non-binary genders (Other, Prefer not to say, etc.)
      // use midpoint between male and female formulas
      genderFactor = 0.5;
    }

    // Calculate using the formula
    double result =
        (1.2 * bmi) + (0.23 * age) - (10.8 * genderFactor) - 5.4;

    // Ensure result is in a reasonable range
    return result.clamp(3.0, 60.0);
  }

  /// Get body fat classification based on percentage and gender
  static String getBodyFatClassification(double bodyFat, String? gender) {
    if (gender == 'Male') {
      if (bodyFat < 6) return 'Essential';
      if (bodyFat < 14) return 'Athletic';
      if (bodyFat < 18) return 'Fitness';
      if (bodyFat < 25) return 'Average';
      if (bodyFat < 30) return 'Above Avg';
      return 'Obese';
    } else if (gender == 'Female') {
      if (bodyFat < 14) return 'Essential';
      if (bodyFat < 21) return 'Athletic';
      if (bodyFat < 25) return 'Fitness';
      if (bodyFat < 32) return 'Average';
      if (bodyFat < 38) return 'Above Avg';
      return 'Obese';
    } else {
      // Gender-neutral classifications
      if (bodyFat < 10) return 'Essential';
      if (bodyFat < 18) return 'Athletic';
      if (bodyFat < 22) return 'Fitness';
      if (bodyFat < 28) return 'Average';
      if (bodyFat < 35) return 'Above Avg';
      return 'Obese';
    }
  }

  // ============================================================================
  // ENERGY EXPENDITURE METRICS
  // ============================================================================

  /// Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
  ///
  /// BMR represents calories burned at rest per day.
  ///
  /// Male formula: (10 × weight) + (6.25 × height) - (5 × age) + 5
  /// Female formula: (10 × weight) + (6.25 × height) - (5 × age) - 161
  /// Non-binary: Average of male and female formulas
  static double? calculateBMR({
    required double? weight, // in kg
    required double? height, // in cm
    required int? age,
    required String? gender,
  }) {
    if (weight == null || height == null || age == null) {
      return null;
    }

    // Gender-specific BMR calculation
    if (gender == 'Male') {
      return (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else if (gender == 'Female') {
      return (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // For non-binary genders (Other, Prefer not to say, etc.)
    // use average of male and female formulas
    final maleBMR = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    final femaleBMR = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    return (maleBMR + femaleBMR) / 2;
  }

  /// Calculate TDEE (Total Daily Energy Expenditure) based on BMR and activity level
  static double? calculateTDEE({
    required double? bmr,
    required double? activityLevel,
  }) {
    if (bmr == null || activityLevel == null) {
      return null;
    }

    return bmr * activityLevel;
  }

  /// Get activity level description based on the multiplier
  static String getActivityLevelText(double? activityLevel) {
    if (activityLevel == null) {
      return 'Not set';
    }

    if (activityLevel < 1.3) return 'Sedentary';
    if (activityLevel < 1.45) return 'Light Activity';
    if (activityLevel < 1.65) return 'Moderate Activity';
    if (activityLevel < 1.8) return 'Active';
    return 'Very Active';
  }

  // ============================================================================
  // CALORIE GOALS & TARGETS
  // ============================================================================

  /// Calculate calorie targets for weight loss, maintenance, and gain
  static Map<String, int> getCalorieTargets(double? tdee) {
    if (tdee == null) {
      return {'lose': 0, 'maintain': 0, 'gain': 0};
    }

    final int maintain = tdee.round();
    final int lose = (maintain * 0.8).round(); // 20% deficit for weight loss
    final int gain = (maintain * 1.15).round(); // 15% surplus for weight gain

    return {'lose': lose, 'maintain': maintain, 'gain': gain};
  }

  /// Calculate average daily calorie needs based on goals
  static Map<String, int> calculateDailyCalorieNeeds({
    required UserProfile? profile,
    required double? currentWeight,
  }) {
    if (profile == null || currentWeight == null) {
      return {
        'maintenance': 0,
        'lose_slow': 0,
        'lose_medium': 0,
        'lose_fast': 0,
        'gain_slow': 0,
        'gain_medium': 0,
        'gain_fast': 0,
      };
    }

    // Calculate BMR
    final bmr = calculateBMR(
      weight: currentWeight,
      height: profile.height,
      age: profile.age,
      gender: profile.gender,
    );

    if (bmr == null || profile.activityLevel == null) {
      return {
        'maintenance': 0,
        'lose_slow': 0,
        'lose_medium': 0,
        'lose_fast': 0,
        'gain_slow': 0,
        'gain_medium': 0,
        'gain_fast': 0,
      };
    }

    // Calculate TDEE
    final tdee = bmr * profile.activityLevel!;
    final maintenance = tdee.round();

    // Calculate calorie targets for different goals
    return {
      'maintenance': maintenance,
      'lose_slow': (maintenance - 250).round(), // 0.25 kg/week loss
      'lose_medium': (maintenance - 500).round(), // 0.5 kg/week loss
      'lose_fast': (maintenance - 1000).round(), // 1 kg/week loss
      'gain_slow': (maintenance + 250).round(), // 0.25 kg/week gain
      'gain_medium': (maintenance + 500).round(), // 0.5 kg/week gain
      'gain_fast': (maintenance + 1000).round(), // 1 kg/week gain
    };
  }

  // ============================================================================
  // WEIGHT PROGRESS TRACKING
  // ============================================================================

  /// Calculate progress percentage toward goal weight
  static double calculateGoalProgress({
    required double? currentWeight,
    required double? targetWeight,
  }) {
    if (currentWeight == null || targetWeight == null) {
      return 0.0;
    }

    // If target equals current, return 100%
    if ((targetWeight - currentWeight).abs() < 0.1) {
      return 1.0;
    }

    // If losing weight
    if (currentWeight > targetWeight) {
      // Assume starting point was 20% higher than target
      final startWeight = targetWeight * 1.2;
      final totalToLose = startWeight - targetWeight;
      final lost = startWeight - currentWeight;

      return (lost / totalToLose).clamp(0.0, 1.0);
    }
    // If gaining weight
    else {
      // Assume starting point was 20% lower than target
      final startWeight = targetWeight * 0.8;
      final totalToGain = targetWeight - startWeight;
      final gained = currentWeight - startWeight;

      return (gained / totalToGain).clamp(0.0, 1.0);
    }
  }

  /// Calculate remaining weight to goal
  static double? getRemainingWeightToGoal({
    required double? currentWeight,
    required double? targetWeight,
  }) {
    if (currentWeight == null || targetWeight == null) {
      return null;
    }

    return currentWeight - targetWeight;
  }

  /// Get weight change direction text (to lose/to gain)
  ///
  /// Note: This method includes formatting. Consider moving to FormatHelpers
  /// if you need pure calculation without formatting.
  static String getWeightChangeDirectionText({
    required double? currentWeight,
    required double? targetWeight,
    required bool isMetric,
  }) {
    if (currentWeight == null || targetWeight == null) {
      return 'Set a target weight to track progress';
    }

    final difference = currentWeight - targetWeight;
    if (difference.abs() < 0.1) {
      return 'Goal achieved! 🎉';
    }

    // Calculate the absolute difference
    final absoluteDifference = difference.abs();

    // Convert to display units (kg or lbs)
    final displayDifference =
        isMetric ? absoluteDifference : absoluteDifference * 2.20462;

    final formattedDifference = displayDifference.toStringAsFixed(1);
    final units = isMetric ? 'kg' : 'lbs';

    // Return formatted text based on whether gaining or losing
    return difference > 0
        ? '$formattedDifference $units to lose'
        : '$formattedDifference $units to gain';
  }

  /// Calculate weight change over a time period
  static double? calculateWeightChange({
    required List<WeightData> entries,
    required DateTime startDate,
  }) {
    if (entries.isEmpty) return null;

    // Sort by timestamp (newest first)
    final sortedEntries = List<WeightData>.from(entries)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Get latest weight
    final latestWeight = sortedEntries.first.weight;

    // Find the closest entry to the start date
    WeightData? startEntry;
    for (final entry in sortedEntries.reversed) {
      if (entry.timestamp.isAfter(startDate) ||
          entry.timestamp.isAtSameMomentAs(startDate)) {
        startEntry = entry;
        break;
      }
    }

    if (startEntry == null) return null;

    // Calculate change (positive means weight gain, negative means weight loss)
    return latestWeight - startEntry.weight;
  }

  // ============================================================================
  // EXERCISE RECOMMENDATIONS
  // ============================================================================

  /// Calculate recommended daily exercise calorie burn based on weight goals
  static Map<String, dynamic> calculateRecommendedExerciseBurn({
    required double? monthlyWeightGoal, // kg/month, negative for loss
    required double? bmr,
    required double? activityLevel,
    required int? age,
    required String? gender,
    required double? currentWeight,
  }) {
    // Default return if we don't have sufficient data
    if (monthlyWeightGoal == null ||
        bmr == null ||
        activityLevel == null ||
        age == null ||
        currentWeight == null) {
      return {
        'daily_burn': 0,
        'weekly_burn': 0,
        'light_minutes': 0,
        'moderate_minutes': 0,
        'intense_minutes': 0,
        'recommendation_type': 'default',
        'safety_adjusted': false,
      };
    }

    // Calculate TDEE (Total Daily Energy Expenditure)
    final tdee = bmr * activityLevel;

    // Calculate daily calorie deficit/surplus needed based on monthly goal
    // 1 kg of body fat = approximately 7700 calories
    final monthlyCalorieChange = monthlyWeightGoal * 7700;
    final dailyCalorieChange = monthlyCalorieChange / 30;

    // Target intake already accounts for the goal, so calculate additional exercise
    int dailyBurn;
    String recommendationType;
    bool safetyAdjusted = false;

    if (monthlyWeightGoal < -0.1) {
      // Weight loss goal
      // For weight loss, we want to recommend exercise to boost the deficit
      // We recommend that about 20-30% of the deficit comes from exercise
      // The rest should come from dietary changes
      dailyBurn = (dailyCalorieChange.abs() * 0.25).round();
      recommendationType = 'loss';

      // Check if calorie intake has been safety adjusted (capped at 90% of BMR)
      // Calculate what the theoretical calorie target would have been without safety adjustment
      final theoreticalTargetCalories = (tdee + dailyCalorieChange).round();
      final minimumSafeCalories = (bmr * 0.9).round();

      if (theoreticalTargetCalories < minimumSafeCalories) {
        // Safety adjustment was applied to calorie intake
        safetyAdjusted = true;

        // Calculate how many calories were added due to safety adjustment
        final calorieAdjustment =
            minimumSafeCalories - theoreticalTargetCalories;

        // Add this adjustment to the daily burn to maintain the same deficit
        // Plus an additional 20% to encourage good exercise habits
        final additionalBurn = (calorieAdjustment * 1.2).round();
        dailyBurn += additionalBurn;
      }
    } else if (monthlyWeightGoal > 0.1) {
      // Weight gain goal
      // For weight gain, we still recommend exercise for health
      // but at a lower level to not counteract the calorie surplus
      dailyBurn = (200).round(); // Base exercise for fitness
      recommendationType = 'gain';
    } else {
      // Maintenance goal
      // Recommend a moderate amount of exercise for general fitness
      dailyBurn = (300).round();
      recommendationType = 'maintain';
    }

    // Calculate weekly total
    final weeklyBurn = dailyBurn * 7;

    // Adjust for age and gender
    double ageAdjustmentFactor = 1.0;
    if (age > 50) {
      ageAdjustmentFactor = 0.85; // Lower intensity for older adults
    } else if (age < 25) {
      ageAdjustmentFactor = 1.15; // Higher intensity for younger adults
    }

    // Gender-based adjustment (if relevant)
    double genderAdjustmentFactor = 1.0;
    if (gender == 'Male') {
      genderAdjustmentFactor =
          1.1; // Slightly higher for males due to muscle mass
    } else if (gender == 'Female') {
      genderAdjustmentFactor = 0.9; // Slightly lower for females
    }

    // Calculate exercise minutes at different intensities
    // Light: ~5 cal/min, Moderate: ~10 cal/min, Intense: ~15 cal/min
    // These are approximations and vary based on weight, fitness level, etc.
    final baseCaloriesPerMinute =
        (currentWeight / 70) * 10; // Baseline for 70kg person

    final lightCaloriesPerMinute = baseCaloriesPerMinute *
        0.5 *
        ageAdjustmentFactor *
        genderAdjustmentFactor;
    final moderateCaloriesPerMinute = baseCaloriesPerMinute *
        1.0 *
        ageAdjustmentFactor *
        genderAdjustmentFactor;
    final intenseCaloriesPerMinute = baseCaloriesPerMinute *
        1.5 *
        ageAdjustmentFactor *
        genderAdjustmentFactor;

    // Calculate minutes needed at each intensity
    final lightMinutes = (dailyBurn / lightCaloriesPerMinute).round();
    final moderateMinutes = (dailyBurn / moderateCaloriesPerMinute).round();
    final intenseMinutes = (dailyBurn / intenseCaloriesPerMinute).round();

    return {
      'daily_burn': dailyBurn,
      'weekly_burn': weeklyBurn,
      'light_minutes': lightMinutes,
      'moderate_minutes': moderateMinutes,
      'intense_minutes': intenseMinutes,
      'recommendation_type': recommendationType,
      'safety_adjusted': safetyAdjusted,
    };
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================

  /// Get list of missing data for calculations
  static List<String> getMissingData({
    required UserProfile? profile,
    required double? currentWeight,
  }) {
    final missingData = <String>[];

    if (profile == null) {
      missingData.add("Profile");
      return missingData;
    }

    if (currentWeight == null) {
      missingData.add("Weight");
    }

    if (profile.height == null) {
      missingData.add("Height");
    }

    if (profile.age == null) {
      missingData.add("Age");
    }

    if (profile.gender == null) {
      missingData.add("Gender");
    }

    if (profile.activityLevel == null) {
      missingData.add("Activity Level");
    }

    return missingData;
  }

  // ============================================================================
  // PROGRESS TRACKING METRICS
  // ============================================================================

  /// Calculate progress percentage toward a goal
  /// Returns value between 0.0 (no progress) and 1.0 (goal reached)
  ///
  /// Formula: (start - current) / (start - target)
  static double? calculateProgress({
    required double? startValue,
    required double? currentValue,
    required double? targetValue,
  }) {
    if (startValue == null || currentValue == null || targetValue == null) {
      return null;
    }

    // If already at target, return 100%
    if ((currentValue - targetValue).abs() < 0.01) {
      return 1.0;
    }

    // If start equals target, can't calculate progress
    if ((startValue - targetValue).abs() < 0.01) {
      return null;
    }

    // Calculate progress
    return ((startValue - currentValue) / (startValue - targetValue)).clamp(0.0, 1.0);
  }

  /// Get starting weight from weight history (oldest entry)
  static double? getStartingWeight(List<WeightData> weightHistory) {
    if (weightHistory.isEmpty) return null;

    final sortedHistory = List<WeightData>.from(weightHistory)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return sortedHistory.first.weight;
  }

  /// Calculate target body fat percentage based on target weight
  static double? calculateTargetBodyFat({
    required double? targetWeight,
    required double? height, // in cm
    required int? age,
    required String? gender,
  }) {
    if (targetWeight == null || height == null) {
      return null;
    }

    // Calculate target BMI
    final targetBMI = calculateBMI(height: height, weight: targetWeight);
    if (targetBMI == null) return null;

    // Calculate body fat from target BMI
    return calculateBodyFat(bmi: targetBMI, age: age, gender: gender);
  }

  /// Calculate starting body fat percentage based on starting weight
  static double? calculateStartingBodyFat({
    required double? startingWeight,
    required double? height, // in cm
    required int? age,
    required String? gender,
  }) {
    if (startingWeight == null || height == null) {
      return null;
    }

    // Calculate starting BMI
    final startingBMI = calculateBMI(height: height, weight: startingWeight);
    if (startingBMI == null) return null;

    // Calculate body fat from starting BMI
    return calculateBodyFat(bmi: startingBMI, age: age, gender: gender);
  }
}
