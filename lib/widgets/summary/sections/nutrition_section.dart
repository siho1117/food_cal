// lib/widgets/summary/sections/nutrition_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';
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
            valueColor: totalCalories <= calorieGoal ? SummaryTheme.success : SummaryTheme.warning,
          ),

          SummaryTheme.itemSpacingWidget,

          // Macronutrient Breakdown Header
          Text(
            'Macronutrient Breakdown:',
            style: SummaryTheme.sectionHeader.copyWith(fontSize: 13),
          ),

          SummaryTheme.itemSpacingWidget,

          // Protein
          _buildMacroRow(
            'Protein',
            (consumedMacros['protein'] ?? 0).toDouble(),
            (targetMacros['protein'] ?? 0).toDouble(),
            SummaryTheme.proteinColor,
          ),

          SummaryTheme.smallSpacingWidget,

          // Carbs
          _buildMacroRow(
            'Carbohydrates',
            (consumedMacros['carbs'] ?? 0).toDouble(),
            (targetMacros['carbs'] ?? 0).toDouble(),
            SummaryTheme.carbsColor,
          ),

          SummaryTheme.smallSpacingWidget,

          // Fat
          _buildMacroRow(
            'Fat',
            (consumedMacros['fat'] ?? 0).toDouble(),
            (targetMacros['fat'] ?? 0).toDouble(),
            SummaryTheme.fatColor,
          ),

          SummaryTheme.itemSpacingWidget,

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
            valueColor: totalCost <= budget ? SummaryTheme.success : SummaryTheme.error,
          ),
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
            Text(label, style: SummaryTheme.infoLabel),
            Text(
              '${consumed.round()}g / ${target.round()}g ($percentage%)',
              style: SummaryTheme.infoValue.copyWith(
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
            minHeight: SummaryTheme.progressBarHeight,
          ),
        ),
      ],
    );
  }
}
