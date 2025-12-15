// lib/widgets/summary/summary_export_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../providers/home_provider.dart';
import '../../providers/exercise_provider.dart';
import '../../providers/progress_data.dart';
import '../../data/models/summary_card_config.dart';
import '../../data/models/food_item.dart';
import '../../data/models/exercise_entry.dart';
import '../../utils/summary/summary_period_utils.dart';
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
///
/// CACHE INVALIDATION:
/// - Tracks cache versions from HomeProvider, ExerciseProvider, and ProgressData
/// - Automatically reloads when any provider's data changes (food, exercise, or weight)
/// - Uses PostFrameCallback to schedule reloads after widget rebuild
class SummaryExportWidget extends StatefulWidget {
  final SummaryPeriod period;
  final List<SummaryCardConfig> cardConfigs;

  const SummaryExportWidget({
    super.key,
    required this.period,
    required this.cardConfigs,
  });

  @override
  State<SummaryExportWidget> createState() => _SummaryExportWidgetState();
}

class _SummaryExportWidgetState extends State<SummaryExportWidget> {
  Map<String, num>? _aggregatedNutrition;
  Map<String, num>? _aggregatedExercise;
  List<FoodItem>? _aggregatedFoodEntries;
  List<ExerciseEntry>? _aggregatedExerciseEntries;
  bool _isLoading = false;

  // Track cache versions to detect when data changes
  int? _lastFoodCacheVersion;
  int? _lastExerciseCacheVersion;
  int? _lastProgressCacheVersion;

  @override
  void initState() {
    super.initState();
    _loadAggregatedData();
  }

  @override
  void didUpdateWidget(SummaryExportWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) {
      _loadAggregatedData();
    }
  }

  Future<void> _loadAggregatedData() async {
    if (_isLoading) return; // Prevent concurrent loads

    setState(() {
      _isLoading = true;
    });

    try {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      final exerciseProvider = Provider.of<ExerciseProvider>(context, listen: false);
      final progressData = Provider.of<ProgressData>(context, listen: false);

      final now = DateTime.now();
      // Normalize to end of day (23:59:59) for consistent date range calculations
      final endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

      // Calculate date range based on period using utility
      final startDate = SummaryPeriodUtils.getStartDateForPeriod(widget.period);

      // Load aggregated data for the period using cached methods
      final nutrition = await homeProvider.getCachedAggregatedNutrition(startDate, endDate);
      final exercise = await exerciseProvider.getCachedAggregatedExercise(startDate, endDate);

      // Load food entries for the period (for meal log)
      final foodEntries = await homeProvider.getCachedFoodEntriesForRange(startDate, endDate);

      // Load exercise entries for the period (for exercise log)
      final exerciseEntries = await exerciseProvider.getCachedExerciseEntriesForRange(startDate, endDate);

      if (mounted) {
        setState(() {
          _aggregatedNutrition = nutrition;
          _aggregatedExercise = exercise;
          _aggregatedFoodEntries = foodEntries;
          _aggregatedExerciseEntries = exerciseEntries;
          _isLoading = false;

          // Update version trackers AFTER data is loaded
          // This prevents skipping updates if Consumer rebuilds during load
          _lastFoodCacheVersion = homeProvider.cacheVersion;
          _lastExerciseCacheVersion = exerciseProvider.cacheVersion;
          _lastProgressCacheVersion = progressData.cacheVersion;
        });
      }
    } catch (e) {
      debugPrint('Error loading aggregated data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeProvider, ExerciseProvider, ProgressData>(
      builder: (context, homeProvider, exerciseProvider, progressData, child) {
        // Check if cache versions have changed (data was added/updated/deleted)
        final currentFoodVersion = homeProvider.cacheVersion;
        final currentExerciseVersion = exerciseProvider.cacheVersion;
        final currentProgressVersion = progressData.cacheVersion;

        // Only reload if cache version changed (not on every rebuild)
        if (_lastFoodCacheVersion != null &&
            (_lastFoodCacheVersion != currentFoodVersion ||
             _lastExerciseCacheVersion != currentExerciseVersion ||
             _lastProgressCacheVersion != currentProgressVersion) &&
            !_isLoading) {
          // Schedule reload after this frame
          // Don't update version here - let _loadAggregatedData do it after loading completes
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && !_isLoading) {
              _loadAggregatedData();
            }
          });
        }

        // Initialize versions on first build
        if (_lastFoodCacheVersion == null) {
          _lastFoodCacheVersion = currentFoodVersion;
          _lastExerciseCacheVersion = currentExerciseVersion;
          _lastProgressCacheVersion = currentProgressVersion;
        }

        // Show loading if aggregating weekly/monthly data
        if (_isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        // Check if data loaded successfully - if not, show error
        if (_aggregatedNutrition == null || _aggregatedExercise == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Text(
                'Failed to load summary data',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            ),
          );
        }

        // Show only visible cards
        final visibleCards = widget.cardConfigs
            .where((config) => config.isVisible)
            .toList()
          ..sort((a, b) => a.order.compareTo(b.order));

        return Container(
          // Transparent to show gradient background
          color: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: AppWidgetTheme.spaceXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report Header (always visible)
              ReportHeaderSection(
                period: widget.period,
                profile: homeProvider.userProfile,
              ),
              const SizedBox(height: AppWidgetTheme.spaceXL),

              // Dynamically rendered cards based on configuration
              ...visibleCards.map((config) {
                return Column(
                  children: [
                    _buildCard(
                      config,
                      homeProvider,
                      exerciseProvider,
                      progressData,
                    ),
                    const SizedBox(height: AppWidgetTheme.spaceXL),
                  ],
                );
              }),

              // Footer (always visible)
              const ReportFooterSection(),
            ],
          ),
        );
      },
    );
  }

  /// Build individual card based on type
  Widget _buildCard(
    SummaryCardConfig config,
    HomeProvider homeProvider,
    ExerciseProvider exerciseProvider,
    ProgressData progressData,
  ) {
    switch (config.type) {
      case SummaryCardType.bodyMetrics:
        return BodyMetricsSection(
          profile: homeProvider.userProfile,
          currentWeight: progressData.currentWeight,
          weightHistory: progressData.weightHistory,
          calorieGoal: homeProvider.calorieGoal,
        );

      case SummaryCardType.nutrition:
        // Use aggregated data (now loaded for all periods including daily)
        final totalCalories = (_aggregatedNutrition!['calories'] as num).toInt();
        final consumedMacros = {
          'protein': _aggregatedNutrition!['protein'] as num,
          'carbs': _aggregatedNutrition!['carbs'] as num,
          'fat': _aggregatedNutrition!['fat'] as num,
        };
        final foodEntriesCount = (_aggregatedNutrition!['mealCount'] as num).toInt();

        // Calculate average calories for weekly/monthly only
        final periodDays = SummaryPeriodUtils.getPeriodDays(widget.period);
        final avgCalories = widget.period != SummaryPeriod.daily
            ? SummaryPeriodUtils.safeDivideInt(totalCalories, periodDays)
            : null;

        return NutritionSection(
          totalCalories: totalCalories,
          calorieGoal: homeProvider.calorieGoal,
          consumedMacros: consumedMacros,
          targetMacros: homeProvider.targetMacros,
          foodEntriesCount: foodEntriesCount,
          exerciseBonusEnabled: homeProvider.exerciseBonusEnabled,
          exerciseBonusCalories: homeProvider.exerciseBonusCalories,
          period: widget.period,
          avgCaloriesPerDay: avgCalories,
        );

      case SummaryCardType.budget:
        // Use aggregated cost data
        final totalCost = (_aggregatedNutrition!['cost'] as num).toDouble();
        final mealCount = (_aggregatedNutrition!['mealCount'] as num).toInt();

        // Always use aggregated food entries for correct date range
        final foodEntries = _aggregatedFoodEntries ?? [];

        return CostBudgetSection(
          foodEntriesCount: mealCount,
          totalCost: totalCost,
          budget: homeProvider.dailyFoodBudget,
          foodEntries: foodEntries,
          period: widget.period,
        );

      case SummaryCardType.exercise:
        // Use aggregated exercise data
        final totalBurned = (_aggregatedExercise!['caloriesBurned'] as num).toInt();

        // Always use aggregated exercise entries for correct date range
        final exerciseEntries = _aggregatedExerciseEntries ?? [];

        return ExerciseSection(
          exercises: exerciseEntries,
          totalBurned: totalBurned,
          burnGoal: exerciseProvider.dailyBurnGoal,
          period: widget.period,
        );

      case SummaryCardType.progress:
        // Use aggregated data for progress
        final progressCalories = (_aggregatedNutrition!['calories'] as num).toInt();
        final progressBurned = (_aggregatedExercise!['caloriesBurned'] as num).toInt();
        final progressCost = (_aggregatedNutrition!['cost'] as num).toDouble();

        return ProgressAchievementsSection(
          currentWeight: progressData.currentWeight,
          goalWeight: progressData.targetWeight,
          startingWeight: progressData.startingWeight,
          isMetric: homeProvider.userProfile?.isMetric ?? true,
          totalCalories: progressCalories,
          calorieGoal: homeProvider.calorieGoal,
          totalBurned: progressBurned,
          burnGoal: exerciseProvider.dailyBurnGoal,
          totalCost: progressCost,
          budget: homeProvider.dailyFoodBudget,
          period: widget.period, // Pass period for weekly/monthly goal calculation
        );

      case SummaryCardType.mealLog:
        // Use aggregated data for meal log totals
        final mealLogCalories = (_aggregatedNutrition!['calories'] as num).toInt();
        final mealLogMacros = {
          'protein': _aggregatedNutrition!['protein'] as num,
          'carbs': _aggregatedNutrition!['carbs'] as num,
          'fat': _aggregatedNutrition!['fat'] as num,
        };

        // Always use aggregated food entries for correct date range
        final foodEntries = _aggregatedFoodEntries ?? [];

        return MealLogSection(
          foodEntries: foodEntries,
          totalCalories: mealLogCalories,
          consumedMacros: mealLogMacros,
          period: widget.period,
        );
    }
  }
}
