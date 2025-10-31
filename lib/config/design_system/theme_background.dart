import 'package:flutter/material.dart';

/// Background gradient themes for the app
/// 
/// Provides gradient definitions and utilities for theme selection.
/// This is a data layer class - it has no opinions about UI implementation.
/// The UI layer (theme_selector_dialog.dart) decides how to display these themes.
class ThemeBackground {
  /// Map of theme ID to gradient color stops
  /// 
  /// All gradients have 5 color tones, from top (darker) to bottom (lighter).
  /// Direction: topCenter → bottomCenter (vertical gradient).
  /// Theme '01' is the default.
  static const Map<String, List<Color>> gradients = {
    // Theme 01: Blue gradient (Image 1)
    '01': [
      Color(0xFF2280E6), // Tone 1 (top)
      Color(0xFF609DF1), // Tone 2
      Color(0xFF6EA1F7), // Tone 3
      Color(0xFF87A4F2), // Tone 4
      Color(0xFFBEAFEC), // Tone 5 (bottom)
    ],

    // Theme 02: Orange gradient (Image 2)
    '02': [
      Color(0xFFE55022), // Tone 1 (top)
      Color(0xFFF59D59), // Tone 2
      Color(0xFFFFC675), // Tone 3
      Color(0xFFFBDD8B), // Tone 4
      Color(0xFFDEEBA9), // Tone 5 (bottom)
    ],

    // Theme 03: Red/Coral gradient (Image 3)
    '03': [
      Color(0xFFE62A26), // Tone 1 (top)
      Color(0xFFF86E64), // Tone 2
      Color(0xFFFF9285), // Tone 3
      Color(0xFFFFB197), // Tone 4
      Color(0xFFEACC98), // Tone 5 (bottom)
    ],

    // Theme 04: Gray gradient (Image 4)
    '04': [
      Color(0xFF909090), // Tone 1 (top)
      Color(0xFFC6C6C6), // Tone 2
      Color(0xFFE1E1E1), // Tone 3
      Color(0xFFD5D5D5), // Tone 4
      Color(0xFFEEEFEF), // Tone 5 (bottom)
    ],

    // Theme 05: Teal/Blue gradient (Image 5)
    '05': [
      Color(0xFF2E8AB2), // Tone 1 (top)
      Color(0xFF79A8BA), // Tone 2
      Color(0xFFA1BBC1), // Tone 3
      Color(0xFFBDD1DA), // Tone 4
      Color(0xFFD0D6E3), // Tone 5 (bottom)
    ],

    // Theme 06: Green gradient (Image 6)
    '06': [
      Color(0xFF339632), // Tone 1 (top)
      Color(0xFF86B481), // Tone 2
      Color(0xFFB3C5AC), // Tone 3
      Color(0xFFC8DBC5), // Tone 4
      Color(0xFFD0DFD9), // Tone 5 (bottom)
    ],

    // Theme 07: Dark/Black gradient (Image 7)
    '07': [
      Color(0xFF070707), // Tone 1 (top)
      Color(0xFF141413), // Tone 2
      Color(0xFF1B1B1B), // Tone 3
      Color(0xFF4D4D4D), // Tone 4
      Color(0xFF717171), // Tone 5 (bottom)
    ],

    // Theme 08: Dark Blue gradient (Image 8)
    '08': [
      Color(0xFF0160B1), // Tone 1 (top)
      Color(0xFF044870), // Tone 2
      Color(0xFF073E51), // Tone 3
      Color(0xFF3F6B83), // Tone 4
      Color(0xFF7F89A8), // Tone 5 (bottom)
    ],

    // Theme 09: Yellow/Green gradient (Image 9)
    '09': [
      Color(0xFFDBB426), // Tone 1 (top)
      Color(0xFFE5D462), // Tone 2
      Color(0xFFEBE57F), // Tone 3
      Color(0xFFD4DB60), // Tone 4
      Color(0xFFD3F1BF), // Tone 5 (bottom)
    ],
  };

  /// Default theme ID
  /// 
  /// Used as fallback when an invalid theme ID is provided
  static const String defaultThemeId = '01';

  /// Gradient direction configuration
  /// 
  /// Vertical gradient: top (darker) → bottom (lighter)
  static const Alignment gradientBegin = Alignment.topCenter;
  static const Alignment gradientEnd = Alignment.bottomCenter;

  /// Returns LinearGradient for the given theme ID
  /// 
  /// Falls back to default theme if the provided ID is invalid.
  /// All gradients have 5 color stops.
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
  /// Returns the middle color (Tone 3) of the 5-tone gradient.
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

    // Return the middle color (Tone 3 of 5)
    return colors[2];
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
  /// if (colors != null) {
  ///   // Custom gradient processing
  ///   final darkestColor = colors.first;
  ///   final lightestColor = colors.last;
  /// }
  /// ```
  static List<Color>? getColors(String themeId) {
    return gradients[themeId];
  }
}