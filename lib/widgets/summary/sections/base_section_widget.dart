// lib/widgets/summary/sections/base_section_widget.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../common/frosted_glass_card.dart';

/// Base widget for all summary report sections
/// Glassmorphism design with frosted glass effect on gradient background
/// 75% white opacity with black text for optimal readability
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
    return FrostedGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Row(
            children: [
              Icon(
                icon,
                size: AppWidgetTheme.iconSizeMedium,
                color: Colors.white,
              ),
              const SizedBox(width: AppWidgetTheme.spaceSM),
              Expanded(
                child: Text(
                  title,
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeML,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          Divider(
            height: AppWidgetTheme.spaceXL,
            color: Colors.white.withValues(alpha: 0.2),
          ),
          // Section Content
          child,
        ],
      ),
    );
  }
}

/// Helper widget for info rows (label: value pairs)
/// Black text on white glass background for readability
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
              color: Colors.white,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: AppWidgetTheme.fontSizeSM,
                fontWeight: FontWeight.w600,
                color: valueColor ?? Colors.white,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for progress rows with bars
/// Black text with colored progress bars on white glass background
class ProgressRow extends StatelessWidget {
  final String label;
  final double progress;
  final Color? progressColor;

  const ProgressRow({
    super.key,
    required this.label,
    required this.progress,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = (progress * 100).round();
    final barColor = progressColor ?? Colors.blue;

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
                  color: Colors.white,
                ),
              ),
              Text(
                '$percentage%',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: AppWidgetTheme.fontSizeSM,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppWidgetTheme.spaceXXS),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXS),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
              minHeight: 8.0,
            ),
          ),
        ],
      ),
    );
  }
}
