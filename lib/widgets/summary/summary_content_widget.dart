// lib/widgets/summary/summary_content_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';
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
              _buildHeader(),
              const SizedBox(height: 24),
              _buildKeyMetrics(keyMetrics),
              const SizedBox(height: 28),
              _buildProgressSection(progressData),
              const SizedBox(height: 28),
              _buildNutritionBreakdown(nutritionData),
              const SizedBox(height: 28),
              _buildExerciseBreakdown(exerciseData),
              const SizedBox(height: 28),
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
          style: AppTypography.displayLarge.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppLegacyColors.primaryBlue,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          SummaryDataCalculator.getPeriodSubtitle(period),
          style: AppTypography.bodyMedium.copyWith(
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
            AppLegacyColors.primaryBlue.withValues(alpha: 0.05),
            AppLegacyColors.primaryBlue.withValues(alpha: 0.02),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Metrics',
            style: AppTypography.displaySmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem('Calories', metrics['calories']!, Colors.blue[600]!),
              _buildMetricItem('Protein', metrics['protein']!, Colors.red[600]!),
              _buildMetricItem('Exercise', metrics['exercise']!, Colors.green[600]!),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(Map<String, dynamic> progressData) {
    final status = progressData['status'] as String;
    final message = progressData['message'] as String;
    
    Color statusColor;
    IconData statusIcon;
    
    if (status == 'on_track') {
      statusColor = Colors.green[600]!;
      statusIcon = Icons.check_circle;
    } else if (status == 'over') {
      statusColor = Colors.orange[600]!;
      statusIcon = Icons.warning;
    } else {
      statusColor = Colors.red[600]!;
      statusIcon = Icons.cancel;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress Overview',
          style: AppTypography.displaySmall.copyWith(
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
            color: statusColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: statusColor.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 14,
                    color: Colors.grey[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionBreakdown(Map<String, dynamic> nutritionData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nutrition Breakdown',
          style: AppTypography.displaySmall.copyWith(
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
              _buildNutritionRow('Protein', nutritionData['protein'], Colors.red[600]!),
              const Divider(height: 24),
              _buildNutritionRow('Carbs', nutritionData['carbs'], Colors.orange[600]!),
              const Divider(height: 24),
              _buildNutritionRow('Fat', nutritionData['fat'], Colors.blue[600]!),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNutritionRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        Text(
          value,
          style: AppTypography.labelLarge.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseBreakdown(Map<String, dynamic> exerciseData) {
    final exercises = exerciseData['exercises'] as List<dynamic>;
    final totalTime = exerciseData['totalTime'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise Breakdown',
          style: AppTypography.displaySmall.copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        if (exercises.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No exercise data',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ),
          )
        else
          ...exercises.map((exercise) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildExerciseRow(exercise),
              )),
        if (exercises.isNotEmpty) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Total Exercise Time: $totalTime',
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 14,
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
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
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${exercise.duration} min',
                style: AppTypography.bodyMedium.copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Text(
          '${exercise.caloriesBurned} cal',
          style: AppTypography.labelLarge.copyWith(
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
          style: AppTypography.displaySmall.copyWith(
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
            children: statsData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      entry.key,
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      entry.value,
                      style: AppTypography.labelLarge.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppLegacyColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}