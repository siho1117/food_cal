// lib/widgets/summary/sections/exercise_section.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:intl/intl.dart';
import '../../../config/design_system/widget_theme.dart';
import '../../../config/design_system/typography.dart';
import '../../../providers/theme_provider.dart';
import '../../../data/models/exercise_entry.dart';
import '../../../utils/shared/summary_data_calculator.dart';
import '../../../utils/summary/summary_period_utils.dart';
import '../summary_controls_widget.dart';
import 'base_section_widget.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../../common/activity_emoji.dart';

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
    final l10n = AppLocalizations.of(context)!;

    // Calculate period multiplier for weekly/monthly goals
    final periodDays = SummaryPeriodUtils.getPeriodDays(period);

    // Scale burn goal based on period
    final periodBurnGoal = burnGoal * periodDays;

    final totalTime = SummaryDataCalculator.getTotalExerciseTime(exercises);
    final isOverGoal = totalBurned >= periodBurnGoal;
    final difference = (totalBurned - periodBurnGoal).abs();
    final percentage = periodBurnGoal > 0 ? ((totalBurned / periodBurnGoal) * 100).round() : 0;

    return BaseSectionWidget(
      icon: AnimatedEmojis.muscle,
      title: l10n.exerciseActivityLog,
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final l10n = AppLocalizations.of(context)!;
          final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(label: l10n.totalExerciseDuration, value: totalTime),
              InfoRow(label: l10n.totalCaloriesBurned, value: '$totalBurned ${l10n.calories}'),
              InfoRow(
                label: _getBurnGoalLabel(l10n),
                value: '$periodBurnGoal ${l10n.calories}',
              ),
              InfoRow(
                label: isOverGoal ? l10n.exceededGoal : l10n.remainingToGoal,
                value: '$difference ${l10n.calories} ($percentage%)',
              ),

              if (exercises.isNotEmpty) ...[
                const SizedBox(height: AppWidgetTheme.spaceMD),
                Text(
                  '${l10n.exerciseBreakdown}:',
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
                                    ActivityEmoji(
                                      _getExerciseIconPath(exercise.name),
                                      size: AppWidgetTheme.iconSizeMedium,
                                    ),
                                    const SizedBox(width: AppWidgetTheme.spaceXS),
                                    Expanded(
                                      child: Text(
                                        _getLocalizedExerciseName(exercise.name, l10n),
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
                                '${exercise.caloriesBurned} ${l10n.cal}',
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
                                '${l10n.durationLabel}${exercise.duration} ${l10n.min}',
                                style: AppTypography.bodySmall.copyWith(
                                  fontSize: AppWidgetTheme.fontSizeSM,
                                  color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${l10n.paceLabel}${SummaryPeriodUtils.safeDivide(exercise.caloriesBurned, exercise.duration).toStringAsFixed(1)} ${l10n.calPerMin}',
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
                              '${l10n.notesLabel}${exercise.notes}',
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
                    final dateStr = _formatDate(context, exercise.timestamp);

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
                              '${index + 1}. ${_getLocalizedExerciseName(exercise.name, l10n)}',
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
                            '${exercise.caloriesBurned} ${l10n.cal}  |  $durationStr  |  $dateStr',
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
                  _getEmptyMessage(l10n),
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

  /// Get the appropriate icon path for an exercise based on its name
  String _getExerciseIconPath(String exerciseName) {
    // Map standard exercise names (in English) to their emoji paths
    final iconMap = {
      'Running': ActivityEmojis.personRunning,
      'Cycling': ActivityEmojis.personBiking,
      'Swimming': ActivityEmojis.personSwimming,
      'Walking': ActivityEmojis.personWalking,
      'Weight Training': ActivityEmojis.personLiftingWeights,
      'Yoga': ActivityEmojis.personLotus,
    };

    // Direct match first (for English or exact matches)
    if (iconMap.containsKey(exerciseName)) {
      return iconMap[exerciseName]!;
    }

    // Fallback to contains check (case-insensitive)
    final key = exerciseName.toLowerCase();
    for (var entry in iconMap.entries) {
      if (key.contains(entry.key.toLowerCase())) {
        return entry.value;
      }
    }

    return ActivityEmojis.personCartwheeling; // Default fallback
  }

  /// Get localized exercise name for standard exercises
  String _getLocalizedExerciseName(String exerciseName, AppLocalizations l10n) {
    switch (exerciseName) {
      case 'Running':
        return l10n.running;
      case 'Walking':
        return l10n.walking;
      case 'Cycling':
        return l10n.cycling;
      case 'Swimming':
        return l10n.swimming;
      case 'Weight Training':
        return l10n.weightTraining;
      case 'Yoga':
        return l10n.yoga;
      default:
        return exerciseName; // Return as-is for custom exercises
    }
  }

  /// Get burn goal label based on period
  String _getBurnGoalLabel(AppLocalizations l10n) {
    if (period == SummaryPeriod.weekly) {
      return l10n.weeklyBurnGoal;
    } else if (period == SummaryPeriod.monthly) {
      return l10n.monthlyBurnGoal;
    }
    return l10n.dailyBurnGoal;
  }

  /// Get empty message based on period
  String _getEmptyMessage(AppLocalizations l10n) {
    if (period == SummaryPeriod.weekly) {
      return l10n.noExercisesLoggedWeek;
    } else if (period == SummaryPeriod.monthly) {
      return l10n.noExercisesLoggedMonth;
    }
    return l10n.noExercisesLoggedToday;
  }

  /// Format date for display (localized short format)
  /// Examples: "12/19" (en_US), "12月19日" (zh_CN), "12/19" (ja_JP)
  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.Md(locale).format(date);
  }

  /// Format duration for compact display (always in minutes: 30m, 75m, etc.)
  String _formatDuration(int minutes) {
    return '${minutes}m';
  }
}
