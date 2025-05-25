// lib/widgets/exercise/exercise_log_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import 'exercise_entry_dialog.dart';

class ExerciseLogWidget extends StatefulWidget {
  final bool showHeader;
  final VoidCallback? onExerciseAdded;

  const ExerciseLogWidget({
    Key? key,
    this.showHeader = true,
    this.onExerciseAdded,
  }) : super(key: key);

  @override
  State<ExerciseLogWidget> createState() => _ExerciseLogWidgetState();
}

class _ExerciseLogWidgetState extends State<ExerciseLogWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Animation for progress bar
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExerciseProvider>(
      builder: (context, exerciseProvider, child) {
        if (exerciseProvider.isLoading) {
          return _buildLoadingState();
        }

        if (exerciseProvider.errorMessage != null) {
          return _buildErrorState(exerciseProvider);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Optional header
            if (widget.showHeader) ...[
              _buildHeader(exerciseProvider),
              const SizedBox(height: 16),
            ],

            // Progress section
            _buildProgressSection(exerciseProvider),

            const SizedBox(height: 16),

            // Quick exercise buttons
            _buildQuickExerciseSection(exerciseProvider),

            const SizedBox(height: 16),

            // Exercise log section
            _buildExerciseLogSection(exerciseProvider),
          ],
        );
      },
    );
  }

  Widget _buildHeader(ExerciseProvider exerciseProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center_rounded,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'TODAY\'S EXERCISE LOG',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              Icons.refresh_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            onPressed: () => exerciseProvider.refreshData(),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(ExerciseProvider exerciseProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red[400],
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Exercises',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            exerciseProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => exerciseProvider.refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(ExerciseProvider exerciseProvider) {
    final totalBurned = exerciseProvider.totalCaloriesBurned;
    final burnGoal = exerciseProvider.dailyBurnGoal;
    final progress = exerciseProvider.burnProgress;
    final remaining = exerciseProvider.caloriesRemaining;
    final isGoalAchieved = exerciseProvider.isGoalAchieved;

    // Determine status color
    Color statusColor = isGoalAchieved 
        ? Colors.green[500]! 
        : AppTheme.primaryBlue;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.02),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Exercise Progress',
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),

          // Progress content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
            child: Column(
              children: [
                // Calories burned display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Current calories burned
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$totalBurned',
                            style: AppTextStyles.getNumericStyle().copyWith(
                              fontSize: 34,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                              height: 0.9,
                            ),
                          ),
                          TextSpan(
                            text: ' / $burnGoal',
                            style: AppTextStyles.getNumericStyle().copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Status indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isGoalAchieved
                            ? Colors.green[50]
                            : AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isGoalAchieved
                              ? Colors.green[200]!
                              : AppTheme.primaryBlue.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isGoalAchieved
                                ? Icons.check_circle_outline_rounded
                                : Icons.schedule_rounded,
                            size: 16,
                            color: isGoalAchieved
                                ? Colors.green[600]
                                : AppTheme.primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isGoalAchieved
                                ? 'Goal achieved!'
                                : '$remaining left',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isGoalAchieved
                                  ? Colors.green[700]
                                  : AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Progress description
                Row(
                  children: [
                    Text(
                      'calories burned today',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(progress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Progress bar
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return _buildProgressBar(
                      progress * _progressAnimation.value,
                      statusColor,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress, Color statusColor) {
    final barHeight = 12.0;
    final trackColor = Colors.grey[200]!;

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        color: trackColor,
        borderRadius: BorderRadius.circular(barHeight / 2),
      ),
      child: FractionallySizedBox(
        widthFactor: progress.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                statusColor.withValues(alpha: 0.7),
                statusColor,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(barHeight / 2),
            boxShadow: [
              BoxShadow(
                color: statusColor.withValues(alpha: 0.3),
                blurRadius: 3,
                spreadRadius: 0,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickExerciseSection(ExerciseProvider exerciseProvider) {
    final commonExercises = [
      {'name': 'Walking', 'icon': Icons.directions_walk, 'color': AppTheme.mintAccent},
      {'name': 'Running', 'icon': Icons.directions_run, 'color': AppTheme.coralAccent},
      {'name': 'Cycling', 'icon': Icons.directions_bike, 'color': AppTheme.goldAccent},
      {'name': 'Swimming', 'icon': Icons.pool, 'color': AppTheme.accentColor},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Quick Log',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _showExerciseEntryDialog(exerciseProvider),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Custom'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  ),
                ),
              ],
            ),
          ),

          // Quick exercise buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Row(
              children: commonExercises.map((exercise) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _buildQuickExerciseButton(
                      name: exercise['name'] as String,
                      icon: exercise['icon'] as IconData,
                      color: exercise['color'] as Color,
                      onTap: () => _showQuickExerciseDialog(
                        exerciseProvider,
                        exercise['name'] as String,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickExerciseButton({
    required String name,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseLogSection(ExerciseProvider exerciseProvider) {
    final exercises = exerciseProvider.exerciseEntries;

    if (exercises.isEmpty) {
      return _buildEmptyExerciseState();
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.list_alt_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Today\'s Exercises',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                const Spacer(),
                Text(
                  '${exercises.length} ${exercises.length == 1 ? 'exercise' : 'exercises'}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Exercise list
          ...exercises.map((exercise) => _buildExerciseListItem(exercise, exerciseProvider)),
        ],
      ),
    );
  }

  Widget _buildEmptyExerciseState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.fitness_center,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Exercises Logged Today',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Use the quick log buttons above or add a custom exercise',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListItem(ExerciseEntry exercise, ExerciseProvider exerciseProvider) {
    final intensityColor = _getIntensityColor(exercise.intensity);

    return Dismissible(
      key: Key(exercise.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red[400],
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 26,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        await exerciseProvider.deleteExercise(exercise.id);
        if (widget.onExerciseAdded != null) {
          widget.onExerciseAdded!();
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${exercise.name} removed'),
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: InkWell(
        onTap: () => _showExerciseEntryDialog(exerciseProvider, exercise),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Exercise type icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: intensityColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getExerciseIcon(exercise.type),
                  color: intensityColor,
                  size: 20,
                ),
              ),

              const SizedBox(width: 12),

              // Exercise details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${exercise.getFormattedDuration()} • ${exercise.intensity}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Calories burned
              Text(
                exercise.getFormattedCalories(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'light':
        return AppTheme.mintAccent;
      case 'moderate':
        return AppTheme.goldAccent;
      case 'intense':
        return AppTheme.coralAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getExerciseIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return Icons.directions_run;
      case 'strength':
        return Icons.fitness_center;
      case 'flexibility':
        return Icons.self_improvement;
      case 'sports':
        return Icons.sports_tennis;
      case 'water':
        return Icons.pool;
      default:
        return Icons.directions_walk;
    }
  }

  void _showExerciseEntryDialog(ExerciseProvider exerciseProvider, [ExerciseEntry? existingExercise]) {
    showDialog(
      context: context,
      builder: (context) => ExerciseEntryDialog(
        exerciseProvider: exerciseProvider,
        existingExercise: existingExercise,
        onExerciseSaved: () {
          if (widget.onExerciseAdded != null) {
            widget.onExerciseAdded!();
          }
        },
      ),
    );
  }

  void _showQuickExerciseDialog(ExerciseProvider exerciseProvider, String exerciseName) {
    showDialog(
      context: context,
      builder: (context) => ExerciseEntryDialog(
        exerciseProvider: exerciseProvider,
        preselectedExercise: exerciseName,
        onExerciseSaved: () {
          if (widget.onExerciseAdded != null) {
            widget.onExerciseAdded!();
          }
        },
      ),
    );
  }
}