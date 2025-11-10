# Summary Page Refactoring Plan

## Overview
Breaking down `summary_export_widget.dart` (~1000 lines) into modular, maintainable section widgets following the design system.

## Completed
- ✅ Created `SummaryTheme` class with consistent styling
- ✅ Created `BaseSectionWidget` and helper widgets
- ✅ Created sections folder structure

## Section Breakdown

### 1. Report Header Section
**File:** `lib/widgets/summary/sections/report_header_section.dart`
**Lines:** ~80
**Combines:**
- `_buildHeader()` - Main title with gradient
- `_buildReportInfo()` - Period, date range, report ID

**Props:**
- `period: SummaryPeriod`

---

### 2. Client Info Section
**File:** `lib/widgets/summary/sections/client_info_section.dart`
**Lines:** ~60
**Replaces:** `_buildClientInfo()`

**Props:**
- `profile: UserProfile?`

**Data Shown:**
- Name, Age, Gender, Date of Birth

---

### 3. Body Metrics Section
**File:** `lib/widgets/summary/sections/body_metrics_section.dart`
**Lines:** ~150
**Combines:**
- `_buildBodyMeasurements()` - Height, weights, progress
- `_buildBodyComposition()` - BMI, body fat, lean/fat mass

**Props:**
- `profile: UserProfile?`
- `currentWeight: double?`
- `weightHistory: List<WeightData>`

**Calculations:**
- Uses `HealthMetrics` class for BMI, body fat, etc.

---

### 4. Metabolism Section
**File:** `lib/widgets/summary/sections/metabolism_section.dart`
**Lines:** ~100
**Replaces:** `_buildMetabolism()`

**Props:**
- `profile: UserProfile?`
- `currentWeight: double?`
- `calorieGoal: int`

**Data Shown:**
- BMR, TDEE, Activity level, Calorie goal, Monthly goal

---

### 5. Nutrition Section
**File:** `lib/widgets/summary/sections/nutrition_section.dart`
**Lines:** ~120
**Replaces:** `_buildDailyNutrition()` + `_buildMacroRow()`

**Props:**
- `totalCalories: int`
- `calorieGoal: int`
- `consumedMacros: Map<String, num>`
- `targetMacros: Map<String, num>`
- `foodEntriesCount: int`
- `totalCost: double`
- `budget: double`

**Features:**
- Macro progress bars (Protein/Carbs/Fat)
- Meal statistics
- Budget tracking

---

### 6. Exercise Section
**File:** `lib/widgets/summary/sections/exercise_section.dart`
**Lines:** ~130
**Replaces:** `_buildExerciseLog()`

**Props:**
- `exercises: List<ExerciseEntry>`
- `totalBurned: int`
- `burnGoal: int`

**Data Shown:**
- Exercise list with duration, intensity, calories, pace, notes
- Total time and calories
- Goal progress

---

### 7. Energy Balance Section
**File:** `lib/widgets/summary/sections/energy_balance_section.dart`
**Lines:** ~110
**Replaces:** `_buildNetEnergyBalance()`

**Props:**
- `consumed: int`
- `burned: int`
- `tdee: double?`
- `profile: UserProfile?`

**Calculations:**
- Net calories
- Deficit/surplus
- Expected weekly weight loss
- Comparison to goal

---

### 8. Weekly Summary Section
**File:** `lib/widgets/summary/sections/weekly_summary_section.dart`
**Lines:** ~80
**Replaces:** `_buildWeeklySummary()`

**Status:** Currently placeholder
**Future:** Will show aggregated weekly data

---

### 9. Progress & Achievements Section
**File:** `lib/widgets/summary/sections/achievements_section.dart`
**Lines:** ~80
**Replaces:** `_buildProgressAchievements()`

**Status:** Currently placeholder
**Future:** Will show streaks and milestones

---

### 10. Meal Log Section
**File:** `lib/widgets/summary/sections/meal_log_section.dart`
**Lines:** ~120
**Replaces:** `_buildDetailedMealLog()`

**Props:**
- `foodEntries: List<FoodItem>`
- `totalCalories: int`
- `totalCost: double`
- `consumedMacros: Map<String, num>`

**Features:**
- Simplified meal list (no meal types/times)
- Nutrition breakdown per meal
- Daily totals

---

### 11. Report Footer Section
**File:** `lib/widgets/summary/sections/report_footer_section.dart`
**Lines:** ~40
**Replaces:** `_buildFooter()`

**Data Shown:**
- App name and version
- Disclaimer text

---

## Refactored `summary_export_widget.dart`

**New Structure (~150 lines):**

```dart
class SummaryExportWidget extends StatelessWidget {
  final SummaryPeriod period;

  @override
  Widget build(BuildContext context) {
    return Consumer3<HomeProvider, ExerciseProvider, ProgressData>(
      builder: (context, home, exercise, progress, child) {
        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(SummaryTheme.containerPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReportHeaderSection(period: period),
              SummaryTheme.sectionSpacingWidget,

              ClientInfoSection(profile: home.userProfile),
              SummaryTheme.sectionSpacingWidget,

              BodyMetricsSection(
                profile: home.userProfile,
                currentWeight: progress.currentWeight,
                weightHistory: progress.weightHistory,
              ),
              SummaryTheme.sectionSpacingWidget,

              MetabolismSection(
                profile: home.userProfile,
                currentWeight: progress.currentWeight,
                calorieGoal: home.calorieGoal,
              ),
              SummaryTheme.sectionSpacingWidget,

              NutritionSection(
                totalCalories: home.totalCalories,
                calorieGoal: home.calorieGoal,
                consumedMacros: home.consumedMacros,
                targetMacros: home.targetMacros,
                foodEntriesCount: home.foodEntriesCount,
                totalCost: home.totalFoodCost,
                budget: home.dailyFoodBudget,
              ),
              SummaryTheme.sectionSpacingWidget,

              ExerciseSection(
                exercises: exercise.exerciseEntries,
                totalBurned: exercise.totalCaloriesBurned,
                burnGoal: exercise.dailyBurnGoal,
              ),
              SummaryTheme.sectionSpacingWidget,

              EnergyBalanceSection(
                consumed: home.totalCalories,
                burned: exercise.totalCaloriesBurned,
                tdee: HealthMetrics.calculateTDEE(...),
                profile: home.userProfile,
              ),
              SummaryTheme.sectionSpacingWidget,

              WeeklySummarySection(),
              SummaryTheme.sectionSpacingWidget,

              AchievementsSection(),
              SummaryTheme.sectionSpacingWidget,

              MealLogSection(
                foodEntries: home.foodEntries,
                totalCalories: home.totalCalories,
                totalCost: home.totalFoodCost,
                consumedMacros: home.consumedMacros,
              ),
              SummaryTheme.sectionSpacingWidget,

              const ReportFooterSection(),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Implementation Steps

### Phase 1: Create Section Widgets (Use example below as template)
1. Create each section widget in `lib/widgets/summary/sections/`
2. Use `BaseSectionWidget` for consistent structure
3. Use `InfoRow` and `ProgressRow` helpers
4. Apply `SummaryTheme` styling throughout

### Phase 2: Refactor Main Widget
1. Update `summary_export_widget.dart` to use sections
2. Remove all `_build*()` methods
3. Remove helper methods (moved to base widget)

### Phase 3: Clean Up
1. Archive `summary_content_widget.dart`
2. Update imports
3. Test all sections

### Phase 4: Test
1. Run app and navigate to Summary screen
2. Verify all data displays correctly
3. Test export functionality
4. Check design consistency

---

## Design System Usage

### Colors
```dart
// Instead of:
color: Color(0xFF0D4033)
color: Colors.red[600]!

// Use:
color: SummaryTheme.primary
color: SummaryTheme.proteinColor
color: SummaryTheme.success
```

### Typography
```dart
// Instead of:
TextStyle(fontSize: 12, fontWeight: FontWeight.bold)

// Use:
SummaryTheme.sectionHeader
SummaryTheme.infoLabel
SummaryTheme.infoValue
```

### Decorations
```dart
// Instead of:
BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(8),
  border: Border.all(color: Colors.grey[300]!),
)

// Use:
SummaryTheme.sectionDecoration
SummaryTheme.subsectionDecoration
```

### Spacing
```dart
// Instead of:
const SizedBox(height: 20)
const SizedBox(height: 12)

// Use:
SummaryTheme.sectionSpacingWidget
SummaryTheme.itemSpacingWidget
```

---

## Example: Complete Section Implementation

See `nutrition_section.dart` below for a complete example following all patterns.

---

## Benefits

✅ **Maintainability:** Each section < 150 lines
✅ **Testability:** Sections can be tested independently
✅ **Reusability:** Sections can be used in other reports
✅ **Consistency:** Enforced through design system
✅ **Readability:** Clear separation of concerns
✅ **Flexibility:** Easy to add/remove/reorder sections

---

## Next Steps

1. Create sections one at a time using the template
2. Start with simpler sections (Footer, Header) before complex ones
3. Test each section as you create it
4. Once all sections created, refactor main widget
5. Remove old code and test thoroughly
