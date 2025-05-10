import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A lightweight class to define font families across the app
/// Only font family is controlled centrally, all other styling
/// properties (size, weight, color) should be set at the widget level
class AppTextStyles {
  // Private constructor to prevent instantiation
  AppTextStyles._();

  /// Main heading font - for app name and primary headers
  /// Recommended for: App title, screen titles, primary headers
  static TextStyle getHeadingStyle() {
    return GoogleFonts.monoton();
  }

  /// Sub-heading font - for section headers and important elements
  /// Recommended for: Section titles, card headers, important UI elements
  static TextStyle getSubHeadingStyle() {
    return GoogleFonts.dmSans();
  }

  /// Body text font - for regular content
  /// Recommended for: Regular text, descriptions, form fields
  static TextStyle getBodyStyle() {
    return GoogleFonts.montserrat();
  }

  /// Numeric font - for numbers, statistics, measurements
  /// Recommended for: Calorie counts, metrics, timers, any numeric displays
  static TextStyle getNumericStyle() {
    return GoogleFonts.robotoMono();
  }
  
  /// Example usage:
  /// Text(
  ///   'FOOD APP',
  ///   style: AppTextStyles.getHeadingStyle().copyWith(
  ///     fontSize: 36.0,
  ///     color: AppTheme.primaryBlue,
  ///     letterSpacing: 2.0,
  ///   ),
  /// )
  ///
  /// Text(
  ///   '250',
  ///   style: AppTextStyles.getNumericStyle().copyWith(
  ///     fontSize: 24.0,
  ///     fontWeight: FontWeight.bold,
  ///     color: Colors.black,
  ///   ),
  /// )
}