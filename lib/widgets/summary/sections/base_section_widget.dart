// lib/widgets/summary/sections/base_section_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';

/// Base widget for all summary report sections
/// Uses professional white background with ReportColors for maximum readability
class BaseSectionWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const BaseSectionWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Get theme color for icon accent (keeps visual interest)
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final iconAccentColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceXL),
          padding: EdgeInsets.all(AppWidgetTheme.cardPadding.top),
          decoration: BoxDecoration(
            color: ReportColors.background,
            border: Border.all(
              color: ReportColors.border,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section Header
              Row(
                children: [
                  Icon(
                    icon,
                    size: AppWidgetTheme.iconSizeMedium,
                    color: iconAccentColor, // Keep theme color for visual interest
                  ),
                  SizedBox(width: AppWidgetTheme.spaceSM),
                  Text(
                    title,
                    style: AppTypography.displaySmall.copyWith(
                      fontSize: AppWidgetTheme.fontSizeML,
                      fontWeight: FontWeight.bold,
                      color: ReportColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Divider(
                height: AppWidgetTheme.spaceXL,
                color: ReportColors.divider,
              ),
              // Section Content
              child,
            ],
          ),
        );
      },
    );
  }
}

/// Helper widget for info rows (label: value pairs)
/// Uses ReportColors for professional white background style
class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppWidgetTheme.spaceSM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: ReportColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: AppWidgetTheme.fontSizeSM,
              fontWeight: FontWeight.w600,
              color: valueColor ?? ReportColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for progress rows with bars
/// Uses ReportColors with theme accent for progress bar
class ProgressRow extends StatelessWidget {
  final String label;
  final double progress;

  const ProgressRow({
    super.key,
    required this.label,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        // Keep theme color for progress bar fill (visual interest)
        final progressColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
        final percentage = (progress * 100).round();

        return Padding(
          padding: const EdgeInsets.only(bottom: AppWidgetTheme.spaceSM),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: AppWidgetTheme.fontSizeSM,
                      color: ReportColors.textSecondary,
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: AppWidgetTheme.fontSizeSM,
                      fontWeight: FontWeight.w600,
                      color: ReportColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppWidgetTheme.spaceXXS),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXS),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: ReportColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 8.0,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
