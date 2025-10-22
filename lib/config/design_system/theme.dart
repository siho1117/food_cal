// lib/config/design_system/theme.dart
import 'package:flutter/material.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  // COLOR PALETTE
  // ═══════════════════════════════════════════════════════════════
  
  // Main colors
  static const Color primaryBlue = Color(0xFF0D4033);
  static const Color secondaryBeige = Color(0xFFF5EFE0);
  static const Color textDark = Color(0xFF333333);
  static const Color textLight = Colors.white;
  static const Color accentColor = Color(0xFF8B3A3A);
  
  // Additional accent colors
  static const Color goldAccent = Color(0xFFCF9340);
  static const Color coralAccent = Color(0xFFE27069);
  static const Color mintAccent = Color(0xFFE4F7D7);
  static const Color nudeAccent = Color(0xFFDEBAB0);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENT LIBRARY
  // ═══════════════════════════════════════════════════════════════
  
  /// Gradient presets - Light Mode
  static const Map<String, List<Color>> gradientsLight = {
    // iOS-inspired (purple/pink → blue) - Home screen
    'home': [
      Color(0xFFB8A3D6), // Soft purple
      Color(0xFFC4B5E3), // Purple-pink
      Color(0xFFB8D5F0), // Lavender-blue
      Color(0xFF9DC9F5), // Sky blue
      Color(0xFF7BB8F0), // Bright blue
    ],
    
    // Warm gradient (coral/peach → gold) - Could be used for Progress
    'warm': [
      Color(0xFFFFB5A7), // Soft coral
      Color(0xFFFFC9A3), // Peach
      Color(0xFFFFD6A5), // Light peach
      Color(0xFFFFE4B5), // Cream
      Color(0xFFFFF0C7), // Light gold
    ],
    
    // Cool gradient (mint → teal) - Could be used for Exercise
    'cool': [
      Color(0xFFB8E6E1), // Mint
      Color(0xFFA8DDD8), // Light teal
      Color(0xFF98D4CF), // Teal
      Color(0xFF88CBC6), // Deep teal
      Color(0xFF78C2BD), // Ocean teal
    ],
    
    // Minimal gradient (light beige → white) - Could be used for Settings
    'minimal': [
      Color(0xFFFAF6F0), // Very light beige
      Color(0xFFF9F5EF), // Light beige
      Color(0xFFF8F4EE), // Beige
      Color(0xFFF7F3ED), // Slightly darker beige
      Color(0xFFF5EFE0), // Your secondaryBeige
    ],
  };
  
  /// Gradient presets - Dark Mode
  static const Map<String, List<Color>> gradientsDark = {
    // Dark purple/blue - Home screen dark mode
    'home': [
      Color(0xFF2D1B4E), // Deep purple
      Color(0xFF2A1F52), // Dark purple-blue
      Color(0xFF1E2B4F), // Navy purple
      Color(0xFF1A2E4E), // Dark navy
      Color(0xFF162F4D), // Deep navy
    ],
    
    // Dark warm - Progress dark mode
    'warm': [
      Color(0xFF4A2C2A), // Dark burgundy
      Color(0xFF3F2B28), // Dark brown
      Color(0xFF342A26), // Darker brown
      Color(0xFF2E2925), // Deep brown
      Color(0xFF252320), // Almost black brown
    ],
    
    // Dark cool - Exercise dark mode
    'cool': [
      Color(0xFF1A3A37), // Dark teal
      Color(0xFF173532), // Darker teal
      Color(0xFF14302D), // Deep teal
      Color(0xFF112B28), // Very dark teal
      Color(0xFF0E2623), // Almost black teal
    ],
    
    // Dark minimal - Settings dark mode
    'minimal': [
      Color(0xFF1C1C1E), // iOS dark gray
      Color(0xFF1B1B1D), // Slightly darker
      Color(0xFF1A1A1C), // Darker
      Color(0xFF19191B), // Even darker
      Color(0xFF18181A), // Deep dark
    ],
  };
  
  /// Gradient stops (same for all gradients)
  static const List<double> gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
  
  /// Get gradient colors based on name and brightness
  static List<Color> getGradientColors(String name, Brightness brightness) {
    final gradients = brightness == Brightness.light ? gradientsLight : gradientsDark;
    return gradients[name] ?? gradientsLight['home']!; // Fallback to home if not found
  }
  
  /// Build LinearGradient from preset name
  static LinearGradient getGradient(
    String name, 
    Brightness brightness, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: getGradientColors(name, brightness),
      stops: gradientStops,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // COLOR UTILITIES
  // ═══════════════════════════════════════════════════════════════
  
  static Color primaryBlueLighter = _lighten(primaryBlue, 0.15);
  static Color primaryBlueDarker = _darken(primaryBlue, 0.15);
  static Color accentLighter = _lighten(accentColor, 0.15);
  static Color accentDarker = _darken(accentColor, 0.15);
  
  static Color primaryBlueBackground = primaryBlue.withValues(alpha: 0.1);
  static Color accentBackground = accentColor.withValues(alpha: 0.1);
  static Color goldAccentBackground = goldAccent.withValues(alpha: 0.1);
  static Color coralAccentBackground = coralAccent.withValues(alpha: 0.1);

  static Color getBackgroundFor(Color color, [double opacity = 0.1]) {
    return color.withValues(alpha: opacity);
  }
  
  static Color getBorderFor(Color color, [double opacity = 0.3]) {
    return color.withValues(alpha: opacity);
  }
  
  static Color getTextColorFor(Color backgroundColor) {
    return backgroundColor.computeLuminance() > 0.5 ? textDark : textLight;
  }
  
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
  
  static Color _lighten(Color color, double amount) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
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
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: secondaryBeige,
      surface: secondaryBeige,
      tertiary: accentColor,
    ),
    
    scaffoldBackgroundColor: secondaryBeige,
    
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: primaryBlue),
      displayMedium: AppTypography.displayMedium.copyWith(color: primaryBlue),
      displaySmall: AppTypography.displaySmall.copyWith(color: primaryBlue),
      headlineLarge: AppTypography.displayLarge.copyWith(color: primaryBlue),
      headlineMedium: AppTypography.displayMedium.copyWith(color: primaryBlue),
      headlineSmall: AppTypography.displaySmall.copyWith(color: primaryBlue),
      titleLarge: AppTypography.displayMedium.copyWith(color: textDark),
      titleMedium: AppTypography.displaySmall.copyWith(color: textDark),
      titleSmall: AppTypography.labelLarge.copyWith(color: textDark),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textDark),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textDark),
      bodySmall: AppTypography.bodySmall.copyWith(color: textDark),
      labelLarge: AppTypography.labelLarge.copyWith(color: textDark),
      labelMedium: AppTypography.labelMedium.copyWith(color: textDark),
      labelSmall: AppTypography.labelSmall.copyWith(color: textDark),
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: AppTypography.labelLarge,
      ),
    ),
    
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
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      labelStyle: AppTypography.bodyMedium.copyWith(color: textDark),
      hintStyle: AppTypography.bodyMedium.copyWith(color: Colors.grey[600]),
    ),
    
    cardTheme: CardTheme(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
    ),
  );
  
  // TODO: Add darkTheme when implementing dark mode
  static final ThemeData darkTheme = lightTheme.copyWith(
    brightness: Brightness.dark,
    // Will be expanded when dark mode is implemented
  );
}