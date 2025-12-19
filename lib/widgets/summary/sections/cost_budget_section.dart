// lib/widgets/summary/sections/cost_budget_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:intl/intl.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/food_item.dart';
import '../../../utils/summary/summary_period_utils.dart';
import '../summary_controls_widget.dart';
import 'base_section_widget.dart';
import '../../../l10n/generated/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    // Calculate period multiplier for weekly/monthly budgets
    final periodDays = SummaryPeriodUtils.getPeriodDays(period);

    // Scale budget based on period
    final periodBudget = budget * periodDays;

    final isOver = totalCost > periodBudget;
    final difference = (periodBudget - totalCost).abs();
    final percentage = periodBudget > 0 ? ((totalCost / periodBudget) * 100).round() : 0;

    return BaseSectionWidget(
      icon: AnimatedEmojis.moneyWithWings,
      title: l10n.foodBudget,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Cost Summary
              InfoRow(
                label: l10n.totalFoodCost,
                value: '\$${totalCost.toStringAsFixed(2)} / \$${periodBudget.toStringAsFixed(2)}',
              ),
              InfoRow(
                label: isOver ? l10n.budgetExceeded : l10n.budgetRemaining,
                value: '\$${difference.toStringAsFixed(2)} ($percentage%)',
              ),
              // Meal Statistics
              InfoRow(label: l10n.mealsLogged, value: '$foodEntriesCount ${l10n.meals}'),

              // Show average per meal for daily, average per day for weekly/monthly
              if (period == SummaryPeriod.daily) ...[
                InfoRow(
                  label: l10n.averagePerMeal,
                  value: '\$${SummaryPeriodUtils.safeDivide(totalCost, foodEntriesCount).toStringAsFixed(2)}',
                ),
              ] else ...[
                InfoRow(
                  label: l10n.averagePerDay,
                  value: '\$${SummaryPeriodUtils.safeDivide(totalCost, periodDays).toStringAsFixed(2)}',
                ),
              ],

              if (foodEntries.isNotEmpty) ...[
                const SizedBox(height: AppWidgetTheme.spaceMD),
                Text(
                  '${l10n.budgetBreakdown}:',
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: AppWidgetTheme.fontSizeMS,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppWidgetTheme.spaceMD),

                // Show food entries based on period
                if (period == SummaryPeriod.daily) ...[
                  // Daily: Show just name and cost (latest first)
                  ...foodEntries.reversed.toList().asMap().entries.map((entry) {
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
                  // Weekly/Monthly: Show name, cost, and date (latest first)
                  ...foodEntries.reversed.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final food = entry.value;
                    final foodCost = food.cost ?? 0.0;

                    // Format date
                    final dateStr = _formatDate(context, food.timestamp);

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

  /// Format date for display (localized short format)
  /// Examples: "12/19" (en_US), "12月19日" (zh_CN), "12/19" (ja_JP)
  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.Md(locale).format(date);
  }
}
