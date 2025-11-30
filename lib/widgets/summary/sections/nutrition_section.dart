// lib/widgets/summary/sections/nutrition_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import 'base_section_widget.dart';

/// Nutrition Section - Daily macro and calorie summary
class NutritionSection extends StatelessWidget {
  final int totalCalories;
  final int calorieGoal;
  final Map<String, num> consumedMacros;
  final Map<String, num> targetMacros;
  final int foodEntriesCount;
  final bool exerciseBonusEnabled;
  final int exerciseBonusCalories;

  const NutritionSection({
    super.key,
    required this.totalCalories,
    required this.calorieGoal,
    required this.consumedMacros,
    required this.targetMacros,
    required this.foodEntriesCount,
    required this.exerciseBonusEnabled,
    required this.exerciseBonusCalories,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate effective calorie goal (includes exercise bonus if enabled)
    final effectiveGoal = calorieGoal + (exerciseBonusEnabled ? exerciseBonusCalories : 0);
    final isOver = totalCalories > effectiveGoal;
    final difference = (effectiveGoal - totalCalories).abs();
    final percentage = ((totalCalories / effectiveGoal) * 100).round();

    return BaseSectionWidget(
      icon: Icons.restaurant,
      title: 'NUTRITION SUMMARY',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Calorie Summary
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
              valueColor: NutritionColors.success,
            ),
          ],

          // Dynamic label: "Remaining" or "Over" with percentage
          InfoRow(
            label: isOver ? 'Over' : 'Remaining',
            value: '$difference cal ($percentage%)',
            valueColor: isOver ? NutritionColors.warning : NutritionColors.success,
          ),

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

          // Protein
          _buildMacroRow(
            'Protein',
            (consumedMacros['protein'] ?? 0).toDouble(),
            (targetMacros['protein'] ?? 0).toDouble(),
            NutritionColors.proteinColor,
          ),

          const SizedBox(height: AppWidgetTheme.spaceSM),

          // Carbs
          _buildMacroRow(
            'Carbohydrates',
            (consumedMacros['carbs'] ?? 0).toDouble(),
            (targetMacros['carbs'] ?? 0).toDouble(),
            NutritionColors.carbsColor,
          ),

          const SizedBox(height: AppWidgetTheme.spaceSM),

          // Fat
          _buildMacroRow(
            'Fat',
            (consumedMacros['fat'] ?? 0).toDouble(),
            (targetMacros['fat'] ?? 0).toDouble(),
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
