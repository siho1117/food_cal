// lib/widgets/summary/sections/progress_achievements_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import 'base_section_widget.dart';
import '../summary_controls_widget.dart';

/// Progress & Achievements Section
/// Shows weight progress and period goals (daily/weekly/monthly)
class ProgressAchievementsSection extends StatelessWidget {
  // Weight Progress
  final double? currentWeight;
  final double? goalWeight;
  final double? startingWeight;
  final bool isMetric;

  // Period Goals (totals for the period)
  final int totalCalories;
  final int calorieGoal; // Daily goal (will be multiplied for weekly/monthly)
  final int totalBurned;
  final int burnGoal; // Daily goal (will be multiplied for weekly/monthly)
  final double totalCost;
  final double budget; // Daily budget (will be multiplied for weekly/monthly)
  final SummaryPeriod? period; // Optional period for weekly/monthly display

  const ProgressAchievementsSection({
    super.key,
    required this.currentWeight,
    required this.goalWeight,
    required this.startingWeight,
    required this.isMetric,
    required this.totalCalories,
    required this.calorieGoal,
    required this.totalBurned,
    required this.burnGoal,
    required this.totalCost,
    required this.budget,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    // Determine period multiplier
    final periodDays = period == SummaryPeriod.weekly
        ? 7
        : period == SummaryPeriod.monthly
            ? 30
            : 1;

    // Calculate period goals (multiply daily goals by period)
    final periodCalorieGoal = calorieGoal * periodDays;
    final periodBurnGoal = burnGoal * periodDays;
    final periodBudget = budget * periodDays;

    // Determine period label for title
    final goalsTitle = period == SummaryPeriod.weekly
        ? 'Weekly Goals'
        : period == SummaryPeriod.monthly
            ? 'Monthly Goals'
            : 'Today\'s Goals';

    // Calculate weight progress
    final weightRemaining = goalWeight != null && currentWeight != null
        ? currentWeight! - goalWeight!
        : null;

    // Format weight values
    final currentWeightDisplay = _formatWeight(currentWeight);
    final goalWeightDisplay = _formatWeight(goalWeight);
    final weightRemainingDisplay = _formatWeight(weightRemaining?.abs());
    final unit = isMetric ? 'kg' : 'lbs';

    // Period goal status
    final caloriesMet = totalCalories <= periodCalorieGoal;
    final exerciseMet = totalBurned >= periodBurnGoal;
    final budgetMet = totalCost <= periodBudget;

    final caloriePercentage = periodCalorieGoal > 0
        ? ((totalCalories / periodCalorieGoal) * 100).round()
        : 0;
    final exercisePercentage = periodBurnGoal > 0
        ? ((totalBurned / periodBurnGoal) * 100).round()
        : 0;
    final budgetPercentage = periodBudget > 0
        ? ((totalCost / periodBudget) * 100).round()
        : 0;

    return BaseSectionWidget(
      icon: Icons.emoji_events,
      title: 'PROGRESS & ACHIEVEMENTS',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Progress Section
          Text(
            'Weight Progress',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: AppWidgetTheme.fontSizeMS,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppWidgetTheme.spaceSM),

          if (currentWeight != null && goalWeight != null) ...[
            InfoRow(
              label: 'Current',
              value: '$currentWeightDisplay $unit',
            ),
            InfoRow(
              label: 'Goal',
              value: '$goalWeightDisplay $unit',
            ),
            if (weightRemaining != null && weightRemaining != 0) ...[
              InfoRow(
                label: 'Remaining to Goal',
                value: '$weightRemainingDisplay $unit',
              ),
            ],
          ] else ...[
            Text(
              'Set your goal weight in settings',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: AppWidgetTheme.fontSizeSM,
                color: Colors.white.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],

          const Divider(
            height: AppWidgetTheme.spaceXL,
            color: Colors.white,
          ),

          // Period Goals Section
          Text(
            goalsTitle,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: AppWidgetTheme.fontSizeMS,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: AppWidgetTheme.spaceSM),

          // Calories Goal
          _buildGoalRow(
            icon: Icons.restaurant_menu,
            label: 'Calories',
            value: '$totalCalories / $periodCalorieGoal cal ($caloriePercentage%)',
            isMet: caloriesMet,
          ),

          // Exercise Goal
          _buildGoalRow(
            icon: Icons.fitness_center,
            label: 'Exercise',
            value: '$totalBurned / $periodBurnGoal cal ($exercisePercentage%)',
            isMet: exerciseMet,
          ),

          // Budget Goal
          _buildGoalRow(
            icon: Icons.attach_money,
            label: 'Budget',
            value: '\$${totalCost.toStringAsFixed(2)} / \$${periodBudget.toStringAsFixed(2)} ($budgetPercentage%)',
            isMet: budgetMet,
          ),
        ],
      ),
    );
  }

  /// Build a goal row with icon and status indicator
  Widget _buildGoalRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isMet,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppWidgetTheme.spaceSM),
      child: Row(
        children: [
          // Status indicator (checkmark or X)
          Icon(
            isMet ? Icons.check_circle : Icons.cancel,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: AppWidgetTheme.spaceXS),
          // Goal icon
          Icon(
            icon,
            color: Colors.white.withValues(alpha: 0.8),
            size: 18,
          ),
          const SizedBox(width: AppWidgetTheme.spaceXS),
          // Label and value
          Expanded(
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
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Format weight with proper decimal places
  String _formatWeight(double? weight) {
    if (weight == null) return '--';

    // Convert to display unit if needed
    final displayWeight = isMetric ? weight : weight * 2.20462;
    return displayWeight.toStringAsFixed(1);
  }
}
