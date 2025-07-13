// lib/widgets/exercise/exercise_dialog_controller.dart
import 'package:flutter/material.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import '../../data/storage/local_storage.dart';

class ExerciseDialogController extends ChangeNotifier {
  final ExerciseProvider exerciseProvider;
  final ExerciseEntry? existingExercise;
  final String? preselectedExercise;
  final LocalStorage _localStorage = LocalStorage();

  // Controllers
  final TextEditingController durationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController customExerciseController = TextEditingController();

  // State variables
  String? selectedExercise;
  String selectedIntensity = 'Moderate';
  int estimatedCalories = 0;
  bool isLoading = false;
  bool showRunWalkOptions = false;
  List<Map<String, String>> savedCustomExercises = [];

  // Exercise data constants
  static const List<Map<String, dynamic>> coreExercises = [
    {'name': 'Running/Walking', 'icon': '🏃‍♂️', 'type': 'Cardio', 'benefit': 'Weight Loss', 'hasSubOptions': true},
    {'name': 'HIIT', 'icon': '⚡', 'type': 'Cardio', 'benefit': 'Fat Burn'},
    {'name': 'Weight Training', 'icon': '🏋️', 'type': 'Strength', 'benefit': 'Muscle Gain'},
    {'name': 'Swimming', 'icon': '🏊', 'type': 'Water', 'benefit': 'Full Body'},
    {'name': 'Cycling', 'icon': '🚴', 'type': 'Cardio', 'benefit': 'Weight Loss'},
    {'name': 'Squats', 'icon': '🏋️‍♀️', 'type': 'Strength', 'benefit': 'Lower Body'},
    {'name': 'Yoga', 'icon': '🧘', 'type': 'Flexibility', 'benefit': 'Tone & Flex'},
    {'name': 'Jump Rope', 'icon': '🪢', 'type': 'Cardio', 'benefit': 'Fat Burn'},
    {'name': 'Planks', 'icon': '🤸‍♂️', 'type': 'Strength', 'benefit': 'Core Strength'},
  ];

  static const List<Map<String, String>> runWalkOptions = [
    {'name': 'Walking', 'icon': '🚶', 'intensity': 'Light to Moderate'},
    {'name': 'Jogging', 'icon': '🏃‍♀️', 'intensity': 'Moderate'},
    {'name': 'Running', 'icon': '🏃‍♂️', 'intensity': 'Moderate to Intense'},
  ];

  static const List<Map<String, dynamic>> intensityLevels = [
    {'name': 'Light', 'icon': '😌', 'description': 'Easy pace'},
    {'name': 'Moderate', 'icon': '😤', 'description': 'Comfortable effort'},
    {'name': 'Intense', 'icon': '🔥', 'description': 'Hard effort'},
  ];

  static const List<int> durationPresets = [15, 20, 30, 45, 60, 90];

  static const Map<String, Map<String, int>> caloriesMap = {
    'Cardio': {'Light': 6, 'Moderate': 8, 'Intense': 12},
    'Strength': {'Light': 4, 'Moderate': 6, 'Intense': 8},
    'Flexibility': {'Light': 2, 'Moderate': 3, 'Intense': 4},
    'Sports': {'Light': 7, 'Moderate': 10, 'Intense': 14},
    'Water': {'Light': 5, 'Moderate': 8, 'Intense': 11},
    'Other': {'Light': 4, 'Moderate': 6, 'Intense': 8},
  };

  ExerciseDialogController({
    required this.exerciseProvider,
    this.existingExercise,
    this.preselectedExercise,
  }) {
    _initializeFields();
    _loadSavedCustomExercises();
  }

  @override
  void dispose() {
    durationController.dispose();
    notesController.dispose();
    customExerciseController.dispose();
    super.dispose();
  }

  // Initialization
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
      calculateCalories();
    }
  }

  // Local storage operations
  Future<void> _loadSavedCustomExercises() async {
    try {
      final saved = await _localStorage.getObjectList('saved_custom_exercises') ?? [];
      savedCustomExercises = saved.cast<Map<String, String>>();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading saved exercises: $e');
    }
  }

  Future<void> _saveSavedCustomExercises() async {
    try {
      await _localStorage.setObjectList('saved_custom_exercises', savedCustomExercises);
    } catch (e) {
      debugPrint('Error saving custom exercises: $e');
    }
  }

  // Validation methods
  String? validateDuration(String? value) {
    if (value == null || value.isEmpty) return 'Duration is required';
    final duration = int.tryParse(value);
    if (duration == null || duration <= 0) return 'Duration must be positive';
    if (duration > 1440) return 'Duration cannot exceed 24 hours';
    return null;
  }

  bool validateExercise() {
    if (selectedExercise == null || selectedExercise!.isEmpty) return false;
    if (selectedExercise == 'custom' && customExerciseController.text.trim().isEmpty) return false;
    return true;
  }

  // Calculation methods
  void calculateCalories() {
    final duration = int.tryParse(durationController.text) ?? 0;
    if (duration <= 0) {
      estimatedCalories = 0;
      notifyListeners();
      return;
    }

    String exerciseType = 'Other';
    final coreExercise = coreExercises.firstWhere(
      (ex) => ex['name'] == selectedExercise,
      orElse: () => <String, dynamic>{},
    );
    if (coreExercise.isNotEmpty) {
      exerciseType = coreExercise['type'] as String;
    }

    final caloriesPerMinute = caloriesMap[exerciseType]?[selectedIntensity] ?? 6;
    final userWeight = exerciseProvider.currentWeight ?? 70.0;
    final adjustedCalories = caloriesPerMinute * (userWeight / 70.0);
    
    estimatedCalories = (adjustedCalories * duration).round();
    notifyListeners();
  }

  String getExerciseType(String exerciseName) {
    final coreExercise = coreExercises.firstWhere(
      (ex) => ex['name'] == exerciseName,
      orElse: () => {'type': 'Other'},
    );
    return coreExercise['type'] as String;
  }

  String getDisplayExerciseName() {
    if (selectedExercise == null || selectedExercise!.isEmpty) return 'Not selected';
    if (selectedExercise == 'custom') {
      return customExerciseController.text.trim().isEmpty 
          ? 'Custom' 
          : customExerciseController.text.trim();
    }
    return selectedExercise!;
  }

  bool get canSave {
    return selectedExercise != null &&
           selectedExercise!.isNotEmpty &&
           durationController.text.isNotEmpty &&
           (selectedExercise != 'custom' || customExerciseController.text.trim().isNotEmpty);
  }

  // Event handlers
  void handleExerciseSelect(String exerciseName) {
    if (exerciseName == 'Running/Walking') {
      showRunWalkOptions = true;
      selectedExercise = null;
    } else {
      selectedExercise = exerciseName;
      showRunWalkOptions = false;
    }
    notifyListeners();
    calculateCalories();
  }

  void handleRunWalkSelect(Map<String, String> option) {
    selectedExercise = option['name'];
    showRunWalkOptions = false;
    notifyListeners();
    calculateCalories();
  }

  void handleDurationPreset(int minutes) {
    durationController.text = minutes.toString();
    calculateCalories();
  }

  void handleIntensitySelect(String intensity) {
    selectedIntensity = intensity;
    notifyListeners();
    calculateCalories();
  }

  void handleCustomExerciseInput(String value) {
    selectedExercise = 'custom';
    notifyListeners();
    calculateCalories();
  }

  void handleDurationChange(String value) {
    calculateCalories();
  }

  // Custom exercise management
  Future<bool> saveCustomExercise() async {
    final exerciseName = customExerciseController.text.trim();
    if (exerciseName.isEmpty || savedCustomExercises.length >= 6) return false;

    final newExercise = {'name': exerciseName, 'icon': '🏃‍♂️', 'type': 'Other'};
    
    savedCustomExercises.add(newExercise);
    selectedExercise = exerciseName;
    customExerciseController.clear();
    
    await _saveSavedCustomExercises();
    notifyListeners();
    calculateCalories();
    return true;
  }

  Future<void> deleteCustomExercise(Map<String, String> exercise) async {
    savedCustomExercises.removeWhere((ex) => ex['name'] == exercise['name']);
    if (selectedExercise == exercise['name']) {
      selectedExercise = null;
    }
    await _saveSavedCustomExercises();
    notifyListeners();
  }

  // Main save operation
  Future<String> saveExercise() async {
    if (!validateExercise()) {
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
      String exerciseName = selectedExercise!;
      
      if (selectedExercise == 'custom') {
        exerciseName = customExerciseController.text.trim();
      }

      if (existingExercise != null) {
        final updatedExercise = existingExercise!.copyWith(
          name: exerciseName,
          duration: duration,
          caloriesBurned: estimatedCalories,
          intensity: selectedIntensity,
          notes: notes.isEmpty ? null : notes,
        );
        await exerciseProvider.updateExercise(updatedExercise);
      } else {
        final newExercise = ExerciseEntry.create(
          name: exerciseName,
          type: getExerciseType(exerciseName),
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

  // Helper methods for UI
  bool isExerciseSelected(String exerciseName) {
    return selectedExercise == exerciseName;
  }

  bool isCustomExerciseSelected(Map<String, String> exercise) {
    return selectedExercise == exercise['name'];
  }

  bool isIntensitySelected(String intensity) {
    return selectedIntensity == intensity;
  }

  bool isDurationPresetSelected(int preset) {
    return durationController.text == preset.toString();
  }

  bool shouldShowRunWalkOptions() {
    return showRunWalkOptions;
  }

  bool hasCustomExercises() {
    return savedCustomExercises.isNotEmpty;
  }

  bool canSaveMoreCustomExercises() {
    return savedCustomExercises.length < 6;
  }

  bool shouldShowCustomExerciseSaveButton() {
    return customExerciseController.text.trim().isNotEmpty && canSaveMoreCustomExercises();
  }

  // Data getters for UI
  List<Map<String, dynamic>> getCoreExercises() => coreExercises;
  List<Map<String, String>> getRunWalkOptions() => runWalkOptions;
  List<Map<String, dynamic>> getIntensityLevels() => intensityLevels;
  List<int> getDurationPresets() => durationPresets;
  List<Map<String, String>> getSavedCustomExercises() => savedCustomExercises;
}