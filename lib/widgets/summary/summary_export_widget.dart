// lib/widgets/summary/summary_export_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/progress_data.dart';
import '../../utils/progress/health_metrics.dart';
import 'summary_controls_widget.dart';
import 'sections/report_header_section.dart';
import 'sections/body_metrics_section.dart';
import 'sections/metabolism_section.dart';
import 'sections/nutrition_section.dart';
import 'sections/exercise_section.dart';
import 'sections/energy_balance_section.dart';
import 'sections/meal_log_section.dart';
import 'sections/report_footer_section.dart';
import 'sections/placeholder_section.dart';

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
        // Calculate BMR baseline for energy balance section
        final profile = homeProvider.userProfile;
        final currentWeight = progressData.currentWeight;
        final bmr = HealthMetrics.calculateBMR(
          weight: currentWeight,
          height: profile?.height,
          age: profile?.age,
          gender: profile?.gender,
        );
        // Use BMR as baseline (no activity multiplier)
        final baseline = bmr;

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
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Metabolism & Energy Expenditure
              MetabolismSection(
                profile: homeProvider.userProfile,
                currentWeight: progressData.currentWeight,
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

              // Net Energy Balance
              EnergyBalanceSection(
                consumed: homeProvider.totalCalories,
                burned: exerciseProvider.totalCaloriesBurned,
                baseline: baseline,
                profile: homeProvider.userProfile,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Weekly Summary (Placeholder)
              const PlaceholderSection(
                icon: Icons.calendar_today,
                title: 'WEEKLY SUMMARY (Last 7 Days)',
                message: 'Weekly aggregation coming soon',
                features: [
                  'Average daily calories, protein, exercise',
                  'Weekly totals and goal achievement rates',
                  'Weight change and budget tracking',
                ],
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Progress & Achievements (Placeholder)
              const PlaceholderSection(
                icon: Icons.emoji_events,
                title: 'PROGRESS & ACHIEVEMENTS',
                message: 'Achievement tracking coming soon',
                features: [
                  'Current and longest tracking streak',
                  'Goal achievement milestones',
                  'Overall progress statistics',
                ],
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Detailed Meal Log
              MealLogSection(
                foodEntries: homeProvider.foodEntries,
                totalCalories: homeProvider.totalCalories,
                totalCost: homeProvider.totalFoodCost,
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
