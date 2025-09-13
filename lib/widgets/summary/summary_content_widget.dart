// lib/widgets/summary/summary_content_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import 'summary_controls_widget.dart';

class SummaryContentWidget extends StatelessWidget {
  final SummaryPeriod period;

  const SummaryContentWidget({
    super.key,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, ExerciseProvider>(
      builder: (context, homeProvider, exerciseProvider, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),
              
              const SizedBox(height: 24),
              
              // Key Metrics Row
              _buildKeyMetrics(homeProvider, exerciseProvider),
              
              const SizedBox(height: 28),
              
              // Progress Section
              _buildProgressSection(homeProvider, exerciseProvider),
              
              const SizedBox(height: 28),
              
              // Nutrition Breakdown
              _buildNutritionBreakdown(homeProvider),
              
              const SizedBox(height: 28),
              
              // Exercise Breakdown
              _buildExerciseBreakdown(exerciseProvider),
              
              const SizedBox(height: 28),
              
              // Summary Stats
              _buildSummaryStats(homeProvider, exerciseProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    String title;
    String subtitle;

    switch (period) {
      case SummaryPeriod.daily:
        title = 'DAILY SUMMARY';
        subtitle = _formatDate(now);
        break;
      case SummaryPeriod.weekly:
        title = 'WEEKLY SUMMARY';
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        final endOfWeek = startOfWeek.add(const Duration(days: 6));
        subtitle = '${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)}';
        break;
      case SummaryPeriod.monthly:
        title = 'MONTHLY SUMMARY';
        subtitle = _formatMonth(now);
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.getHeadingStyle().copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(HomeProvider homeProvider, ExerciseProvider exerciseProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryBlue.withValues(alpha: 0.05),
            AppTheme.primaryBlue.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricItem(
              icon: '🔥',
              value: _getCaloriesValue(homeProvider),
              label: 'Calories',
              color: Colors.orange[600]!,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildMetricItem(
              icon: '💰',
              value: _getCostValue(homeProvider),
              label: 'Spent',
              color: Colors.green[600]!,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[300],
          ),
          Expanded(
            child: _buildMetricItem(
              icon: '🏃',
              value: _getExerciseValue(exerciseProvider),
              label: 'Burned',
              color: Colors.red[600]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem({
    required String icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(HomeProvider homeProvider, ExerciseProvider exerciseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PROGRESS OVERVIEW',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        // Calories Consumed Progress
        _buildProgressBar(
          label: 'Calories Consumed',
          value: homeProvider.totalCalories,
          target: homeProvider.calorieGoal,
          progress: homeProvider.calorieProgress,
          color: Colors.blue[600]!,
          unit: '',
        ),
        
        const SizedBox(height: 16),
        
        // Exercise Burned Progress
        _buildProgressBar(
          label: 'Exercise Burned',
          value: exerciseProvider.totalCaloriesBurned,
          target: exerciseProvider.dailyBurnGoal,
          progress: exerciseProvider.burnProgress,
          color: Colors.red[600]!,
          unit: '',
        ),
        
        const SizedBox(height: 16),
        
        // Budget Progress
        _buildProgressBar(
          label: 'Budget',
          value: homeProvider.totalFoodCost,
          target: homeProvider.dailyFoodBudget,
          progress: homeProvider.budgetProgress,
          color: Colors.green[600]!,
          unit: '\$',
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required String label,
    required num value,
    required num target,
    required double progress,
    required Color color,
    required String unit,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '$unit${value.toStringAsFixed(unit == '\$' ? 2 : 0)} / $unit${target.toStringAsFixed(unit == '\$' ? 2 : 0)}',
              style: AppTextStyles.getNumericStyle().copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            widthFactor: progress.clamp(0.0, 1.0),
            alignment: Alignment.centerLeft,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progress * 100).clamp(0, 999).round()}%',
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBreakdown(HomeProvider homeProvider) {
    final consumed = homeProvider.consumedMacros;
    final targets = homeProvider.targetMacros;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NUTRITION BREAKDOWN',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildMacroRow(
          icon: '🍳',
          name: 'Protein',
          consumed: consumed['protein']!.round(),
          target: targets['protein']!,
          color: Colors.purple[600]!,
        ),
        
        const SizedBox(height: 12),
        
        _buildMacroRow(
          icon: '🍞',
          name: 'Carbs',
          consumed: consumed['carbs']!.round(),
          target: targets['carbs']!,
          color: Colors.orange[600]!,
        ),
        
        const SizedBox(height: 12),
        
        _buildMacroRow(
          icon: '🥑',
          name: 'Fat',
          consumed: consumed['fat']!.round(),
          target: targets['fat']!,
          color: Colors.green[600]!,
        ),
      ],
    );
  }

  Widget _buildMacroRow({
    required String icon,
    required String name,
    required int consumed,
    required int target,
    required Color color,
  }) {
    final progress = target > 0 ? (consumed / target).clamp(0.0, 1.0) : 0.0;
    
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  Text(
                    '${consumed}g / ${target}g',
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(3),
                ),
                child: FractionallySizedBox(
                  widthFactor: progress,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseBreakdown(ExerciseProvider exerciseProvider) {
    final exercises = exerciseProvider.exerciseEntries;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EXERCISE BREAKDOWN',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        if (exercises.isEmpty) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
                const SizedBox(width: 12),
                Text(
                  period == SummaryPeriod.daily 
                      ? 'No exercises logged today'
                      : 'No exercises logged this ${period.name}',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          ...exercises.take(3).map((exercise) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildExerciseRow(exercise),
          )),
          if (exercises.length > 3) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+${exercises.length - 3} more exercises',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 12,
                  color: AppTheme.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
        
        const SizedBox(height: 12),
        
        if (exercises.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'Total Exercise Time: ${_getTotalExerciseTime(exercises)}',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 14,
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildExerciseRow(dynamic exercise) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.red[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.fitness_center,
            size: 16,
            color: Colors.red[600],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise.name ?? 'Unknown Exercise',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${exercise.duration ?? 0} min',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          '${exercise.caloriesBurned ?? 0} cal',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(HomeProvider homeProvider, ExerciseProvider exerciseProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          period == SummaryPeriod.daily ? 'DAILY STATS' : '${period.name.toUpperCase()} STATS',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              _buildStatRow(
                icon: '📊',
                label: 'Meals Logged',
                value: homeProvider.mealsCount.toString(),
              ),
              
              const SizedBox(height: 12),
              
              _buildStatRow(
                icon: '💵',
                label: 'Avg per meal',
                value: homeProvider.mealsCount > 0 
                    ? '\$${(homeProvider.totalFoodCost / homeProvider.mealsCount).toStringAsFixed(2)}'
                    : '\$0.00',
              ),
              
              const SizedBox(height: 12),
              
              _buildStatRow(
                icon: '🔥',
                label: 'Net Calories',
                value: '${homeProvider.totalCalories - exerciseProvider.totalCaloriesBurned}',
              ),
              
              const SizedBox(height: 12),
              
              _buildStatRow(
                icon: '⏱️',
                label: 'Exercise Duration',
                value: _getTotalExerciseTime(exerciseProvider.exerciseEntries),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow({
    required String icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatMonth(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _getCaloriesValue(HomeProvider homeProvider) {
    switch (period) {
      case SummaryPeriod.daily:
        return homeProvider.totalCalories.toString();
      case SummaryPeriod.weekly:
        return (homeProvider.totalCalories * 7).toStringAsFixed(0);
      case SummaryPeriod.monthly:
        return (homeProvider.totalCalories * 30).toStringAsFixed(0);
    }
  }

  String _getCostValue(HomeProvider homeProvider) {
    switch (period) {
      case SummaryPeriod.daily:
        return '\${homeProvider.totalFoodCost.toStringAsFixed(2)}';
      case SummaryPeriod.weekly:
        return '\${homeProvider.weeklyFoodCost.toStringAsFixed(2)}';
      case SummaryPeriod.monthly:
        return '\${homeProvider.monthlyFoodCost.toStringAsFixed(2)}';
    }
  }

  String _getExerciseValue(ExerciseProvider exerciseProvider) {
    switch (period) {
      case SummaryPeriod.daily:
        return '${exerciseProvider.totalCaloriesBurned}';
      case SummaryPeriod.weekly:
        return '${(exerciseProvider.totalCaloriesBurned * 7).toStringAsFixed(0)}'; // Approximate
      case SummaryPeriod.monthly:
        return '${(exerciseProvider.totalCaloriesBurned * 30).toStringAsFixed(0)}'; // Approximate
    }
  }

  String _getTotalExerciseTime(List<dynamic> exercises) {
    final totalMinutes = exercises.fold<int>(
      0,
      (sum, exercise) => sum + (exercise.duration ?? 0),
    );
    
    if (totalMinutes < 60) {
      return '${totalMinutes} min';
    } else {
      final hours = totalMinutes ~/ 60;
      final minutes = totalMinutes % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }
}