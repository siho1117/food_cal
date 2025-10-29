import 'package:flutter/material.dart';

/// Background gradient themes for the app
/// 
/// Provides gradient definitions and utilities for theme selection.
/// This is a data layer class - it has no opinions about UI implementation.
/// The UI layer (theme_selector_dialog.dart) decides how to display these themes.
class ThemeBackground {
  /// Map of theme ID to gradient color stops
  /// 
  /// Supports 2+ color gradients. Theme '01' is the default.
  /// Each gradient is defined as a list of Color objects.
  /// - 2 colors: simple gradient from start to end
  /// - 3+ colors: gradient with intermediate color stops
  static const Map<String, List<Color>> gradients = {
    // Theme 01: Light Gray (default)
    '01': [
      Color(0xFFF5F5F5), // Light gray
      Color(0xFFE0E0E0), // Medium gray
    ],

    // Theme 02: Light Blue
    '02': [
      Color(0xFFE3F2FD), // Very light blue
      Color(0xFF90CAF9), // Medium blue
    ],

    // Theme 03: Pink
    '03': [
      Color(0xFFFCE4EC), // Very light pink
      Color(0xFFF48FB1), // Medium pink
    ],

    // Theme 04: Yellow
    '04': [
      Color(0xFFFFF9C4), // Very light yellow
      Color(0xFFFFF176), // Medium yellow
    ],

    // Theme 05: Green
    '05': [
      Color(0xFFE8F5E9), // Very light green
      Color(0xFFA5D6A7), // Medium green
    ],

    // Theme 06: Orange
    '06': [
      Color(0xFFFFF3E0), // Very light orange
      Color(0xFFFFB74D), // Medium orange
    ],

    // Theme 07: Cyan
    '07': [
      Color(0xFFE1F5FE), // Very light cyan
      Color(0xFF81D4FA), // Medium cyan
    ],

    // Theme 08: Purple
    '08': [
      Color(0xFFF3E5F5), // Very light purple
      Color(0xFFCE93D8), // Medium purple
    ],

    // Theme 09: Brown
    '09': [
      Color(0xFFEFEBE9), // Very light brown
      Color(0xFFBCAAA4), // Medium brown
    ],
  };

  /// Default theme ID
  /// 
  /// Used as fallback when an invalid theme ID is provided
  static const String defaultThemeId = '01';

  /// Gradient direction configuration
  /// 
  /// TODO: Make this configurable per-theme or user-preference
  /// Currently hardcoded to topLeft → bottomRight
  static const Alignment gradientBegin = Alignment.topLeft;
  static const Alignment gradientEnd = Alignment.bottomRight;

  /// Returns LinearGradient for the given theme ID
  /// 
  /// Falls back to default theme if the provided ID is invalid.
  /// Supports 2+ color gradients automatically.
  /// 
  /// Example usage:
  /// ```dart
  /// Container(
  ///   decoration: BoxDecoration(
  ///     gradient: ThemeBackground.getGradient('02'),
  ///   ),
  /// )
  /// ```
  static LinearGradient getGradient(String themeId) {
    final colors = gradients[themeId] ?? gradients[defaultThemeId]!;

    return LinearGradient(
      begin: gradientBegin,
      end: gradientEnd,
      colors: colors,
    );
  }

  /// Returns list of all available theme IDs
  /// 
  /// Useful for building UI pickers that need to iterate through all themes.
  /// Order matches the definition order in the gradients map.
  /// 
  /// Example usage:
  /// ```dart
  /// GridView.builder(
  ///   itemCount: ThemeBackground.availableThemes.length,
  ///   itemBuilder: (context, index) {
  ///     final themeId = ThemeBackground.availableThemes[index];
  ///     return ThemeCard(themeId: themeId);
  ///   },
  /// )
  /// ```
  static List<String> get availableThemes => gradients.keys.toList();

  /// Check if the given theme ID exists
  /// 
  /// Returns true if the theme ID is valid, false otherwise.
  /// 
  /// Example usage:
  /// ```dart
  /// if (ThemeBackground.isValidTheme(userSelectedTheme)) {
  ///   applyTheme(userSelectedTheme);
  /// }
  /// ```
  static bool isValidTheme(String themeId) => gradients.containsKey(themeId);

  /// Get validated theme ID with fallback to default
  /// 
  /// Returns the provided theme ID if valid, otherwise returns default theme.
  /// Handles null input gracefully.
  /// 
  /// Example usage:
  /// ```dart
  /// // Loading from SharedPreferences
  /// final savedTheme = prefs.getString('theme');
  /// final validTheme = ThemeBackground.getValidThemeId(savedTheme);
  /// ```
  static String getValidThemeId(String? themeId) {
    return (themeId != null && isValidTheme(themeId)) ? themeId : defaultThemeId;
  }

  /// Get a representative single color for theme preview
  /// 
  /// This is an OPTIONAL helper method for compact UI elements.
  /// Returns a color that blends the gradient's start and end colors.
  /// 
  /// Use cases:
  /// - Small icon previews (< 50px)
  /// - Dropdown menu items
  /// - Notification indicators
  /// 
  /// For full gradient display (recommended), use getGradient() instead.
  /// 
  /// Example usage:
  /// ```dart
  /// // Small circular icon in toolbar
  /// CircleAvatar(
  ///   backgroundColor: ThemeBackground.getPreviewColor(currentTheme),
  ///   radius: 12,
  /// )
  /// ```
  static Color getPreviewColor(String themeId) {
    final colors = gradients[themeId] ?? gradients[defaultThemeId]!;

    // For 2-color gradients: blend at 50%
    // For 3+ color gradients: blend first and last color
    return Color.lerp(colors.first, colors.last, 0.5)!;
  }

  /// Get the raw color list for a theme
  /// 
  /// Advanced use case: if you need direct access to color stops
  /// for custom gradient implementations or color analysis.
  /// 
  /// Returns null if theme ID is invalid.
  /// 
  /// Example usage:
  /// ```dart
  /// final colors = ThemeBackground.getColors('03');
  /// if (colors != null && colors.length >= 3) {
  ///   // Custom handling for 3+ color gradients
  /// }
  /// ```
  static List<Color>? getColors(String themeId) {
    return gradients[themeId];
  }
}