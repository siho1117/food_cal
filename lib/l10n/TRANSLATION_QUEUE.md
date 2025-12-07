# OptiMate Translation Inventory

> **Last Updated**: 2025-12-07 (Summary Screen audit completed)
> **Exclude from translation**: "OptiMate" (app name)

---

## How This Works

### Purpose
Track all user-facing text in the app for internationalization (i18n). This file serves as the source of truth during development before finalizing translations.

### Workflow

**During Development (Current Phase):**
1. Audit one screen at a time
2. Document all user-facing strings in simple tables below
3. Review and update as UI evolves
4. Re-audit screens when text changes

**When Ready to Localize:**
1. Review this file - ensure all text is current
2. Generate `app_en.arb` from this inventory
3. Translate to target languages (zh_CN, zh_TW, ja, ko, de, fr, es, pt_BR, ar)
4. Replace hardcoded strings with `AppLocalizations.of(context)!.keyName`
5. Run `flutter gen-l10n`
6. Test each language

### Key Naming Convention
- **Simple, descriptive names** in camelCase
- **Screen titles**: `homeTitle`, `settingsTitle`
- **Buttons**: `save`, `cancel`, `addFood`
- **Labels**: `caloriesToday`, `protein`, `dailySpend`
- **Messages**: `errorLoadingData`, `settingsSavedSuccess`
- **Reuse keys** across screens when text is identical (e.g., "Save" button)
- **Add prefix** only if conflict exists (e.g., `saveAndContinue` vs `save`)

### Format
Each screen section contains a simple 2-column table:
- **Key**: Future ARB key name (camelCase)
- **Text**: Current English string in the app

Common elements (dialogs, errors, shared buttons) appear under the screen where they're first used.

---

## Translation Inventory by Screen

### Home Screen

#### Calorie Summary Widget
| Key | Text |
|-----|------|
| caloriesToday | Calories Intake |
| cal | cal |
| remainingCalories | Remaining calories |
| caloriesOver | Calories over |

#### Macronutrient Widget
| Key | Text |
|-----|------|
| protein | Protein |
| carbs | Carbs |
| fat | Fat |

#### Cost Summary Widget
| Key | Text |
|-----|------|
| dailySpend | Daily Spend |
| budget | Budget |
| cancel | Cancel |
| save | Save |

#### Cost Summary - Dialog
| Key | Text |
|-----|------|
| saving | Saving... |
| enterValidAmount | Enter a valid amount |
| saveFailed | Save failed |

#### Week Navigation Widget
| Key | Text |
|-----|------|
| today | Today |
| yesterday | Yesterday |

#### Food Log Widget
| Key | Text |
|-----|------|
| foodLog | Food Log |
| quickActions | Quick Actions |
| noFoodLoggedToday | No food logged today |
| takePhotoOrAddManually | Take a photo or add manually |
| addFood | Add Food |
| deleteFoodItem | Delete Food Item |
| delete | Delete |

#### Error State
| Key | Text |
|-----|------|
| unableToLoadData | Unable to Load Data |
| unexpectedError | An unexpected error occurred |
| tryAgain | Try Again |

---

### Settings Screen

#### Screen Title
| Key | Text |
|-----|------|
| settings | Settings |

#### Profile Section
| Key | Text |
|-----|------|
| tapToEdit | Tap to edit |
| editName | Edit Name |

#### Personal Details Section
| Key | Text |
|-----|------|
| dateOfBirth | Date of Birth |
| height | Height |
| currentWeight | Current Weight |
| startingWeight | Starting Weight |
| gender | Gender |
| notSet | Not set |
| dateOfBirthUpdated | Date of birth updated |
| genderUpdated | Gender updated |
| weightUpdated | Weight updated |
| startingWeightUpdated | Starting weight updated |
| error | Error |
| setYourWeightWhenStarted | Set your weight when you started your journey |

#### Gender Options
| Key | Text |
|-----|------|
| male | Male |
| female | Female |
| other | Other |
| preferNotToSay | Prefer not to say |

#### Unit Labels
| Key | Text |
|-----|------|
| kg | kg |
| lbs | lbs |

#### Preferences Section
| Key | Text |
|-----|------|
| language | Language |
| theme | Theme |
| units | Units |
| metric | Metric |
| imperial | Imperial |
| monthlyWeightGoal | Monthly Weight Goal |
| unitsChangedToMetric | Units changed to Metric |
| unitsChangedToImperial | Units changed to Imperial |

#### Language Selector Dialog
| Key | Text |
|-----|------|
| selectLanguage | Select Language |
| choosePreferredLanguage | Choose your preferred language |
| languageSavedApplied | Language will be saved and applied immediately |

#### Theme Selector Dialog
| Key | Text |
|-----|------|
| selectTheme | Select Theme |
| chooseColorScheme | Choose your color scheme |
| themeAppliedAllScreens | Theme will be applied to all screens |

#### Monthly Goal Dialog
| Key | Text |
|-----|------|
| lose | Lose |
| gain | Gain |
| safe | Safe |
| aggressive | Aggressive |
| gradual | Gradual |
| athletic | Athletic |

#### Feedback Section
| Key | Text |
|-----|------|
| sendFeedback | Send Feedback |
| helpUsImprove | Help us improve the app |
| feedbackAppreciated | We appreciate your feedback! Please let us know how we can improve the app. |
| yourFeedbackHere | Your feedback here... |
| send | Send |
| thankYouForFeedback | Thank you for your feedback! |
| enterFeedbackFirst | Please enter your feedback first |

---

### Food Entry & Quick Actions

#### Quick Actions Dialog
| Key | Text |
|-----|------|
| gallery | Gallery |
| pickFoodPhoto | Pick food photo |
| type | Type |
| logManually | Log manually |
| takePhoto | Take Photo |
| scanFoodWithCamera | Scan food with camera |
| weight | Weight |
| update | Update |
| exercise | Exercise |
| logActivity | Log activity |
| weightUpdatedSuccessfully | Weight updated successfully |
| targetWeightUpdatedSuccessfully | Target weight updated successfully |

#### Food Edit Dialog
| Key | Text |
|-----|------|
| addFoodPhoto | Add Food Photo |
| editFoodName | Edit Food Name |
| chooseFromGallery | Choose from Gallery |
| removePhoto | Remove Photo |
| failedToAddPhoto | Failed to add photo |
| failedToSaveChanges | Failed to save changes |
| remove | Remove |
| failedToDeleteItem | Failed to delete item |
| errorOccurredWhileDeleting | An error occurred while deleting |
| failedToCaptureCard | Failed to capture food card |
| failedToExportCard | Failed to export food card |

---

### Progress Screen

#### Exercise Entry Dialog
| Key | Text |
|-----|------|
| editExercise | Edit Exercise |
| logExercise | Log Exercise |
| preset | Preset |
| custom | Custom |
| chooseExercise | Choose Exercise |
| running | Running |
| walking | Walking |
| cycling | Cycling |
| swimming | Swimming |
| weightTraining | Weight Training |
| exerciseName | Exercise Name |
| exerciseNameRequired | Exercise name is required |
| duration | Duration |
| minutes | Minutes |
| intensity | Intensity |
| caloriesBurned | Calories Burned |
| required | Required |
| caloriesRequiredCustom | Calories are required for custom exercises |
| enterValidNumber | Please enter a valid number |
| enterCaloriesBurned | Enter calories burned |
| moderate | Moderate |

#### Weight Edit Dialog
| Key | Text |
|-----|------|
| editWeight | Edit Weight |
| current | Current |
| target | Target |
| targetWeight | Target Weight |
| failedToSave | Failed to save |

#### Exercise Summary
| Key | Text |
|-----|------|
| totalExerciseDuration | Total Exercise Duration |
| totalCaloriesBurned | Total Calories Burned |
| calories | calories |
| exceededGoal | Exceeded Goal |
| remainingToGoal | Remaining to Goal |
| exerciseBreakdown | Exercise Breakdown |
| pace | Pace |
| notes | Notes |
| weeklyBurnGoal | Weekly Burn Goal |
| monthlyBurnGoal | Monthly Burn Goal |

---

### Summary Screen

#### Controls
| Key | Text |
|-----|------|
| daily | Daily |
| weekly | Weekly |
| monthly | Monthly |
| trackYourNutrition | Track your nutrition |

#### Main Screen - Error States
| Key | Text |
|-----|------|
| errorLoadingSummaryData | Error Loading Summary Data |
| unknownErrorOccurred | Unknown error occurred |
| retry | Retry |
| dismiss | Dismiss |

#### Export Functionality
| Key | Text |
|-----|------|
| failedToCaptureScreenshot | Failed to capture screenshot |
| checkOutMyFitnessSummary | Check out my fitness summary! |
| summaryExportedSuccessfully | Summary exported! You can save or share from the dialog. |
| exportError | Export error: |

#### Card Settings Bottom Sheet
| Key | Text |
|-----|------|
| customizeSummaryCards | Customize Summary Cards |
| chooseCardsToShow | Choose which cards to show in your summary |
| hiddenFromSummary | Hidden from summary |

#### Report Header
| Key | Text |
|-----|------|
| report | REPORT |
| generated | Generated: |
| generatedByOptimate | Generated by OptiMate |

#### Body Metrics Section
| Key | Text |
|-----|------|
| bodyMetricsMetabolism | BODY METRICS & METABOLISM |
| metric | Metric |
| starting | Starting |
| goal | Goal |
| progress | Progress |
| weightWithUnit | Weight ({unit}) |
| bmi | BMI |
| bodyFatPercent | Body Fat (%) |
| na | N/A |
| bmrBasalMetabolicRate | BMR (Basal Metabolic Rate) |
| calPerDay | cal/day |
| monthlyGoalLossGain | Monthly Goal ({type}) |
| loss | Loss |
| perMonth | /month |
| calorieGoal | Calorie Goal |

#### Nutrition Section
| Key | Text |
|-----|------|
| nutritionSummary | NUTRITION SUMMARY |
| totalCaloriesPeriod | Total Calories ({period}) |
| averagePerDay | Average per Day |
| overBy | Over by |
| totalCaloriesConsumed | Total Calories Consumed |
| baseGoal | Base Goal |
| exerciseBonusRollover | Exercise Bonus (Rollover) |
| over | Over |
| macronutrientBreakdown | Macronutrient Breakdown: |
| carbohydrates | Carbohydrates |
| mealsLogged | Meals Logged |
| meals | meals |
| gramsFormat | {consumed}g / {target}g ({percentage}%) |

#### Cost Budget Section
| Key | Text |
|-----|------|
| foodBudget | FOOD BUDGET |
| totalFoodCost | Total Food Cost |
| budgetExceeded | Budget Exceeded |
| budgetRemaining | Budget Remaining |
| averagePerMeal | Average per Meal |
| budgetBreakdown | Budget Breakdown: |

#### Exercise Section
| Key | Text |
|-----|------|
| exerciseActivityLog | EXERCISE & ACTIVITY LOG |
| dailyBurnGoal | Daily Burn Goal |
| noExercisesLoggedWeek | No exercises logged this week |
| noExercisesLoggedMonth | No exercises logged this month |
| noExercisesLoggedToday | No exercises logged today |
| durationLabel | Duration: |
| min | min |
| paceLabel | Pace: |
| calPerMin | cal/min |
| notesLabel | Notes: |
| minutesShort | m |

#### Progress & Achievements Section
| Key | Text |
|-----|------|
| progressAchievements | PROGRESS & ACHIEVEMENTS |
| weightProgress | Weight Progress |
| remainingToGoal | Remaining to Goal |
| setGoalWeightInSettings | Set your goal weight in settings |
| weeklyGoals | Weekly Goals |
| monthlyGoals | Monthly Goals |
| todaysGoals | Today's Goals |
| budget | Budget |

#### Meal Log Section
| Key | Text |
|-----|------|
| mealLog | MEAL LOG |
| noMealsLoggedWeek | No meals logged this week |
| noMealsLoggedMonth | No meals logged this month |
| noMealsLoggedToday | No meals logged today |
| weeklyTotals | Weekly Totals ({count} meals): |
| monthlyTotals | Monthly Totals ({count} meals): |
| dailyTotals | Daily Totals: |
| macrosShortFormat | P: {protein}g  C: {carbs}g  F: {fat}g |
| macrosFullFormat | Protein: {protein}g  |  Carbs: {carbs}g  |  Fat: {fat}g |

#### Report Footer
| Key | Text |
|-----|------|
| reportGeneratedBy | Report generated by OptiMate v1.0 |
| disclaimerText | Disclaimer: This report contains estimates based on user-provided data. Consult healthcare professionals for medical advice. Body composition estimates use standard formulas and may vary from clinical measurements. |

---

### Splash Screen

| Key | Text |
|-----|------|
| _No translatable strings - only "OptiMate" (excluded) and "Track your nutrition" (shared)_ |

---

## Audit Notes

- **Screen order**: Auditing by user journey (Splash → Home → Food Entry → Settings)
- **Exclusions**: Debug messages, technical IDs, API endpoints, file paths
- **App name**: "OptiMate" should NOT be translated
