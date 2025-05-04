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