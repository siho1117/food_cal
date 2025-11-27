// lib/widgets/summary/sections/metabolism_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
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

    // Calculate baseline (BMR × 1.2) instead of TDEE
    final baseline = bmr != null ? bmr * 1.2 : null;

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
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
                return Text(
                  '  • Calories needed at complete rest',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
            SizedBox(height: AppWidgetTheme.spaceSM),
          ],

          if (baseline != null) ...[
            InfoRow(
              label: 'Baseline (BMR × 1.2)',
              value: '${baseline.round()} cal/day',
            ),
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '  • Sedentary baseline (exercise logged separately)',
                      style: AppTypography.bodySmall.copyWith(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                );
              },
            ),
            SizedBox(height: AppWidgetTheme.spaceMD),
          ],

          InfoRow(
            label: 'Calorie Goal (Current)',
            value: '$calorieGoal cal/day',
          ),
          if (baseline != null) ...[
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
                return Text(
                  '  • Target Type: ${calorieGoal < baseline.round() ? "Weight Loss" : "Weight Gain"} (${((1 - calorieGoal / baseline.round()) * 100).abs().round()}% ${calorieGoal < baseline.round() ? "deficit" : "surplus"})',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
          if (profile?.monthlyWeightGoal != null) ...[
            Consumer<ThemeProvider>(
              builder: (context, themeProvider, _) {
                final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
                return Text(
                  '  • Monthly Goal: ${profile!.monthlyWeightGoal! > 0 ? "+" : ""}${profile!.monthlyWeightGoal!.toStringAsFixed(1)} kg (${(profile!.monthlyWeightGoal! * 2.20462).toStringAsFixed(1)} lbs)',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    fontStyle: FontStyle.italic,
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
