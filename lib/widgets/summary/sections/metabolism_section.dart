// lib/widgets/summary/sections/metabolism_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';
import '../../../data/models/user_profile.dart';
import '../../../utils/progress/health_metrics.dart';
import 'base_section_widget.dart';

/// Metabolism & Energy Expenditure Section
class MetabolismSection extends StatelessWidget {
  final UserProfile? profile;
  final double? currentWeight;
  final int calorieGoal;

  const MetabolismSection({
    super.key,
    required this.profile,
    required this.currentWeight,
    required this.calorieGoal,
  });

  @override
  Widget build(BuildContext context) {
    final bmr = HealthMetrics.calculateBMR(
      weight: currentWeight,
      height: profile?.height,
      age: profile?.age,
      gender: profile?.gender,
    );

    final tdee = HealthMetrics.calculateTDEE(
      bmr: bmr,
      activityLevel: profile?.activityLevel,
    );

    return BaseSectionWidget(
      icon: Icons.local_fire_department,
      title: 'METABOLISM & ENERGY EXPENDITURE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (bmr != null) ...[
            InfoRow(
              label: 'BMR (Basal Metabolic Rate)',
              value: '${bmr.round()} cal/day',
            ),
            Text(
              '  • Calories needed at complete rest',
              style: SummaryTheme.helperText,
            ),
            SummaryTheme.smallSpacingWidget,
          ],

          if (tdee != null) ...[
            InfoRow(
              label: 'TDEE (Total Daily Energy)',
              value: '${tdee.round()} cal/day',
            ),
            Text(
              '  • Activity Level: ${HealthMetrics.getActivityLevelText(profile?.activityLevel)} (${profile?.activityLevel?.toStringAsFixed(1)}x)',
              style: SummaryTheme.helperText,
            ),
            Text(
              '  • Total daily energy expenditure',
              style: SummaryTheme.helperText,
            ),
            SummaryTheme.itemSpacingWidget,
          ],

          InfoRow(
            label: 'Calorie Goal (Current)',
            value: '$calorieGoal cal/day',
          ),
          if (tdee != null) ...[
            Text(
              '  • Target Type: ${calorieGoal < tdee.round() ? "Weight Loss" : "Weight Gain"} (${((1 - calorieGoal / tdee.round()) * 100).abs().round()}% ${calorieGoal < tdee.round() ? "deficit" : "surplus"})',
              style: SummaryTheme.helperText,
            ),
          ],
          if (profile?.monthlyWeightGoal != null) ...[
            Text(
              '  • Monthly Goal: ${profile!.monthlyWeightGoal! > 0 ? "+" : ""}${profile!.monthlyWeightGoal!.toStringAsFixed(1)} kg (${(profile!.monthlyWeightGoal! * 2.20462).toStringAsFixed(1)} lbs)',
              style: SummaryTheme.helperText,
            ),
          ],
        ],
      ),
    );
  }
}
