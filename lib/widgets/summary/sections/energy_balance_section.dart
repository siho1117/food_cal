// lib/widgets/summary/sections/energy_balance_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import '../../../data/models/user_profile.dart';
import 'base_section_widget.dart';

/// Net Energy Balance Section
/// Uses ReportColors for professional white background style
///
/// Note: Uses baseline (BMR × 1.2) instead of TDEE.
/// Exercise is counted separately to avoid double-counting.
class EnergyBalanceSection extends StatelessWidget {
  final int consumed;
  final int burned;
  final double? baseline; // BMR × 1.2 (renamed from tdee)
  final UserProfile? profile;

  const EnergyBalanceSection({
    super.key,
    required this.consumed,
    required this.burned,
    required this.baseline,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final netCalories = consumed - burned;
    final netDeficit = baseline != null ? (baseline!.round() - netCalories) : 0;

    return BaseSectionWidget(
      icon: Icons.balance,
      title: 'NET ENERGY BALANCE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Breakdown section
          InfoRow(label: 'Calories Consumed', value: '$consumed cal'),
          InfoRow(label: 'Exercise Burned', value: '-$burned cal'),
          const Divider(height: AppWidgetTheme.spaceXL, color: ReportColors.divider),
          InfoRow(
            label: 'Net Calories',
            value: '$netCalories cal',
            valueColor: NutritionColors.primary,
          ),

          const SizedBox(height: AppWidgetTheme.spaceMD),

          if (baseline != null) ...[
            InfoRow(label: 'Baseline (BMR × 1.2)', value: '${baseline!.round()} cal'),
            InfoRow(
              label: 'Net Deficit',
              value: netDeficit > 0 ? '-$netDeficit cal' : '+${netDeficit.abs()} cal',
              valueColor: netDeficit > 0 ? NutritionColors.success : NutritionColors.warning,
            ),

            const SizedBox(height: AppWidgetTheme.spaceMD),

            if (netDeficit > 0) ...[
              InfoRow(
                label: 'Expected Weekly Loss',
                value: '~${((netDeficit * 7) / 7700).toStringAsFixed(2)} kg (~${(((netDeficit * 7) / 7700) * 2.20462).toStringAsFixed(2)} lbs)',
              ),

              if (profile?.monthlyWeightGoal != null && profile!.monthlyWeightGoal! < 0) ...[
                InfoRow(
                  label: 'Target Weekly Loss',
                  value: '${((profile!.monthlyWeightGoal!.abs() * 7) / 30).toStringAsFixed(2)} kg (${(((profile!.monthlyWeightGoal!.abs() * 7) / 30) * 2.20462).toStringAsFixed(2)} lbs)',
                ),

                const SizedBox(height: AppWidgetTheme.spaceSM),

                Text(
                  ((netDeficit * 7) / 7700) >= ((profile!.monthlyWeightGoal!.abs() * 7) / 30)
                      ? 'Status: Above target - Great progress!'
                      : 'Status: Below target - Consider adjusting',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    fontWeight: FontWeight.w600,
                    color: ((netDeficit * 7) / 7700) >= ((profile!.monthlyWeightGoal!.abs() * 7) / 30)
                        ? NutritionColors.success
                        : NutritionColors.warning,
                  ),
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
