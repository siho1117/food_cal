// lib/widgets/summary/summary_export_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/summary_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/progress_data.dart';
import '../../utils/progress/health_metrics.dart';
import 'summary_controls_widget.dart';
import 'sections/report_header_section.dart';
import 'sections/client_info_section.dart';
import 'sections/body_metrics_section.dart';
import 'sections/metabolism_section.dart';
import 'sections/nutrition_section.dart';
import 'sections/exercise_section.dart';
import 'sections/energy_balance_section.dart';
import 'sections/meal_log_section.dart';
import 'sections/report_footer_section.dart';
import 'sections/placeholder_section.dart';

/// Comprehensive fitness report widget optimized for PDF/image export
/// Now modularized into reusable section widgets for better maintainability
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
        // Calculate TDEE for energy balance section
        final profile = homeProvider.userProfile;
        final currentWeight = progressData.currentWeight;
        final bmr = HealthMetrics.calculateBMR(
          weight: currentWeight,
          height: profile?.height,
          age: profile?.age,
          gender: profile?.gender,
        );
        final tdee = HealthMetrics.calculateTDEE(
          bmr: bmr,
          activityLevel: profile?.activityLevel,
        );

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(SummaryTheme.containerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header & Info
              ReportHeaderSection(period: period),
              SummaryTheme.sectionSpacingWidget,

              // Client Information
              ClientInfoSection(profile: homeProvider.userProfile),
              SummaryTheme.sectionSpacingWidget,

              // Body Measurements & Composition
              BodyMetricsSection(
                profile: homeProvider.userProfile,
                currentWeight: progressData.currentWeight,
                weightHistory: progressData.weightHistory,
              ),
              SummaryTheme.sectionSpacingWidget,

              // Metabolism & Energy Expenditure
              MetabolismSection(
                profile: homeProvider.userProfile,
                currentWeight: progressData.currentWeight,
                calorieGoal: homeProvider.calorieGoal,
              ),
              SummaryTheme.sectionSpacingWidget,

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
              SummaryTheme.sectionSpacingWidget,

              // Exercise & Activity Log
              ExerciseSection(
                exercises: exerciseProvider.exerciseEntries,
                totalBurned: exerciseProvider.totalCaloriesBurned,
                burnGoal: exerciseProvider.dailyBurnGoal,
              ),
              SummaryTheme.sectionSpacingWidget,

              // Net Energy Balance
              EnergyBalanceSection(
                consumed: homeProvider.totalCalories,
                burned: exerciseProvider.totalCaloriesBurned,
                tdee: tdee,
                profile: homeProvider.userProfile,
              ),
              SummaryTheme.sectionSpacingWidget,

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
              SummaryTheme.sectionSpacingWidget,

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
              SummaryTheme.sectionSpacingWidget,

              // Detailed Meal Log
              MealLogSection(
                foodEntries: homeProvider.foodEntries,
                totalCalories: homeProvider.totalCalories,
                totalCost: homeProvider.totalFoodCost,
                consumedMacros: homeProvider.consumedMacros,
              ),
              SummaryTheme.sectionSpacingWidget,

              // Footer
              const ReportFooterSection(),
            ],
          ),
        );
      },
    );
  }
}
