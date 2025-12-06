// lib/widgets/summary/sections/meal_log_section.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/food_item.dart';
import '../../../services/food_image_service.dart';
import 'base_section_widget.dart';
import '../summary_controls_widget.dart';

/// Detailed Meal Log Section
class MealLogSection extends StatelessWidget {
  final List<FoodItem> foodEntries;
  final int totalCalories;
  final Map<String, num> consumedMacros;
  final SummaryPeriod? period; // Optional period for weekly/monthly display

  const MealLogSection({
    super.key,
    required this.foodEntries,
    required this.totalCalories,
    required this.consumedMacros,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    return BaseSectionWidget(
      icon: Icons.restaurant_menu,
      title: 'MEAL LOG',
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (foodEntries.isEmpty) ...[
                Text(
                  _getEmptyMessage(),
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ] else ...[
                // Show meals based on period
                if (period == SummaryPeriod.daily) ...[
                  // Daily: Show detailed view with images
                  ...foodEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final food = entry.value;

                    // Get nutrition values adjusted for serving size
                    final nutrition = food.getNutritionForServing();
                    final calories = nutrition['calories']!.round();
                    final protein = nutrition['proteins']!.round();
                    final carbs = nutrition['carbs']!.round();
                    final fat = nutrition['fats']!.round();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Food content (left side)
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Row 1: Name
                                Text(
                                  '${index + 1}. ${food.name}',
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontSize: AppWidgetTheme.fontSizeSM,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2.5),
                                // Row 2: Calories and Servings
                                Text(
                                  '$calories cal  |  ${food.servingSize} ${food.servingUnit}',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: AppWidgetTheme.fontSizeSM,
                                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                                  ),
                                ),
                                const SizedBox(height: 2.5),
                                // Row 3: Macros
                                Text(
                                  'P: ${protein}g  C: ${carbs}g  F: ${fat}g',
                                  style: AppTypography.bodySmall.copyWith(
                                    fontSize: AppWidgetTheme.fontSizeSM,
                                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Food image (right side)
                          _buildFoodImage(food, textColor),
                        ],
                      ),
                    );
                  }),
                ] else ...[
                  // Weekly/Monthly: Show simplified compact list
                  ...foodEntries.asMap().entries.map((entry) {
                    final index = entry.key;
                    final food = entry.value;

                    // Get nutrition values adjusted for serving size
                    final nutrition = food.getNutritionForServing();
                    final calories = nutrition['calories']!.round();

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
                          // Right: Calories and Date
                          Text(
                            '$calories cal  •  $dateStr',
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

                const SizedBox(height: 8),
                Divider(color: textColor.withValues(alpha: 0.3)),
                const SizedBox(height: 8),

                // Period Totals
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Row 1: Title and Calories
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getTotalsLabel(),
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: AppWidgetTheme.fontSizeMS,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '$totalCalories cal',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: AppWidgetTheme.fontSizeSM,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Row 2: Macros (right-aligned)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Protein: ${consumedMacros['protein']?.round() ?? 0}g  |  Carbs: ${consumedMacros['carbs']?.round() ?? 0}g  |  Fat: ${consumedMacros['fat']?.round() ?? 0}g',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: AppWidgetTheme.fontSizeSM,
                            color: Colors.white.withValues(alpha: AppWidgetTheme.opacityHigher),
                          ),
                        ),
                      ],
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

  /// Get empty message based on period
  String _getEmptyMessage() {
    if (period == SummaryPeriod.weekly) {
      return 'No meals logged this week';
    } else if (period == SummaryPeriod.monthly) {
      return 'No meals logged this month';
    }
    return 'No meals logged today';
  }

  /// Get totals label based on period
  String _getTotalsLabel() {
    if (period == SummaryPeriod.weekly) {
      return 'Weekly Totals (${foodEntries.length} meals):';
    } else if (period == SummaryPeriod.monthly) {
      return 'Monthly Totals (${foodEntries.length} meals):';
    }
    return 'Daily Totals:';
  }

  /// Format date for display (MM/DD)
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  /// Build food image with File-based loading
  Widget _buildFoodImage(FoodItem food, Color textColor) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7), // Slightly smaller to account for border
        child: (food.imagePath == null || food.imagePath!.isEmpty)
            ? _buildImagePlaceholder(textColor)
            : FutureBuilder<File?>(
                future: FoodImageService.getImageFile(food.imagePath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildImagePlaceholder(textColor);
                  }

                  if (snapshot.hasData && snapshot.data != null) {
                    return Image.file(
                      snapshot.data!,
                      width: 58, // Reduced to account for border
                      height: 58,
                      fit: BoxFit.cover,
                    );
                  }

                  return _buildImagePlaceholder(textColor);
                },
              ),
      ),
    );
  }

  /// Build placeholder when no image available
  Widget _buildImagePlaceholder(Color textColor) {
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      child: Icon(
        Icons.restaurant,
        color: textColor.withValues(alpha: 0.5),
        size: 30,
      ),
    );
  }
}
