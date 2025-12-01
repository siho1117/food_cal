// lib/widgets/summary/sections/cost_budget_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/food_item.dart';
import 'base_section_widget.dart';

/// Cost Budget Section - Daily food cost tracking
class CostBudgetSection extends StatelessWidget {
  final int foodEntriesCount;
  final double totalCost;
  final double budget;
  final List<FoodItem> foodEntries;

  const CostBudgetSection({
    super.key,
    required this.foodEntriesCount,
    required this.totalCost,
    required this.budget,
    required this.foodEntries,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = totalCost > budget;
    final difference = (budget - totalCost).abs();
    final percentage = ((totalCost / budget) * 100).round();

    return BaseSectionWidget(
      icon: Icons.attach_money,
      title: 'FOOD BUDGET',
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Cost Summary
              InfoRow(
                label: 'Total Food Cost',
                value: '\$${totalCost.toStringAsFixed(2)} / \$${budget.toStringAsFixed(2)}',
              ),
              InfoRow(
                label: isOver ? 'Budget Exceeded' : 'Budget Remaining',
                value: '\$${difference.toStringAsFixed(2)} ($percentage%)',
                valueColor: isOver ? NutritionColors.error : NutritionColors.success,
              ),
              // Meal Statistics
              InfoRow(label: 'Meals Logged', value: '$foodEntriesCount meals'),
              InfoRow(
                label: 'Average per Meal',
                value: foodEntriesCount > 0
                    ? '\$${(totalCost / foodEntriesCount).toStringAsFixed(2)}'
                    : '\$0.00',
              ),

              if (foodEntries.isNotEmpty) ...[
                const SizedBox(height: AppWidgetTheme.spaceMD),
                Text(
                  'Budget Breakdown:',
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: AppWidgetTheme.fontSizeMS,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppWidgetTheme.spaceMD),

                ...foodEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final food = entry.value;
                  final foodCost = food.cost ?? 0.0;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            '${index + 1}. ${food.name}',
                            style: AppTypography.bodyMedium.copyWith(
                              fontSize: AppWidgetTheme.fontSizeSM,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        Text(
                          '\$${foodCost.toStringAsFixed(2)}',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: AppWidgetTheme.fontSizeSM,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}
