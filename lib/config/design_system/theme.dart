// lib/config/design_system/theme.dart
import 'package:flutter/material.dart';
import 'typography.dart';

class AppTheme {
  AppTheme._();

  // ═══════════════════════════════════════════════════════════════
  // COLOR PALETTE - SIMPLIFIED (White/Black/Grey Tones)
  // ═══════════════════════════════════════════════════════════════
  
  // Core colors (neutral tones only)
  static const Color textDark = Color(0xFF1A1A1A);      // Almost black for light backgrounds
  static const Color textLight = Colors.white;          // White for dark backgrounds
  static const Color textGrey = Color(0xFF666666);      // Grey for secondary text
  
  // UI element colors
  static const Color borderLight = Colors.white;        // White borders for dark backgrounds
  static const Color borderDark = Color(0xFF2A2A2A);    // Dark borders for light backgrounds
  
  // Background colors (for non-gradient elements)
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF1A1A1A);
  
  // Legacy colors (kept for backward compatibility, will be phased out)
  static const Color primaryBlue = Color(0xFF0D4033);   // Used in some old widgets
  static const Color secondaryBeige = Color(0xFFF5EFE0); // Used in some old widgets
  static const Color accentColor = Color(0xFF8B3A3A);   // Used in some old widgets
  static const Color goldAccent = Color(0xFFCF9340);
  static const Color coralAccent = Color(0xFFE27069);
  static const Color mintAccent = Color(0xFFE4F7D7);
  static const Color nudeAccent = Color(0xFFDEBAB0);

  // ═══════════════════════════════════════════════════════════════
  // GRADIENT LIBRARY - NUMBERED THEMES (01-09)
  // ═══════════════════════════════════════════════════════════════
  
  /// Gradient presets - Light Mode (numbered 01-09)
  /// UPDATED: More subtle, sophisticated color transitions
  /// Smaller color variations for smooth, elegant look
  static const Map<String, List<Color>> gradientsLight = {
    // 01 - Light Gray/Minimal (very subtle gray shifts)
    '01': [
      Color(0xFFE8E8E8), // Very light gray
      Color(0xFFE3E3E3), // Slightly darker
      Color(0xFFDEDEDE), // Light gray
      Color(0xFFD9D9D9), // Medium-light gray
      Color(0xFFD4D4D4), // Medium gray
    ],
    
    // 02 - Dark/Midnight (from IMG_5961.PNG)
    '02': [
      Color(0xFF2C2C2C), // Very dark gray
      Color(0xFF272727), // Dark gray
      Color(0xFF222222), // Darker
      Color(0xFF1D1D1D), // Very dark
      Color(0xFF181818), // Almost black
    ],
    
    // 03 - Purple Blue (subtle purple-blue wash)
    '03': [
      Color(0xFFC5B8DC), // Soft purple
      Color(0xFFC2B8E0), // Purple-lavender
      Color(0xFFBFBDE4), // Lavender-blue
      Color(0xFFBCC2E8), // Blue-lavender
      Color(0xFFB9C7EC), // Soft blue
    ],
    
    // 04 - Warm Sunrise (subtle warm gradient)
    '04': [
      Color(0xFFFFE5C2), // Light peach
      Color(0xFFFFE0BC), // Peach
      Color(0xFFFFDBB6), // Warm peach
      Color(0xFFFFD6B0), // Golden peach
      Color(0xFFFFD1AA), // Warm gold
    ],
    
    // 05 - Coral/Pink (subtle coral wash)
    '05': [
      Color(0xFFFFDDD6), // Very light coral
      Color(0xFFFFD8D0), // Light coral
      Color(0xFFFFD3CA), // Soft coral
      Color(0xFFFFCEC4), // Coral
      Color(0xFFFFC9BE), // Warm coral
    ],
    
    // 06 - Ocean Blue (SUBTLE like your reference image!)
    '06': [
      Color(0xFFD4E8EE), // Very light blue
      Color(0xFFCDE4EB), // Light blue
      Color(0xFFC6E0E8), // Soft blue
      Color(0xFFBFDCE5), // Blue
      Color(0xFFB8D8E2), // Ocean blue
    ],
    
    // 07 - Mint Green (subtle mint wash)
    '07': [
      Color(0xFFE0F0E0), // Very light mint
      Color(0xFFDBECDB), // Light mint
      Color(0xFFD6E8D6), // Soft mint
      Color(0xFFD1E4D1), // Mint
      Color(0xFFCCE0CC), // Green mint
    ],
    
    // 08 - Warm Peach (subtle warm wash)
    '08': [
      Color(0xFFFFE5D9), // Very light peach
      Color(0xFFFFE0D3), // Light peach
      Color(0xFFFFDBCD), // Soft peach
      Color(0xFFFFD6C7), // Peach
      Color(0xFFFFD1C1), // Warm peach
    ],
    
    // 09 - Cool Teal (subtle teal wash)
    '09': [
      Color(0xFFD9F0ED), // Very light teal
      Color(0xFFD3ECE9), // Light teal
      Color(0xFFCDE8E5), // Soft teal
      Color(0xFFC7E4E1), // Teal
      Color(0xFFC1E0DD), // Cool teal
    ],
  };
  
  /// Gradient presets - Dark Mode (numbered 01-09)
  /// Updated to have VISIBLE color tones, not just dark gray
  static const Map<String, List<Color>> gradientsDark = {
    // 01 - Dark Gray (keep as gray for consistency)
    '01': [
      Color(0xFF3A3A3A), // Dark gray
      Color(0xFF333333), // Darker gray
      Color(0xFF2C2C2C), // Very dark gray
      Color(0xFF252525), // Almost black
      Color(0xFF1E1E1E), // Near black
    ],
    
    // 02 - Midnight (pure dark - keep as is)
    '02': [
      Color(0xFF1C1C1C), // Very dark
      Color(0xFF151515), // Darker
      Color(0xFF0E0E0E), // Almost black
      Color(0xFF080808), // Near black
      Color(0xFF000000), // Black
    ],
    
    // 03 - Dark Purple (COLORFUL dark mode)
    '03': [
      Color(0xFF4A3B5C), // Dark purple
      Color(0xFF3D334F), // Darker purple
      Color(0xFF2F2A42), // Deep purple
      Color(0xFF252036), // Very dark purple
      Color(0xFF1A1729), // Almost black purple
    ],
    
    // 04 - Dark Warm (COLORFUL - orange/brown tones)
    '04': [
      Color(0xFF5C4A33), // Dark warm brown
      Color(0xFF4F3D28), // Darker brown
      Color(0xFF42311E), // Deep brown
      Color(0xFF362616), // Very dark brown
      Color(0xFF291B0F), // Almost black brown
    ],
    
    // 05 - Dark Coral (COLORFUL - burgundy/wine tones)
    '05': [
      Color(0xFF5C3B3B), // Dark coral/burgundy
      Color(0xFF4F3030), // Darker burgundy
      Color(0xFF422626), // Deep burgundy
      Color(0xFF361E1E), // Very dark burgundy
      Color(0xFF291616), // Almost black burgundy
    ],
    
    // 06 - Dark Ocean (COLORFUL - teal/navy tones)
    '06': [
      Color(0xFF2D4A52), // Dark teal
      Color(0xFF253D44), // Darker teal
      Color(0xFF1E3137), // Deep teal
      Color(0xFF18262B), // Very dark teal
      Color(0xFF121B1F), // Almost black teal
    ],
    
    // 07 - Dark Mint (COLORFUL - forest green tones)
    '07': [
      Color(0xFF2D4A3B), // Dark mint/forest
      Color(0xFF253D32), // Darker green
      Color(0xFF1E3129), // Deep green
      Color(0xFF182621), // Very dark green
      Color(0xFF121B18), // Almost black green
    ],
    
    // 08 - Dark Warm Coral (COLORFUL - rust tones)
    '08': [
      Color(0xFF5C4539), // Dark rust
      Color(0xFF4F3A2F), // Darker rust
      Color(0xFF422F26), // Deep rust
      Color(0xFF36251E), // Very dark rust
      Color(0xFF291B16), // Almost black rust
    ],
    
    // 09 - Dark Cool Teal (COLORFUL - deep teal)
    '09': [
      Color(0xFF2D4A47), // Dark teal
      Color(0xFF253D3B), // Darker teal
      Color(0xFF1E312F), // Deep teal
      Color(0xFF182624), // Very dark teal
      Color(0xFF121B1A), // Almost black teal
    ],
  };
  
  /// Gradient stops (same for all gradients)
  static const List<double> gradientStops = [0.0, 0.25, 0.5, 0.75, 1.0];
  
  /// OPTION C: Predefined themed pairs for each gradient
  /// Each theme has manually defined text and border colors
  /// 
  /// User Specification:
  /// - White text (NO opacity) + White border (40%) for all themes EXCEPT Theme 01
  /// - Black text (NO opacity) + Black border (40%) ONLY for Theme 01 (Light Gray)
  
  /// Get predefined border color for specific theme
  static Color getBorderColor(String gradientName, Brightness brightness) {
    // Theme 01 (Light Gray) uses black border
    if (gradientName == '01') {
      return Colors.black.withValues(alpha: 0.4);  // 40% black border
    }
    
    // All other themes (02-09) use white border
    return Colors.white.withValues(alpha: 0.4);  // 40% white border
  }
  
  /// Get predefined text color for specific theme
  static Color getTextColor(String gradientName, Brightness brightness) {
    // Theme 01 (Light Gray) uses black text
    if (gradientName == '01') {
      return textDark;  // Solid black (NO opacity)
    }
    
    // All other themes (02-09) use white text
    return Colors.white;  // Solid white (NO opacity)
  }
  
  /// Get gradient colors based on name and brightness
  static List<Color> getGradientColors(String name, Brightness brightness) {
    final gradients = brightness == Brightness.light ? gradientsLight : gradientsDark;
    return gradients[name] ?? gradientsLight['03']!; // Fallback to 03 (purple) if not found
  }
  
  /// Build LinearGradient from preset name
  static LinearGradient getGradient(
    String name, 
    Brightness brightness, {
    Alignment begin = Alignment.topLeft,
    Alignment end = Alignment.bottomRight,
  }) {
    final colors = getGradientColors(name, brightness);
    
    // REVERSED: Darker tones at top, lighter at bottom
    // User requested to rotate gradient 180 degrees
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors.reversed.toList(), // ← REVERSED order
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
    
    appBarTheme: const AppBarTheme(
      backgroundColor: secondaryBeige,
      foregroundColor: primaryBlue,
      elevation: 0,
      centerTitle: true,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: primaryBlue,
      secondary: secondaryBeige,
      surface: Color(0xFF1E1E1E),
      tertiary: accentColor,
    ),
    
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    textTheme: TextTheme(
      displayLarge: AppTypography.displayLarge.copyWith(color: textLight),
      displayMedium: AppTypography.displayMedium.copyWith(color: textLight),
      displaySmall: AppTypography.displaySmall.copyWith(color: textLight),
      headlineLarge: AppTypography.displayLarge.copyWith(color: textLight),
      headlineMedium: AppTypography.displayMedium.copyWith(color: textLight),
      headlineSmall: AppTypography.displaySmall.copyWith(color: textLight),
      titleLarge: AppTypography.displayMedium.copyWith(color: textLight),
      titleMedium: AppTypography.displaySmall.copyWith(color: textLight),
      titleSmall: AppTypography.labelLarge.copyWith(color: textLight),
      bodyLarge: AppTypography.bodyLarge.copyWith(color: textLight),
      bodyMedium: AppTypography.bodyMedium.copyWith(color: textLight),
      bodySmall: AppTypography.bodySmall.copyWith(color: textLight),
      labelLarge: AppTypography.labelLarge.copyWith(color: textLight),
      labelMedium: AppTypography.labelMedium.copyWith(color: textLight),
      labelSmall: AppTypography.labelSmall.copyWith(color: textLight),
    ),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: textLight,
      elevation: 0,
      centerTitle: true,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: textLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
    ),
    
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryBlue, width: 2),
      ),
    ),
  );
}

// ═══════════════════════════════════════════════════════════════
// SHARED WIDGET DESIGN TOKENS
// ═══════════════════════════════════════════════════════════════

/// Shared card/widget design system
/// Used by 10+ widgets for consistent iOS-inspired styling
class AppWidgetDesign {
  AppWidgetDesign._(); // Private constructor to prevent instantiation
  
  // Border styling (iOS-inspired borders with 40% opacity)
  static const double cardBorderWidth = 4.0;
  static const double cardBorderRadius = 28.0;
  static const double cardBorderOpacity = 0.4;  // Updated to 40% per user request
  static const Color cardBorderColor = Colors.white;
  
  // Text shadow policy - NO SHADOWS for clean, modern look
  static const List<Shadow>? textShadows = null;
  
  // Standard card padding
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(24, 28, 24, 28);
  
  // Text opacity - NO OPACITY for solid text (per user request)
  static const double primaryTextOpacity = 1.0;   // Solid text (was 0.9)
  static const double secondaryTextOpacity = 0.7; // Secondary text (can keep)
}