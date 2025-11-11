// lib/widgets/summary/sections/nutrition_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import 'base_section_widget.dart';

/// Nutrition Section - Daily macro and calorie summary
class NutritionSection extends StatelessWidget {
  final int totalCalories;
  final int calorieGoal;
  final Map<String, num> consumedMacros;
  final Map<String, num> targetMacros;
  final int foodEntriesCount;
  final double totalCost;
  final double budget;

  const NutritionSection({
    super.key,
    required this.totalCalories,
    required this.calorieGoal,
    required this.consumedMacros,
    required this.targetMacros,
    required this.foodEntriesCount,
    required this.totalCost,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSectionWidget(
      icon: Icons.restaurant,
      title: 'DAILY NUTRITION SUMMARY (${SummaryDataCalculator.formatDate(DateTime.now())})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Summary
          InfoRow(
            label: 'Total Calories Consumed',
            value: '$totalCalories / $calorieGoal cal (${((totalCalories / calorieGoal) * 100).round()}%)',
          ),
          InfoRow(
            label: 'Remaining',
            value: '${calorieGoal - totalCalories} cal',
            valueColor: totalCalories <= calorieGoal ? NutritionColors.success : NutritionColors.warning,
          ),

          SizedBox(height: AppWidgetTheme.spaceMD),

          // Macronutrient Breakdown Header
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, _) {
              final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
              return Text(
                'Macronutrient Breakdown:',
                style: AppTypography.labelLarge.copyWith(
                  fontSize: AppWidgetTheme.fontSizeMS,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              );
            },
          ),

          SizedBox(height: AppWidgetTheme.spaceMD),

          // Protein
          _buildMacroRow(
            'Protein',
            (consumedMacros['protein'] ?? 0).toDouble(),
            (targetMacros['protein'] ?? 0).toDouble(),
            NutritionColors.proteinColor,
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Carbs
          _buildMacroRow(
            'Carbohydrates',
            (consumedMacros['carbs'] ?? 0).toDouble(),
            (targetMacros['carbs'] ?? 0).toDouble(),
            NutritionColors.carbsColor,
          ),

          SizedBox(height: AppWidgetTheme.spaceSM),

          // Fat
          _buildMacroRow(
            'Fat',
            (consumedMacros['fat'] ?? 0).toDouble(),
            (targetMacros['fat'] ?? 0).toDouble(),
            NutritionColors.fatColor,
          ),

          SizedBox(height: AppWidgetTheme.spaceMD),

          // Meal Statistics
          InfoRow(label: 'Meals Logged', value: '$foodEntriesCount meals'),
          InfoRow(
            label: 'Average per Meal',
            value: foodEntriesCount > 0
                ? '\$${(totalCost / foodEntriesCount).toStringAsFixed(2)}'
                : '\$0.00',
          ),
          InfoRow(
            label: 'Total Food Cost',
            value: '\$${totalCost.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)} (${((totalCost / budget) * 100).round()}%)',
          ),
          InfoRow(
            label: 'Budget Remaining',
            value: '\$${(budget - totalCost).toStringAsFixed(2)}',
            valueColor: totalCost <= budget ? NutritionColors.success : NutritionColors.error,
          ),
        ],
      ),
    );
  }

  Widget _buildMacroRow(String label, double consumed, double target, Color color) {
    final percentage = target > 0 ? (consumed / target * 100).round() : 0;
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

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
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                  ),
                ),
                Text(
                  '${consumed.round()}g / ${target.round()}g ($percentage%)',
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: color,
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
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8.0,
              ),
            ),
          ],
        );
      },
    );
  }
}
