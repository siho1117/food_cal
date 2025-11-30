// lib/widgets/summary/summary_export_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/progress_data.dart';
import 'summary_controls_widget.dart';
import 'sections/report_header_section.dart';
import 'sections/body_metrics_section.dart';
import 'sections/nutrition_section.dart';
import 'sections/cost_budget_section.dart';
import 'sections/exercise_section.dart';
import 'sections/progress_achievements_section.dart';
import 'sections/meal_log_section.dart';
import 'sections/report_footer_section.dart';

/// Comprehensive fitness report widget optimized for PDF/image export
/// Uses professional white background with ReportColors for maximum readability
class SummaryExportWidget extends StatelessWidget {
  final SummaryPeriod period;

  const SummaryExportWidget({
    super.key,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeProvider, ExerciseProvider, ProgressData>(
      builder: (context, homeProvider, exerciseProvider, progressData, child) {
        return Container(
          // Transparent to show gradient background
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: AppWidgetTheme.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header (includes client info)
              ReportHeaderSection(
                period: period,
                profile: homeProvider.userProfile,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Body Measurements & Composition
              BodyMetricsSection(
                profile: homeProvider.userProfile,
                currentWeight: progressData.currentWeight,
                weightHistory: progressData.weightHistory,
                calorieGoal: homeProvider.calorieGoal,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Daily Nutrition Summary
              NutritionSection(
                totalCalories: homeProvider.totalCalories,
                calorieGoal: homeProvider.calorieGoal,
                consumedMacros: homeProvider.consumedMacros,
                targetMacros: homeProvider.targetMacros,
                foodEntriesCount: homeProvider.foodEntriesCount,
                exerciseBonusEnabled: homeProvider.exerciseBonusEnabled,
                exerciseBonusCalories: homeProvider.exerciseBonusCalories,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Food Budget
              CostBudgetSection(
                foodEntriesCount: homeProvider.foodEntriesCount,
                totalCost: homeProvider.totalFoodCost,
                budget: homeProvider.dailyFoodBudget,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Exercise & Activity Log
              ExerciseSection(
                exercises: exerciseProvider.exerciseEntries,
                totalBurned: exerciseProvider.totalCaloriesBurned,
                burnGoal: exerciseProvider.dailyBurnGoal,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Progress & Achievements
              ProgressAchievementsSection(
                currentWeight: progressData.currentWeight,
                goalWeight: progressData.targetWeight,
                startingWeight: progressData.startingWeight,
                isMetric: homeProvider.userProfile?.isMetric ?? true,
                totalCalories: homeProvider.totalCalories,
                calorieGoal: homeProvider.calorieGoal,
                totalBurned: exerciseProvider.totalCaloriesBurned,
                burnGoal: exerciseProvider.dailyBurnGoal,
                totalCost: homeProvider.totalFoodCost,
                budget: homeProvider.dailyFoodBudget,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Detailed Meal Log
              MealLogSection(
                foodEntries: homeProvider.foodEntries,
                totalCalories: homeProvider.totalCalories,
                consumedMacros: homeProvider.consumedMacros,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Footer
              const ReportFooterSection(),
            ],
          ),
        );
      },
    );
  }
}
