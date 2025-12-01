// lib/widgets/summary/sections/exercise_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../config/design_system/nutrition_colors.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/exercise_entry.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import 'base_section_widget.dart';

/// Exercise & Activity Log Section
class ExerciseSection extends StatelessWidget {
  final List<ExerciseEntry> exercises;
  final int totalBurned;
  final int burnGoal;

  const ExerciseSection({
    super.key,
    required this.exercises,
    required this.totalBurned,
    required this.burnGoal,
  });

  @override
  Widget build(BuildContext context) {
    final totalTime = SummaryDataCalculator.getTotalExerciseTime(exercises);
    final isOverGoal = totalBurned >= burnGoal;
    final difference = (totalBurned - burnGoal).abs();
    final percentage = burnGoal > 0 ? ((totalBurned / burnGoal) * 100).round() : 0;

    return BaseSectionWidget(
      icon: Icons.fitness_center,
      title: 'EXERCISE & ACTIVITY LOG',
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(label: 'Total Exercise Duration', value: totalTime),
              InfoRow(label: 'Total Calories Burned', value: '$totalBurned calories'),
              InfoRow(
                label: 'Daily Burn Goal',
                value: '$burnGoal calories',
              ),
              InfoRow(
                label: isOverGoal ? 'Exceeded Goal' : 'Remaining to Goal',
                value: '$difference calories ($percentage%)',
                valueColor: isOverGoal ? NutritionColors.success : NutritionColors.warning,
              ),

              if (exercises.isNotEmpty) ...[
                const SizedBox(height: AppWidgetTheme.spaceMD),
                Text(
                  'Exercise Breakdown:',
                  style: AppTypography.labelLarge.copyWith(
                    fontSize: AppWidgetTheme.fontSizeMS,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: AppWidgetTheme.spaceMD),

                ...exercises.asMap().entries.map((entry) {
                  final index = entry.key;
                  final exercise = entry.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    '${index + 1}.',
                                    style: AppTypography.bodyMedium.copyWith(
                                      fontSize: AppWidgetTheme.fontSizeSM,
                                      fontWeight: FontWeight.w600,
                                      color: textColor,
                                    ),
                                  ),
                                  const SizedBox(width: AppWidgetTheme.spaceXS),
                                  Icon(
                                    _getExerciseIcon(exercise.name),
                                    color: textColor,
                                    size: AppWidgetTheme.iconSizeMedium,
                                  ),
                                  const SizedBox(width: AppWidgetTheme.spaceXS),
                                  Expanded(
                                    child: Text(
                                      exercise.name,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontSize: AppWidgetTheme.fontSizeSM,
                                        fontWeight: FontWeight.w600,
                                        color: textColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${exercise.caloriesBurned} cal',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: AppWidgetTheme.fontSizeSM,
                                fontWeight: FontWeight.bold,
                                color: NutritionColors.exerciseColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              'Duration: ${exercise.duration} min',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: AppWidgetTheme.fontSizeSM,
                                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Text(
                              'Pace: ${(exercise.caloriesBurned / exercise.duration).toStringAsFixed(1)} cal/min',
                              style: AppTypography.bodySmall.copyWith(
                                fontSize: AppWidgetTheme.fontSizeSM,
                                color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                              ),
                            ),
                          ],
                        ),
                        if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Notes: ${exercise.notes}',
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: AppWidgetTheme.fontSizeSM,
                              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ] else ...[
                const SizedBox(height: AppWidgetTheme.spaceMD),
                Text(
                  'No exercises logged today',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: AppWidgetTheme.fontSizeSM,
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// Get the appropriate icon for an exercise based on its name
  IconData _getExerciseIcon(String exerciseName) {
    final iconMap = {
      'running': Icons.directions_run,
      'cycling': Icons.directions_bike,
      'swimming': Icons.pool,
      'walking': Icons.directions_walk,
      'weight training': Icons.fitness_center,
      'yoga': Icons.self_improvement,
      'hiking': Icons.terrain,
      'basketball': Icons.sports_basketball,
      'soccer': Icons.sports_soccer,
      'tennis': Icons.sports_tennis,
    };

    final key = exerciseName.toLowerCase();
    for (var entry in iconMap.entries) {
      if (key.contains(entry.key)) {
        return entry.value;
      }
    }
    return Icons.sports_gymnastics;
  }
}
