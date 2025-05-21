// lib/widgets/progress/progress_data.dart
import 'package:flutter/foundation.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/weight_data.dart';
import '../../utils/formula.dart';

/// A data provider class that manages progress screen data
/// Uses ChangeNotifier to inform widgets when data changes
class ProgressData extends ChangeNotifier {
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
      
      if (userProfile?.height != null && currentWeight != null) {
        // Calculate BMI
        bmi = Formula.calculateBMI(
          height: userProfile!.height,
          weight: currentWeight,
        );
        
        if (bmi != null) {
          bmiClassification = Formula.getBMIClassification(bmi);
          
          // Calculate body fat percentage based on BMI
          bodyFatValue = Formula.calculateBodyFat(
            bmi: bmi,
            age: userProfile.age,
            gender: userProfile.gender,
          );
          
          if (bodyFatValue != null) {
            bodyFatClassification = Formula.getBodyFatClassification(
              bodyFatValue, 
              userProfile.gender,
            );
          }
        }
        
        // Calculate BMR and TDEE if we have all the necessary data
        if (userProfile.age != null && userProfile.gender != null) {
          // Calculate BMR
          bmr = Formula.calculateBMR(
            weight: currentWeight,
            height: userProfile.height,
            age: userProfile.age,
            gender: userProfile.gender,
          );
          
          if (bmr != null) {
            // Calculate TDEE
            final activityLevel = userProfile.activityLevel ?? 1.2;
            tdee = bmr * activityLevel;
            
            // Calculate calorie targets
            final maintenance = tdee.round();
            calorieGoals = {
              'maintain': maintenance,
              'lose': (maintenance - 500).round(),
              'lose_mild': (maintenance - 250).round(),
              'gain': (maintenance + 500).round(),
            };
          }
        }
      }
      
      // Update the state with loaded and calculated data
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
      _errorMessage = 'Error loading data: $e';
      _isLoading = false;
    }
    
    // Notify UI of changes
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
}