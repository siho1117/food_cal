// lib/widgets/progress/exercise_log_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/exercise_entry.dart';
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/dialog_theme.dart';
import 'exercise_entry_dialog.dart';

// TODO: Add localization
// Required translation keys: exercise, calories, minutes, exercises,
// noActivityYet, logFirstExercise, logExercise

class ExerciseLogWidget extends StatelessWidget {
  final bool showHeader;
  final VoidCallback? onExerciseAdded;

  const ExerciseLogWidget({
    super.key,
    this.showHeader = true,
    this.onExerciseAdded,
  });

  void _showExerciseDialog(
    BuildContext context,
    ExerciseProvider provider, {
    ExerciseEntry? existingExercise,
  }) {
    showDialog(
      context: context,
      builder: (context) => ExerciseEntryDialog(
        exerciseProvider: provider,
        existingExercise: existingExercise,
        onExerciseSaved: onExerciseAdded,
      ),
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    ExerciseProvider provider,
    ExerciseEntry exercise,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: const Text(
          'Delete Exercise',
          style: AppDialogTheme.titleStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppDialogTheme.cancelButtonStyle,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppDialogTheme.buttonGap),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteExercise(exercise.id);
            },
            style: AppDialogTheme.destructiveButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  int _calculateTotalCalories(List<ExerciseEntry> exercises) {
    return exercises.fold(0, (sum, exercise) => sum + exercise.caloriesBurned);
  }

  int _calculateTotalMinutes(List<ExerciseEntry> exercises) {
    return exercises.fold(0, (sum, exercise) => sum + exercise.duration);
  }

  IconData _getExerciseIconData(String exerciseName) {
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
    return Icons.fitness_center;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ExerciseProvider, ThemeProvider>(
      builder: (context, exerciseProvider, themeProvider, child) {
        if (exerciseProvider.isLoading) {
          return _buildLoadingState(context, themeProvider);
        }

        if (exerciseProvider.errorMessage != null) {
          return _buildErrorState(context, exerciseProvider, themeProvider);
        }

        final exercises = exerciseProvider.exerciseEntries;

        if (exercises.isEmpty) {
          return _buildEmptyState(context, exerciseProvider, themeProvider);
        }

        return _buildContent(context, exerciseProvider, themeProvider, exercises);
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ExerciseProvider provider,
    ThemeProvider themeProvider,
    List<ExerciseEntry> exercises,
  ) {
    final textColor = AppColors.getTextColorForTheme(themeProvider.selectedGradient);
    final totalCalories = _calculateTotalCalories(exercises);
    final totalMinutes = _calculateTotalMinutes(exercises);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeProvider.selectedGradient == '01'
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header - Fixed title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercise',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () => _showExerciseDialog(context, provider),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: textColor == Colors.black
                        ? Colors.black.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Content - Side by Side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Stats Card with Animated Numbers
              _AnimatedStatsCard(
                textColor: textColor,
                totalCalories: totalCalories,
                totalMinutes: totalMinutes,
                exerciseCount: exercises.length,
              ),
              const SizedBox(width: 16),

              // Right: Exercise List with swipe-to-delete and tap-to-edit
              Expanded(
                child: _buildExerciseList(
                  context,
                  provider,
                  exercises,
                  textColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseList(
    BuildContext context,
    ExerciseProvider provider,
    List<ExerciseEntry> exercises,
    Color textColor,
  ) {
    return Column(
      children: exercises.map((exercise) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          child: Slidable(
            key: ValueKey(exercise.id),
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              extentRatio: 0.25,
              children: [
                CustomSlidableAction(
                  onPressed: (_) {
                    _showDeleteConfirmation(context, provider, exercise);
                  },
                  backgroundColor: Colors.red.shade600,
                  borderRadius: BorderRadius.circular(12),
                  autoClose: true,
                  padding: EdgeInsets.zero,
                  child: const Center(
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                _showExerciseDialog(
                  context,
                  provider,
                  existingExercise: exercise,
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: textColor == Colors.black
                      ? Colors.black.withValues(alpha: 0.06)
                      : Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: textColor == Colors.black
                            ? Colors.black.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _getExerciseIconData(exercise.name),
                        size: 20,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Exercise Info - 3 lines
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line 1: Exercise name
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          
                          // Line 2: Calories (emphasized - key metric)
                          Text(
                            '${exercise.caloriesBurned} cal',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: textColor.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 3),
                          
                          // Line 3: Duration
                          Text(
                            '${exercise.duration} min',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              color: textColor.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Edit indicator (chevron)
                    Icon(
                      Icons.chevron_right,
                      size: 18,
                      color: textColor.withValues(alpha: 0.4),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    ExerciseProvider provider,
    ThemeProvider themeProvider,
  ) {
    final textColor = AppColors.getTextColorForTheme(themeProvider.selectedGradient);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeProvider.selectedGradient == '01'
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header - Fixed title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Exercise',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Empty state content
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: textColor == Colors.black
                  ? Colors.black.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              size: 24,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Log your first exercise',
            style: TextStyle(
              fontSize: 13,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showExerciseDialog(context, provider),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: textColor == Colors.black
                    ? Colors.black.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.15),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: 16, color: textColor),
                  const SizedBox(width: 6),
                  Text(
                    'Log Exercise',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeProvider themeProvider) {
    final textColor = AppColors.getTextColorForTheme(themeProvider.selectedGradient);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 700),
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: themeProvider.selectedGradient == '01'
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    ExerciseProvider provider,
    ThemeProvider themeProvider,
  ) {
    final textColor = AppColors.getTextColorForTheme(themeProvider.selectedGradient);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 700),
      decoration: BoxDecoration(
        border: Border.all(
          color: themeProvider.selectedGradient == '01'
              ? Colors.black.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.5),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: textColor.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Exercises',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: 14,
              color: textColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor.withValues(alpha: 0.15),
              foregroundColor: textColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

// Animated Stats Card Widget
class _AnimatedStatsCard extends StatefulWidget {
  final Color textColor;
  final int totalCalories;
  final int totalMinutes;
  final int exerciseCount;

  const _AnimatedStatsCard({
    required this.textColor,
    required this.totalCalories,
    required this.totalMinutes,
    required this.exerciseCount,
  });

  @override
  State<_AnimatedStatsCard> createState() => _AnimatedStatsCardState();
}

class _AnimatedStatsCardState extends State<_AnimatedStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _caloriesAnimation;
  late Animation<double> _minutesAnimation;
  late Animation<double> _exerciseAnimation;

  int _previousCalories = 0;
  int _previousMinutes = 0;
  int _previousExercises = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _updateAnimations();
    _controller.forward();
  }

  @override
  void didUpdateWidget(_AnimatedStatsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.totalCalories != widget.totalCalories ||
        oldWidget.totalMinutes != widget.totalMinutes ||
        oldWidget.exerciseCount != widget.exerciseCount) {
      _previousCalories = oldWidget.totalCalories;
      _previousMinutes = oldWidget.totalMinutes;
      _previousExercises = oldWidget.exerciseCount;
      
      _controller.reset();
      _updateAnimations();
      _controller.forward();
    }
  }

  void _updateAnimations() {
    _caloriesAnimation = Tween<double>(
      begin: _previousCalories.toDouble(),
      end: widget.totalCalories.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _minutesAnimation = Tween<double>(
      begin: _previousMinutes.toDouble(),
      end: widget.totalMinutes.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _exerciseAnimation = Tween<double>(
      begin: _previousExercises.toDouble(),
      end: widget.exerciseCount.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      decoration: BoxDecoration(
        color: widget.textColor == Colors.black
            ? Colors.black.withValues(alpha: 0.08)
            : Colors.black.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            children: [
              // Calories
              _buildStatItem(
                widget.textColor,
                _caloriesAnimation.value.round().toString(),
                'Calories',
              ),
              Container(
                height: 1,
                width: 50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: widget.textColor.withValues(alpha: 0.2),
              ),

              // Minutes
              _buildStatItem(
                widget.textColor,
                _minutesAnimation.value.round().toString(),
                'Minutes',
              ),
              Container(
                height: 1,
                width: 50,
                margin: const EdgeInsets.symmetric(vertical: 10),
                color: widget.textColor.withValues(alpha: 0.2),
              ),

              // Exercises
              _buildStatItem(
                widget.textColor,
                _exerciseAnimation.value.round().toString(),
                _exerciseAnimation.value.round() == 1 ? 'Exercise' : 'Exercises',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatItem(Color textColor, String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            height: 1,
            color: textColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: textColor.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}