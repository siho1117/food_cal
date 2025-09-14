// lib/widgets/summary/summary_content_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../utils/summary_data_calculator.dart';
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
        // Calculate all data using the separated calculator
        final keyMetrics = SummaryDataCalculator.calculateKeyMetrics(period, homeProvider, exerciseProvider);
        final progressData = SummaryDataCalculator.calculateProgressData(period, homeProvider, exerciseProvider);
        final nutritionData = SummaryDataCalculator.calculateNutritionData(homeProvider);
        final exerciseData = SummaryDataCalculator.calculateExerciseData(period, exerciseProvider);
        final statsData = SummaryDataCalculator.calculateSummaryStats(homeProvider, exerciseProvider);

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
              _buildKeyMetrics(keyMetrics),
              
              const SizedBox(height: 28),
              
              // Progress Section
              _buildProgressSection(progressData),
              
              const SizedBox(height: 28),
              
              // Nutrition Breakdown
              _buildNutritionBreakdown(nutritionData),
              
              const SizedBox(height: 28),
              
              // Exercise Breakdown
              _buildExerciseBreakdown(exerciseData),
              
              const SizedBox(height: 28),
              
              // Summary Stats
              _buildSummaryStats(statsData),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SummaryDataCalculator.getPeriodTitle(period),
          style: AppTextStyles.getHeadingStyle().copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          SummaryDataCalculator.getPeriodSubtitle(period),
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics(Map<String, String> metrics) {
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
              value: metrics['calories']!,
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
              value: metrics['cost']!,
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
              value: metrics['burned']!,
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

  Widget _buildProgressSection(Map<String, Map<String, dynamic>> progressData) {
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
        
        // Calories Progress
        _buildProgressBar(
          data: progressData['calories']!,
          color: Colors.blue[600]!,
        ),
        
        const SizedBox(height: 16),
        
        // Exercise Progress
        _buildProgressBar(
          data: progressData['exercise']!,
          color: Colors.red[600]!,
        ),
        
        const SizedBox(height: 16),
        
        // Budget Progress
        _buildProgressBar(
          data: progressData['budget']!,
          color: Colors.green[600]!,
        ),
      ],
    );
  }

  Widget _buildProgressBar({
    required Map<String, dynamic> data,
    required Color color,
  }) {
    final label = data['label'] as String;
    final value = data['value'] as double;
    final target = data['target'] as double;
    final progress = data['progress'] as double;
    final unit = data['unit'] as String;

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

  Widget _buildNutritionBreakdown(Map<String, Map<String, dynamic>> nutritionData) {
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
          data: nutritionData['protein']!,
          color: Colors.purple[600]!,
        ),
        
        const SizedBox(height: 12),
        
        _buildMacroRow(
          data: nutritionData['carbs']!,
          color: Colors.orange[600]!,
        ),
        
        const SizedBox(height: 12),
        
        _buildMacroRow(
          data: nutritionData['fat']!,
          color: Colors.green[600]!,
        ),
      ],
    );
  }

  Widget _buildMacroRow({
    required Map<String, dynamic> data,
    required Color color,
  }) {
    final icon = data['icon'] as String;
    final name = data['name'] as String;
    final consumed = data['consumed'] as int;
    final target = data['target'] as int;
    final progress = data['progress'] as double;
    
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

  Widget _buildExerciseBreakdown(Map<String, dynamic> exerciseData) {
    final exercises = exerciseData['exercises'] as List;
    final isEmpty = exerciseData['isEmpty'] as bool;
    final displayCount = exerciseData['displayCount'] as int;
    final extraCount = exerciseData['extraCount'] as int;
    final totalTime = exerciseData['totalTime'] as String;
    
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
        
        if (isEmpty) ...[
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
                  SummaryDataCalculator.getEmptyExerciseMessage(period),
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
          // Show first 3 exercises
          for (int i = 0; i < displayCount; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildExerciseRow(exercises[i]),
            ),
          
          // Show extra count if more than 3
          if (extraCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$extraCount more exercises',
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
        
        // Total exercise time
        if (!isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Text(
              'Total Exercise Time: $totalTime',
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
                exercise.name,
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${exercise.duration} min',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          '${exercise.caloriesBurned} cal',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red[600],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(Map<String, String> statsData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          SummaryDataCalculator.getStatsTitle(period),
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
                value: statsData['mealsLogged']!,
              ),
              
              const SizedBox(height: 12),
              
              _buildStatRow(
                icon: '💵',
                label: 'Avg per meal',
                value: statsData['avgPerMeal']!,
              ),
              
              const SizedBox(height: 12),
              
              _buildStatRow(
                icon: '🔥',
                label: 'Net Calories',
                value: statsData['netCalories']!,
              ),
              
              const SizedBox(height: 12),
              
              _buildStatRow(
                icon: '⏱️',
                label: 'Exercise Duration',
                value: statsData['exerciseDuration']!,
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
}