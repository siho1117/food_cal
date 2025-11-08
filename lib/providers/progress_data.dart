// lib/providers/progress_data.dart
import 'package:flutter/foundation.dart';

import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/weight_data.dart';
import '../utils/progress/health_metrics.dart';

/// A data provider class that manages progress screen data
/// Uses ChangeNotifier to inform widgets when data changes
class ProgressData extends ChangeNotifier {
  // Direct instantiation - UserRepository is effectively a singleton
  final UserRepository _userRepository = UserRepository();
  
  // User data
  UserProfile? _userProfile;
  double? _currentWeight;
  bool _isMetric = true;
  List<WeightData> _weightHistory = [];
  
  // Calculated metrics
  double? _bmiValue;
  String _bmiClassification = 'Not available';
  
  // Body fat metrics
  double? _bodyFatValue;
  String _bodyFatClassification = 'Not available';
  
  // Energy metrics
  double? _bmrValue;
  double? _tdeeValue;
  Map<String, int> _calorieGoals = {};

  // Progress tracking metrics
  double? _startingWeight;
  double? _startingBMI;
  double? _targetBMI;
  double? _bmiProgress;
  double? _startingBodyFat;
  double? _targetBodyFat;
  double? _bodyFatProgress;

  // UI state
  bool _isLoading = true;
  String? _errorMessage;
  
  // Getters for UI to access the data
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserProfile? get userProfile => _userProfile;
  double? get currentWeight => _currentWeight;
  bool get isMetric => _isMetric;
  double? get bmiValue => _bmiValue;
  String get bmiClassification => _bmiClassification;
  double? get bodyFatValue => _bodyFatValue;
  String get bodyFatClassification => _bodyFatClassification;
  double? get bmrValue => _bmrValue;
  double? get tdeeValue => _tdeeValue;
  Map<String, int> get calorieGoals => _calorieGoals;
  List<WeightData> get weightHistory => _weightHistory;

  // ✅ NEW: Expose target weight from UserProfile
  double? get targetWeight => _userProfile?.goalWeight;

  // Progress tracking getters
  double? get startingWeight => _startingWeight;
  double? get startingBMI => _startingBMI;
  double? get targetBMI => _targetBMI;
  double? get bmiProgress => _bmiProgress;
  double? get startingBodyFat => _startingBodyFat;
  double? get targetBodyFat => _targetBodyFat;
  double? get bodyFatProgress => _bodyFatProgress;

  /// Load all necessary user data and calculate metrics
  Future<void> loadUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load user profile
      final userProfile = await _userRepository.getUserProfile();
      
      // Load latest weight entry
      final latestWeight = await _userRepository.getLatestWeightEntry();
      
      // Load weight history
      final weightHistory = await _userRepository.getWeightEntries();
      
      // Get current weight or null if not available
      final currentWeight = latestWeight?.weight;
      
      // Get user's preferred unit system
      final isMetric = userProfile?.isMetric ?? true;
      
      // Calculate BMI if we have height and weight
      double? bmi;
      String bmiClassification = 'Not available';
      
      // Body fat variables
      double? bodyFatValue;
      String bodyFatClassification = 'Not available';
      
      // Energy metrics
      double? bmr;
      double? tdee;
      Map<String, int> calorieGoals = {};
      
      if (userProfile != null && currentWeight != null && userProfile.height != null) {
        // Calculate BMI
        bmi = HealthMetrics.calculateBMI(
          height: userProfile.height,
          weight: currentWeight,
        );

        if (bmi != null) {
          bmiClassification = HealthMetrics.getBMIClassification(bmi);

          // Calculate body fat percentage
          bodyFatValue = HealthMetrics.calculateBodyFat(
            bmi: bmi,
            age: userProfile.age,
            gender: userProfile.gender,
          );

          if (bodyFatValue != null) {
            bodyFatClassification = HealthMetrics.getBodyFatClassification(
              bodyFatValue,
              userProfile.gender,
            );
          }
        }

        // Calculate BMR and TDEE
        bmr = HealthMetrics.calculateBMR(
          weight: currentWeight,
          height: userProfile.height,
          age: userProfile.age,
          gender: userProfile.gender,
        );

        if (bmr != null && userProfile.activityLevel != null) {
          tdee = bmr * userProfile.activityLevel!;

          // Calculate different calorie goals
          calorieGoals = HealthMetrics.calculateDailyCalorieNeeds(
            profile: userProfile,
            currentWeight: currentWeight,
          );
        }

        // Calculate progress tracking metrics
        // Get starting weight from history
        final startingWeight = HealthMetrics.getStartingWeight(weightHistory);

        // Calculate starting BMI
        final startingBMI = startingWeight != null
            ? HealthMetrics.calculateBMI(height: userProfile.height, weight: startingWeight)
            : null;

        // Calculate target BMI
        final targetBMI = userProfile.goalWeight != null
            ? HealthMetrics.calculateBMI(height: userProfile.height, weight: userProfile.goalWeight)
            : null;

        // Calculate BMI progress
        final bmiProgress = HealthMetrics.calculateProgress(
          startValue: startingBMI,
          currentValue: bmi,
          targetValue: targetBMI,
        );

        // Calculate starting body fat
        final startingBodyFat = HealthMetrics.calculateStartingBodyFat(
          startingWeight: startingWeight,
          height: userProfile.height,
          age: userProfile.age,
          gender: userProfile.gender,
        );

        // Calculate target body fat
        final targetBodyFat = HealthMetrics.calculateTargetBodyFat(
          targetWeight: userProfile.goalWeight,
          height: userProfile.height,
          age: userProfile.age,
          gender: userProfile.gender,
        );

        // Calculate body fat progress
        final bodyFatProgress = HealthMetrics.calculateProgress(
          startValue: startingBodyFat,
          currentValue: bodyFatValue,
          targetValue: targetBodyFat,
        );

        // Store progress tracking values
        _startingWeight = startingWeight;
        _startingBMI = startingBMI;
        _targetBMI = targetBMI;
        _bmiProgress = bmiProgress;
        _startingBodyFat = startingBodyFat;
        _targetBodyFat = targetBodyFat;
        _bodyFatProgress = bodyFatProgress;
      }

      // Update all instance variables
      _userProfile = userProfile;
      _currentWeight = currentWeight;
      _isMetric = isMetric;
      _weightHistory = weightHistory;
      _bmiValue = bmi;
      _bmiClassification = bmiClassification;
      _bodyFatValue = bodyFatValue;
      _bodyFatClassification = bodyFatClassification;
      _bmrValue = bmr;
      _tdeeValue = tdee;
      _calorieGoals = calorieGoals;
      
      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading progress data: $e';
      _isLoading = false;
      debugPrint('Error in ProgressData.loadUserData: $e');
    }

    notifyListeners();
  }
  
  /// Handle new weight entry
  Future<void> addWeightEntry(double weight, bool isMetric) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Create new weight entry
      final entry = WeightData.create(weight: weight);
      
      // Save to repository
      await _userRepository.addWeightEntry(entry);
      
      // Update unit preference if it changed
      if (_userProfile != null && _userProfile!.isMetric != isMetric) {
        final updatedProfile = _userProfile!.copyWith(isMetric: isMetric);
        await _userRepository.saveUserProfile(updatedProfile);
      }
      
      // Reload data to reflect changes
      await loadUserData();
    } catch (e) {
      _errorMessage = 'Error saving weight: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update the user's target weight goal
  Future<void> updateTargetWeight(double targetWeight) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      if (_userProfile != null) {
        // Create updated profile with new goal weight
        final updatedProfile = _userProfile!.copyWith(
          goalWeight: targetWeight,
        );
        
        // Save to repository
        await _userRepository.saveUserProfile(updatedProfile);
        
        // Update local state
        _userProfile = updatedProfile;
        
        // Reload data to ensure all calculated fields are updated
        await loadUserData();
      } else {
        // If no profile exists yet, create a new one with this goal weight
        final userId = DateTime.now().millisecondsSinceEpoch.toString();
        final newProfile = UserProfile(
          id: userId,
          isMetric: _isMetric,
          goalWeight: targetWeight,
        );
        
        await _userRepository.saveUserProfile(newProfile);
        
        // Reload data
        await loadUserData();
      }
    } catch (e) {
      _errorMessage = 'Error updating target weight: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Manually refresh all data
  Future<void> refreshData() async {
    await loadUserData();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Dispose method to clean up
  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}