import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh'),
    Locale('zh', 'CN'),
    Locale('zh', 'TW')
  ];

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @quickAdd.
  ///
  /// In en, this message translates to:
  /// **'Quick Add'**
  String get quickAdd;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @caloriesToday.
  ///
  /// In en, this message translates to:
  /// **'Calories Intake'**
  String get caloriesToday;

  /// No description provided for @cal.
  ///
  /// In en, this message translates to:
  /// **'cal'**
  String get cal;

  /// No description provided for @remainingCalories.
  ///
  /// In en, this message translates to:
  /// **'Remaining calories'**
  String get remainingCalories;

  /// No description provided for @caloriesOver.
  ///
  /// In en, this message translates to:
  /// **'Calories over'**
  String get caloriesOver;

  /// No description provided for @exerciseCalorieBonusToggle.
  ///
  /// In en, this message translates to:
  /// **'Exercise calorie bonus toggle'**
  String get exerciseCalorieBonusToggle;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @doubleTapToToggleExerciseBonus.
  ///
  /// In en, this message translates to:
  /// **'Double tap to toggle exercise calorie bonus'**
  String get doubleTapToToggleExerciseBonus;

  /// No description provided for @goalReached.
  ///
  /// In en, this message translates to:
  /// **'Goal reached'**
  String get goalReached;

  /// No description provided for @overBudgetBy.
  ///
  /// In en, this message translates to:
  /// **'Over budget by'**
  String get overBudgetBy;

  /// No description provided for @protein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get protein;

  /// No description provided for @carbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get carbs;

  /// No description provided for @fat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get fat;

  /// No description provided for @proteinShort.
  ///
  /// In en, this message translates to:
  /// **'P'**
  String get proteinShort;

  /// No description provided for @carbsShort.
  ///
  /// In en, this message translates to:
  /// **'C'**
  String get carbsShort;

  /// No description provided for @fatShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get fatShort;

  /// No description provided for @dailySpend.
  ///
  /// In en, this message translates to:
  /// **'Daily Spend'**
  String get dailySpend;

  /// No description provided for @budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get budget;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get saving;

  /// No description provided for @enterValidAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid amount'**
  String get enterValidAmount;

  /// No description provided for @saveFailed.
  ///
  /// In en, this message translates to:
  /// **'Save failed'**
  String get saveFailed;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @foodLog.
  ///
  /// In en, this message translates to:
  /// **'Food Log'**
  String get foodLog;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @noFoodLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No food logged today'**
  String get noFoodLoggedToday;

  /// No description provided for @takePhotoOrAddManually.
  ///
  /// In en, this message translates to:
  /// **'Take a photo or add manually'**
  String get takePhotoOrAddManually;

  /// No description provided for @addFood.
  ///
  /// In en, this message translates to:
  /// **'Add Food'**
  String get addFood;

  /// No description provided for @deleteFoodItem.
  ///
  /// In en, this message translates to:
  /// **'Delete Food Item'**
  String get deleteFoodItem;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @unableToLoadData.
  ///
  /// In en, this message translates to:
  /// **'Unable to Load Data'**
  String get unableToLoadData;

  /// No description provided for @unexpectedError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get unexpectedError;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @oopsSomethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Oops! Something went wrong'**
  String get oopsSomethingWentWrong;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @current.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get current;

  /// No description provided for @goal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get goal;

  /// No description provided for @progress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get progress;

  /// No description provided for @lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get lost;

  /// No description provided for @gained.
  ///
  /// In en, this message translates to:
  /// **'Gained'**
  String get gained;

  /// No description provided for @toGo.
  ///
  /// In en, this message translates to:
  /// **'To Go'**
  String get toGo;

  /// No description provided for @weightHistory7Days.
  ///
  /// In en, this message translates to:
  /// **'Weight History (7 Days)'**
  String get weightHistory7Days;

  /// No description provided for @weightHistory28Days.
  ///
  /// In en, this message translates to:
  /// **'Weight History (28 Days)'**
  String get weightHistory28Days;

  /// No description provided for @weightHistory3Months.
  ///
  /// In en, this message translates to:
  /// **'Weight History (3 Months)'**
  String get weightHistory3Months;

  /// No description provided for @weightHistory6Months.
  ///
  /// In en, this message translates to:
  /// **'Weight History (6 Months)'**
  String get weightHistory6Months;

  /// No description provided for @weightHistory1Year.
  ///
  /// In en, this message translates to:
  /// **'Weight History (1 Year)'**
  String get weightHistory1Year;

  /// No description provided for @totalChange.
  ///
  /// In en, this message translates to:
  /// **'Total Change'**
  String get totalChange;

  /// No description provided for @average.
  ///
  /// In en, this message translates to:
  /// **'Average'**
  String get average;

  /// No description provided for @weeklyRate.
  ///
  /// In en, this message translates to:
  /// **'Weekly Rate'**
  String get weeklyRate;

  /// No description provided for @bodyFatEstimatePercent.
  ///
  /// In en, this message translates to:
  /// **'Body Fat Estimate %'**
  String get bodyFatEstimatePercent;

  /// No description provided for @healthMetrics.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics'**
  String get healthMetrics;

  /// No description provided for @healthMetricsInfo.
  ///
  /// In en, this message translates to:
  /// **'Health Metrics Info'**
  String get healthMetricsInfo;

  /// No description provided for @fitness.
  ///
  /// In en, this message translates to:
  /// **'Fitness'**
  String get fitness;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @bmiDescription.
  ///
  /// In en, this message translates to:
  /// **'Body Mass Index (BMI) is a measure of body fat based on height and weight. It helps classify weight categories:'**
  String get bmiDescription;

  /// No description provided for @bodyFatDescription.
  ///
  /// In en, this message translates to:
  /// **'Body fat percentage estimates your body composition. These estimates use standard formulas and may have a margin of error of ±5%.'**
  String get bodyFatDescription;

  /// No description provided for @bmrDescription.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic Rate (BMR) is the number of calories your body needs at rest to maintain vital functions.'**
  String get bmrDescription;

  /// No description provided for @warningText.
  ///
  /// In en, this message translates to:
  /// **'Note: These are estimates based on standard formulas and may vary from clinical measurements.'**
  String get warningText;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'calories'**
  String get calories;

  /// No description provided for @complete.
  ///
  /// In en, this message translates to:
  /// **'COMPLETE'**
  String get complete;

  /// No description provided for @noActivityYet.
  ///
  /// In en, this message translates to:
  /// **'No activity yet'**
  String get noActivityYet;

  /// No description provided for @logFirstExercise.
  ///
  /// In en, this message translates to:
  /// **'Log your first exercise'**
  String get logFirstExercise;

  /// No description provided for @logExercise.
  ///
  /// In en, this message translates to:
  /// **'Log Exercise'**
  String get logExercise;

  /// No description provided for @editExercise.
  ///
  /// In en, this message translates to:
  /// **'Edit Exercise'**
  String get editExercise;

  /// No description provided for @deleteExercise.
  ///
  /// In en, this message translates to:
  /// **'Delete Exercise'**
  String get deleteExercise;

  /// No description provided for @errorLoadingExercises.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Exercises'**
  String get errorLoadingExercises;

  /// No description provided for @unknownErrorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Unknown error occurred'**
  String get unknownErrorOccurred;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @preset.
  ///
  /// In en, this message translates to:
  /// **'Preset'**
  String get preset;

  /// No description provided for @custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get custom;

  /// No description provided for @chooseExercise.
  ///
  /// In en, this message translates to:
  /// **'Choose Exercise'**
  String get chooseExercise;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @walking.
  ///
  /// In en, this message translates to:
  /// **'Walking'**
  String get walking;

  /// No description provided for @cycling.
  ///
  /// In en, this message translates to:
  /// **'Cycling'**
  String get cycling;

  /// No description provided for @swimming.
  ///
  /// In en, this message translates to:
  /// **'Swimming'**
  String get swimming;

  /// No description provided for @weightTraining.
  ///
  /// In en, this message translates to:
  /// **'Weight Training'**
  String get weightTraining;

  /// No description provided for @yoga.
  ///
  /// In en, this message translates to:
  /// **'Yoga'**
  String get yoga;

  /// No description provided for @exerciseName.
  ///
  /// In en, this message translates to:
  /// **'Exercise Name'**
  String get exerciseName;

  /// No description provided for @exerciseNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Exercise name is required'**
  String get exerciseNameRequired;

  /// No description provided for @exerciseNamePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g., Jump Rope, Pilates'**
  String get exerciseNamePlaceholder;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'Minutes'**
  String get minutes;

  /// No description provided for @intensity.
  ///
  /// In en, this message translates to:
  /// **'Intensity'**
  String get intensity;

  /// No description provided for @light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// No description provided for @moderate.
  ///
  /// In en, this message translates to:
  /// **'Moderate'**
  String get moderate;

  /// No description provided for @intense.
  ///
  /// In en, this message translates to:
  /// **'Intense'**
  String get intense;

  /// No description provided for @caloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Calories Burned'**
  String get caloriesBurned;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @caloriesRequiredCustom.
  ///
  /// In en, this message translates to:
  /// **'Calories are required for custom exercises'**
  String get caloriesRequiredCustom;

  /// No description provided for @enterValidNumber.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid number'**
  String get enterValidNumber;

  /// No description provided for @enterCaloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Enter calories burned'**
  String get enterCaloriesBurned;

  /// No description provided for @estimatedCalories.
  ///
  /// In en, this message translates to:
  /// **'ESTIMATED CALORIES'**
  String get estimatedCalories;

  /// No description provided for @manualOverride.
  ///
  /// In en, this message translates to:
  /// **'MANUAL OVERRIDE'**
  String get manualOverride;

  /// No description provided for @auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get auto;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @tapToEdit.
  ///
  /// In en, this message translates to:
  /// **'Tap to edit'**
  String get tapToEdit;

  /// No description provided for @editName.
  ///
  /// In en, this message translates to:
  /// **'Edit Name'**
  String get editName;

  /// No description provided for @dateOfBirth.
  ///
  /// In en, this message translates to:
  /// **'Date of Birth'**
  String get dateOfBirth;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @currentWeight.
  ///
  /// In en, this message translates to:
  /// **'Current Weight'**
  String get currentWeight;

  /// No description provided for @startingWeight.
  ///
  /// In en, this message translates to:
  /// **'Starting Weight'**
  String get startingWeight;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @dateOfBirthUpdated.
  ///
  /// In en, this message translates to:
  /// **'Date of birth updated'**
  String get dateOfBirthUpdated;

  /// No description provided for @genderUpdated.
  ///
  /// In en, this message translates to:
  /// **'Gender updated'**
  String get genderUpdated;

  /// No description provided for @weightUpdated.
  ///
  /// In en, this message translates to:
  /// **'Weight updated'**
  String get weightUpdated;

  /// No description provided for @startingWeightUpdated.
  ///
  /// In en, this message translates to:
  /// **'Starting weight updated'**
  String get startingWeightUpdated;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @setYourWeightWhenStarted.
  ///
  /// In en, this message translates to:
  /// **'Set your weight when you started your journey'**
  String get setYourWeightWhenStarted;

  /// No description provided for @male.
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// No description provided for @female.
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// No description provided for @other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get other;

  /// No description provided for @preferNotToSay.
  ///
  /// In en, this message translates to:
  /// **'Prefer not to say'**
  String get preferNotToSay;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @g.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get g;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @metric.
  ///
  /// In en, this message translates to:
  /// **'Metric'**
  String get metric;

  /// No description provided for @imperial.
  ///
  /// In en, this message translates to:
  /// **'Imperial'**
  String get imperial;

  /// No description provided for @monthlyWeightGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Weight Goal'**
  String get monthlyWeightGoal;

  /// No description provided for @unitsChangedToMetric.
  ///
  /// In en, this message translates to:
  /// **'Units changed to Metric'**
  String get unitsChangedToMetric;

  /// No description provided for @unitsChangedToImperial.
  ///
  /// In en, this message translates to:
  /// **'Units changed to Imperial'**
  String get unitsChangedToImperial;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @choosePreferredLanguage.
  ///
  /// In en, this message translates to:
  /// **'Choose your preferred language'**
  String get choosePreferredLanguage;

  /// No description provided for @languageSavedApplied.
  ///
  /// In en, this message translates to:
  /// **'Language will be saved and applied immediately'**
  String get languageSavedApplied;

  /// No description provided for @selectTheme.
  ///
  /// In en, this message translates to:
  /// **'Select Theme'**
  String get selectTheme;

  /// No description provided for @chooseColorScheme.
  ///
  /// In en, this message translates to:
  /// **'Choose your color scheme'**
  String get chooseColorScheme;

  /// No description provided for @themeAppliedAllScreens.
  ///
  /// In en, this message translates to:
  /// **'Theme will be applied to all screens'**
  String get themeAppliedAllScreens;

  /// No description provided for @lose.
  ///
  /// In en, this message translates to:
  /// **'Lose'**
  String get lose;

  /// No description provided for @gain.
  ///
  /// In en, this message translates to:
  /// **'Gain'**
  String get gain;

  /// No description provided for @safe.
  ///
  /// In en, this message translates to:
  /// **'Safe'**
  String get safe;

  /// No description provided for @aggressive.
  ///
  /// In en, this message translates to:
  /// **'Aggressive'**
  String get aggressive;

  /// No description provided for @gradual.
  ///
  /// In en, this message translates to:
  /// **'Gradual'**
  String get gradual;

  /// No description provided for @athletic.
  ///
  /// In en, this message translates to:
  /// **'Athletic'**
  String get athletic;

  /// No description provided for @sendFeedback.
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get helpUsImprove;

  /// No description provided for @feedbackAppreciated.
  ///
  /// In en, this message translates to:
  /// **'We appreciate your feedback! Please let us know how we can improve the app.'**
  String get feedbackAppreciated;

  /// No description provided for @yourFeedbackHere.
  ///
  /// In en, this message translates to:
  /// **'Your feedback here...'**
  String get yourFeedbackHere;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;

  /// No description provided for @thankYouForFeedback.
  ///
  /// In en, this message translates to:
  /// **'Thank you for your feedback!'**
  String get thankYouForFeedback;

  /// No description provided for @enterFeedbackFirst.
  ///
  /// In en, this message translates to:
  /// **'Please enter your feedback first'**
  String get enterFeedbackFirst;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @pickFoodPhoto.
  ///
  /// In en, this message translates to:
  /// **'Pick food photo'**
  String get pickFoodPhoto;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @logManually.
  ///
  /// In en, this message translates to:
  /// **'Log manually'**
  String get logManually;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take Photo'**
  String get takePhoto;

  /// No description provided for @scanFoodWithCamera.
  ///
  /// In en, this message translates to:
  /// **'Scan food with camera'**
  String get scanFoodWithCamera;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @logActivity.
  ///
  /// In en, this message translates to:
  /// **'Log activity'**
  String get logActivity;

  /// No description provided for @weightUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Weight updated successfully'**
  String get weightUpdatedSuccessfully;

  /// No description provided for @targetWeightUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Target weight updated successfully'**
  String get targetWeightUpdatedSuccessfully;

  /// No description provided for @addFoodPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Food Photo'**
  String get addFoodPhoto;

  /// No description provided for @editFoodName.
  ///
  /// In en, this message translates to:
  /// **'Edit Food Name'**
  String get editFoodName;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from Gallery'**
  String get chooseFromGallery;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove Photo'**
  String get removePhoto;

  /// No description provided for @failedToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Failed to add photo'**
  String get failedToAddPhoto;

  /// No description provided for @failedToSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Failed to save changes'**
  String get failedToSaveChanges;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeFoodFromLog.
  ///
  /// In en, this message translates to:
  /// **'Remove \"{foodName}\" from your food log?'**
  String removeFoodFromLog(String foodName);

  /// No description provided for @failedToDeleteItem.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete item'**
  String get failedToDeleteItem;

  /// No description provided for @errorOccurredWhileDeleting.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while deleting'**
  String get errorOccurredWhileDeleting;

  /// No description provided for @failedToCaptureCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture food card'**
  String get failedToCaptureCard;

  /// No description provided for @failedToExportCard.
  ///
  /// In en, this message translates to:
  /// **'Failed to export food card'**
  String get failedToExportCard;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap + to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @analyzingYourFood.
  ///
  /// In en, this message translates to:
  /// **'Analyzing your food...'**
  String get analyzingYourFood;

  /// No description provided for @foodName.
  ///
  /// In en, this message translates to:
  /// **'Food name'**
  String get foodName;

  /// No description provided for @serving.
  ///
  /// In en, this message translates to:
  /// **'SERVING'**
  String get serving;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @addCostPerServing.
  ///
  /// In en, this message translates to:
  /// **'Food Cost'**
  String get addCostPerServing;

  /// No description provided for @editCalories.
  ///
  /// In en, this message translates to:
  /// **'Edit Calories'**
  String get editCalories;

  /// No description provided for @editServingSize.
  ///
  /// In en, this message translates to:
  /// **'Edit Serving Size'**
  String get editServingSize;

  /// No description provided for @editMacro.
  ///
  /// In en, this message translates to:
  /// **'Edit {macroName} (g)'**
  String editMacro(String macroName);

  /// No description provided for @cents.
  ///
  /// In en, this message translates to:
  /// **'cents'**
  String get cents;

  /// No description provided for @orEnterAmount.
  ///
  /// In en, this message translates to:
  /// **'Or enter amount over \${maxDollars}:'**
  String orEnterAmount(String maxDollars);

  /// No description provided for @egAmount.
  ///
  /// In en, this message translates to:
  /// **'e.g., 1234.56'**
  String get egAmount;

  /// No description provided for @durationIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Duration is required'**
  String get durationIsRequired;

  /// No description provided for @durationMustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Duration must be positive'**
  String get durationMustBePositive;

  /// No description provided for @durationCannotExceed24Hours.
  ///
  /// In en, this message translates to:
  /// **'Duration cannot exceed 24 hours'**
  String get durationCannotExceed24Hours;

  /// No description provided for @pleaseFillInAllRequiredFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill in all required fields'**
  String get pleaseFillInAllRequiredFields;

  /// No description provided for @errorSavingExercise.
  ///
  /// In en, this message translates to:
  /// **'Error saving exercise'**
  String get errorSavingExercise;

  /// No description provided for @editWeight.
  ///
  /// In en, this message translates to:
  /// **'Edit Weight'**
  String get editWeight;

  /// No description provided for @target.
  ///
  /// In en, this message translates to:
  /// **'Target'**
  String get target;

  /// No description provided for @targetWeight.
  ///
  /// In en, this message translates to:
  /// **'Target Weight'**
  String get targetWeight;

  /// No description provided for @failedToSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save'**
  String get failedToSave;

  /// No description provided for @totalExerciseDuration.
  ///
  /// In en, this message translates to:
  /// **'Total Exercise Duration'**
  String get totalExerciseDuration;

  /// No description provided for @totalCaloriesBurned.
  ///
  /// In en, this message translates to:
  /// **'Total Calories Burned'**
  String get totalCaloriesBurned;

  /// No description provided for @exceededGoal.
  ///
  /// In en, this message translates to:
  /// **'Exceeded Goal'**
  String get exceededGoal;

  /// No description provided for @remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining'**
  String get remaining;

  /// No description provided for @remainingToGoal.
  ///
  /// In en, this message translates to:
  /// **'Remaining to Goal'**
  String get remainingToGoal;

  /// No description provided for @exerciseBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Exercise Breakdown'**
  String get exerciseBreakdown;

  /// No description provided for @pace.
  ///
  /// In en, this message translates to:
  /// **'Pace'**
  String get pace;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @weeklyBurnGoal.
  ///
  /// In en, this message translates to:
  /// **'Weekly Burn Goal'**
  String get weeklyBurnGoal;

  /// No description provided for @monthlyBurnGoal.
  ///
  /// In en, this message translates to:
  /// **'Monthly Burn Goal'**
  String get monthlyBurnGoal;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @trackYourNutrition.
  ///
  /// In en, this message translates to:
  /// **'Track your nutrition'**
  String get trackYourNutrition;

  /// No description provided for @errorLoadingSummaryData.
  ///
  /// In en, this message translates to:
  /// **'Error Loading Summary Data'**
  String get errorLoadingSummaryData;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @failedToCaptureScreenshot.
  ///
  /// In en, this message translates to:
  /// **'Failed to capture screenshot'**
  String get failedToCaptureScreenshot;

  /// No description provided for @checkOutMyFitnessSummary.
  ///
  /// In en, this message translates to:
  /// **'Check out my fitness summary!'**
  String get checkOutMyFitnessSummary;

  /// No description provided for @summaryExportedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Summary exported! You can save or share from the dialog.'**
  String get summaryExportedSuccessfully;

  /// No description provided for @exportError.
  ///
  /// In en, this message translates to:
  /// **'Export error: '**
  String get exportError;

  /// No description provided for @customizeSummaryCards.
  ///
  /// In en, this message translates to:
  /// **'Customize Summary Cards'**
  String get customizeSummaryCards;

  /// No description provided for @chooseCardsToShow.
  ///
  /// In en, this message translates to:
  /// **'Choose which cards to show in your summary'**
  String get chooseCardsToShow;

  /// No description provided for @hiddenFromSummary.
  ///
  /// In en, this message translates to:
  /// **'Hidden from summary'**
  String get hiddenFromSummary;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @generated.
  ///
  /// In en, this message translates to:
  /// **'Generated: '**
  String get generated;

  /// No description provided for @generatedByOptimate.
  ///
  /// In en, this message translates to:
  /// **'Generated by OptiMate'**
  String get generatedByOptimate;

  /// No description provided for @dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get dailySummary;

  /// No description provided for @weeklySummary.
  ///
  /// In en, this message translates to:
  /// **'Weekly Summary'**
  String get weeklySummary;

  /// No description provided for @monthlySummary.
  ///
  /// In en, this message translates to:
  /// **'Monthly Summary'**
  String get monthlySummary;

  /// No description provided for @bodyMetricsMetabolism.
  ///
  /// In en, this message translates to:
  /// **'BODY METRICS & METABOLISM'**
  String get bodyMetricsMetabolism;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting'**
  String get starting;

  /// No description provided for @weightWithUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight ({unit})'**
  String weightWithUnit(String unit);

  /// No description provided for @bmi.
  ///
  /// In en, this message translates to:
  /// **'BMI'**
  String get bmi;

  /// No description provided for @bodyFatPercent.
  ///
  /// In en, this message translates to:
  /// **'Body Fat (%)'**
  String get bodyFatPercent;

  /// No description provided for @na.
  ///
  /// In en, this message translates to:
  /// **'N/A'**
  String get na;

  /// No description provided for @bmrBasalMetabolicRate.
  ///
  /// In en, this message translates to:
  /// **'BMR (Basal Metabolic Rate)'**
  String get bmrBasalMetabolicRate;

  /// No description provided for @calPerDay.
  ///
  /// In en, this message translates to:
  /// **'cal/day'**
  String get calPerDay;

  /// No description provided for @loss.
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get loss;

  /// No description provided for @perMonth.
  ///
  /// In en, this message translates to:
  /// **'/month'**
  String get perMonth;

  /// No description provided for @monthlyGoalLabel.
  ///
  /// In en, this message translates to:
  /// **'Monthly Goal ({type})'**
  String monthlyGoalLabel(Object type);

  /// No description provided for @bmiUnderweight.
  ///
  /// In en, this message translates to:
  /// **'Underweight'**
  String get bmiUnderweight;

  /// No description provided for @bmiNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get bmiNormal;

  /// No description provided for @bmiOverweight.
  ///
  /// In en, this message translates to:
  /// **'Overweight'**
  String get bmiOverweight;

  /// No description provided for @bmiObese.
  ///
  /// In en, this message translates to:
  /// **'Obese'**
  String get bmiObese;

  /// No description provided for @calorieGoal.
  ///
  /// In en, this message translates to:
  /// **'Calorie Goal'**
  String get calorieGoal;

  /// No description provided for @nutritionSummary.
  ///
  /// In en, this message translates to:
  /// **'NUTRITION SUMMARY'**
  String get nutritionSummary;

  /// No description provided for @totalCaloriesPeriod.
  ///
  /// In en, this message translates to:
  /// **'Total Calories ({period})'**
  String totalCaloriesPeriod(String period);

  /// No description provided for @averagePerDay.
  ///
  /// In en, this message translates to:
  /// **'Average per Day'**
  String get averagePerDay;

  /// No description provided for @overBy.
  ///
  /// In en, this message translates to:
  /// **'Over by'**
  String get overBy;

  /// No description provided for @totalCaloriesConsumed.
  ///
  /// In en, this message translates to:
  /// **'Total Calories Consumed'**
  String get totalCaloriesConsumed;

  /// No description provided for @baseGoal.
  ///
  /// In en, this message translates to:
  /// **'Base Goal'**
  String get baseGoal;

  /// No description provided for @exerciseBonusRollover.
  ///
  /// In en, this message translates to:
  /// **'Exercise Bonus (Rollover)'**
  String get exerciseBonusRollover;

  /// No description provided for @over.
  ///
  /// In en, this message translates to:
  /// **'Over'**
  String get over;

  /// No description provided for @macronutrientBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Macronutrient Breakdown:'**
  String get macronutrientBreakdown;

  /// No description provided for @carbohydrates.
  ///
  /// In en, this message translates to:
  /// **'Carbohydrates'**
  String get carbohydrates;

  /// No description provided for @mealsLogged.
  ///
  /// In en, this message translates to:
  /// **'Meals Logged'**
  String get mealsLogged;

  /// No description provided for @meals.
  ///
  /// In en, this message translates to:
  /// **'meals'**
  String get meals;

  /// No description provided for @gramsFormat.
  ///
  /// In en, this message translates to:
  /// **'{consumed}g / {target}g ({percentage}%)'**
  String gramsFormat(String consumed, String target, String percentage);

  /// No description provided for @foodBudget.
  ///
  /// In en, this message translates to:
  /// **'FOOD BUDGET'**
  String get foodBudget;

  /// No description provided for @totalFoodCost.
  ///
  /// In en, this message translates to:
  /// **'Total Food Cost'**
  String get totalFoodCost;

  /// No description provided for @budgetExceeded.
  ///
  /// In en, this message translates to:
  /// **'Budget Exceeded'**
  String get budgetExceeded;

  /// No description provided for @budgetRemaining.
  ///
  /// In en, this message translates to:
  /// **'Budget Remaining'**
  String get budgetRemaining;

  /// No description provided for @averagePerMeal.
  ///
  /// In en, this message translates to:
  /// **'Average per Meal'**
  String get averagePerMeal;

  /// No description provided for @budgetBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Budget Breakdown:'**
  String get budgetBreakdown;

  /// No description provided for @exerciseActivityLog.
  ///
  /// In en, this message translates to:
  /// **'EXERCISE & ACTIVITY LOG'**
  String get exerciseActivityLog;

  /// No description provided for @dailyBurnGoal.
  ///
  /// In en, this message translates to:
  /// **'Daily Burn Goal'**
  String get dailyBurnGoal;

  /// No description provided for @noExercisesLoggedWeek.
  ///
  /// In en, this message translates to:
  /// **'No exercises logged this week'**
  String get noExercisesLoggedWeek;

  /// No description provided for @noExercisesLoggedMonth.
  ///
  /// In en, this message translates to:
  /// **'No exercises logged this month'**
  String get noExercisesLoggedMonth;

  /// No description provided for @noExercisesLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No exercises logged today'**
  String get noExercisesLoggedToday;

  /// No description provided for @durationLabel.
  ///
  /// In en, this message translates to:
  /// **'Duration: '**
  String get durationLabel;

  /// No description provided for @min.
  ///
  /// In en, this message translates to:
  /// **'min'**
  String get min;

  /// No description provided for @paceLabel.
  ///
  /// In en, this message translates to:
  /// **'Pace: '**
  String get paceLabel;

  /// No description provided for @calPerMin.
  ///
  /// In en, this message translates to:
  /// **'cal/min'**
  String get calPerMin;

  /// No description provided for @notesLabel.
  ///
  /// In en, this message translates to:
  /// **'Notes: '**
  String get notesLabel;

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'m'**
  String get minutesShort;

  /// No description provided for @progressAchievements.
  ///
  /// In en, this message translates to:
  /// **'PROGRESS & ACHIEVEMENTS'**
  String get progressAchievements;

  /// No description provided for @weightProgress.
  ///
  /// In en, this message translates to:
  /// **'Weight Progress'**
  String get weightProgress;

  /// No description provided for @setGoalWeightInSettings.
  ///
  /// In en, this message translates to:
  /// **'Set your goal weight in settings'**
  String get setGoalWeightInSettings;

  /// No description provided for @weeklyGoals.
  ///
  /// In en, this message translates to:
  /// **'Weekly Goals'**
  String get weeklyGoals;

  /// No description provided for @monthlyGoals.
  ///
  /// In en, this message translates to:
  /// **'Monthly Goals'**
  String get monthlyGoals;

  /// No description provided for @todaysGoals.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Goals'**
  String get todaysGoals;

  /// No description provided for @mealLog.
  ///
  /// In en, this message translates to:
  /// **'MEAL LOG'**
  String get mealLog;

  /// No description provided for @noMealsLoggedWeek.
  ///
  /// In en, this message translates to:
  /// **'No meals logged this week'**
  String get noMealsLoggedWeek;

  /// No description provided for @noMealsLoggedMonth.
  ///
  /// In en, this message translates to:
  /// **'No meals logged this month'**
  String get noMealsLoggedMonth;

  /// No description provided for @noMealsLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No meals logged today'**
  String get noMealsLoggedToday;

  /// No description provided for @weeklyTotals.
  ///
  /// In en, this message translates to:
  /// **'Weekly Totals ({count} meals):'**
  String weeklyTotals(String count);

  /// No description provided for @monthlyTotals.
  ///
  /// In en, this message translates to:
  /// **'Monthly Totals ({count} meals):'**
  String monthlyTotals(String count);

  /// No description provided for @dailyTotals.
  ///
  /// In en, this message translates to:
  /// **'Daily Totals:'**
  String get dailyTotals;

  /// No description provided for @macrosShortFormat.
  ///
  /// In en, this message translates to:
  /// **'P: {protein}g  C: {carbs}g  F: {fat}g'**
  String macrosShortFormat(String protein, String carbs, String fat);

  /// No description provided for @macrosFullFormat.
  ///
  /// In en, this message translates to:
  /// **'Protein: {protein}g  |  Carbs: {carbs}g  |  Fat: {fat}g'**
  String macrosFullFormat(String protein, String carbs, String fat);

  /// No description provided for @reportGeneratedBy.
  ///
  /// In en, this message translates to:
  /// **'Report generated by OptiMate v1.0'**
  String get reportGeneratedBy;

  /// No description provided for @disclaimerText.
  ///
  /// In en, this message translates to:
  /// **'Disclaimer: This report contains estimates based on user-provided data. Consult healthcare professionals for medical advice. Body composition estimates use standard formulas and may vary from clinical measurements.'**
  String get disclaimerText;

  /// No description provided for @noWeightHistory.
  ///
  /// In en, this message translates to:
  /// **'No Weight History'**
  String get noWeightHistory;

  /// No description provided for @addWeightEntriesToSeeCharts.
  ///
  /// In en, this message translates to:
  /// **'Add weight entries to see beautiful charts'**
  String get addWeightEntriesToSeeCharts;

  /// No description provided for @tapToAdd.
  ///
  /// In en, this message translates to:
  /// **'(tap to add)'**
  String get tapToAdd;

  /// No description provided for @startingWeightUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Starting weight updated successfully'**
  String get startingWeightUpdatedSuccessfully;

  /// No description provided for @weightEntryAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Weight entry added successfully'**
  String get weightEntryAddedSuccessfully;

  /// No description provided for @heightUpdated.
  ///
  /// In en, this message translates to:
  /// **'Height updated'**
  String get heightUpdated;

  /// No description provided for @ft.
  ///
  /// In en, this message translates to:
  /// **'ft'**
  String get ft;

  /// No description provided for @inchesUnit.
  ///
  /// In en, this message translates to:
  /// **'in'**
  String get inchesUnit;

  /// No description provided for @bmr.
  ///
  /// In en, this message translates to:
  /// **'BMR'**
  String get bmr;

  /// No description provided for @bmrFullName.
  ///
  /// In en, this message translates to:
  /// **'Basal Metabolic Rate'**
  String get bmrFullName;

  /// No description provided for @bmiFullName.
  ///
  /// In en, this message translates to:
  /// **'BMI (Body Mass Index)'**
  String get bmiFullName;

  /// No description provided for @bodyFatPercentage.
  ///
  /// In en, this message translates to:
  /// **'Body Fat %'**
  String get bodyFatPercentage;

  /// No description provided for @caloriesYourBodyBurnsAtRest.
  ///
  /// In en, this message translates to:
  /// **'Calories your body burns at rest'**
  String get caloriesYourBodyBurnsAtRest;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @month.
  ///
  /// In en, this message translates to:
  /// **'month'**
  String get month;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'zh': {
  switch (locale.countryCode) {
    case 'CN': return AppLocalizationsZhCn();
case 'TW': return AppLocalizationsZhTw();
   }
  break;
   }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
