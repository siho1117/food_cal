// lib/config/design_system/widget_theme.dart
import 'package:flutter/material.dart';
import 'theme_background.dart';
import 'color_utils.dart';

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

  /// Get dynamic accent color based on theme background
  /// Uses complementary color theory to create visual interest
  ///
  /// This color is used for:
  /// - Food card background color
  /// - Calorie summary icon color
  /// - Other widget accent elements
  ///
  /// Example:
  /// ```dart
  /// final accentColor = AppWidgetTheme.getAccentColor(
  ///   context.watch<ThemeProvider>().selectedGradient,
  /// );
  /// ```
  static Color getAccentColor(String gradientId) {
    // Get Tone 2 from the background gradient
    final backgroundColor = ThemeBackground.getColors(gradientId)?[1] ??
        ThemeBackground.getColors(ThemeBackground.defaultThemeId)![1];

    // Calculate complementary color
    final complementary = ColorUtils.getComplementaryColor(backgroundColor);

    // Map to nearest accent color from palette
    return ColorUtils.findNearestAccentColor(complementary);
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASSMORPHISM / BLUR CARD EFFECTS
// ═══════════════════════════════════════════════════════════════

/// Refined glassmorphism card styling for widgets with blur backdrop effects
///
/// This style creates a frosted glass appearance with:
/// - Subtle blur backdrop filter
/// - Thin, semi-transparent border
/// - Light background tint
///
/// Usage example:
/// ```dart
/// ClipRRect(
///   borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
///   child: BackdropFilter(
///     filter: ImageFilter.blur(
///       sigmaX: GlassCardStyle.blurSigma,
///       sigmaY: GlassCardStyle.blurSigma,
///     ),
///     child: Container(
///       decoration: BoxDecoration(
///         color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
///         border: Border.all(
///           color: borderColor,
///           width: GlassCardStyle.borderWidth,
///         ),
///       ),
///     ),
///   ),
/// )
/// ```
class GlassCardStyle {
  GlassCardStyle._(); // Private constructor to prevent instantiation

  /// Refined border width (thinner than default for delicate look)
  static const double borderWidth = 1.0;

  /// Refined border opacity (lighter than default 0.5 for subtle appearance)
  static const double borderOpacity = 0.3;

  /// Blur intensity for backdrop filter (standard glassmorphism effect)
  static const double blurSigma = 10.0;

  /// Background tint opacity (subtle darkening/lightening)
  /// Works with both black and white tints
  static const double backgroundTintOpacity = 0.08;
}

/// Frosted pill glassmorphism style
///
/// This style creates a frosted glass pill appearance with:
/// - Light blur backdrop filter (5.0 sigma)
/// - Fully transparent background
/// - White semi-transparent border (0.6 opacity)
/// - Pill-shaped border radius (34.0)
///
/// Used in:
/// - Custom bottom navigation
/// - Summary controls widget
/// - Report sections
///
/// Usage example:
/// ```dart
/// ClipRRect(
///   borderRadius: BorderRadius.circular(FrostedPillStyle.borderRadius),
///   child: BackdropFilter(
///     filter: ImageFilter.blur(
///       sigmaX: FrostedPillStyle.blurSigma,
///       sigmaY: FrostedPillStyle.blurSigma,
///     ),
///     child: Container(
///       decoration: BoxDecoration(
///         color: Colors.white.withValues(alpha: FrostedPillStyle.backgroundTintOpacity),
///         borderRadius: BorderRadius.circular(FrostedPillStyle.borderRadius),
///         border: Border.all(
///           color: Colors.white.withValues(alpha: FrostedPillStyle.borderOpacity),
///           width: FrostedPillStyle.borderWidth,
///         ),
///       ),
///     ),
///   ),
/// )
/// ```
class FrostedPillStyle {
  FrostedPillStyle._(); // Private constructor to prevent instantiation

  /// Thin border width for delicate frosted appearance
  static const double borderWidth = 1.0;

  /// White border opacity for frosted glass effect
  static const double borderOpacity = 0.6;

  /// Light blur intensity for subtle frosted effect
  static const double blurSigma = 5.0;

  /// Fully transparent background (no tint)
  static const double backgroundTintOpacity = 0.0;

  /// Pill-shaped border radius (matches custom bottom nav)
  static const double borderRadius = 34.0;
}

// ═══════════════════════════════════════════════════════════════
// REPORT COLORS (WHITE BACKGROUND PROFESSIONAL STYLE)
// ═══════════════════════════════════════════════════════════════

/// Color scheme for professional white background reports
/// Used in summary/export widgets for maximum readability and print-friendliness
class ReportColors {
  ReportColors._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════
  // TEXT COLORS (HIERARCHICAL)
  // ═══════════════════════════════════════════════════════════════

  /// Primary text color for main content, values, and data
  /// High emphasis - Material Design 87% black
  static const Color textPrimary = Color(0xFF212121); // grey.shade900

  /// Secondary text color for labels and headings
  /// Medium emphasis - Material Design 60% black
  static const Color textSecondary = Color(0xFF616161); // grey.shade700

  /// Tertiary text color for helper text and metadata
  /// Disabled/subtle - Material Design 38% black
  static const Color textTertiary = Color(0xFF757575); // grey.shade600

  // ═══════════════════════════════════════════════════════════════
  // BACKGROUND COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Pure white background for professional reports
  static const Color background = Colors.white;

  /// Light grey background for subtle sections
  static const Color backgroundSubtle = Color(0xFFFAFAFA); // grey.shade50

  // ═══════════════════════════════════════════════════════════════
  // BORDER AND DIVIDER COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Standard border color
  static const Color border = Color(0xFFE0E0E0); // grey.shade300

  /// Light divider color
  static const Color divider = Color(0xFFEEEEEE); // grey.shade200

  /// Subtle divider color
  static const Color dividerSubtle = Color(0xFFF5F5F5); // grey.shade100

  // ═══════════════════════════════════════════════════════════════
  // SEMANTIC COLORS (CONVEYING MEANING)
  // ═══════════════════════════════════════════════════════════════

  /// Positive values (goal achieved, weight loss, etc.)
  static const Color positive = Color(0xFF388E3C); // green.shade700

  /// Negative values (over budget, weight gain, etc.)
  static const Color negative = Color(0xFFD32F2F); // red.shade700

  /// Neutral highlight (current value, info)
  static const Color neutral = Color(0xFF1976D2); // blue.shade700

  /// Warning (approaching limit, caution)
  static const Color warning = Color(0xFFF57C00); // orange.shade700

  // ═══════════════════════════════════════════════════════════════
  // ICON AND ACCENT COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Icon background color (subtle grey)
  static const Color iconBackground = Color(0xFFF5F5F5); // grey.shade100

  /// Icon color (medium grey for neutral icons)
  static const Color iconNeutral = Color(0xFF9E9E9E); // grey.shade500

  // ═══════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ═══════════════════════════════════════════════════════════════

  /// Get semantic color based on comparison (positive/negative/neutral)
  /// Use for displaying deltas, comparisons, goal progress
  static Color getSemanticColor({
    required double value,
    bool higherIsBetter = true,
  }) {
    if (value == 0) return neutral;
    if (higherIsBetter) {
      return value > 0 ? positive : negative;
    } else {
      return value > 0 ? negative : positive;
    }
  }

  /// Get text color based on hierarchy level (1 = primary, 2 = secondary, 3 = tertiary)
  static Color getTextColorByLevel(int level) {
    switch (level) {
      case 1:
        return textPrimary;
      case 2:
        return textSecondary;
      case 3:
        return textTertiary;
      default:
        return textPrimary;
    }
  }
}
