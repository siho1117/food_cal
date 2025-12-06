// lib/widgets/summary/sections/nutrition_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import 'base_section_widget.dart';
import '../summary_controls_widget.dart';

/// Nutrition Section - Daily macro and calorie summary
class NutritionSection extends StatelessWidget {
  final int totalCalories;
  final int calorieGoal;
  final Map<String, num> consumedMacros;
  final Map<String, num> targetMacros;
  final int foodEntriesCount;
  final bool exerciseBonusEnabled;
  final int exerciseBonusCalories;
  final SummaryPeriod? period; // Optional for weekly/monthly display
  final int? avgCaloriesPerDay; // Optional for weekly/monthly display

  const NutritionSection({
    super.key,
    required this.totalCalories,
    required this.calorieGoal,
    required this.consumedMacros,
    required this.targetMacros,
    required this.foodEntriesCount,
    required this.exerciseBonusEnabled,
    required this.exerciseBonusCalories,
    this.period,
    this.avgCaloriesPerDay,
  });

  @override
  Widget build(BuildContext context) {
    // Determine if we're showing aggregated data
    final isWeeklyOrMonthly = period == SummaryPeriod.weekly || period == SummaryPeriod.monthly;
    final periodLabel = period == SummaryPeriod.weekly
        ? 'Weekly'
        : period == SummaryPeriod.monthly
            ? 'Monthly'
            : 'Daily';

    // Calculate period multiplier for weekly/monthly goals
    final periodDays = period == SummaryPeriod.weekly
        ? 7
        : period == SummaryPeriod.monthly
            ? 30
            : 1;

    // Calculate effective calorie goal
    // For weekly/monthly: just use base goal × period (no exercise bonus)
    // For daily: include exercise bonus if enabled
    final basePeriodGoal = calorieGoal * periodDays;
    final effectiveGoal = isWeeklyOrMonthly
        ? basePeriodGoal
        : basePeriodGoal + (exerciseBonusEnabled && exerciseBonusCalories > 0 ? exerciseBonusCalories : 0);

    final isOver = totalCalories > effectiveGoal;
    final difference = (effectiveGoal - totalCalories).abs();
    final percentage = effectiveGoal > 0 ? ((totalCalories / effectiveGoal) * 100).round() : 0;

    return BaseSectionWidget(
      icon: Icons.restaurant,
      title: 'NUTRITION SUMMARY',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Summary
          if (isWeeklyOrMonthly) ...[
            // Weekly/Monthly: Show total with goal (no percentage on first line)
            InfoRow(
              label: 'Total Calories ($periodLabel)',
              value: '$totalCalories / $effectiveGoal cal',
            ),
            if (avgCaloriesPerDay != null)
              InfoRow(
                label: 'Average per Day',
                value: '$avgCaloriesPerDay / $calorieGoal cal',
              ),

            // Show over/remaining with percentage
            InfoRow(
              label: isOver ? 'Over by' : 'Remaining',
              value: '$difference cal ($percentage%)',
            ),
          ] else ...[
            // Daily: Show current format
            InfoRow(
              label: 'Total Calories Consumed',
              value: '$totalCalories / $effectiveGoal cal',
            ),

            // Show breakdown of the goal
            InfoRow(
              label: '  • Base Goal',
              value: '$calorieGoal cal',
            ),

            // Show exercise bonus if enabled
            if (exerciseBonusEnabled && exerciseBonusCalories > 0) ...[
              InfoRow(
                label: '  • Exercise Bonus (Rollover)',
                value: '+$exerciseBonusCalories cal',
              ),
            ],

            // Dynamic label: "Remaining" or "Over" with percentage
            InfoRow(
              label: isOver ? 'Over' : 'Remaining',
              value: '$difference cal ($percentage%)',
            ),
          ],

          const SizedBox(height: AppWidgetTheme.spaceMD),

          // Macronutrient Breakdown Header
          Text(
            'Macronutrient Breakdown:',
            style: AppTypography.labelLarge.copyWith(
              fontSize: AppWidgetTheme.fontSizeMS,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: AppWidgetTheme.spaceMD),

          // Protein (period-adjusted targets)
          _buildMacroRow(
            'Protein',
            (consumedMacros['protein'] ?? 0).toDouble(),
            (targetMacros['protein'] ?? 0).toDouble() * periodDays,
            NutritionColors.proteinColor,
          ),

          const SizedBox(height: AppWidgetTheme.spaceSM),

          // Carbs (period-adjusted targets)
          _buildMacroRow(
            'Carbohydrates',
            (consumedMacros['carbs'] ?? 0).toDouble(),
            (targetMacros['carbs'] ?? 0).toDouble() * periodDays,
            NutritionColors.carbsColor,
          ),

          const SizedBox(height: AppWidgetTheme.spaceSM),

          // Fat (period-adjusted targets)
          _buildMacroRow(
            'Fat',
            (consumedMacros['fat'] ?? 0).toDouble(),
            (targetMacros['fat'] ?? 0).toDouble() * periodDays,
            NutritionColors.fatColor,
          ),

          const SizedBox(height: AppWidgetTheme.spaceMD),

          // Meal Statistics
          InfoRow(label: 'Meals Logged', value: '$foodEntriesCount meals'),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, double consumed, double target, Color color) {
    final percentage = target > 0 ? (consumed / target * 100).round() : 0;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Column(
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
              '${consumed.round()}g / ${target.round()}g ($percentage%)',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: AppWidgetTheme.fontSizeSM,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8.0,
          ),
        ),
      ],
    );
  }
}
