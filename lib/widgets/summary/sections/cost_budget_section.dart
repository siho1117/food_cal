// lib/widgets/summary/sections/cost_budget_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/nutrition_colors.dart';
import 'base_section_widget.dart';

/// Cost Budget Section - Daily food cost tracking
class CostBudgetSection extends StatelessWidget {
  final int foodEntriesCount;
  final double totalCost;
  final double budget;

  const CostBudgetSection({
    super.key,
    required this.foodEntriesCount,
    required this.totalCost,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final isOver = totalCost > budget;
    final difference = (budget - totalCost).abs();
    final percentage = ((totalCost / budget) * 100).round();

    return BaseSectionWidget(
      icon: Icons.attach_money,
      title: 'FOOD BUDGET',
      child: Column(
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
        ],
      ),
    );
  }
}
