// lib/widgets/progress/health_metrics_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/accent_colors.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/user_profile.dart';
import '../../l10n/generated/app_localizations.dart';

/// Combined health metrics display widget showing BMI, Body Fat, and BMR
///
/// This widget is purely for display - all calculations are handled by
/// HealthMetrics utility class and passed in via props.
class HealthMetricsWidget extends StatelessWidget {
  final double? currentWeight;
  final double? targetWeight;
  final UserProfile? userProfile;
  final double? bmi;
  final String? bmiCategory;
  final double? bodyFat;
  final String? bodyFatCategory;
  final double? bmr;
  final double? baseline;

  // Progress tracking values (calculated in provider)
  final double? targetBMI;
  final double? bmiProgress;
  final double? targetBodyFat;
  final double? bodyFatProgress;

  const HealthMetricsWidget({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.userProfile,
    required this.bmi,
    required this.bmiCategory,
    required this.bodyFat,
    required this.bodyFatCategory,
    required this.bmr,
    required this.baseline,
    this.targetBMI,
    this.bmiProgress,
    this.targetBodyFat,
    this.bodyFatProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final l10n = AppLocalizations.of(context)!;
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassCardStyle.blurSigma,
              sigmaY: GlassCardStyle.blurSigma,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                border: Border.all(
                  color: borderColor.withValues(alpha: GlassCardStyle.borderOpacity / AppWidgetTheme.cardBorderOpacity),
                  width: GlassCardStyle.borderWidth,
                ),
              ),
              padding: AppWidgetTheme.cardPadding,
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.monitor_heart_outlined,
                    size: AppWidgetTheme.iconSizeSmall,
                    color: textColor,
                  ),
                  SizedBox(width: AppWidgetTheme.spaceMS),
                  Text(
                    l10n.healthMetrics,
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeLG,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                      color: textColor,
                      shadows: AppWidgetTheme.textShadows,
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                      size: AppWidgetTheme.iconSizeSmall,
                    ),
                    onPressed: () {
                      _showInfoDialog(context);
                    },
                    padding: EdgeInsets.all(AppWidgetTheme.spaceXS),
                    constraints: BoxConstraints(),
                  ),
                ],
              ),

              SizedBox(height: AppWidgetTheme.spaceLG),

              // BMI Timeline
              _buildTimelineMetric(
                context,
                label: l10n.bmi,
                currentValue: bmi?.toStringAsFixed(1) ?? '--',
                targetValue: targetBMI?.toStringAsFixed(1) ?? '--',
                progress: bmiProgress ?? 0.0,
                zones: [
                  _ScaleZone(l10n.bmiUnderweight, 0, 18.5, AccentColors.electricBlue),
                  _ScaleZone(l10n.bmiNormal, 18.5, 25, AccentColors.brightGreen),
                  _ScaleZone(l10n.bmiOverweight, 25, 30, AccentColors.goldenYellow),
                  _ScaleZone(l10n.bmiObese, 30, 40, AccentColors.vibrantRed),
                ],
                currentPosition: bmi,
                targetPosition: targetBMI,
                maxValue: 40.0,
                textColor: textColor,
              ),

              SizedBox(height: AppWidgetTheme.spaceLG),

              // Body Fat Timeline
              _buildTimelineMetric(
                context,
                label: l10n.bodyFatEstimatePercent,
                currentValue: bodyFat != null ? '${bodyFat!.toStringAsFixed(1)}%' : '--',
                targetValue: targetBodyFat != null ? '${targetBodyFat!.toStringAsFixed(1)}%' : '--',
                progress: bodyFatProgress ?? 0.0,
                zones: _getBodyFatZones(userProfile?.gender, l10n),
                currentPosition: bodyFat,
                targetPosition: targetBodyFat,
                maxValue: _getBodyFatMaxValue(userProfile?.gender),
                textColor: textColor,
              ),

              SizedBox(height: AppWidgetTheme.spaceLG),

              // Metabolism Timeline
              _buildMetabolismTimeline(
                context: context,
                bmr: bmr,
                baseline: baseline, // BMR baseline
                textColor: textColor,
              ),
            ],
          ),
            ),
          ),
        );
      },
    );
  }

  /// Compact metric with horizontal gradient bar
  Widget _buildTimelineMetric(
    BuildContext context, {
    required String label,
    required String currentValue,
    required String targetValue,
    required double progress,
    required List<_ScaleZone> zones,
    required double? currentPosition,
    required double? targetPosition,
    required double maxValue,
    required Color textColor,
  }) {
    // Find current category
    String currentCategory = zones.first.label;
    Color categoryColor = zones.first.color;
    for (final zone in zones) {
      if (currentPosition != null &&
          currentPosition >= zone.start &&
          currentPosition < zone.end) {
        currentCategory = zone.label;
        categoryColor = zone.color;
        break;
      }
    }

    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(
          textColor,
          AppWidgetTheme.opacityLight,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title/Label only
          Text(
            label,
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeSM,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceXS),

          // Row 2: Current value, target value, and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Current and target values
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      currentValue,
                      style: TextStyle(
                        fontSize: AppWidgetTheme.fontSizeXL,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: AppWidgetTheme.spaceXS),
                    Text(
                      '→',
                      style: TextStyle(
                        fontSize: AppWidgetTheme.fontSizeMD,
                        fontWeight: FontWeight.w500,
                        color: textColor.withValues(alpha: AppWidgetTheme.opacityHigh),
                      ),
                    ),
                    SizedBox(width: AppWidgetTheme.spaceXS),
                    Text(
                      targetValue,
                      style: TextStyle(
                        fontSize: AppWidgetTheme.fontSizeML,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppWidgetTheme.spaceSM,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: categoryColor,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  currentCategory,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Horizontal gradient bar with indicator
          LayoutBuilder(
            builder: (context, constraints) {
              final barWidth = constraints.maxWidth;
              final indicatorPosition = currentPosition != null
                  ? (currentPosition / maxValue).clamp(0.0, 1.0) * barWidth
                  : 0.0;

              return SizedBox(
                height: 4,
                child: Stack(
                  children: [
                    // Gradient bar
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(2),
                          gradient: LinearGradient(
                            colors: [
                              ...zones.map((zone) => zone.color),
                              zones.last.color, // Repeat last color to fill to end
                            ],
                            stops: [
                              ...zones.map((zone) => zone.start / maxValue),
                              1.0, // Ensure gradient fills to the end
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Current position indicator
                    if (currentPosition != null)
                      Positioned(
                        left: indicatorPosition - 1.5,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: AppWidgetTheme.spaceXS),

          // Zone legend
          Wrap(
            spacing: AppWidgetTheme.spaceSM,
            runSpacing: 4,
            children: zones.map((zone) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: zone.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    zone.label,
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeXS,
                      fontWeight: FontWeight.w500,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// BMR section showing basal metabolic rate
  Widget _buildMetabolismTimeline({
    required BuildContext context,
    required double? bmr,
    required double? baseline,
    required Color textColor,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.all(AppWidgetTheme.spaceMD),
      decoration: BoxDecoration(
        color: AppWidgetTheme.getBackgroundColor(
          textColor,
          AppWidgetTheme.opacityLight,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title/Label only
          Text(
            l10n.bmrFullName,
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeSM,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
          ),

          SizedBox(height: AppWidgetTheme.spaceXS),

          // Row 2: BMR value and badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // BMR value with unit
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      bmr != null ? '${bmr.round()}' : '--',
                      style: TextStyle(
                        fontSize: AppWidgetTheme.fontSizeXL,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        height: 1.0,
                      ),
                    ),
                    SizedBox(width: AppWidgetTheme.spaceXS),
                    Text(
                      l10n.calPerDay,
                      style: TextStyle(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        fontWeight: FontWeight.w600,
                        color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              // BMR badge
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppWidgetTheme.spaceSM,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AccentColors.electricBlue,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  l10n.bmr,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Explanation text
          Text(
            l10n.caloriesYourBodyBurnsAtRest,
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeXS,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: AppDialogTheme.shape,
        backgroundColor: AppDialogTheme.backgroundColor,
        title: Text(
          l10n.healthMetricsInfo,
          style: AppDialogTheme.titleStyle,
        ),
        contentPadding: AppDialogTheme.contentPadding,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // BMI Section
              Text(
                l10n.bmiFullName,
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                l10n.bmiDescription,
                style: AppDialogTheme.bodyStyle,
              ),
              SizedBox(height: AppDialogTheme.spaceMD),

              // Body Fat Section
              Text(
                l10n.bodyFatPercentage,
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                l10n.bodyFatDescription,
                style: AppDialogTheme.bodyStyle,
              ),
              const SizedBox(height: AppDialogTheme.spaceXS),
              Container(
                padding: const EdgeInsets.all(AppDialogTheme.spaceSM),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.orange.shade300,
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: Colors.orange.shade700,
                    ),
                    const SizedBox(width: AppDialogTheme.spaceXS),
                    Expanded(
                      child: Text(
                        l10n.warningText,
                        style: AppDialogTheme.bodyStyle.copyWith(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceMD),

              // BMR Section
              Text(
                l10n.bmrFullName,
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
              SizedBox(height: AppDialogTheme.spaceXS),
              Text(
                l10n.bmrDescription,
                style: AppDialogTheme.bodyStyle,
              ),
            ],
          ),
        ),
        actionsPadding: AppDialogTheme.actionsPadding,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: AppDialogTheme.cancelButtonStyle,
            child: Text(l10n.close),
          ),
        ],
      ),
    );
  }

  /// Get body fat zones based on gender
  static List<_ScaleZone> _getBodyFatZones(String? gender, AppLocalizations l10n) {
    if (gender == 'Male') {
      return [
        _ScaleZone(l10n.athletic, 0, 14, AccentColors.brightGreen),
        _ScaleZone(l10n.fitness, 14, 18, AccentColors.goldenYellow),
        _ScaleZone(l10n.average, 18, 25, AccentColors.brightOrange),
        _ScaleZone(l10n.high, 25, 40, AccentColors.vibrantRed),
      ];
    } else if (gender == 'Female') {
      return [
        _ScaleZone(l10n.athletic, 0, 21, AccentColors.brightGreen),
        _ScaleZone(l10n.fitness, 21, 25, AccentColors.goldenYellow),
        _ScaleZone(l10n.average, 25, 32, AccentColors.brightOrange),
        _ScaleZone(l10n.high, 32, 45, AccentColors.vibrantRed),
      ];
    } else {
      // Gender-neutral zones (midpoint between male and female)
      return [
        _ScaleZone(l10n.athletic, 0, 18, AccentColors.brightGreen),
        _ScaleZone(l10n.fitness, 18, 22, AccentColors.goldenYellow),
        _ScaleZone(l10n.average, 22, 28, AccentColors.brightOrange),
        _ScaleZone(l10n.high, 28, 42, AccentColors.vibrantRed),
      ];
    }
  }

  /// Get max value for body fat scale based on gender
  static double _getBodyFatMaxValue(String? gender) {
    if (gender == 'Male') {
      return 40.0;
    } else if (gender == 'Female') {
      return 45.0;
    } else {
      return 42.0; // Midpoint for gender-neutral
    }
  }
}

class _ScaleZone {
  final String label;
  final double start;
  final double end;
  final Color color;

  _ScaleZone(this.label, this.start, this.end, this.color);
}



