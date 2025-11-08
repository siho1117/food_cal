// lib/widgets/progress/exercise_log_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/theme_provider.dart';
import '../../data/models/exercise_entry.dart';
import '../../config/design_system/widget_theme.dart';
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
    final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);
    final totalCalories = _calculateTotalCalories(exercises);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppWidgetTheme.getBorderColor(
            themeProvider.selectedGradient,
            AppWidgetTheme.cardBorderOpacity,
          ),
          width: AppWidgetTheme.cardBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
      ),
      padding: AppWidgetTheme.cardPadding,
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
                  fontSize: AppWidgetTheme.fontSizeLG,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                  color: textColor,
                ),
              ),
              GestureDetector(
                onTap: () => _showExerciseDialog(context, provider),
                child: Container(
                  width: AppWidgetTheme.iconContainerSmall,
                  height: AppWidgetTheme.iconContainerSmall,
                  decoration: BoxDecoration(
                    color: AppWidgetTheme.getIconContainerColor(
                      textColor,
                      AppWidgetTheme.opacityMediumLight,
                    ),
                    borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXS),
                  ),
                  child: Icon(
                    Icons.add,
                    size: AppWidgetTheme.iconSizeSmall,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppWidgetTheme.spaceLG),

          // Main Content - Side by Side
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: Stats Card with Animated Numbers
              _AnimatedStatsCard(
                textColor: textColor,
                currentCalories: totalCalories,
                targetCalories: provider.dailyBurnGoal,
                progressPercentage: provider.burnProgress,
              ),
              SizedBox(width: AppWidgetTheme.spaceLG),

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
          margin: EdgeInsets.only(bottom: AppWidgetTheme.spaceMS),
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
                  backgroundColor: AppDialogTheme.colorDestructive,
                  borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
                  autoClose: true,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: AppWidgetTheme.iconSizeMedium,
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
              borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
              child: Container(
                padding: EdgeInsets.all(AppWidgetTheme.spaceML),
                decoration: BoxDecoration(
                  color: AppWidgetTheme.getBackgroundColor(
                    textColor,
                    AppWidgetTheme.opacityLight,
                  ),
                  borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusSM),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icon
                    Container(
                      width: AppWidgetTheme.iconContainerMedium,
                      height: AppWidgetTheme.iconContainerMedium,
                      decoration: BoxDecoration(
                        color: AppWidgetTheme.getIconContainerColor(
                          textColor,
                          AppWidgetTheme.opacityMedium,
                        ),
                        borderRadius: BorderRadius.circular(AppWidgetTheme.spaceMS),
                      ),
                      child: Icon(
                        _getExerciseIconData(exercise.name),
                        size: AppWidgetTheme.iconSizeSmall,
                        color: textColor,
                      ),
                    ),
                    SizedBox(width: AppWidgetTheme.spaceML),

                    // Exercise Info - 3 lines
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Line 1: Exercise name
                          Text(
                            exercise.name,
                            style: TextStyle(
                              fontSize: AppWidgetTheme.fontSizeML,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppWidgetTheme.spaceXS),

                          // Line 2: Calories (emphasized - key metric)
                          Text(
                            '${exercise.caloriesBurned} cal',
                            style: TextStyle(
                              fontSize: AppWidgetTheme.fontSizeMD,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              color: textColor.withValues(alpha: AppWidgetTheme.opacityHighest),
                            ),
                          ),
                          SizedBox(height: AppWidgetTheme.spaceXXS),

                          // Line 3: Duration
                          Text(
                            '${exercise.duration} min',
                            style: TextStyle(
                              fontSize: AppWidgetTheme.fontSizeMS,
                              fontWeight: FontWeight.w500,
                              height: 1.2,
                              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Edit indicator (chevron)
                    Icon(
                      Icons.chevron_right,
                      size: AppWidgetTheme.fontSizeLG,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityHigh),
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
    final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppWidgetTheme.getBorderColor(
            themeProvider.selectedGradient,
            AppWidgetTheme.cardBorderOpacity,
          ),
          width: AppWidgetTheme.cardBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
      ),
      padding: AppWidgetTheme.cardPadding,
      child: Column(
        children: [
          // Header - Fixed title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Exercise',
              style: TextStyle(
                fontSize: AppWidgetTheme.fontSizeLG,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXXXL),

          // Empty state content
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppWidgetTheme.getIconContainerColor(
                textColor,
                AppWidgetTheme.opacityMediumLight,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center,
              size: AppWidgetTheme.iconSizeMedium,
              color: textColor,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceMD),
          Text(
            'No activity yet',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeML,
              fontWeight: FontWeight.w600,
              color: textColor,
              height: 1,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXS),
          Text(
            'Log your first exercise',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeSM,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceLG),
          GestureDetector(
            onTap: () => _showExerciseDialog(context, provider),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppWidgetTheme.spaceLG,
                vertical: AppWidgetTheme.spaceSM,
              ),
              decoration: BoxDecoration(
                color: AppWidgetTheme.getBackgroundColor(
                  textColor,
                  AppWidgetTheme.opacityMediumLight,
                ),
                border: Border.all(
                  color: textColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXS),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, size: AppWidgetTheme.spaceLG, color: textColor),
                  SizedBox(width: AppWidgetTheme.spaceXS),
                  Text(
                    'Log Exercise',
                    style: TextStyle(
                      fontSize: AppWidgetTheme.fontSizeSM,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceXXXL),
        ],
      ),
    );
  }

  Widget _buildLoadingState(BuildContext context, ThemeProvider themeProvider) {
    final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(
          color: AppWidgetTheme.getBorderColor(
            themeProvider.selectedGradient,
            AppWidgetTheme.cardBorderOpacity,
          ),
          width: AppWidgetTheme.cardBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
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
    final textColor = AppWidgetTheme.getTextColor(themeProvider.selectedGradient);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(maxWidth: AppWidgetTheme.maxWidgetWidth),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppWidgetTheme.getBorderColor(
            themeProvider.selectedGradient,
            AppWidgetTheme.cardBorderOpacity,
          ),
          width: AppWidgetTheme.cardBorderWidth,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
      ),
      padding: AppWidgetTheme.cardPadding,
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          ),
          SizedBox(height: AppWidgetTheme.spaceLG),
          Text(
            'Error Loading Exercises',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeLG,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          SizedBox(height: AppWidgetTheme.spaceSM),
          Text(
            provider.errorMessage ?? 'Unknown error occurred',
            style: TextStyle(
              fontSize: AppWidgetTheme.fontSizeMS,
              color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppWidgetTheme.spaceLG),
          ElevatedButton(
            onPressed: () => provider.refreshData(),
            style: ElevatedButton.styleFrom(
              backgroundColor: textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
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
  final int currentCalories;
  final int targetCalories;
  final double progressPercentage;

  const _AnimatedStatsCard({
    required this.textColor,
    required this.currentCalories,
    required this.targetCalories,
    required this.progressPercentage,
  });

  @override
  State<_AnimatedStatsCard> createState() => _AnimatedStatsCardState();
}

class _AnimatedStatsCardState extends State<_AnimatedStatsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _currentCaloriesAnimation;
  late Animation<double> _targetCaloriesAnimation;
  late Animation<double> _percentageAnimation;

  int _previousCurrentCalories = 0;
  int _previousTargetCalories = 0;
  double _previousPercentage = 0.0;

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

    if (oldWidget.currentCalories != widget.currentCalories ||
        oldWidget.targetCalories != widget.targetCalories ||
        oldWidget.progressPercentage != widget.progressPercentage) {
      _previousCurrentCalories = oldWidget.currentCalories;
      _previousTargetCalories = oldWidget.targetCalories;
      _previousPercentage = oldWidget.progressPercentage;

      _controller.reset();
      _updateAnimations();
      _controller.forward();
    }
  }

  void _updateAnimations() {
    _currentCaloriesAnimation = Tween<double>(
      begin: _previousCurrentCalories.toDouble(),
      end: widget.currentCalories.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _targetCaloriesAnimation = Tween<double>(
      begin: _previousTargetCalories.toDouble(),
      end: widget.targetCalories.toDouble(),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _percentageAnimation = Tween<double>(
      begin: _previousPercentage,
      end: widget.progressPercentage,
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
        color: AppWidgetTheme.getBackgroundColor(
          widget.textColor,
          AppWidgetTheme.opacityLight,
        ),
        borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceMS,
        vertical: AppWidgetTheme.spaceML,
      ),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final currentCal = _currentCaloriesAnimation.value.round();
          final targetCal = _targetCaloriesAnimation.value.round();
          final percentage = (_percentageAnimation.value * 100).round();

          return Column(
            children: [
              // Calories (current / target)
              _buildCaloriesFractionItem(
                widget.textColor,
                currentCal,
                targetCal,
              ),
              Container(
                height: 1,
                width: 50,
                margin: EdgeInsets.symmetric(vertical: AppWidgetTheme.spaceMS),
                color: widget.textColor.withValues(alpha: AppWidgetTheme.opacityMediumHigh),
              ),

              // Percentage with circular progress ring
              _buildPercentageRing(
                widget.textColor,
                percentage,
                _percentageAnimation.value,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCaloriesFractionItem(Color textColor, int current, int target) {
    return Column(
      children: [
        // Calories Burned (current)
        Text(
          current.toString(),
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeXXL,
            fontWeight: FontWeight.w700,
            height: 1,
            color: textColor,
          ),
        ),
        SizedBox(height: 2),
        // Divider
        Container(
          height: 1.5,
          width: 40,
          color: textColor.withValues(alpha: AppWidgetTheme.opacityHigh),
        ),
        SizedBox(height: 2),
        // Target Calories
        Text(
          target.toString(),
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeLG,
            fontWeight: FontWeight.w600,
            height: 1,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'CALORIES',
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeXS,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPercentageRing(Color textColor, int percentage, double progress) {
    return Column(
      children: [
        // Circular progress ring
        SizedBox(
          width: 55,
          height: 55,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Background ring
              SizedBox(
                width: 55,
                height: 55,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 4.5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    textColor.withValues(alpha: AppWidgetTheme.opacityMedium),
                  ),
                ),
              ),
              // Progress ring
              SizedBox(
                width: 55,
                height: 55,
                child: CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 4.5,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              ),
              // Percentage text
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: AppWidgetTheme.fontSizeML,
                  fontWeight: FontWeight.w700,
                  height: 1,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'COMPLETE',
          style: TextStyle(
            fontSize: AppWidgetTheme.fontSizeXS,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
            color: textColor.withValues(alpha: AppWidgetTheme.opacityHigher),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

}