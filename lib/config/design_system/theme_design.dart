// lib/config/design_system/theme_design.dart
import 'package:flutter/material.dart';

/// Core color primitives for the app
class AppColors {
  AppColors._();

  // Text colors
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Colors.white;
  static const Color textGrey = Color(0xFF666666);

  // Border colors
  static const Color borderLight = Colors.white;
  static const Color borderDark = Color(0xFF2A2A2A);

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color backgroundDark = Color(0xFF1A1A1A);

  /// Get border color for specific gradient theme
  /// Theme '01' uses black, all others use white
  static Color getBorderColorForTheme(String gradientId, double opacity) {
    final baseColor = gradientId == '01' ? Colors.black : Colors.white;
    return baseColor.withValues(alpha: opacity);
  }

  /// Get text color for specific gradient theme
  /// Theme '01' uses dark text, all others use white
  static Color getTextColorForTheme(String gradientId) {
    return gradientId == '01' ? textDark : textLight;
  }
}

/// Widget dimensions and layout constants
class AppDimensions {
  AppDimensions._();

  // Card styling
  static const double cardBorderWidth = 4.0;
  static const double cardBorderRadius = 28.0;
  static const EdgeInsets cardPadding = EdgeInsets.fromLTRB(24, 28, 24, 28);
}

/// Visual effects (opacity, shadows)
class AppEffects {
  AppEffects._();

  // Opacity values
  static const double borderOpacity = 0.8;
  static const double textOpacityPrimary = 1.0;
  static const double textOpacitySecondary = 0.7;

  // Text shadows (null = no shadows)
  static const List<Shadow>? textShadows = null;
}

/// Legacy widget design constants
/// Keep for backward compatibility - will be deprecated later
class AppWidgetDesign {
  AppWidgetDesign._();

  // Border styling
  static const double cardBorderWidth = AppDimensions.cardBorderWidth;
  static const double cardBorderRadius = AppDimensions.cardBorderRadius;
  static const double cardBorderOpacity = AppEffects.borderOpacity;
  static const Color cardBorderColor = Colors.white;

  // Text shadow policy
  static const List<Shadow>? textShadows = AppEffects.textShadows;

  // Standard card padding
  static const EdgeInsets cardPadding = AppDimensions.cardPadding;

  // Text opacity
  static const double primaryTextOpacity = AppEffects.textOpacityPrimary;
  static const double secondaryTextOpacity = AppEffects.textOpacitySecondary;
}

// ═══════════════════════════════════════════════════════════════
// LEGACY COLOR COMPATIBILITY (TEMPORARY)
// ═══════════════════════════════════════════════════════════════
// These colors are kept for backwards compatibility during migration.
// They will be removed once all widgets are updated to use the new design system.

/// Legacy colors from old theme.dart
/// @deprecated Will be removed in future versions
class AppLegacyColors {
  AppLegacyColors._();
  
  /// Legacy beige background color
  /// @deprecated Use AppColors.backgroundLight or ThemeBackground gradients
  static const Color secondaryBeige = Color(0xFFF5EFE0);
  
  /// Legacy blue accent color
  /// @deprecated Use AppColors.textDark for dark text/buttons
  static const Color primaryBlue = Color(0xFF0D4033);
  
  /// Legacy coral accent color
  /// @deprecated Use semantic colors from AppColors
  static const Color coralAccent = Color(0xFFE27069);
  
  /// Legacy gold accent color  
  /// @deprecated Use semantic colors from AppColors
  static const Color goldAccent = Color(0xFFCF9340);
  
  /// Legacy dark text color (already available in AppColors)
  /// @deprecated Use AppColors.textDark instead
  static const Color textDark = AppColors.textDark;
  
  /// Legacy light text color
  /// @deprecated Use AppColors.textLight instead
  static const Color textLight = Colors.white;
  
  /// Legacy accent color
  /// @deprecated Use semantic colors from AppColors
  static const Color accentColor = Color(0xFF8B3A3A);
}

// ═══════════════════════════════════════════════════════════════
// THEME CONFIGURATION (MINIMAL)
// ═══════════════════════════════════════════════════════════════

/// Minimal theme configuration
/// Provides neutral foundation - widgets handle their own styling
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.textDark,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: AppColors.textLight,
        surface: AppColors.backgroundDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
    );
  }
}