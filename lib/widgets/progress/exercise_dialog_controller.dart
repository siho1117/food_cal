// lib/widgets/progress/exercise_dialog_controller.dart
import 'package:flutter/material.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import '../../utils/progress/calorie_estimator.dart';
import '../../l10n/generated/app_localizations.dart';

/// Controller for exercise entry dialog
///
/// Manages state, validation, and calorie estimation for logging exercises.
/// Uses MET-based calculation for accurate calorie estimates.
class ExerciseDialogController extends ChangeNotifier {
  final ExerciseProvider exerciseProvider;
  final ExerciseEntry? existingExercise;
  final BuildContext context;

  // Input controllers
  final TextEditingController durationController = TextEditingController();

  // State
  String? selectedExercise;
  String selectedIntensity = 'Moderate';
  int estimatedCalories = 0;
  bool isLoading = false;

  // Constants
  static const List<String> exercises = [
    'Running',
    'Walking',
    'Cycling',
    'Swimming',
    'Weight Training',
    'Yoga',
  ];

  static const List<String> intensityLevels = [
    'Light',
    'Moderate',
    'Intense',
  ];

  static const List<int> durationPresets = [15, 30, 45, 60];

  ExerciseDialogController({
    required this.exerciseProvider,
    required this.context,
    this.existingExercise,
    String? preselectedExercise,
  }) {
    _initialize(preselectedExercise);
  }

  @override
  void dispose() {
    durationController.dispose();
    super.dispose();
  }

  /// Initialize fields from existing exercise or preselection
  void _initialize(String? preselectedExercise) {
    if (existingExercise != null) {
      selectedExercise = existingExercise!.name;
      selectedIntensity = existingExercise!.intensity;
      durationController.text = existingExercise!.duration.toString();
      estimatedCalories = existingExercise!.caloriesBurned;
    } else if (preselectedExercise != null) {
      selectedExercise = preselectedExercise;
      _recalculate();
    }
  }

  /// Recalculate calories using MET-based formula
  void _recalculate() {
    final duration = int.tryParse(durationController.text) ?? 0;

    if (duration <= 0 || selectedExercise == null) {
      estimatedCalories = 0;
      notifyListeners();
      return;
    }

    estimatedCalories = CalorieEstimator.estimate(
      exerciseName: selectedExercise!,
      intensity: selectedIntensity,
      minutes: duration,
      userWeightKg: exerciseProvider.currentWeight,
    );

    notifyListeners();
  }

  /// Update selected exercise
  void selectExercise(String exercise) {
    selectedExercise = exercise;
    _recalculate();
  }

  /// Update intensity level
  void selectIntensity(String intensity) {
    selectedIntensity = intensity;
    _recalculate();
  }

  /// Update duration from preset
  void selectDurationPreset(int minutes) {
    durationController.text = minutes.toString();
    _recalculate();
  }

  /// Update duration from text input
  void onDurationChanged(String value) {
    _recalculate();
  }

  /// Validate duration input
  String? validateDuration(String? value) {
    final l10n = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return l10n.durationIsRequired;
    }

    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) {
      return l10n.durationMustBePositive;
    }

    if (duration > 1440) {
      return l10n.durationCannotExceed24Hours;
    }

    return null;
  }

  /// Check if form can be saved
  bool get canSave =>
      selectedExercise != null &&
      selectedExercise!.isNotEmpty &&
      durationController.text.isNotEmpty;

  /// Save exercise to provider
  Future<String> saveExercise() async {
    final l10n = AppLocalizations.of(context)!;

    if (!canSave) {
      return l10n.pleaseFillInAllRequiredFields;
    }

    final error = validateDuration(durationController.text);
    if (error != null) return error;

    isLoading = true;
    notifyListeners();

    try {
      final duration = int.parse(durationController.text);

      if (existingExercise != null) {
        // Update existing
        await exerciseProvider.updateExercise(
          existingExercise!.copyWith(
            name: selectedExercise!,
            duration: duration,
            caloriesBurned: estimatedCalories,
            intensity: selectedIntensity,
          ),
        );
      } else {
        // Create new
        await exerciseProvider.logExercise(
          ExerciseEntry.create(
            name: selectedExercise!,
            type: _inferType(selectedExercise!),
            duration: duration,
            caloriesBurned: estimatedCalories,
            intensity: selectedIntensity,
          ),
        );
      }

      isLoading = false;
      notifyListeners();
      return 'success';
    } catch (e) {
      isLoading = false;
      notifyListeners();
      return l10n.errorSavingExercise;
    }
  }

  /// Infer exercise type from name
  String _inferType(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('run') ||
        lower.contains('walk') ||
        lower.contains('cycl') ||
        lower.contains('swim')) return 'Cardio';
    if (lower.contains('weight') || lower.contains('strength')) return 'Strength';
    if (lower.contains('yoga') || lower.contains('stretch')) return 'Flexibility';
    return 'Other';
  }

  // Selection state checkers
  bool isExerciseSelected(String exercise) => selectedExercise == exercise;
  bool isIntensitySelected(String intensity) => selectedIntensity == intensity;
  bool isDurationPresetSelected(int preset) =>
      durationController.text == preset.toString();

  // Getters for constants
  List<String> getExercises() => exercises;
  List<String> getIntensityLevels() => intensityLevels;
  List<int> getDurationPresets() => durationPresets;

  // Helper to get localized exercise name
  String getLocalizedExerciseName(String exerciseName) {
    final l10n = AppLocalizations.of(context)!;
    switch (exerciseName) {
      case 'Running':
        return l10n.running;
      case 'Walking':
        return l10n.walking;
      case 'Cycling':
        return l10n.cycling;
      case 'Swimming':
        return l10n.swimming;
      case 'Weight Training':
        return l10n.weightTraining;
      case 'Yoga':
        return l10n.yoga;
      default:
        return exerciseName;
    }
  }

  // Helper to get localized intensity level
  String getLocalizedIntensity(String intensity) {
    final l10n = AppLocalizations.of(context)!;
    switch (intensity) {
      case 'Light':
        return l10n.light;
      case 'Moderate':
        return l10n.moderate;
      case 'Intense':
        return l10n.intense;
      default:
        return intensity;
    }
  }
}