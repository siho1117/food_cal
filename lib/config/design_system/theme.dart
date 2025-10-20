// lib/config/design_system/theme.dart
import 'package:flutter/material.dart';
import 'typography.dart'; // Import the new typography system

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════
  
  // Main colors
  static const Color primaryBlue = Color(0xFF0D4033);      // Deep green
  static const Color secondaryBeige = Color(0xFFF5EFE0);   // Beige background
  static const Color textDark = Color(0xFF333333);         // Dark text
  static const Color textLight = Colors.white;             // Light text
  static const Color accentColor = Color(0xFF8B3A3A);      // Burgundy accent
  
  // Additional accent colors
  static const Color goldAccent = Color(0xFFCF9340);       // Gold/mustard 
  static const Color coralAccent = Color(0xFFE27069);      // Coral/salmon
  static const Color mintAccent = Color(0xFFE4F7D7);       // Mint green
  static const Color nudeAccent = Color(0xFFDEBAB0);       // Nude/blush

  // ═══════════════════════════════════════════════════════════════
  // COLOR UTILITIES
  // ═══════════════════════════════════════════════════════════════
  
  // Pre-computed color variants
  static Color primaryBlueLighter = _lighten(primaryBlue, 0.15);
  static Color primaryBlueDarker = _darken(primaryBlue, 0.15);
  static Color accentLighter = _lighten(accentColor, 0.15);
  static Color accentDarker = _darken(accentColor, 0.15);
  
  // Background opacity presets
  static Color primaryBlueBackground = primaryBlue.withValues(alpha: 0.1);
  static Color accentBackground = accentColor.withValues(alpha: 0.1);
  static Color goldAccentBackground = goldAccent.withValues(alpha: 0.1);
  static Color coralAccentBackground = coralAccent.withValues(alpha: 0.1);

  // Semantic helpers for backgrounds and borders
  static Color getBackgroundFor(Color color, [double opacity = 0.1]) {
    return color.withValues(alpha: opacity);
  }
  
  static Color getBorderFor(Color color, [double opacity = 0.3]) {
    return color.withValues(alpha: opacity);
  }
  
  // Get appropriate text color based on background brightness
  static Color getTextColorFor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? textDark : textLight;
  }
  
  // Create a Material Color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        (r + ((ds < 0 ? r : (255 - r)) * ds)).round().clamp(0, 255),
        (g + ((ds < 0 ? g : (255 - g)) * ds)).round().clamp(0, 255),
        (b + ((ds < 0 ? b : (255 - b)) * ds)).round().clamp(0, 255),
        1,
      );
    }
    
    return MaterialColor(color.toARGB32(), swatch);
  }
  
  // Helper method to lighten colors
  static Color _lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  // Helper method to darken colors
  static Color _darken(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }

  // ═══════════════════════════════════════════════════════════════
  // THEME DATA
  // ═══════════════════════════════════════════════════════════════
  
  static final ThemeData lightTheme = ThemeData(
    // Color scheme
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryBeige,
      surface: secondaryBeige,
      tertiary: accentColor,
    ),
    
    scaffoldBackgroundColor: secondaryBeige,
    
    // Typography - NOW USING SYSTEM FONTS
    textTheme: TextTheme(
      // Display styles (headings, titles)
      displayLarge: AppTypography.displayLarge.copyWith(color: primaryBlue),
      displayMedium: AppTypography.displayMedium.copyWith(color: primaryBlue),
      displaySmall: AppTypography.displaySmall.copyWith(color: primaryBlue),
      
      // Headline styles (screen titles)
      headlineLarge: AppTypography.displayLarge.copyWith(color: primaryBlue),
      headlineMedium: AppTypography.displayMedium.copyWith(color: primaryBlue),
      headlineSmall: AppTypography.displaySmall.copyWith(color: primaryBlue),
      
      // Title styles (section headers)
      titleLarge: AppTypography.displayMedium.copyWith(color: textDark),
      titleMedium: AppTypography.displaySmall.copyWith(color: textDark),
      titleSmall: AppTypography.labelLarge.copyWith(color: textDark),
      
      // Body styles (content)
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textDark),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textDark),
      bodySmall: AppTypography.bodySmall.copyWith(color: textDark),
      
      // Label styles (buttons, UI elements)
      labelLarge: AppTypography.labelLarge.copyWith(color: textDark),
      labelMedium: AppTypography.labelMedium.copyWith(color: textDark),
      labelSmall: AppTypography.labelSmall.copyWith(color: textDark),
    ),
    
    // Button themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.labelLarge, // Use typography system
      ),
    ),
    
    // AppBar theme
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: AppTypography.displayMedium.copyWith(
        color: primaryBlue,
      ),
      iconTheme: const IconThemeData(
        color: primaryBlue,
      ),
    ),
    
    // Input decoration theme (form fields)
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: AppTypography.bodyMedium.copyWith(color: textDark),
      hintStyle: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
    ),
    
    // Card theme
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
  );
}