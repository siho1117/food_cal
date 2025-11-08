// lib/providers/settings_provider.dart
import 'package:flutter/foundation.dart';

import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../data/models/weight_data.dart';
import '../utils/shared/format_helpers.dart';
import '../utils/progress/health_metrics.dart';

class SettingsProvider extends ChangeNotifier {
  // Direct instantiation - UserRepository is effectively a singleton
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
  String get formattedHeight => _userProfile?.height != null
      ? FormatHelpers.formatHeight(_userProfile!.height!)
      : 'Not set';

  String get formattedWeight => _currentWeight != null
      ? FormatHelpers.formatWeight(_currentWeight)
      : 'Not set';

  String get formattedMonthlyGoal => _userProfile?.monthlyWeightGoal != null
      ? FormatHelpers.formatMonthlyWeightGoal(_userProfile!.monthlyWeightGoal)
      : 'Not set';

  String get activityLevelText => HealthMetrics.getActivityLevelText(
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
      debugPrint('Error in SettingsProvider.loadUserData: $e');
    }

    notifyListeners();
  }

  /// Refresh data
  Future<void> refreshData() async {
    await loadUserData();
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
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

  /// Update user name
  Future<void> updateName(String name) async {
    await _createUserProfileIfNeeded();

    if (_userProfile != null) {
      final updatedProfile = _userProfile!.copyWith(name: name);
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
  Future<void> updateAvatarUrl(String? url) async {
    _avatarUrl = url;
    notifyListeners();
  }

  Future<void> sendFeedback(String message) async {
    try {
      // TODO: Implement actual feedback sending logic
      // This could send to an API, email service, or local storage
      debugPrint('Feedback sent: $message');
      
      // For now, just show success
      // In a real app, you'd integrate with your feedback service
    } catch (e) {
      debugPrint('Error sending feedback: $e');
      rethrow;
    }
  }

  double get profileCompletionPercentage {
    if (_userProfile == null) return 0.0;
    
    int completedFields = 0;
    int totalFields = 6; // height, weight, age, gender, activity level, monthly goal
    
    if (_userProfile!.height != null) completedFields++;
    if (_currentWeight != null) completedFields++;
    if (_userProfile!.age != null || _userProfile!.birthDate != null) completedFields++;
    if (_userProfile!.gender != null) completedFields++;
    if (_userProfile!.activityLevel != null) completedFields++;
    if (_userProfile!.monthlyWeightGoal != null) completedFields++;
    
    return completedFields / totalFields;
  }

  bool get isProfileComplete {
    return profileCompletionPercentage >= 1.0;
  }

  List<String> getMissingProfileData() {
    if (_userProfile == null) {
      return ['All profile information'];
    }
    
    List<String> missing = [];
    
    if (_userProfile!.height == null) missing.add('Height');
    if (_currentWeight == null) missing.add('Current Weight');
    if (_userProfile!.age == null && _userProfile!.birthDate == null) missing.add('Date of Birth');
    if (_userProfile!.gender == null) missing.add('Gender');
    if (_userProfile!.activityLevel == null) missing.add('Activity Level');
    if (_userProfile!.monthlyWeightGoal == null) missing.add('Monthly Weight Goal');
    
    return missing;
  }
}