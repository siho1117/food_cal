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
    'kg',          // ADDED: Missing from your current file
    'lb',          // ADDED: Missing from your current file
  ];

  static const int maxFoodNameLength = 100;
  static const double maxBudgetAmount = 1000.0;
  static const double defaultServingSize = 1.0;

  // === BUDGET PRESETS ===
  static const List<Map<String, dynamic>> budgetPresets = [
    {'label': 'Frugal', 'amount': 15.0},
    {'label': 'Moderate', 'amount': 25.0}, 
    {'label': 'Generous', 'amount': 40.0},
  ];

  // === WEIGHT RELATED ===
  static const double weightLimitPercentage = 0.20; // 20% max change
  static const double defaultWeightKg = 70.0;
  static const double defaultWeightLbs = 154.0;
  static const double lbsToKgRatio = 2.20462;

  // === TIME CONSTANTS ===
  static const int mealTimeBoundaries = 11; // breakfast < 11am
  static const int lunchBoundary = 15;      // lunch < 3pm  
  static const int snackBoundary = 18;      // snack < 6pm
  // dinner >= 6pm

  // === API & TIMEOUTS ===
  static const Duration apiTimeout = Duration(seconds: 60);
  static const Duration shortTimeout = Duration(seconds: 15);
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration loadingDelay = Duration(milliseconds: 200);

  static const int imageQuality = 90;
  static const int compressionQuality = 45;
  static const int targetImageWidth = 256;
  static const int targetImageHeight = 256;

  // === VALIDATION LIMITS ===
  static const int maxRecentSearches = 10;
  static const int maxDurationHours = 1440; // 24 hours in minutes
  static const int maxTextFieldLength = 8;
  static const int maxDecimalPlaces = 2;

  // === PROGRESS THRESHOLDS ===
  static const double budgetWarningThreshold = 0.9;   // 90%
  static const double budgetCautionThreshold = 0.7;   // 70%
  static const double budgetGoodThreshold = 0.4;      // 40%

  // === ANIMATION VALUES ===
  static const Curve animationCurve = Curves.easeOutCubic;
  static const Duration bottomNavAnimationDuration = Duration(milliseconds: 400);
  static const double shadowOpacity = 0.05;
  static const double blurRadius = 10.0;
  static const Offset shadowOffset = Offset(0, 2);

  // === STORAGE KEYS ===
  static const String foodEntriesKey = 'food_entries';
  static const String tempImageFolderKey = 'food_images';
  static const String recentSearchesKey = 'recent_food_searches';
  static const String favoriteFoodsKey = 'favorite_foods';
  static const String errorLogKey = 'error_log';

  // ADDED: Missing storage keys your code is using
  static const String userWeightKey = 'user_weight';
  static const String userHeightKey = 'user_height';
  static const String userAgeKey = 'user_age';
  static const String userGenderKey = 'user_gender';
  static const String isMetricKey = 'is_metric';
  static const String dailyBudgetKey = 'daily_budget';
  static const String targetWeightKey = 'target_weight';
  static const String activityLevelKey = 'activity_level';

  // === UI TEXT ===
  static const String appName = 'FOOD LLM';
  
  // Screen titles
  static const String homeTitle = 'Daily Dashboard';
  static const String progressTitle = 'Fitness Tracker';
  static const String exerciseTitle = 'Workout Log';
  static const String cameraTitle = 'Food Scanner';
  static const String analyticsTitle = 'Analytics Dashboard';

  // Common button labels
  static const String saveLabel = 'Save';
  static const String cancelLabel = 'Cancel';
  static const String retryLabel = 'Retry';
  static const String analyzeLabel = 'Analyze Food';
  static const String retakeLabel = 'Retake';

  // Common messages
  static const String loadingMessage = 'Loading...';
  static const String savingMessage = 'Saving...';
  static const String errorLoadingData = 'Error Loading Data';
  static const String noFoodDetected = 'No food items were detected in the image. Please try again.';
  static const String saveSuccess = 'Saved successfully!';
  static const String updateSuccess = 'Updated successfully!';

  // Form validation messages
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

  // Budget messages
  static const String budgetQuestion = 'How much do you want to spend on food per day?';
  static const String budgetAdvice = 'Consider your food goals and spending habits';
  static const String budgetTooHigh = 'Budget seems high. Please check the amount.';
  static const String invalidBudget = 'Please enter a valid budget amount';
  static const String budgetUpdateSuccess = 'Budget updated successfully!';
  
  // Budget status messages
  static const String overBudget = '🚨 Over budget!';
  static const String approachingBudget = '⚠️ Approaching your budget limit!';
  static const String onTrackBudget = '📊 On track with your budget!';
  static const String goodBudget = '💡 Great spending discipline!';
  static const String excellentBudget = '🎯 Excellent budget management!';

  // === REGEX PATTERNS ===
  static const String decimalNumberPattern = r'[0-9.,]';  // FIXED: Your code expects this pattern
  static const String numberOnlyPattern = r'[0-9.]';
  static const String integerOnlyPattern = r'[0-9]';

  // === NUTRITIONAL VALIDATION RANGES ===
  // ADDED: Missing validation constants your forms are using
  static const double minCaloriesValue = 0.0;
  static const double maxCaloriesValue = 9999.0;
  static const double minNutrientValue = 0.0;
  static const double maxNutrientValue = 999.0;

  // === API CONSTANTS ===
  // ADDED: Missing API constants 
  static const String apiBaseUrl = 'https://api.edamam.com/api/food-database/v2';
  static const int apiTimeoutSeconds = 30;
  static const int maxRetryAttempts = 3;
  static const int dailyQuotaLimit = 100;

  // === BMI CATEGORIES ===
  // ADDED: Missing BMI constants
  static const double bmiUnderweight = 18.5;
  static const double bmiNormal = 24.9;
  static const double bmiOverweight = 29.9;
  // Above 30 is obese

  // === ACTIVITY LEVELS ===
  // ADDED: Missing activity multipliers
  static const Map<String, double> activityMultipliers = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extremely Active': 1.9,
  };

  // === DEBOUNCE DURATIONS ===
  // ADDED: Missing debounce constants
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration apiDebounce = Duration(milliseconds: 1000);

  // === NUTRITIONAL DEFAULTS ===
  // ADDED: Missing nutritional constants
  static const double defaultCaloriesPerGram = 4.0; // For carbs/protein
  static const double fatCaloriesPerGram = 9.0;
  static const double alcoholCaloriesPerGram = 7.0;

  // === IMAGE CONSTANTS ===
  // ADDED: Missing image constants
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const double imageCompressionQuality = 0.8;

  // === ASSET PATHS ===
  // Add any asset paths here when you have them
  // static const String logoPath = 'assets/images/logo.png';
  // static const String placeholderImagePath = 'assets/images/placeholder.png';
}

// Extension to make meal type formatting easier
extension MealTypeExtension on String {
  String get capitalized {
    if (isEmpty) return 'Snack';
    return substring(0, 1).toUpperCase() + substring(1).toLowerCase();
  }
}

// Utility class for common calculations
class AppCalculations {
  AppCalculations._();

  static double lbsToKg(double lbs) => lbs / AppConstants.lbsToKgRatio;
  static double kgToLbs(double kg) => kg * AppConstants.lbsToKgRatio;
  
  static String getSuggestedMealType() {
    final hour = DateTime.now().hour;
    if (hour < AppConstants.mealTimeBoundaries) return AppConstants.mealTypes[0]; // breakfast
    if (hour < AppConstants.lunchBoundary) return AppConstants.mealTypes[1];      // lunch
    if (hour < AppConstants.snackBoundary) return AppConstants.mealTypes[3];     // snack
    return AppConstants.mealTypes[2]; // dinner
  }
  
  static double calculateBudgetProgress(double spent, double budget) {
    if (budget <= 0) return 0.0;
    return (spent / budget).clamp(0.0, double.infinity);
  }
  
  static bool isBudgetOverLimit(double progress) {
    return progress > 1.0;
  }
  
  static bool isBudgetWarning(double progress) {
    return progress >= AppConstants.budgetWarningThreshold;
  }
}