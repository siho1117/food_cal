import 'package:flutter/material.dart';
import '../design_system/theme.dart';
import '../widgets/widget_ui_design_standards.dart';

/// Collection of standardized BoxDecoration factories
/// 
/// This class reduces code duplication by centralizing commonly used
/// decoration patterns throughout the app.
class BoxDecorations {
  // Private constructor to prevent instantiation
  BoxDecorations._();

  /// Standard card decoration with white background and shadow
  static BoxDecoration card({
    double? borderRadius,
    double? elevation,
    Color? backgroundColor,
  }) {
    final radius = borderRadius ?? WidgetUIStandards.containerBorderRadius;
    final shadow = elevation ?? WidgetUIStandards.containerShadowOpacity;
    
    return BoxDecoration(
      color: backgroundColor ?? Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((shadow * 0.25 * 255).toInt()),
          blurRadius: shadow * 10,
          spreadRadius: 0,
          offset: Offset(0, shadow * 2),
        ),
      ],
    );
  }

  /// Card decoration with gradient background
  static BoxDecoration cardGradient({
    double? borderRadius,
    double? elevation,
    List<Color>? gradientColors,
    List<double>? gradientStops,
  }) {
    final radius = borderRadius ?? WidgetUIStandards.containerBorderRadius;
    final shadow = elevation ?? WidgetUIStandards.containerShadowOpacity;
    
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withAlpha((shadow * 0.25 * 255).toInt()),
          blurRadius: shadow * 10,
          spreadRadius: 0,
          offset: Offset(0, shadow * 2),
        ),
      ],
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors ?? [
          Colors.white,
          Colors.grey[50]!,
        ],
        stops: gradientStops ?? const [0.7, 1.0],
      ),
    );
  }

  /// Header container decoration - SIMPLIFIED
  static BoxDecoration header({
    Color? backgroundColor,
    double? borderRadius,
    bool topOnly = true,
  }) {
    final radius = borderRadius ?? WidgetUIStandards.containerBorderRadius;
    
    // Use simpler white background with very subtle grey tint
    final background = backgroundColor ?? Colors.grey[50];
    
    return BoxDecoration(
      color: background,
      // Use subtle bottom border instead of background color
      border: Border(
        bottom: BorderSide(
          color: Colors.grey[200]!,
          width: 1.0,
        ),
      ),
      borderRadius: topOnly
          ? BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            )
          : BorderRadius.circular(radius),
    );
  }

  /// Decoration for icon containers - SIMPLIFIED
  static BoxDecoration iconContainer({
    required Color color,
    double opacity = 0.1,
    double borderRadius = 8.0,
  }) {
    // Simplified, minimalist container with subtle background
    return BoxDecoration(
      color: color.withAlpha((opacity * 255).toInt()),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Circle container decoration for rounded icons - SIMPLIFIED
  static BoxDecoration circleIcon({
    required Color color,
    double opacity = 0.1,
  }) {
    // Simplified circle decoration
    return BoxDecoration(
      color: color.withAlpha((opacity * 255).toInt()),
      shape: BoxShape.circle,
    );
  }

  /// NEW: Simple info button decoration
  static BoxDecoration infoButton({
    Color? color,
    double size = 36.0,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      shape: BoxShape.circle,
      // Very subtle border for definition
      border: Border.all(
        color: Colors.grey[300]!,
        width: 1.0,
      ),
    );
  }

  /// Info box decoration for message containers
  static BoxDecoration infoBox({
    required Color color,
    double opacity = 0.05,
    double borderOpacity = 0.2,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      color: color.withAlpha((opacity * 255).toInt()),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: color.withAlpha((borderOpacity * 255).toInt()),
        width: 1,
      ),
    );
  }

  /// Badge decoration for status indicators
  static BoxDecoration badge({
    required Color color,
    double opacity = 0.1,
    double borderRadius = 12.0,
  }) {
    return BoxDecoration(
      color: color.withAlpha((opacity * 255).toInt()),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Progress bar container decoration
  static BoxDecoration progressBar({
    Color? backgroundColor,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? Colors.grey[200],
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  /// Progress indicator fill decoration with gradient
  static BoxDecoration progressFill({
    required Color color,
    double borderRadius = 8.0,
  }) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          color.withAlpha((0.7 * 255).toInt()),
          color,
        ],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }
}