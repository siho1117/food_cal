// lib/widgets/summary/sections/energy_balance_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';
import '../../../data/models/user_profile.dart';
import 'base_section_widget.dart';

/// Net Energy Balance Section
class EnergyBalanceSection extends StatelessWidget {
  final int consumed;
  final int burned;
  final double? tdee;
  final UserProfile? profile;

  const EnergyBalanceSection({
    super.key,
    required this.consumed,
    required this.burned,
    required this.tdee,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final netCalories = consumed - burned;
    final netDeficit = tdee != null ? (tdee!.round() - netCalories) : 0;

    return BaseSectionWidget(
      icon: Icons.balance,
      title: 'NET ENERGY BALANCE',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: 'Calories Consumed', value: '$consumed cal'),
          InfoRow(label: 'Exercise Burned', value: '-$burned cal'),
          const Divider(height: SummaryTheme.dividerHeight),
          InfoRow(
            label: 'Net Calories',
            value: '$netCalories cal',
            valueColor: SummaryTheme.primary,
          ),

          SummaryTheme.itemSpacingWidget,

          if (tdee != null) ...[
            InfoRow(label: 'TDEE (Maintenance)', value: '${tdee!.round()} cal'),
            InfoRow(
              label: 'Net Deficit',
              value: netDeficit > 0 ? '-$netDeficit cal' : '+${netDeficit.abs()} cal',
              valueColor: netDeficit > 0 ? SummaryTheme.success : SummaryTheme.warning,
            ),

            SummaryTheme.itemSpacingWidget,

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

                SummaryTheme.smallSpacingWidget,

                Text(
                  ((netDeficit * 7) / 7700) >= ((profile!.monthlyWeightGoal!.abs() * 7) / 30)
                      ? 'Status: Above target - Great progress!'
                      : 'Status: Below target - Consider adjusting',
                  style: SummaryTheme.infoValue.copyWith(
                    fontWeight: FontWeight.w600,
                    color: ((netDeficit * 7) / 7700) >= ((profile!.monthlyWeightGoal!.abs() * 7) / 30) ? SummaryTheme.success : SummaryTheme.warning,
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
