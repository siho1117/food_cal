// lib/widgets/exercise/exercise_dialog_controller.dart
import 'package:flutter/material.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';

class ExerciseDialogController extends ChangeNotifier {
  final ExerciseProvider exerciseProvider;
  final ExerciseEntry? existingExercise;
  final String? preselectedExercise;

  // Controllers
  final TextEditingController durationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  // State variables
  String? selectedExercise;
  String selectedIntensity = 'Moderate';
  int estimatedCalories = 0;
  bool isLoading = false;

  // Simple exercise list
  static const List<Map<String, String>> exercises = [
    {'name': 'Running', 'icon': '🏃‍♂️'},
    {'name': 'Walking', 'icon': '🚶'},
    {'name': 'Cycling', 'icon': '🚴'},
    {'name': 'Swimming', 'icon': '🏊'},
    {'name': 'Weight Training', 'icon': '🏋️'},
    {'name': 'Yoga', 'icon': '🧘'},
  ];

  static const List<String> intensityLevels = ['Light', 'Moderate', 'Intense'];
  static const List<int> durationPresets = [15, 30, 45, 60];

  ExerciseDialogController({
    required this.exerciseProvider,
    this.existingExercise,
    this.preselectedExercise,
  }) {
    _initializeFields();
  }

  @override
  void dispose() {
    durationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void _initializeFields() {
    if (existingExercise != null) {
      final exercise = existingExercise!;
      selectedExercise = exercise.name;
      selectedIntensity = exercise.intensity;
      durationController.text = exercise.duration.toString();
      notesController.text = exercise.notes ?? '';
      estimatedCalories = exercise.caloriesBurned;
    } else if (preselectedExercise != null) {
      selectedExercise = preselectedExercise;
      _calculateCalories();
    }
  }

  // Simple calorie calculation
  void _calculateCalories() {
    final duration = int.tryParse(durationController.text) ?? 0;
    if (duration <= 0 || selectedExercise == null) {
      estimatedCalories = 0;
      notifyListeners();
      return;
    }

    int baseCalories = 5; // Base calories per minute
    if (selectedIntensity == 'Light') baseCalories = 4;
    if (selectedIntensity == 'Moderate') baseCalories = 6;
    if (selectedIntensity == 'Intense') baseCalories = 8;

    estimatedCalories = baseCalories * duration;
    notifyListeners();
  }

  // Event handlers
  void selectExercise(String exercise) {
    selectedExercise = exercise;
    notifyListeners();
    _calculateCalories();
  }

  void selectIntensity(String intensity) {
    selectedIntensity = intensity;
    notifyListeners();
    _calculateCalories();
  }

  void selectDurationPreset(int minutes) {
    durationController.text = minutes.toString();
    _calculateCalories();
  }

  void onDurationChanged(String value) {
    _calculateCalories();
  }

  // Validation
  String? validateDuration(String? value) {
    if (value == null || value.isEmpty) return 'Duration is required';
    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) return 'Duration must be positive';
    if (duration > 1440) return 'Duration cannot exceed 24 hours';
    return null;
  }

  bool get canSave {
    return selectedExercise != null && 
           selectedExercise!.isNotEmpty && 
           durationController.text.isNotEmpty;
  }

  // Save exercise
  Future<String> saveExercise() async {
    if (!canSave) {
      return 'Please fill in all required fields';
    }

    if (validateDuration(durationController.text) != null) {
      return validateDuration(durationController.text)!;
    }

    isLoading = true;
    notifyListeners();

    try {
      final duration = int.parse(durationController.text);
      final notes = notesController.text.trim();

      if (existingExercise != null) {
        final updatedExercise = existingExercise!.copyWith(
          name: selectedExercise!,
          duration: duration,
          caloriesBurned: estimatedCalories,
          intensity: selectedIntensity,
          notes: notes.isEmpty ? null : notes,
        );
        await exerciseProvider.updateExercise(updatedExercise);
      } else {
        final newExercise = ExerciseEntry.create(
          name: selectedExercise!,
          type: 'Cardio', // Simple default type
          duration: duration,
          caloriesBurned: estimatedCalories,
          intensity: selectedIntensity,
          notes: notes.isEmpty ? null : notes,
        );
        await exerciseProvider.logExercise(newExercise);
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

  // Getters
  List<Map<String, String>> getExercises() => exercises;
  List<String> getIntensityLevels() => intensityLevels;
  List<int> getDurationPresets() => durationPresets;
  
  bool isExerciseSelected(String exercise) => selectedExercise == exercise;
  bool isIntensitySelected(String intensity) => selectedIntensity == intensity;
  bool isDurationPresetSelected(int preset) => durationController.text == preset.toString();
}