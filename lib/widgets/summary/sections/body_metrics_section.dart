// lib/widgets/summary/sections/body_metrics_section.dart
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/weight_data.dart';
import '../../../utils/progress/health_metrics.dart';
import '../../../utils/summary/summary_constants.dart';
import 'base_section_widget.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Body Measurements, Composition and Metabolism Section
class BodyMetricsSection extends StatelessWidget {
  final UserProfile? profile;
  final double? currentWeight;
  final List<WeightData> weightHistory;
  final int calorieGoal;

  const BodyMetricsSection({
    super.key,
    required this.profile,
    required this.currentWeight,
    required this.weightHistory,
    required this.calorieGoal,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate all values directly - no Consumer wrapper needed
    // Parent already rebuilds when profile changes via Consumer3
    final goalWeight = profile?.goalWeight;
    final startingWeight = HealthMetrics.getStartingWeight(weightHistory);

    final currentBMI = HealthMetrics.calculateBMI(
      height: profile?.height,
      weight: currentWeight,
    );
    final goalBMI = HealthMetrics.calculateBMI(
      height: profile?.height,
      weight: goalWeight,
    );
    final startingBMI = HealthMetrics.calculateBMI(
      height: profile?.height,
      weight: startingWeight,
    );

    final currentBodyFat = HealthMetrics.calculateBodyFat(
      bmi: currentBMI,
      age: profile?.age,
      gender: profile?.gender,
    );
    final targetBodyFat = HealthMetrics.calculateBodyFat(
      bmi: goalBMI,
      age: profile?.age,
      gender: profile?.gender,
    );
    final startingBodyFat = HealthMetrics.calculateBodyFat(
      bmi: startingBMI,
      age: profile?.age,
      gender: profile?.gender,
    );

    // Get unit preferences from profile
    final isMetric = profile?.isMetric ?? true;

    // Calculate BMR for metabolism info
    final bmr = HealthMetrics.calculateBMR(
      weight: currentWeight,
      height: profile?.height,
      age: profile?.age,
      gender: profile?.gender,
    );

    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        final weightUnit = isMetric ? l10n.kg : l10n.lbs;

        // Format weight values based on unit preference
        String formatWeight(double? weight) {
          if (weight == null) return l10n.na;
          final displayWeight = isMetric ? weight : weight * SummaryConstants.kgToLbsRatio;
          return displayWeight.toStringAsFixed(1);
        }

        // Get localized BMI classification
        String getBMIClassificationLocalized(double bmi) {
          final key = HealthMetrics.getBMIClassificationKey(bmi);
          switch (key) {
            case 'underweight':
              return l10n.bmiUnderweight;
            case 'normal':
              return l10n.bmiNormal;
            case 'overweight':
              return l10n.bmiOverweight;
            case 'obese':
              return l10n.bmiObese;
            default:
              return l10n.na;
          }
        }

        return BaseSectionWidget(
          icon: AnimatedEmojis.fire,
          title: l10n.bodyMetricsMetabolism,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Height (Simple row) - Moved above table
              InfoRow(
                label: l10n.height,
                value: profile?.height != null
                    ? (isMetric
                        ? '${profile!.height} ${l10n.cm}'
                        : (() {
                            final totalInches = profile!.height! / 2.54;
                            final feet = (totalInches / 12).floor();
                            final inches = (totalInches % 12).round();
                            return '$feet\' $inches"';
                          })())
                    : l10n.na,
              ),

              const SizedBox(height: 4.0),

              // OPTION 3: Compact Grid

              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXS),
                ),
                padding: const EdgeInsets.all(AppWidgetTheme.spaceSM),
                child: Column(
                  children: [
                    // Header Row
                    _buildGridHeaderRow(),
                    const SizedBox(height: AppWidgetTheme.spaceSM),

                    // Weight Row
                    _buildGridDataRow(
                      '${l10n.weight} ($weightUnit)',
                      formatWeight(startingWeight),
                      formatWeight(currentWeight),
                      formatWeight(goalWeight),
                      (startingWeight != null && currentWeight != null)
                          ? formatWeight(currentWeight! - startingWeight)
                          : l10n.na,
                    ),

                    const SizedBox(height: AppWidgetTheme.spaceXS),

                    // BMI Row
                    _buildGridDataRow(
                      l10n.bmi,
                      startingBMI != null ? startingBMI.toStringAsFixed(1) : l10n.na,
                      currentBMI != null ? currentBMI.toStringAsFixed(1) : l10n.na,
                      goalBMI != null ? goalBMI.toStringAsFixed(1) : l10n.na,
                      currentBMI != null ? getBMIClassificationLocalized(currentBMI) : l10n.na,
                    ),

                    if (currentBodyFat != null) ...[
                      const SizedBox(height: AppWidgetTheme.spaceXS),

                      // Body Fat % Row
                      _buildGridDataRow(
                        l10n.bodyFatPercent,
                        startingBodyFat != null ? startingBodyFat.toStringAsFixed(1) : l10n.na,
                        currentBodyFat.toStringAsFixed(1),
                        targetBodyFat != null ? targetBodyFat.toStringAsFixed(1) : l10n.na,
                        startingBodyFat != null
                            ? (currentBodyFat - startingBodyFat).toStringAsFixed(1)
                            : l10n.na,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16.0),

              // BMR and Calorie Goal Section
              if (bmr != null) ...[
                InfoRow(
                  label: l10n.bmrBasalMetabolicRate,
                  value: '${bmr.round()} ${l10n.calPerDay}',
                ),
                const SizedBox(height: 4.0),
              ],

              if (profile?.monthlyWeightGoal != null) ...[
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;
                    final monthlyGoal = profile!.monthlyWeightGoal!;
                    final label = monthlyGoal < 0 ? l10n.loss : l10n.gain;
                    final absValue = monthlyGoal.abs();
                    final displayValue = isMetric ? absValue : absValue * SummaryConstants.kgToLbsRatio;
                    final unit = isMetric ? l10n.kg : l10n.lbs;

                    return InfoRow(
                      label: l10n.monthlyGoalLabel(label),
                      value: '${displayValue.toStringAsFixed(1)} $unit${l10n.perMonth}',
                    );
                  },
                ),
                const SizedBox(height: 4.0),
              ],

              InfoRow(
                label: l10n.calorieGoal,
                value: '$calorieGoal ${l10n.calPerDay}',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridHeaderRow() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Row(
          children: [
            // Metric column
            Expanded(
              flex: 2,
              child: Text(
                l10n.metric,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // Starting column
            Expanded(
              flex: 2,
              child: Text(
                l10n.starting,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Current column
            Expanded(
              flex: 2,
              child: Text(
                l10n.current,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Goal column
            Expanded(
              flex: 2,
              child: Text(
                l10n.goal,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Progress/Status column
            Expanded(
              flex: 2,
              child: Text(
                l10n.progress,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: AppWidgetTheme.fontSizeXS,
                  color: Colors.white.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGridDataRow(
    String metric,
    String starting,
    String current,
    String goal,
    String progress,
  ) {
    return Row(
      children: [
        // Metric column
        Expanded(
          flex: 2,
          child: Text(
            metric,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Starting column
        Expanded(
          flex: 2,
          child: Text(
            starting,
            style: AppTypography.bodySmall.copyWith(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Current column
        Expanded(
          flex: 2,
          child: Text(
            current,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Goal column
        Expanded(
          flex: 2,
          child: Text(
            goal,
            style: AppTypography.bodySmall.copyWith(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ),
        // Progress/Status column (highlighted)
        Expanded(
          flex: 2,
          child: Text(
            progress,
            style: AppTypography.bodySmall.copyWith(
              fontSize: AppWidgetTheme.fontSizeXS,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
