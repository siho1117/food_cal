// lib/widgets/summary/sections/exercise_section.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/summary_theme.dart';
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

    return BaseSectionWidget(
      icon: Icons.fitness_center,
      title: 'EXERCISE & ACTIVITY LOG (${SummaryDataCalculator.formatDate(DateTime.now())})',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InfoRow(label: 'Total Exercise Duration', value: totalTime),
          InfoRow(label: 'Total Calories Burned', value: '$totalBurned calories'),
          InfoRow(
            label: 'Daily Burn Goal',
            value: '$burnGoal calories (${((totalBurned / burnGoal) * 100).round()}%)',
          ),
          InfoRow(
            label: 'Remaining to Goal',
            value: '${burnGoal - totalBurned} calories',
            valueColor: totalBurned >= burnGoal ? SummaryTheme.success : SummaryTheme.warning,
          ),

          if (exercises.isNotEmpty) ...[
            SummaryTheme.itemSpacingWidget,
            Text('Exercise Breakdown:', style: SummaryTheme.sectionHeader.copyWith(fontSize: 13)),
            SummaryTheme.itemSpacingWidget,

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
                        Text(
                          '${index + 1}. ${exercise.name}',
                          style: SummaryTheme.infoValue.copyWith(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${exercise.caloriesBurned} cal',
                          style: SummaryTheme.infoValue.copyWith(
                            fontWeight: FontWeight.bold,
                            color: SummaryTheme.exerciseColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Duration: ${exercise.duration} min',
                          style: SummaryTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Intensity: ${exercise.intensity ?? "Not set"}',
                          style: SummaryTheme.bodySmall,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Pace: ${(exercise.caloriesBurned / exercise.duration).toStringAsFixed(1)} cal/min',
                          style: SummaryTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (exercise.notes != null && exercise.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Notes: ${exercise.notes}',
                        style: SummaryTheme.helperText,
                      ),
                    ],
                  ],
                ),
              );
            }),
          ] else ...[
            SummaryTheme.itemSpacingWidget,
            Text('No exercises logged today', style: SummaryTheme.helperText),
          ],
        ],
      ),
    );
  }
}
