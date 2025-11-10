// lib/widgets/summary/sections/body_metrics_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';
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

    return BaseSectionWidget(
      icon: Icons.straighten,
      title: 'BODY MEASUREMENTS & COMPOSITION',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Measurements
          Text('Body Measurements:', style: SummaryTheme.sectionHeader.copyWith(fontSize: 13)),
          SummaryTheme.smallSpacingWidget,

          InfoRow(label: 'Height', value: profile?.formattedHeight() ?? 'Not set'),
          InfoRow(
            label: 'Current Weight',
            value: currentWeight != null
                ? '${currentWeight!.toStringAsFixed(1)} kg (${(currentWeight! * 2.20462).toStringAsFixed(1)} lbs)'
                : 'Not set',
          ),
          InfoRow(
            label: 'Goal Weight',
            value: goalWeight != null
                ? '${goalWeight.toStringAsFixed(1)} kg (${(goalWeight * 2.20462).toStringAsFixed(1)} lbs)'
                : 'Not set',
          ),
          if (startingWeight != null)
            InfoRow(
              label: 'Starting Weight',
              value: '${startingWeight.toStringAsFixed(1)} kg (${(startingWeight * 2.20462).toStringAsFixed(1)} lbs)',
            ),

          if (currentWeight != null && startingWeight != null) ...[
            SummaryTheme.itemSpacingWidget,
            Text('Weight Progress:', style: SummaryTheme.sectionHeader.copyWith(fontSize: 13)),
            SummaryTheme.smallSpacingWidget,
            InfoRow(
              label: 'Change (Total)',
              value: '${(currentWeight! - startingWeight!).toStringAsFixed(1)} kg (${((currentWeight! - startingWeight!) * 2.20462).toStringAsFixed(1)} lbs)',
              valueColor: currentWeight! < startingWeight! ? SummaryTheme.success : SummaryTheme.warning,
            ),
            if (goalWeight != null) ...[
              InfoRow(
                label: 'Remaining to Goal',
                value: '${(currentWeight! - goalWeight!).abs().toStringAsFixed(1)} kg (${((currentWeight! - goalWeight!).abs() * 2.20462).toStringAsFixed(1)} lbs)',
              ),
              ProgressRow(
                label: 'Progress to Goal',
                progress: HealthMetrics.calculateGoalProgress(
                  currentWeight: currentWeight,
                  targetWeight: goalWeight,
                ),
              ),
            ],
          ],

          SummaryTheme.itemSpacingWidget,
          Text('Body Composition:', style: SummaryTheme.sectionHeader.copyWith(fontSize: 13)),
          SummaryTheme.smallSpacingWidget,

          if (currentBMI != null) ...[
            InfoRow(
              label: 'BMI (Current)',
              value: '${currentBMI.toStringAsFixed(1)} (${HealthMetrics.getBMIClassification(currentBMI)})',
            ),
            if (goalBMI != null)
              InfoRow(
                label: 'BMI (Goal)',
                value: '${goalBMI.toStringAsFixed(1)} (${HealthMetrics.getBMIClassification(goalBMI)})',
              ),
            if (startingBMI != null)
              InfoRow(
                label: 'BMI (Starting)',
                value: '${startingBMI.toStringAsFixed(1)} (${HealthMetrics.getBMIClassification(startingBMI)})',
              ),
          ],

          if (currentBodyFat != null) ...[
            SummaryTheme.smallSpacingWidget,
            InfoRow(
              label: 'Body Fat % (Est.)',
              value: '${currentBodyFat.toStringAsFixed(1)}% (${HealthMetrics.getBodyFatClassification(currentBodyFat, profile?.gender)})',
            ),
            if (targetBodyFat != null) ...[
              InfoRow(
                label: 'Target Body Fat %',
                value: '${targetBodyFat.toStringAsFixed(1)}% (${HealthMetrics.getBodyFatClassification(targetBodyFat, profile?.gender)})',
              ),
              InfoRow(
                label: 'Body Fat to Lose',
                value: '${(currentBodyFat - targetBodyFat).toStringAsFixed(1)}%',
              ),
            ],
          ],

          if (currentWeight != null && currentBodyFat != null) ...[
            SummaryTheme.smallSpacingWidget,
            InfoRow(
              label: 'Lean Body Mass',
              value: '${(currentWeight! * (1 - currentBodyFat! / 100)).toStringAsFixed(1)} kg (${(currentWeight! * (1 - currentBodyFat! / 100) * 2.20462).toStringAsFixed(1)} lbs)',
            ),
            InfoRow(
              label: 'Fat Mass',
              value: '${(currentWeight! * currentBodyFat! / 100).toStringAsFixed(1)} kg (${(currentWeight! * currentBodyFat! / 100 * 2.20462).toStringAsFixed(1)} lbs)',
            ),
          ],
        ],
      ),
    );
  }
}
