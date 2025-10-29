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