// lib/widgets/common/frosted_glass_card.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../providers/theme_provider.dart';

/// Reusable frosted glass card widget matching calorie_summary_widget design
///
/// Creates a consistent glassmorphism appearance across the app using:
/// - Backdrop blur filter (10.0 sigma)
/// - Subtle background tint (black with 0.08 opacity)
/// - Theme-adaptive border color
/// - Rounded rectangle border radius (24.0)
///
/// Used in:
/// - Report sections
/// - Summary widgets
/// - Any widget requiring glassmorphism design
///
/// Example usage:
/// ```dart
/// FrostedGlassCard(
///   child: Text('Content goes here'),
///   padding: EdgeInsets.all(20),
/// )
/// ```
class FrostedGlassCard extends StatelessWidget {
  /// The child widget to display inside the frosted glass card
  final Widget child;

  /// Padding inside the card (defaults to AppWidgetTheme.spaceXL)
  final EdgeInsets? padding;

  /// Margin outside the card (defaults to horizontal spaceXL)
  final EdgeInsets? margin;

  /// Border radius (defaults to AppWidgetTheme.cardBorderRadius = 24.0)
  final double? borderRadius;

  /// Custom border color opacity (defaults to GlassCardStyle.borderOpacity = 0.3)
  final double? borderOpacity;

  /// Custom blur sigma (defaults to GlassCardStyle.blurSigma = 10.0)
  final double? blurSigma;

  const FrostedGlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.borderOpacity,
    this.blurSigma,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final effectiveBorderRadius = borderRadius ?? AppWidgetTheme.cardBorderRadius;
        final effectivePadding = padding ?? const EdgeInsets.all(AppWidgetTheme.spaceXL);
        final effectiveMargin = margin ?? const EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceXL);
        final effectiveBorderOpacity = borderOpacity ?? GlassCardStyle.borderOpacity;
        final effectiveBlurSigma = blurSigma ?? GlassCardStyle.blurSigma;

        // Get theme-adaptive border color
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          effectiveBorderOpacity,
        );

        return Container(
          margin: effectiveMargin,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: effectiveBlurSigma,
                sigmaY: effectiveBlurSigma,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                  borderRadius: BorderRadius.circular(effectiveBorderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: GlassCardStyle.borderWidth,
                  ),
                ),
                padding: effectivePadding,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
