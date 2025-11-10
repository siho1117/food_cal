// lib/config/design_system/summary_theme.dart
import 'package:flutter/material.dart';
import 'typography.dart';

/// Design system for Summary/Export widgets
/// Ensures consistent styling across all summary report sections
class SummaryTheme {
  // Private constructor to prevent instantiation
  SummaryTheme._();

  // ============================================================================
  // COLORS
  // ============================================================================

  /// Primary brand color for headers and accents
  static const Color primary = Color(0xFF0D4033);

  /// Secondary brand color for gradients
  static const Color secondary = Color(0xFF1A237E);

  /// Success/positive indicators
  static const Color success = Color(0xFF4CAF50);

  /// Warning/caution indicators
  static const Color warning = Color(0xFFFF9800);

  /// Error/negative indicators
  static const Color error = Color(0xFFF44336);

  /// Neutral background
  static const Color background = Colors.white;

  /// Section background
  static final Color sectionBackground = Colors.grey[50]!;

  /// Border color
  static final Color border = Colors.grey[300]!;

  /// Text colors
  static final Color textPrimary = Colors.grey[800]!;
  static final Color textSecondary = Colors.grey[600]!;
  static final Color textHint = Colors.grey[500]!;

  /// Macro colors (nutrition)
  static final Color proteinColor = Colors.red[600]!;
  static final Color carbsColor = Colors.orange[600]!;
  static final Color fatColor = Colors.blue[600]!;

  /// Metric colors
  static final Color caloriesColor = Colors.blue[600]!;
  static final Color exerciseColor = Colors.green[600]!;
  static final Color budgetColor = Colors.teal[600]!;

  // ============================================================================
  // TYPOGRAPHY
  // ============================================================================

  /// Report title (main header)
  static TextStyle get reportTitle => AppTypography.displayLarge.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: 1.5,
      );

  /// Report subtitle (under main header)
  static TextStyle get reportSubtitle => AppTypography.bodyMedium.copyWith(
        fontSize: 14,
        color: Colors.white70,
      );

  /// Section header
  static TextStyle get sectionHeader => AppTypography.displaySmall.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primary,
        letterSpacing: 0.8,
      );

  /// Info label (left side of key-value pairs)
  static TextStyle get infoLabel => AppTypography.bodyMedium.copyWith(
        fontSize: 12,
        color: textSecondary,
      );

  /// Info value (right side of key-value pairs)
  static TextStyle get infoValue => AppTypography.bodyMedium.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textPrimary,
      );

  /// Data label (larger values)
  static TextStyle get dataLabel => AppTypography.labelLarge.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      );

  /// Small descriptive text
  static TextStyle get bodySmall => AppTypography.bodySmall.copyWith(
        fontSize: 11,
        color: textSecondary,
      );

  /// Italic helper text
  static TextStyle get helperText => AppTypography.bodySmall.copyWith(
        fontSize: 11,
        color: textSecondary,
        fontStyle: FontStyle.italic,
      );

  /// Metric value (large numbers)
  static TextStyle get metricValue => AppTypography.labelLarge.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      );

  // ============================================================================
  // DECORATIONS
  // ============================================================================

  /// Main report header decoration (gradient)
  static BoxDecoration get headerDecoration => BoxDecoration(
        gradient: const LinearGradient(
          colors: [secondary, primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      );

  /// Section container decoration
  static BoxDecoration get sectionDecoration => BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      );

  /// Subsection background decoration
  static BoxDecoration get subsectionDecoration => BoxDecoration(
        color: sectionBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
      );

  /// Footer decoration
  static BoxDecoration get footerDecoration => BoxDecoration(
        color: sectionBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: border),
      );

  /// Progress bar decoration
  static BoxDecoration progressBarDecoration(Color color) => BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      );

  // ============================================================================
  // DIMENSIONS
  // ============================================================================

  /// Standard padding for sections
  static const double sectionPadding = 16.0;

  /// Padding for main container
  static const double containerPadding = 24.0;

  /// Spacing between sections
  static const double sectionSpacing = 20.0;

  /// Spacing within sections
  static const double itemSpacing = 12.0;

  /// Small spacing
  static const double smallSpacing = 8.0;

  /// Border radius for cards
  static const double cardRadius = 8.0;

  /// Border radius for subsections
  static const double subsectionRadius = 12.0;

  /// Progress bar height
  static const double progressBarHeight = 8.0;

  /// Divider height
  static const double dividerHeight = 20.0;

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Get status color based on progress
  static Color getStatusColor(String status) {
    switch (status) {
      case 'on_track':
      case 'success':
      case 'excellent':
        return success;
      case 'over':
      case 'warning':
      case 'moderate':
        return warning;
      case 'under':
      case 'error':
      case 'low':
        return error;
      default:
        return textSecondary;
    }
  }

  /// Get color for percentage progress (0.0 - 1.0)
  static Color getProgressColor(double progress) {
    if (progress >= 0.9 && progress <= 1.1) {
      return success;
    } else if (progress > 1.1) {
      return warning;
    } else {
      return error;
    }
  }

  /// Build info row spacing
  static Widget get infoRowSpacing => const SizedBox(height: 8);

  /// Build section spacing
  static Widget get sectionSpacingWidget => const SizedBox(height: sectionSpacing);

  /// Build item spacing
  static Widget get itemSpacingWidget => const SizedBox(height: itemSpacing);

  /// Build small spacing
  static Widget get smallSpacingWidget => const SizedBox(height: smallSpacing);
}
