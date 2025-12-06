// lib/widgets/summary/sections/exercise_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/exercise_entry.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import '../summary_controls_widget.dart';
import 'base_section_widget.dart';

/// Exercise & Activity Log Section
class ExerciseSection extends StatelessWidget {
  final List<ExerciseEntry> exercises;
  final int totalBurned;
  final int burnGoal;
  final SummaryPeriod? period; // Optional period for weekly/monthly display

  const ExerciseSection({
    super.key,
    required this.exercises,
    required this.totalBurned,
    required this.burnGoal,
    this.period,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate period multiplier for weekly/monthly goals
    final periodDays = period == SummaryPeriod.weekly
        ? 7
        : period == SummaryPeriod.monthly
            ? 30
            : 1;

    // Scale burn goal based on period
    final periodBurnGoal = burnGoal * periodDays;

    final totalTime = SummaryDataCalculator.getTotalExerciseTime(exercises);
    final isOverGoal = totalBurned >= periodBurnGoal;
    final difference = (totalBurned - periodBurnGoal).abs();
    final percentage = periodBurnGoal > 0 ? ((totalBurned / periodBurnGoal) * 100).round() : 0;

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
                label: _getBurnGoalLabel(),
                value: '$periodBurnGoal calories',
              ),
              InfoRow(
                label: isOverGoal ? 'Exceeded Goal' : 'Remaining to Goal',
                value: '$difference calories ($percentage%)',
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

                // Show exercises based on period
                if (period == SummaryPeriod.daily) ...[
                  // Daily: Show detailed view with duration and pace (latest first)
                  ...exercises.reversed.toList().asMap().entries.map((entry) {
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
                                  color: textColor,
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
                  // Weekly/Monthly: Show simplified compact list with dates (latest first)
                  ...exercises.reversed.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final exercise = entry.value;

                    // Format date
                    final dateStr = _formatDate(exercise.timestamp);

                    // Format duration
                    final durationStr = _formatDuration(exercise.duration);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Exercise name
                          Expanded(
                            child: Text(
                              '${index + 1}. ${exercise.name}',
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
                          // Right: Calories | Duration | Date
                          Text(
                            '${exercise.caloriesBurned} cal  |  $durationStr  |  $dateStr',
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
              ] else ...[
                const SizedBox(height: AppWidgetTheme.spaceMD),
                Text(
                  _getEmptyMessage(),
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

  /// Get burn goal label based on period
  String _getBurnGoalLabel() {
    if (period == SummaryPeriod.weekly) {
      return 'Weekly Burn Goal';
    } else if (period == SummaryPeriod.monthly) {
      return 'Monthly Burn Goal';
    }
    return 'Daily Burn Goal';
  }

  /// Get empty message based on period
  String _getEmptyMessage() {
    if (period == SummaryPeriod.weekly) {
      return 'No exercises logged this week';
    } else if (period == SummaryPeriod.monthly) {
      return 'No exercises logged this month';
    }
    return 'No exercises logged today';
  }

  /// Format date for display (MM/DD)
  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$month/$day';
  }

  /// Format duration for compact display (always in minutes: 30m, 75m, etc.)
  String _formatDuration(int minutes) {
    return '${minutes}m';
  }
}
