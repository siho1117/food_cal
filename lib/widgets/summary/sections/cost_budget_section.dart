// lib/widgets/summary/sections/cost_budget_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/food_item.dart';
import '../summary_controls_widget.dart';
import 'base_section_widget.dart';

/// Cost Budget Section - Food cost tracking (daily/weekly/monthly)
class CostBudgetSection extends StatelessWidget {
  final int foodEntriesCount;
  final double totalCost;
  final double budget;
  final List<FoodItem> foodEntries;
  final SummaryPeriod? period; // Optional period for weekly/monthly display

  const CostBudgetSection({
    super.key,
    required this.foodEntriesCount,
    required this.totalCost,
    required this.budget,
    required this.foodEntries,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate period multiplier for weekly/monthly budgets
    final periodDays = period == SummaryPeriod.weekly
        ? 7
        : period == SummaryPeriod.monthly
            ? 30
            : 1;

    // Scale budget based on period
    final periodBudget = budget * periodDays;

    final isOver = totalCost > periodBudget;
    final difference = (periodBudget - totalCost).abs();
    final percentage = periodBudget > 0 ? ((totalCost / periodBudget) * 100).round() : 0;

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
                value: '\$${totalCost.toStringAsFixed(2)} / \$${periodBudget.toStringAsFixed(2)}',
              ),
              InfoRow(
                label: isOver ? 'Budget Exceeded' : 'Budget Remaining',
                value: '\$${difference.toStringAsFixed(2)} ($percentage%)',
              ),
              // Meal Statistics
              InfoRow(label: 'Meals Logged', value: '$foodEntriesCount meals'),

              // Show average per meal for daily, average per day for weekly/monthly
              if (period == SummaryPeriod.daily) ...[
                InfoRow(
                  label: 'Average per Meal',
                  value: foodEntriesCount > 0
                      ? '\$${(totalCost / foodEntriesCount).toStringAsFixed(2)}'
                      : '\$0.00',
                ),
              ] else ...[
                InfoRow(
                  label: 'Average per Day',
                  value: periodDays > 0
                      ? '\$${(totalCost / periodDays).toStringAsFixed(2)}'
                      : '\$0.00',
                ),
              ],

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

                // Show food entries based on period
                if (period == SummaryPeriod.daily) ...[
                  // Daily: Show just name and cost
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
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                ] else ...[
                  // Weekly/Monthly: Show name, cost, and date
                  ...foodEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final food = entry.value;
                    final foodCost = food.cost ?? 0.0;

                    // Format date
                    final dateStr = _formatDate(food.timestamp);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Food name
                          Expanded(
                            child: Text(
                              '${index + 1}. ${food.name}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: AppWidgetTheme.fontSizeSM,
                                fontWeight: FontWeight.w600,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Right: Cost and Date
                          Text(
                            '\$${foodCost.toStringAsFixed(2)}  •  $dateStr',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: AppWidgetTheme.fontSizeSM,
                              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],
            ],
          );
        },
      ),
    );
  }

  /// Format date for display (MM/DD)
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }
}
