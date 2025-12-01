// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_data.dart';
import '../providers/exercise_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/progress/combined_weight_widget.dart';
import '../widgets/progress/weight_history_graph_widget.dart';
import '../widgets/progress/health_metrics_widget.dart';
import '../widgets/progress/exercise_log_widget.dart';
import '../widgets/common/week_navigation_widget.dart';
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
  void initState() {
    super.initState();
    // Reset to today when screen is first created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final exerciseProvider = context.read<ExerciseProvider>();
      if (!exerciseProvider.isToday) {
        exerciseProvider.changeDate(DateTime.now());
      }
    });
  }

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
                        // ✅ Week Navigation Widget - FIRST (at the top, no date display)
                        WeekNavigationWidget(
                          selectedDate: exerciseProvider.selectedDate,
                          onDateChanged: (date) {
                            exerciseProvider.changeDate(date);
                          },
                          daysToShow: 8,
                          padding: EdgeInsets.zero, // Remove padding to prevent overflow
                          showDateDisplay: false, // ✅ Hide date display on progress screen
                        ),
                        
                        const SizedBox(height: 20),

                        // Weight Widget (full width) - SECOND
                        CombinedWeightWidget(
                          currentWeight: progressData.currentWeight,
                          isMetric: progressData.isMetric,
                          onWeightEntered: progressData.addWeightEntry,
                        ),

                        const SizedBox(height: 20),

                        // Exercise Log Widget - THIRD
                        ExerciseLogWidget(
                          showHeader: true,
                          onExerciseAdded: () {
                            exerciseProvider.refreshData();
                          },
                        ),

                        const SizedBox(height: 20),

                        // Weight History Graph
                        WeightHistoryGraphWidget(
                          weightHistory: progressData.weightHistory,
                          isMetric: progressData.isMetric,
                        ),

                        const SizedBox(height: 20),

                        // Health Metrics (BMI, Body Fat, and BMR baseline)
                        HealthMetricsWidget(
                          currentWeight: progressData.currentWeight,
                          targetWeight: progressData.targetWeight,
                          userProfile: progressData.userProfile,
                          bmi: progressData.bmiValue,
                          bmiCategory: progressData.bmiClassification,
                          bodyFat: progressData.bodyFatValue,
                          bodyFatCategory: progressData.bodyFatClassification,
                          bmr: progressData.bmrValue,
                          baseline: progressData.baselineValue,
                          targetBMI: progressData.targetBMI,
                          bmiProgress: progressData.bmiProgress,
                          targetBodyFat: progressData.targetBodyFat,
                          bodyFatProgress: progressData.bodyFatProgress,
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
                color: Colors.red.withOpacity(0.1),
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
                color: Colors.white.withOpacity(0.8),
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