// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/weight_data.dart';
import '../utils/formula.dart';

class SettingsProvider extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // User data
  UserProfile? _userProfile;
  UserProfile? get userProfile => _userProfile;

  double? _currentWeight;
  double? get currentWeight => _currentWeight;

  bool _isMetric = true;
  bool get isMetric => _isMetric;

  String? _avatarUrl;
  String? get avatarUrl => _avatarUrl;

  // Computed properties for UI display
  String get formattedHeight => Formula.formatHeight(
    height: _userProfile?.height,
    isMetric: _isMetric,
  );

  String get formattedWeight => Formula.formatWeight(
    weight: _currentWeight,
    isMetric: _isMetric,
  );

  String get formattedMonthlyGoal => _userProfile?.monthlyWeightGoal != null
      ? Formula.formatMonthlyWeightGoal(
          goal: _userProfile!.monthlyWeightGoal,
          isMetric: _isMetric,
        )
      : 'Not set';

  String get activityLevelText => Formula.getActivityLevelText(
    _userProfile?.activityLevel,
  );

  String get calculatedAge {
    if (_userProfile?.birthDate == null) return 'Not set';
    
    final now = DateTime.now();
    final birthDate = _userProfile!.birthDate!;
    int age = now.year - birthDate.year;

    // Adjust age if birthday hasn't occurred yet this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return '$age years';
  }

  /// Load all user data
  Future<void> loadUserData() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load user profile
      _userProfile = await _userRepository.getUserProfile();
      
      // Load latest weight entry
      final latestWeight = await _userRepository.getLatestWeightEntry();
      _currentWeight = latestWeight?.weight;

      // Get user's preferred unit system
      if (_userProfile != null) {
        _isMetric = _userProfile!.isMetric;
      }

      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = 'Error loading user data: $e';
      _isLoading = false;
      print('Error in SettingsProvider.loadUserData: $e');
    }

    notifyListeners();
  }

  /// Create a new user profile if one doesn't exist
  Future<void> _createUserProfileIfNeeded() async {
    if (_userProfile == null) {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newProfile = UserProfile(
        id: userId,
        isMetric: _isMetric,
      );

      await _userRepository.saveUserProfile(newProfile);
      _userProfile = newProfile;
      notifyListeners();
    }
  }

  /// Update user profile with new data
  Future<void> _updateProfile(UserProfile updatedProfile) async {
    try {
      await _userRepository.saveUserProfile(updatedProfile);
      _userProfile = updatedProfile;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating profile: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update date of birth and calculated age
  Future<void> updateDateOfBirth(DateTime selectedDate, int calculatedAge) async {
    await _createUserProfileIfNeeded();

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(
        birthDate: selectedDate,
        age: calculatedAge,
      );

      await _updateProfile(updatedProfile);
    }
  }

  /// Update height
  Future<void> updateHeight(double heightValue) async {
    await _createUserProfileIfNeeded();

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(height: heightValue);
      await _updateProfile(updatedProfile);
    }
  }

  /// Update gender
  Future<void> updateGender(String gender) async {
    await _createUserProfileIfNeeded();

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(gender: gender);
      await _updateProfile(updatedProfile);
    }
  }

  /// Update activity level
  Future<void> updateActivityLevel(double level) async {
    await _createUserProfileIfNeeded();

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(activityLevel: level);
      await _updateProfile(updatedProfile);
    }
  }

  /// Update monthly weight goal
  Future<void> updateMonthlyWeightGoal(double monthlyGoal) async {
    await _createUserProfileIfNeeded();

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(
        monthlyWeightGoal: monthlyGoal,
      );
      await _updateProfile(updatedProfile);
    }
  }

  /// Update unit system preference
  Future<void> updateUnitPreference(bool isMetric) async {
    await _createUserProfileIfNeeded();

    _isMetric = isMetric;

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(isMetric: isMetric);
      await _updateProfile(updatedProfile);
    }
  }

  /// Update weight entry
  Future<void> updateWeight(double weight, bool isMetric) async {
    try {
      // Update current weight
      _currentWeight = weight; // Always in kg
      
      // Update unit preference if it changed
      if (_userProfile != null && _userProfile!.isMetric != isMetric) {
        await updateUnitPreference(isMetric);
      }

      // Save new weight entry
      final entry = WeightData.create(weight: weight);
      await _userRepository.addWeightEntry(entry);
      
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error updating weight: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Update avatar URL
  Future<void> updateAvatarUrl(String? avatarUrl) async {
    _avatarUrl = avatarUrl;
    notifyListeners();
    
    // In a real app, you might want to save this to the user profile
    // For now, it's just stored in memory
  }

  /// Send feedback (placeholder implementation)
  Future<void> sendFeedback(String feedbackText) async {
    try {
      // In a real app, this would send feedback to your backend
      // For now, just simulate a network call
      await Future.delayed(const Duration(seconds: 1));
      
      print('Feedback sent: $feedbackText');
      
      // You could also store feedback locally for later sync
      // await _storeFeedbackLocally(feedbackText);
      
    } catch (e) {
      _errorMessage = 'Error sending feedback: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Refresh all data
  Future<void> refreshData() async {
    await loadUserData();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Get missing profile data for completeness check
  List<String> getMissingProfileData() {
    final missing = <String>[];

    if (_userProfile == null) {
      missing.add('Profile');
      return missing;
    }

    if (_currentWeight == null) {
      missing.add('Weight');
    }

    if (_userProfile!.height == null) {
      missing.add('Height');
    }

    if (_userProfile!.age == null || _userProfile!.birthDate == null) {
      missing.add('Date of Birth');
    }

    if (_userProfile!.gender == null) {
      missing.add('Gender');
    }

    if (_userProfile!.activityLevel == null) {
      missing.add('Activity Level');
    }

    if (_userProfile!.monthlyWeightGoal == null) {
      missing.add('Monthly Weight Goal');
    }

    return missing;
  }

  /// Check if profile is complete
  bool get isProfileComplete => getMissingProfileData().isEmpty;

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    const totalFields = 6; // Weight, Height, Age, Gender, Activity Level, Monthly Goal
    final missingFields = getMissingProfileData().length;
    final completedFields = totalFields - missingFields;
    return (completedFields / totalFields).clamp(0.0, 1.0);
  }

  /// Debug method to print all user profile details
  void debugPrintProfile() {
    if (_userProfile != null) {
      _userProfile!.debugPrint();
    } else {
      print('No user profile loaded');
    }
  }
}