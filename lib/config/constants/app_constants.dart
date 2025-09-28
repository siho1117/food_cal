// lib/config/constants/app_constants.dart
import 'package:flutter/material.dart';

/// Central location for all app constants to avoid magic numbers and strings
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // === UI DIMENSIONS ===
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  static const double borderRadiusXLarge = 20.0;

  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 20.0;
  static const double paddingXLarge = 24.0;

  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 20.0;
  static const double spacingXLarge = 30.0;

  static const double iconSizeSmall = 16.0;
  static const double iconSizeMedium = 20.0;
  static const double iconSizeLarge = 24.0;
  static const double iconSizeXLarge = 28.0;

  static const double emojiSize = 20.0;
  static const double bottomNavHeight = 75.0;
  static const double appBarHeight = 100.0;

  // === FONT SIZES ===
  static const double fontSizeSmall = 11.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeTitle = 26.0;
  static const double fontSizeAppTitle = 38.0;

  // === ANIMATION CONSTANTS ===
  static const Curve animationCurve = Curves.easeInOut;
  static const Duration bottomNavAnimationDuration = Duration(milliseconds: 400);
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 600);

  // === FOOD RELATED CONSTANTS ===
  static const List<String> mealTypes = [
    'breakfast',
    'lunch', 
    'dinner',
    'snack',
  ];

  static const List<String> servingUnits = [
    'serving',
    'cup',
    'gram',
    'g',
    'ml',
    'oz',
    'piece',
    'slice',
    'tbsp',
    'tsp',
    'kg',
    'lb',
    'liter',
    'fl oz',
    'pint',
    'quart',
  ];

  // === MEAL TYPE EMOJIS ===
  static const Map<String, String> mealTypeEmojis = {
    'breakfast': '🌅',
    'lunch': '☀️',
    'dinner': '🌙',
    'snack': '🍎',
  };

  // === NUTRITION GOALS (default values) ===
  static const Map<String, dynamic> defaultNutritionGoals = {
    'calories': 2000,
    'protein': 150.0,      // grams
    'carbs': 250.0,        // grams
    'fat': 65.0,           // grams
    'fiber': 25.0,         // grams
    'sugar': 50.0,         // grams
    'sodium': 2300.0,      // milligrams
  };

  // === API CONSTANTS ===
  static const int defaultApiTimeout = 30; // seconds
  static const int imageApiTimeout = 45; // seconds
  static const int maxRetries = 3;
  static const int dailyApiQuota = 50;

  // === IMAGE PROCESSING CONSTANTS ===
  static const int maxImageSizeMB = 10;
  static const int targetImageWidth = 1024;
  static const int targetImageHeight = 1024;
  static const int imageCompressionQuality = 85;

  // === VALIDATION CONSTANTS ===
  static const double minCalories = 0.0;
  static const double maxCalories = 5000.0;
  static const double minMacros = 0.0;
  static const double maxProtein = 300.0;
  static const double maxCarbs = 500.0;
  static const double maxFat = 200.0;

  // === USER PROFILE CONSTANTS ===
  static const double minWeight = 30.0;  // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm
  static const int minAge = 13;
  static const int maxAge = 120;

  // === STORAGE KEYS ===
  static const String userProfileKey = 'user_profile';
  static const String foodEntriesKey = 'food_entries';
  static const String settingsKey = 'app_settings';
  static const String onboardingKey = 'onboarding_completed';
  static const String apiQuotaKey = 'api_quota_usage';
  static const String apiQuotaDateKey = 'api_quota_date';
  static const String recentSearchesKey = 'recent_food_searches';
  static const String favoriteFoodsKey = 'favorite_foods';
  static const String errorLogKey = 'error_log';
  static const String userWeightKey = 'user_weight';
  static const String userHeightKey = 'user_height';
  static const String userAgeKey = 'user_age';
  static const String userGenderKey = 'user_gender';
  static const String isMetricKey = 'is_metric';
  static const String dailyBudgetKey = 'daily_budget';
  static const String targetWeightKey = 'target_weight';
  static const String activityLevelKey = 'activity_level';
  static const String tempImageFolderKey = 'food_images';

  // === COMMON BUTTON LABELS ===
  static const String saveLabel = 'Save';
  static const String cancelLabel = 'Cancel';
  static const String retryLabel = 'Retry';
  static const String analyzeLabel = 'Analyze Food';
  static const String retakeLabel = 'Retake';

  // === COMMON MESSAGES ===
  static const String loadingMessage = 'Loading...';
  static const String savingMessage = 'Saving...';
  static const String errorLoadingData = 'Error Loading Data';
  static const String noFoodDetected = 'No food items were detected in the image. Please try again.';

  // === ERROR MESSAGES ===
  static const String networkErrorMessage = 'No internet connection. Please check your network and try again.';
  static const String genericErrorMessage = 'Something went wrong. Please try again.';
  static const String quotaExceededMessage = 'Daily analysis limit reached. Please try again tomorrow.';
  static const String cameraErrorMessage = 'Unable to access camera. Please check permissions.';
  static const String storageErrorMessage = 'Unable to save data. Please check available storage.';
  static const String fieldRequired = 'This field is required';
  static const String invalidNumber = 'Please enter a valid number';
  static const String nameRequired = 'Food name cannot be empty';
  static const String nameTooLong = 'Food name must be 100 characters or less';
  static const String invalidServingSize = 'Please enter a valid serving size';
  static const String invalidCalories = 'Please enter valid calories';
  static const String invalidProtein = 'Please enter valid protein amount';
  static const String invalidCarbs = 'Please enter valid carbs amount'; 
  static const String invalidFat = 'Please enter valid fat amount';
  static const String invalidCost = 'Please enter a valid cost (0 or greater)';

  // === BUDGET MESSAGES ===
  static const String budgetQuestion = 'How much do you want to spend on food per day?';
  static const String budgetAdvice = 'Consider your food goals and spending habits';
  static const String budgetTooHigh = 'Budget seems high. Please check the amount.';
  static const String invalidBudget = 'Please enter a valid budget amount';
  static const String budgetUpdateSuccess = 'Budget updated successfully!';

  // === BUDGET PRESETS ===
  static const List<Map<String, dynamic>> budgetPresets = [
    {'label': 'Frugal', 'amount': 15.0},
    {'label': 'Moderate', 'amount': 25.0}, 
    {'label': 'Generous', 'amount': 40.0},
  ];

  // === SUCCESS MESSAGES ===
  static const String foodAddedSuccessMessage = 'Food item added to your log!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String settingsSavedMessage = 'Settings saved successfully!';
  static const String saveSuccess = 'Saved successfully!';
  static const String updateSuccess = 'Updated successfully!';

  // === ACTIVITY LEVELS (for calorie calculations) ===
  static const Map<String, double> activityMultipliers = {
    'sedentary': 1.2,        // Little or no exercise
    'light': 1.375,          // Light exercise 1-3 days/week
    'moderate': 1.55,        // Moderate exercise 3-5 days/week
    'active': 1.725,         // Hard exercise 6-7 days/week
    'very_active': 1.9,      // Very hard exercise, physical job
  };

  // === GENDER OPTIONS ===
  static const List<String> genderOptions = [
    'male',
    'female',
    'other',
  ];

  // === GOAL TYPES ===
  static const List<String> goalTypes = [
    'lose_weight',
    'maintain_weight',
    'gain_weight',
    'build_muscle',
    'improve_health',
  ];

  // === COMMON ALLERGENS ===
  static const List<String> commonAllergens = [
    'dairy',
    'eggs',
    'fish',
    'shellfish',
    'tree_nuts',
    'peanuts',
    'wheat',
    'soy',
    'sesame',
  ];

  // === DIETARY PREFERENCES ===
  static const List<String> dietaryPreferences = [
    'none',
    'vegetarian',
    'vegan',
    'pescatarian',
    'keto',
    'paleo',
    'mediterranean',
    'low_carb',
    'low_fat',
    'gluten_free',
  ];

  // === TIME CONSTANTS ===
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration loadingTimeout = Duration(seconds: 10);
  static const Duration apiTimeout = Duration(seconds: 60);
  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration loadingDelay = Duration(milliseconds: 200);

  // === UI BREAKPOINTS ===
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 900.0;
  static const double desktopBreakpoint = 1200.0;

  // === CHARTS & GRAPHS ===
  static const double chartHeight = 200.0;
  static const double progressBarHeight = 8.0;
  static const int chartAnimationDuration = 1000; // milliseconds

  // === CAMERA CONSTANTS ===
  static const double cameraOverlayOpacity = 0.7;
  static const double focusCircleSize = 80.0;
  static const Duration cameraFocusDuration = Duration(milliseconds: 500);

  // === FORM VALIDATION ===
  static const double minCaloriesValue = 0.0;
  static const double maxCaloriesValue = 9999.0;
  static const double minNutrientValue = 0.0;
  static const double maxNutrientValue = 999.0;
  static const int maxFoodNameLength = 100;
  static const double maxBudgetAmount = 1000.0;
  static const double defaultServingSize = 1.0;
  static const int maxDecimalPlaces = 2;
  static const int maxRecentSearches = 10;

  // === REGEX PATTERNS ===
  static const String decimalNumberPattern = r'[0-9.,]';
  static const String numberOnlyPattern = r'[0-9.]';
  static const String integerOnlyPattern = r'[0-9]';

  // === BMI CATEGORIES ===
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;

  // === BUDGET CONSTANTS ===
  static const double budgetWarningThreshold = 0.9;   // 90%
  static const double budgetCautionThreshold = 0.7;   // 70%
  static const double budgetGoodThreshold = 0.4;      // 40%
  static const double defaultWeightKg = 70.0;
  static const double defaultWeightLbs = 154.0;
  static const double lbsToKgRatio = 2.20462;

  // === MEAL TIME BOUNDARIES ===
  static const int mealTimeBoundaries = 11; // breakfast < 11am
  static const int lunchBoundary = 15;      // lunch < 3pm  
  static const int snackBoundary = 18;      // snack < 6pm

  // === NUTRITIONAL DEFAULTS ===
  static const double defaultCaloriesPerGram = 4.0; // For carbs/protein
  static const double fatCaloriesPerGram = 9.0;
  static const double alcoholCaloriesPerGram = 7.0;

  /// Helper method to get meal type display name
  static String getMealTypeDisplayName(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return 'Breakfast';
      case 'lunch':
        return 'Lunch';
      case 'dinner':
        return 'Dinner';
      case 'snack':
        return 'Snack';
      default:
        return mealType.capitalize();
    }
  }

  /// Helper method to get meal type emoji
  static String getMealTypeEmoji(String mealType) {
    return mealTypeEmojis[mealType.toLowerCase()] ?? '🍽️';
  }

  /// Helper method to validate calorie value
  static bool isValidCalorieValue(double calories) {
    return calories >= minCalories && calories <= maxCalories;
  }

  /// Helper method to validate macro value
  static bool isValidMacroValue(double value, String macroType) {
    if (value < minMacros) return false;
    
    switch (macroType.toLowerCase()) {
      case 'protein':
        return value <= maxProtein;
      case 'carbs':
      case 'carbohydrates':
        return value <= maxCarbs;
      case 'fat':
      case 'fats':
        return value <= maxFat;
      default:
        return true;
    }
  }

  /// Helper method to get activity level multiplier
  static double getActivityMultiplier(String activityLevel) {
    return activityMultipliers[activityLevel.toLowerCase()] ?? activityMultipliers['sedentary']!;
  }

  /// Helper method to format serving unit display
  static String formatServingUnit(String unit, double amount) {
    if (amount == 1.0) {
      return unit;
    } else {
      // Add 's' for plural if needed (basic pluralization)
      if (unit.endsWith('s') || unit.endsWith('x')) {
        return unit;
      } else {
        return '${unit}s';
      }
    }
  }

  /// Helper method to get readable file size
  static String getReadableFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  /// Helper method to check if device is tablet
  static bool isTablet(BuildContext context) {
    return MediaQuery.of(context).size.width >= tabletBreakpoint;
  }

  /// Helper method to check if device is mobile
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  String get capitalized => capitalize();
}