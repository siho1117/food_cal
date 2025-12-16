// lib/utils/constants/unit_constants.dart

/// Unit conversion constants used throughout the app
class UnitConstants {
  // Prevent instantiation
  UnitConstants._();

  /// Conversion ratio from kilograms to pounds
  static const double kgToLbsRatio = 2.20462;

  /// Conversion ratio from centimeters to inches
  static const double cmToInchesRatio = 0.393701;

  /// Inches per foot
  static const int inchesPerFoot = 12;

  /// Weight range constants (in kg)
  static const int minWeightKg = 30;
  static const int maxWeightKg = 300;

  /// Height range constants (in cm)
  static const int minHeightCm = 100;
  static const int maxHeightCm = 250;

  /// Height range constants (in feet)
  static const int minHeightFeet = 3;
  static const int maxHeightFeet = 8;

  // Conversion helper methods

  /// Convert kilograms to pounds
  static double kgToLbs(double kg) => kg * kgToLbsRatio;

  /// Convert pounds to kilograms
  static double lbsToKg(double lbs) => lbs / kgToLbsRatio;

  /// Convert centimeters to total inches
  static double cmToInches(double cm) => cm * cmToInchesRatio;

  /// Convert inches to centimeters
  static double inchesToCm(double inches) => inches / cmToInchesRatio;

  /// Convert height in cm to feet and inches
  static ({int feet, int inches}) cmToFeetAndInches(double cm) {
    final totalInches = cmToInches(cm);
    final feet = totalInches ~/ inchesPerFoot;
    final inches = (totalInches % inchesPerFoot).round();
    return (feet: feet, inches: inches);
  }

  /// Convert feet and inches to cm
  static double feetAndInchesToCm(int feet, int inches) {
    final totalInches = (feet * inchesPerFoot) + inches;
    return inchesToCm(totalInches.toDouble());
  }
}
