// lib/widgets/summary/sections/body_metrics_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../data/models/user_profile.dart';
import '../../../data/models/weight_data.dart';
import '../../../utils/progress/health_metrics.dart';
import 'base_section_widget.dart';

/// Body Measurements and Composition Section
class BodyMetricsSection extends StatelessWidget {
  final UserProfile? profile;
  final double? currentWeight;
  final List<WeightData> weightHistory;

  const BodyMetricsSection({
    super.key,
    required this.profile,
    required this.currentWeight,
    required this.weightHistory,
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
    final weightUnit = isMetric ? 'kg' : 'lbs';
    const kgToLbsRatio = 2.20462;

    // Format weight values based on unit preference
    String formatWeight(double? weight) {
      if (weight == null) return 'N/A';
      final displayWeight = isMetric ? weight : weight * kgToLbsRatio;
      return displayWeight.toStringAsFixed(1);
    }

    return BaseSectionWidget(
          icon: Icons.straighten,
          title: 'BODY MEASUREMENTS & COMPOSITION',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Height (Simple row) - Moved above table
              InfoRow(
                label: 'Height',
                value: profile?.formattedHeight() ?? 'Not set',
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
                      'Weight ($weightUnit)',
                      formatWeight(startingWeight),
                      formatWeight(currentWeight),
                      formatWeight(goalWeight),
                      (startingWeight != null && currentWeight != null)
                          ? formatWeight(currentWeight! - startingWeight)
                          : 'N/A',
                    ),

                    const SizedBox(height: AppWidgetTheme.spaceXS),

                    // BMI Row
                    _buildGridDataRow(
                      'BMI',
                      startingBMI != null ? startingBMI.toStringAsFixed(1) : 'N/A',
                      currentBMI != null ? currentBMI.toStringAsFixed(1) : 'N/A',
                      goalBMI != null ? goalBMI.toStringAsFixed(1) : 'N/A',
                      currentBMI != null ? HealthMetrics.getBMIClassification(currentBMI) : 'N/A',
                    ),

                    if (currentBodyFat != null) ...[
                      const SizedBox(height: AppWidgetTheme.spaceXS),

                      // Body Fat % Row
                      _buildGridDataRow(
                        'Body Fat (%)',
                        startingBodyFat != null ? startingBodyFat.toStringAsFixed(1) : 'N/A',
                        currentBodyFat.toStringAsFixed(1),
                        targetBodyFat != null ? targetBodyFat.toStringAsFixed(1) : 'N/A',
                        (startingBodyFat != null && currentBodyFat != null)
                            ? (currentBodyFat - startingBodyFat).toStringAsFixed(1)
                            : 'N/A',
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
  }

  Widget _buildGridHeaderRow() {
    return Row(
      children: [
        // Metric column
        Expanded(
          flex: 2,
          child: Text(
            'Metric',
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
            'Starting',
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
            'Current',
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
            'Goal',
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
            'Progress',
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
