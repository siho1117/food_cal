// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_data.dart';
import '../providers/exercise_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/progress/combined_weight_widget.dart';
import '../widgets/progress/combined_bmi_bodyfat_widget.dart';
import '../widgets/progress/weight_history_graph_widget.dart';
import '../widgets/progress/energy_metrics_widget.dart';
import '../widgets/progress/daily_burn_widget.dart';
import '../widgets/progress/exercise_log_widget.dart';
import '../config/design_system/theme_background.dart';
import '../config/design_system/theme_design.dart';
import '../widgets/common/custom_app_bar.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: ThemeBackground.getGradient(themeProvider.selectedGradient),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(currentPage: 'progress'),
            body: Consumer2<ProgressData, ExerciseProvider>(
              builder: (context, progressData, exerciseProvider, child) {
                if (progressData.isLoading || exerciseProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
                
                if (progressData.errorMessage != null) {
                  return _buildErrorState(context, progressData.errorMessage!);
                }
                if (exerciseProvider.errorMessage != null) {
                  return _buildErrorState(context, exerciseProvider.errorMessage!);
                }
                
                return RefreshIndicator(
                  onRefresh: () async {
                    await Future.wait([
                      progressData.refreshData(),
                      exerciseProvider.refreshData(),
                    ]);
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Main Header
                        const Text(
                          'ACTIVITY & PROGRESS',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                        
                        const SizedBox(height: 30),
                        
                        // Progress Section
                        _buildSectionHeader('Progress Tracking'),
                        
                        const SizedBox(height: 16),
                        
                        // Weight Input Widget
                        CombinedWeightWidget(
                          currentWeight: progressData.currentWeight,
                          isMetric: progressData.isMetric,
                          onWeightEntered: progressData.addWeightEntry,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // BMI and Body Fat Widget
                        CombinedBMIBodyFatWidget(
                          bmiValue: progressData.bmiValue,
                          bmiClassification: progressData.bmiClassification,
                          bodyFatPercentage: progressData.bodyFatValue,
                          bodyFatClassification: progressData.bodyFatClassification,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Weight History Graph
                        WeightHistoryGraphWidget(
                          weightHistory: progressData.weightHistory,
                          isMetric: progressData.isMetric,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Energy Metrics
                        EnergyMetricsWidget(
                          userProfile: progressData.userProfile,
                          currentWeight: progressData.currentWeight,
                        ),
                        
                        const SizedBox(height: 40),
                        
                        // Exercise Section
                        _buildSectionHeader('Exercise Tracking'),
                        
                        const SizedBox(height: 16),
                        
                        // Daily Burn Widget
                        DailyBurnWidget(
                          userProfile: exerciseProvider.userProfile,
                          currentWeight: progressData.currentWeight,
                          totalCaloriesBurned: exerciseProvider.totalCaloriesBurned,
                          weeklyCaloriesBurned: 0,
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Exercise Log Widget
                        ExerciseLogWidget(
                          showHeader: true,
                          onExerciseAdded: () {
                            exerciseProvider.refreshData();
                          },
                        ),
                        
                        // Bottom padding for navigation bar
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    IconData icon;
    if (title.contains('Progress')) {
      icon = Icons.trending_up;
    } else if (title.contains('Exercise')) {
      icon = Icons.fitness_center_rounded;
    } else {
      icon = Icons.analytics_outlined;
    }
    
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.white,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(left: 12),
            height: 1,
            color: Colors.white.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              errorMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.read<ProgressData>().refreshData();
                context.read<ExerciseProvider>().refreshData();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.textDark,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}