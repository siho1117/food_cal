// lib/config/constants/nutrition_constants.dart

/// Nutritional and physiological constants used throughout the app
class NutritionConstants {
  NutritionConstants._(); // Private constructor to prevent instantiation

  // MARK: - Calories per Gram

  /// Calories per gram of protein
  /// Standard: 1g protein = 4 calories
  static const double caloriesPerGramProtein = 4.0;

  /// Calories per gram of carbohydrates
  /// Standard: 1g carbs = 4 calories
  static const double caloriesPerGramCarbs = 4.0;

  /// Calories per gram of fat
  /// Standard: 1g fat = 9 calories
  static const double caloriesPerGramFat = 9.0;

  // MARK: - Default Macro Percentages

  /// Default protein percentage of total calories (30%)
  static const double defaultProteinPercent = 0.30;

  /// Default carbohydrates percentage of total calories (45%)
  static const double defaultCarbsPercent = 0.45;

  /// Default fat percentage of total calories (25%)
  static const double defaultFatPercent = 0.25;

  // MARK: - Macro Limits

  /// Maximum grams for any macro nutrient
  static const int maxMacroGrams = 9999;

  /// Minimum grams for any macro nutrient
  static const int minMacroGrams = 1;
}

/// Health and weight-related constants
class HealthConstants {
  HealthConstants._(); // Private constructor to prevent instantiation

  /// Approximate calories per kg of body fat
  /// Based on: 1 kg fat ≈ 7700 calories
  /// This is an approximation used for goal calculations
  static const double caloriesPerKgBodyFat = 7700.0;

  /// Average days per month for goal calculations
  /// Using 30 as approximation for monthly weight goals
  static const int averageDaysPerMonth = 30;
}
