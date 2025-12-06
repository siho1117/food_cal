// lib/config/constants/app_constants.dart

/// Central location for business logic constants and app configuration
/// 
/// UI-related constants (dimensions, spacing, colors) should be in theme_design.dart
/// This file contains only business rules, validation, storage keys, and app behavior
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ═══════════════════════════════════════════════════════════════
  // APP METADATA
  // ═══════════════════════════════════════════════════════════════

  static const String appName = 'OptiMate';
  static const String appDisplayName = 'OptiMate';

  // ═══════════════════════════════════════════════════════════════
  // FOOD CONSTANTS
  // ═══════════════════════════════════════════════════════════════

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

  static const double defaultServingSize = 1.0;

  // ═══════════════════════════════════════════════════════════════
  // NUTRITION GOALS (default values)
  // ═══════════════════════════════════════════════════════════════
  
  static const Map<String, dynamic> defaultNutritionGoals = {
    'calories': 2000,
    'protein': 150.0,      // grams
    'carbs': 250.0,        // grams
    'fat': 65.0,           // grams
    'fiber': 25.0,         // grams
    'sugar': 50.0,         // grams
    'sodium': 2300.0,      // milligrams
  };

  // ═══════════════════════════════════════════════════════════════
  // API CONSTANTS
  // ═══════════════════════════════════════════════════════════════
  
  static const int defaultApiTimeout = 30; // seconds
  static const int imageApiTimeout = 45; // seconds
  static const int maxRetries = 3;
  // Note: Daily API quota limit is defined in api_config.dart (150 requests/day)

  // ═══════════════════════════════════════════════════════════════
  // IMAGE PROCESSING CONSTANTS
  // ═══════════════════════════════════════════════════════════════

  static const int maxImageSizeMB = 10;
  // ⚠️ PRODUCTION SETTINGS - Optimized for cost/quality balance
  // 300x300 @ 50% compression = ~700-800 tokens (~$0.00040/request)
  // Validated: Maintains excellent food recognition accuracy
  // DO NOT modify without testing - affects all vision API calls
  static const int targetImageWidth = 300;
  static const int targetImageHeight = 300;
  static const int imageCompressionQuality = 50;

  // ═══════════════════════════════════════════════════════════════
  // VALIDATION CONSTANTS
  // ═══════════════════════════════════════════════════════════════
  
  static const double minCalories = 0.0;
  static const double maxCalories = 5000.0;
  static const double minMacros = 0.0;
  static const double maxProtein = 300.0;
  static const double maxCarbs = 500.0;
  static const double maxFat = 200.0;

  static const double minWeight = 30.0;  // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm
  static const int minAge = 13;
  static const int maxAge = 120;

  static const double minCaloriesValue = 0.0;
  static const double maxCaloriesValue = 9999.0;
  static const double minNutrientValue = 0.0;
  static const double maxNutrientValue = 999.0;
  static const int maxFoodNameLength = 100;
  static const double maxBudgetAmount = 1000.0;
  static const int maxDecimalPlaces = 2;
  static const int maxRecentSearches = 10;

  // ═══════════════════════════════════════════════════════════════
  // STORAGE KEYS
  // ═══════════════════════════════════════════════════════════════
  
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

  // ═══════════════════════════════════════════════════════════════
  // COMMON BUTTON LABELS
  // ═══════════════════════════════════════════════════════════════
  
  static const String saveLabel = 'Save';
  static const String cancelLabel = 'Cancel';
  static const String retryLabel = 'Retry';
  static const String analyzeLabel = 'Analyze Food';
  static const String retakeLabel = 'Retake';

  // ═══════════════════════════════════════════════════════════════
  // COMMON MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const String loadingMessage = 'Loading...';
  static const String savingMessage = 'Saving...';
  static const String errorLoadingData = 'Error Loading Data';
  static const String noFoodDetected = 'No food items were detected in the image. Please try again.';

  // ═══════════════════════════════════════════════════════════════
  // ERROR MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
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

  // ═══════════════════════════════════════════════════════════════
  // BUDGET MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const String budgetQuestion = 'How much do you want to spend on food per day?';
  static const String budgetAdvice = 'Consider your food goals and spending habits';
  static const String budgetTooHigh = 'Budget seems high. Please check the amount.';
  static const String invalidBudget = 'Please enter a valid budget amount';
  static const String budgetUpdateSuccess = 'Budget updated successfully!';

  static const List<Map<String, dynamic>> budgetPresets = [
    {'label': 'Frugal', 'amount': 15.0},
    {'label': 'Moderate', 'amount': 25.0}, 
    {'label': 'Generous', 'amount': 40.0},
  ];

  static const double budgetWarningThreshold = 0.9;   // 90%
  static const double budgetCautionThreshold = 0.7;   // 70%
  static const double budgetGoodThreshold = 0.4;      // 40%

  // ═══════════════════════════════════════════════════════════════
  // SUCCESS MESSAGES
  // ═══════════════════════════════════════════════════════════════
  
  static const String foodAddedSuccessMessage = 'Food item added to your log!';
  static const String profileUpdatedMessage = 'Profile updated successfully!';
  static const String settingsSavedMessage = 'Settings saved successfully!';
  static const String saveSuccess = 'Saved successfully!';
  static const String updateSuccess = 'Updated successfully!';


  // ═══════════════════════════════════════════════════════════════
  // GENDER & GOAL OPTIONS
  // ═══════════════════════════════════════════════════════════════
  
  static const List<String> genderOptions = [
    'male',
    'female',
    'other',
  ];

  static const List<String> goalTypes = [
    'lose_weight',
    'maintain_weight',
    'gain_weight',
    'build_muscle',
    'improve_health',
  ];

  // ═══════════════════════════════════════════════════════════════
  // ALLERGENS & DIETARY PREFERENCES
  // ═══════════════════════════════════════════════════════════════
  
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

  // ═══════════════════════════════════════════════════════════════
  // TIME CONSTANTS
  // ═══════════════════════════════════════════════════════════════
  
  static const Duration splashScreenDuration = Duration(seconds: 3);
  static const Duration snackBarDuration = Duration(seconds: 4);
  static const Duration loadingTimeout = Duration(seconds: 10);
  static const Duration apiTimeout = Duration(seconds: 60);
  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration loadingDelay = Duration(milliseconds: 200);

  // ═══════════════════════════════════════════════════════════════
  // NUTRITIONAL DEFAULTS
  // ═══════════════════════════════════════════════════════════════
  
  static const double defaultCaloriesPerGram = 4.0; // For carbs/protein
  static const double fatCaloriesPerGram = 9.0;
  static const double alcoholCaloriesPerGram = 7.0;
  static const double defaultWeightKg = 70.0;
  static const double defaultWeightLbs = 154.0;
  static const double lbsToKgRatio = 2.20462;

  // ═══════════════════════════════════════════════════════════════
  // BMI CATEGORIES
  // ═══════════════════════════════════════════════════════════════
  
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;

  // ═══════════════════════════════════════════════════════════════
  // REGEX PATTERNS
  // ═══════════════════════════════════════════════════════════════
  
  static const String decimalNumberPattern = r'[0-9.,]';
  static const String numberOnlyPattern = r'[0-9.]';
  static const String integerOnlyPattern = r'[0-9]';

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

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
}

/// Extension for string capitalization
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
  
  String get capitalized => capitalize();
}