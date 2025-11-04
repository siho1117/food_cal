// lib/widgets/progress/exercise_dialog_controller.dart
import 'package:flutter/material.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import '../../utils/calorie_estimator.dart';

/// Controller for exercise entry dialog
/// 
/// Manages state, validation, and calorie estimation for logging exercises.
/// Uses MET-based calculation for accurate calorie estimates.
class ExerciseDialogController extends ChangeNotifier {
  final ExerciseProvider exerciseProvider;
  final ExerciseEntry? existingExercise;

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
    if (value == null || value.isEmpty) {
      return 'Duration is required';
    }

    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) {
      return 'Duration must be positive';
    }

    if (duration > 1440) {
      return 'Duration cannot exceed 24 hours';
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
    if (!canSave) {
      return 'Please fill in all required fields';
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
      return 'Error saving exercise: $e';
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
}