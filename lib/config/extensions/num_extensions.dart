import 'dart:math' as math;

/// Extension methods on num types (int, double) for common calculations
/// and conversions used throughout the app.
extension NumExtensions on num {
  /// Convert to percentage string
  String toPercentString({int decimals = 0}) {
    return '${toStringAsFixed(decimals)}%';
  }
  
  /// Convert to currency string (USD by default)
  String toCurrencyString({
    String symbol = '\$',
    int decimals = 2,
    bool showSymbolAtEnd = false,
  }) {
    final formattedValue = toStringAsFixed(decimals);
    return showSymbolAtEnd ? '$formattedValue$symbol' : '$symbol$formattedValue';
  }
  
  /// Round to a specific number of decimal places
  double roundTo(int places) {
    final mod = math.pow(10.0, places);
    return (this * mod).round() / mod;
  }
  
  /// Convert kilograms to pounds
  double get kgToLbs => this * 2.20462;
  
  /// Convert pounds to kilograms
  double get lbsToKg => this / 2.20462;
  
  /// Convert centimeters to inches
  double get cmToInches => this / 2.54;
  
  /// Convert inches to centimeters
  double get inchesToCm => this * 2.54;
  
  /// Convert centimeters to feet and inches string (e.g. 5' 10")
  String get cmToFeetInchesString {
    final totalInches = cmToInches;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return '$feet\' $inches"';
  }
  
  /// Get a formatted weight string based on unit system
  String toWeightString({
    bool isMetric = true,
    int decimals = 1,
  }) {
    if (isMetric) {
      return '${toStringAsFixed(decimals)} kg';
    } else {
      final pounds = kgToLbs;
      return '${pounds.toStringAsFixed(decimals)} lbs';
    }
  }
  
  /// Get a formatted height string based on unit system
  String toHeightString({
    bool isMetric = true,
    int decimals = 0,
  }) {
    if (isMetric) {
      return '${toStringAsFixed(decimals)} cm';
    } else {
      return cmToFeetInchesString;
    }
  }
  
  /// Calculate BMI given a height in cm
  double calculateBMI(num heightCm) {
    assert(heightCm > 0, 'Height must be greater than 0');
    final heightMeters = heightCm / 100;
    return this / (heightMeters * heightMeters);
  }
  
  /// Get days from milliseconds
  int get millisecondsToDays => (this / (1000 * 60 * 60 * 24)).round();
  
  /// Convert to calorie representation
  String toCalorieString() {
    if (this >= 1000) {
      final thousands = (this / 1000).roundTo(1);
      return '${thousands}k cal';
    }
    return '${round()} cal';
  }
  
  /// Get a percentage of this value
  double percentOf(num percent) => this * percent / 100;
  
  /// Clamp a value with more readable syntax
  num clampBetween(num min, num max) => (this).clamp(min, max);
  
  /// Check if this value is between two numbers (inclusive)
  bool isBetween(num min, num max) => this >= min && this <= max;
  
  /// Map this value from one range to another
  double mapRange({
    required num fromMin, 
    required num fromMax, 
    required num toMin, 
    required num toMax,
  }) {
    return (this - fromMin) * (toMax - toMin) / (fromMax - fromMin) + toMin;
  }
}