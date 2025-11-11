// lib/widgets/summary/sections/meal_log_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/food_item.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import 'base_section_widget.dart';

/// Detailed Meal Log Section
class MealLogSection extends StatelessWidget {
  final List<FoodItem> foodEntries;
  final int totalCalories;
  final double totalCost;
  final Map<String, num> consumedMacros;

  const MealLogSection({
    super.key,
    required this.foodEntries,
    required this.totalCalories,
    required this.totalCost,
    required this.consumedMacros,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSectionWidget(
      icon: Icons.restaurant_menu,
      title: 'DETAILED MEAL LOG (${SummaryDataCalculator.formatDate(DateTime.now())})',
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (foodEntries.isEmpty) ...[
                Text(
                  'No meals logged today',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                ...foodEntries.asMap().entries.map((entry) {
                  final index = entry.key;
                  final food = entry.value;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                              '${food.calories} cal',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: AppWidgetTheme.fontSizeSM,
                                fontWeight: FontWeight.bold,
                                color: NutritionColors.caloriesColor,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '\$${(food.cost ?? 0).toStringAsFixed(2)}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: AppWidgetTheme.fontSizeSM,
                                fontWeight: FontWeight.bold,
                                color: NutritionColors.budgetColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'P: ${food.proteins.round()}g  C: ${food.carbs.round()}g  F: ${food.fats.round()}g',
                          style: AppTypography.bodySmall.copyWith(
                            fontSize: AppWidgetTheme.fontSizeSM,
                            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: 8),
                const Divider(),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daily Totals:',
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: AppWidgetTheme.fontSizeMS,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '$totalCalories cal  |  P: ${consumedMacros['protein']?.round() ?? 0}g  C: ${consumedMacros['carbs']?.round() ?? 0}g  F: ${consumedMacros['fat']?.round() ?? 0}g',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost:',
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: AppWidgetTheme.fontSizeMS,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      '\$${totalCost.toStringAsFixed(2)}',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: AppWidgetTheme.fontSizeSM,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
