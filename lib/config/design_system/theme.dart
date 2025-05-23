import 'package:flutter/material.dart';

class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // Color Constants - Main palette from the design
  static const Color primaryBlue = Color(0xFF0D4033);      // Deep green (replacing blue)
  static const Color secondaryBeige = Color(0xFFF5EFE0);   // Keeping original beige
  static const Color textDark = Color(0xFF333333);         // Keeping original dark text
  static const Color textLight = Colors.white;             // Keeping white text
  static const Color accentColor = Color(0xFF8B3A3A);      // Burgundy (replacing blue accent)
  
  // Additional colors from the design palette
  static const Color goldAccent = Color(0xFFCF9340);       // Gold/mustard 
  static const Color coralAccent = Color(0xFFE27069);      // Coral/salmon
  static const Color mintAccent = Color(0xFFE4F7D7);       // Mint green
  static const Color nudeAccent = Color(0xFFDEBAB0);       // Nude/blush

  // Font Constants
  static const String fontFamily = 'Montserrat';          // Keeping original font

  // Pre-computed color variants (integrated from color_extensions.dart)
  static Color primaryBlueLighter = _lighten(primaryBlue, 0.15);
  static Color primaryBlueDarker = _darken(primaryBlue, 0.15);
  static Color accentLighter = _lighten(accentColor, 0.15);
  static Color accentDarker = _darken(accentColor, 0.15);
  
  // Background opacity presets
  static Color primaryBlueBackground = primaryBlue.withOpacity(0.1);
  static Color accentBackground = accentColor.withOpacity(0.1);
  static Color goldAccentBackground = goldAccent.withOpacity(0.1);
  static Color coralAccentBackground = coralAccent.withOpacity(0.1);

  // Semantic background helpers
  static Color getBackgroundFor(Color color, [double opacity = 0.1]) => color.withOpacity(opacity);
  static Color getBorderFor(Color color, [double opacity = 0.3]) => color.withOpacity(opacity);
  
  // Get appropriate text color based on background color
  static Color getTextColorFor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? textDark : textLight;
  }
  
  // Create a Material Color swatch from a single color
  static MaterialColor createMaterialColor(Color color) {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    final r = color.red, g = color.green, b = color.blue;

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
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

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: primaryBlue,
    letterSpacing: 1.2,
  );

  static const TextStyle titleStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: primaryBlue,
  );

  static const TextStyle bodyStyle = TextStyle(
    fontSize: 16,
    color: textDark,
  );

  static const TextStyle buttonStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.2,
  );

  // The main theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryBeige,
      background: secondaryBeige,
      surface: Colors.white,
      tertiary: accentColor,
    ),
    scaffoldBackgroundColor: secondaryBeige,
    textTheme: const TextTheme(
      headlineLarge: headingStyle,
      titleLarge: titleStyle,
      bodyLarge: bodyStyle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: buttonStyle,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: primaryBlue,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
      iconTheme: IconThemeData(
        color: primaryBlue,
      ),
    ),
  );
}