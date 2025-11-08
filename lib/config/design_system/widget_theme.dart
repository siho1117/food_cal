// lib/config/design_system/widget_theme.dart
import 'package:flutter/material.dart';

/// Widget styling constants for the NEW design system
///
/// This file contains design tokens for widget-level components (cards, containers, etc.)
/// that appear on main screens. For dialog-specific styling, see dialog_theme.dart.
///
/// This is part of the NEW design system and is independent from legacy theme files.
class AppWidgetTheme {
  AppWidgetTheme._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════
  // COLOR SYSTEM
  // ═══════════════════════════════════════════════════════════════

  /// Primary dark color (for text/icons on light backgrounds)
  static const Color colorPrimaryDark = Color(0xFF1A1A1A);

  /// Primary light color (for text/icons on dark backgrounds)
  static const Color colorPrimaryLight = Colors.white;

  /// Get text color based on gradient theme
  /// Theme '01' uses dark text, all others use white
  static Color getTextColor(String gradientId) {
    return gradientId == '01' ? colorPrimaryDark : colorPrimaryLight;
  }

  /// Get border color based on gradient theme with opacity
  /// Theme '01' uses black border, all others use white
  static Color getBorderColor(String gradientId, double opacity) {
    final baseColor = gradientId == '01' ? Colors.black : Colors.white;
    return baseColor.withValues(alpha: opacity);
  }

  /// Get solid avatar background color based on gradient theme
  /// Theme '01' uses black, all others use white
  static Color getAvatarColor(String gradientId) {
    return gradientId == '01' ? Colors.black : Colors.white;
  }

  // ═══════════════════════════════════════════════════════════════
  // CARD STYLING
  // ═══════════════════════════════════════════════════════════════

  /// Standard card border width
  static const double cardBorderWidth = 4.0;

  /// Standard card border radius
  static const double cardBorderRadius = 24.0;

  /// Card border opacity
  static const double cardBorderOpacity = 0.5;

  /// Standard card padding
  static const EdgeInsets cardPadding = EdgeInsets.all(20.0);

  /// Card with header padding (slightly more top padding)
  static const EdgeInsets cardPaddingWithHeader = EdgeInsets.fromLTRB(20, 20, 20, 20);

  // ═══════════════════════════════════════════════════════════════
  // WIDGET DIMENSIONS
  // ═══════════════════════════════════════════════════════════════

  /// Maximum width for cards/widgets
  static const double maxWidgetWidth = 700.0;

  /// Small icon container size
  static const double iconContainerSmall = 32.0;

  /// Medium icon container size
  static const double iconContainerMedium = 40.0;

  /// Large icon container size (avatar)
  static const double iconContainerLarge = 52.0;

  /// Small icon size
  static const double iconSizeSmall = 20.0;

  /// Medium icon size
  static const double iconSizeMedium = 24.0;

  /// Large icon size
  static const double iconSizeLarge = 28.0;

  // ═══════════════════════════════════════════════════════════════
  // BORDER RADIUS SCALE
  // ═══════════════════════════════════════════════════════════════

  /// Extra small border radius (buttons, chips)
  static const double borderRadiusXS = 8.0;

  /// Small border radius (list items, small cards)
  static const double borderRadiusSM = 12.0;

  /// Medium border radius (icon containers)
  static const double borderRadiusMD = 16.0;

  /// Large border radius (main cards)
  static const double borderRadiusLG = 24.0;

  /// Extra large border radius (pill shapes)
  static const double borderRadiusXL = 52.0;

  // ═══════════════════════════════════════════════════════════════
  // SPACING SCALE
  // ═══════════════════════════════════════════════════════════════

  /// Extra extra small spacing (3px)
  static const double spaceXXS = 3.0;

  /// Extra small spacing (6px)
  static const double spaceXS = 6.0;

  /// Small spacing (8px)
  static const double spaceSM = 8.0;

  /// Medium-small spacing (10px)
  static const double spaceMS = 10.0;

  /// Medium spacing (12px)
  static const double spaceMD = 12.0;

  /// Medium-large spacing (14px)
  static const double spaceML = 14.0;

  /// Large spacing (16px)
  static const double spaceLG = 16.0;

  /// Extra large spacing (20px)
  static const double spaceXL = 20.0;

  /// Extra extra large spacing (24px)
  static const double spaceXXL = 24.0;

  /// Extra extra extra large spacing (30px)
  static const double spaceXXXL = 30.0;

  // ═══════════════════════════════════════════════════════════════
  // TYPOGRAPHY SCALE
  // ═══════════════════════════════════════════════════════════════

  /// Extra small font size
  static const double fontSizeXS = 10.0;

  /// Small font size
  static const double fontSizeSM = 13.0;

  /// Medium-small font size
  static const double fontSizeMS = 14.0;

  /// Medium font size
  static const double fontSizeMD = 15.0;

  /// Medium-large font size
  static const double fontSizeML = 16.0;

  /// Large font size (widget headers)
  static const double fontSizeLG = 18.0;

  /// Extra large font size (profile names)
  static const double fontSizeXL = 24.0;

  /// Extra extra large font size (stats)
  static const double fontSizeXXL = 30.0;

  // ═══════════════════════════════════════════════════════════════
  // OPACITY SCALE
  // ═══════════════════════════════════════════════════════════════

  /// Very light opacity (background tints)
  static const double opacityVeryLight = 0.06;

  /// Light opacity (backgrounds)
  static const double opacityLight = 0.08;

  /// Medium-light opacity (hover states)
  static const double opacityMediumLight = 0.1;

  /// Medium opacity (disabled states)
  static const double opacityMedium = 0.15;

  /// Medium-high opacity (dividers)
  static const double opacityMediumHigh = 0.2;

  /// High opacity (icons, secondary text)
  static const double opacityHigh = 0.4;

  /// Very high opacity (secondary text)
  static const double opacityVeryHigh = 0.6;

  /// Higher opacity (emphasized secondary text)
  static const double opacityHigher = 0.7;

  /// Highest opacity (slightly muted primary text)
  static const double opacityHighest = 0.8;

  // ═══════════════════════════════════════════════════════════════
  // VISUAL EFFECTS
  // ═══════════════════════════════════════════════════════════════

  /// Text shadows (null = no shadows for NEW design)
  static const List<Shadow>? textShadows = null;

  /// Standard box shadow for elevated elements
  static BoxShadow get standardBoxShadow => BoxShadow(
    color: Colors.black.withValues(alpha: 0.1),
    blurRadius: 8,
    offset: const Offset(0, 2),
  );

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get background color with opacity based on theme and text color
  /// Used for interactive elements like buttons, list items, etc.
  static Color getBackgroundColor(Color textColor, double opacity) {
    return textColor == Colors.black
        ? Colors.black.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity);
  }

  /// Get icon container background color based on theme
  static Color getIconContainerColor(Color textColor, double opacity) {
    return textColor == Colors.black
        ? Colors.black.withValues(alpha: opacity)
        : Colors.black.withValues(alpha: opacity);
  }
}
