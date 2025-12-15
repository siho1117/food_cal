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
  double? _baselineValue;
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

  // Cache version for summary page invalidation
  int _cacheVersion = 0;
  
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
  double? get baselineValue => _baselineValue;
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

  // Cache version getter for summary page
  int get cacheVersion => _cacheVersion;

  /// Invalidate summary page cache when progress data changes
  void _invalidateSummaryCache() {
    _cacheVersion++;
  }

  /// Calculate all health metrics from current data
  /// Pure calculation method - doesn't load data, just computes from existing state
  void _calculateMetrics() {
    if (_userProfile == null || _currentWeight == null || _userProfile!.height == null) {
      _bmiValue = null;
      _bmiClassification = 'Not available';
      _bodyFatValue = null;
      _bodyFatClassification = 'Not available';
      _bmrValue = null;
      _baselineValue = null;
      _calorieGoals = {};
      _startingWeight = null;
      _startingBMI = null;
      _targetBMI = null;
      _bmiProgress = null;
      _startingBodyFat = null;
      _targetBodyFat = null;
      _bodyFatProgress = null;
      return;
    }

    // Calculate BMI
    _bmiValue = HealthMetrics.calculateBMI(
      height: _userProfile!.height,
      weight: _currentWeight!,
    );

    if (_bmiValue != null) {
      _bmiClassification = HealthMetrics.getBMIClassification(_bmiValue!);

      // Calculate body fat percentage
      _bodyFatValue = HealthMetrics.calculateBodyFat(
        bmi: _bmiValue!,
        age: _userProfile!.age,
        gender: _userProfile!.gender,
      );

      if (_bodyFatValue != null) {
        _bodyFatClassification = HealthMetrics.getBodyFatClassification(
          _bodyFatValue!,
          _userProfile!.gender,
        );
      }
    }

    // Calculate BMR and baseline
    _bmrValue = HealthMetrics.calculateBMR(
      weight: _currentWeight!,
      height: _userProfile!.height,
      age: _userProfile!.age,
      gender: _userProfile!.gender,
    );

    if (_bmrValue != null) {
      _baselineValue = _bmrValue;
      _calorieGoals = HealthMetrics.calculateDailyCalorieNeeds(
        profile: _userProfile!,
        currentWeight: _currentWeight!,
      );
    }

    // Calculate progress tracking metrics
    final startingWeight = _userProfile!.startingWeight
        ?? HealthMetrics.getStartingWeight(_weightHistory);

    _startingWeight = startingWeight;
    _startingBMI = startingWeight != null
        ? HealthMetrics.calculateBMI(height: _userProfile!.height, weight: startingWeight)
        : null;

    _targetBMI = _userProfile!.goalWeight != null
        ? HealthMetrics.calculateBMI(height: _userProfile!.height, weight: _userProfile!.goalWeight)
        : null;

    _bmiProgress = HealthMetrics.calculateProgress(
      startValue: _startingBMI,
      currentValue: _bmiValue,
      targetValue: _targetBMI,
    );

    _startingBodyFat = HealthMetrics.calculateStartingBodyFat(
      startingWeight: startingWeight,
      height: _userProfile!.height,
      age: _userProfile!.age,
      gender: _userProfile!.gender,
    );

    _targetBodyFat = HealthMetrics.calculateTargetBodyFat(
      targetWeight: _userProfile!.goalWeight,
      height: _userProfile!.height,
      age: _userProfile!.age,
      gender: _userProfile!.gender,
    );

    _bodyFatProgress = HealthMetrics.calculateProgress(
      startValue: _startingBodyFat,
      currentValue: _bodyFatValue,
      targetValue: _targetBodyFat,
    );
  }

  /// Load all necessary user data and calculate metrics
  Future<void> loadUserData() async {
    final stopwatch = kDebugMode ? (Stopwatch()..start()) : null;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load user profile
      _userProfile = await _userRepository.getUserProfile();

      // Load latest weight entry
      final latestWeight = await _userRepository.getLatestWeightEntry();
      _currentWeight = latestWeight?.weight;

      // Load weight history
      _weightHistory = await _userRepository.getWeightEntries();

      // Get user's preferred unit system
      _isMetric = _userProfile?.isMetric ?? true;

      // Calculate all metrics using extracted method
      _calculateMetrics();

      _isLoading = false;
      _errorMessage = null;

      if (kDebugMode) {
        debugPrint('[ProgressData] loadUserData: ${stopwatch?.elapsedMilliseconds}ms');
      }
    } catch (e) {
      _errorMessage = 'Error loading progress data: $e';
      _isLoading = false;
      debugPrint('Error in ProgressData.loadUserData: $e');
    }

    notifyListeners();
  }
  
  /// Handle new weight entry
  Future<void> addWeightEntry(double weight, bool isMetric) async {
    WeightData? addedEntry;
    double? previousWeight;
    UserProfile? originalProfile;
    bool addedToLocal = false;
    bool profileUpdated = false;

    try {
      // Optimistically update local state
      addedEntry = WeightData.create(weight: weight);
      previousWeight = _currentWeight;

      _weightHistory.add(addedEntry);
      _currentWeight = weight;
      addedToLocal = true;

      // Update unit preference optimistically if needed
      if (_userProfile != null && _userProfile!.isMetric != isMetric) {
        originalProfile = _userProfile;
        _userProfile = _userProfile!.copyWith(isMetric: isMetric);
        _isMetric = isMetric;
        profileUpdated = true;
      }

      // Recalculate metrics with new weight
      _calculateMetrics();
      notifyListeners(); // Immediate UI update

      // Persist to storage
      await _userRepository.addWeightEntry(addedEntry);

      if (profileUpdated && _userProfile != null) {
        await _userRepository.saveUserProfile(_userProfile!);
      }

      // Invalidate summary cache
      _invalidateSummaryCache();
    } catch (e) {
      // Rollback: Restore previous state
      if (addedToLocal && addedEntry != null) {
        _weightHistory.remove(addedEntry);
        _currentWeight = previousWeight;
      }

      if (profileUpdated && originalProfile != null) {
        _userProfile = originalProfile;
        _isMetric = originalProfile.isMetric;
      }

      // Recalculate with restored data
      _calculateMetrics();
      notifyListeners();

      _errorMessage = 'Error saving weight: $e';
      debugPrint('Error in addWeightEntry: $e');
      rethrow;
    }
  }

  /// Add weight entry with custom timestamp (for forward-filled entries)
  Future<void> addWeightEntryWithTimestamp(double weight, DateTime timestamp, bool isMetric) async {
    WeightData? addedEntry;
    UserProfile? originalProfile;
    bool addedToLocal = false;
    bool profileUpdated = false;

    try {
      // Optimistically update local state
      addedEntry = WeightData.create(weight: weight, timestamp: timestamp);

      _weightHistory.add(addedEntry);
      addedToLocal = true;

      // Update unit preference optimistically if needed
      if (_userProfile != null && _userProfile!.isMetric != isMetric) {
        originalProfile = _userProfile;
        _userProfile = _userProfile!.copyWith(isMetric: isMetric);
        _isMetric = isMetric;
        profileUpdated = true;
      }

      // Sort weight history by timestamp
      _weightHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      // Update current weight if this is the most recent entry
      final mostRecent = _weightHistory.last;
      if (mostRecent.id == addedEntry.id) {
        _currentWeight = weight;
        _calculateMetrics();
      }

      notifyListeners(); // Immediate UI update

      // Persist to storage
      await _userRepository.addWeightEntry(addedEntry);

      if (profileUpdated && _userProfile != null) {
        await _userRepository.saveUserProfile(_userProfile!);
      }

      // Invalidate summary cache
      _invalidateSummaryCache();
    } catch (e) {
      // Rollback: Restore previous state
      if (addedToLocal && addedEntry != null) {
        _weightHistory.remove(addedEntry);
      }

      if (profileUpdated && originalProfile != null) {
        _userProfile = originalProfile;
        _isMetric = originalProfile.isMetric;
      }

      // Recalculate with restored data
      _calculateMetrics();
      notifyListeners();

      _errorMessage = 'Error saving weight: $e';
      debugPrint('Error in addWeightEntryWithTimestamp: $e');
      rethrow;
    }
  }

  /// Update an existing weight entry
  Future<void> updateWeightEntry(String entryId, double weight, DateTime timestamp, String? note) async {
    WeightData? originalEntry;
    int entryIndex = -1;
    double? previousWeight;

    try {
      // Find and save original entry for rollback
      entryIndex = _weightHistory.indexWhere((entry) => entry.id == entryId);
      if (entryIndex != -1) {
        originalEntry = _weightHistory[entryIndex];

        // Update local state optimistically
        final updatedEntry = WeightData(
          id: entryId,
          weight: weight,
          timestamp: timestamp,
          note: note,
        );

        _weightHistory[entryIndex] = updatedEntry;

        // Update current weight if this is the most recent entry
        _weightHistory.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        final mostRecent = _weightHistory.last;
        if (mostRecent.id == entryId) {
          previousWeight = _currentWeight;
          _currentWeight = weight;
          _calculateMetrics();
        }

        notifyListeners(); // Immediate UI update
      }

      // Persist to storage
      final success = await _userRepository.updateWeightEntry(entryId, weight, timestamp, note);

      if (!success) {
        throw Exception('Failed to update weight entry');
      }

      // Invalidate summary cache
      _invalidateSummaryCache();
    } catch (e) {
      // Rollback: Restore original entry
      if (originalEntry != null && entryIndex != -1) {
        _weightHistory[entryIndex] = originalEntry;

        if (previousWeight != null) {
          _currentWeight = previousWeight;
          _calculateMetrics();
        }

        notifyListeners();
      }

      _errorMessage = 'Error updating weight: $e';
      debugPrint('Error in updateWeightEntry: $e');
      rethrow;
    }
  }

  /// Delete a weight entry
  Future<void> deleteWeightEntry(String entryId) async {
    WeightData? removedEntry;
    int removedIndex = -1;
    double? previousWeight;

    try {
      // Find and save entry for rollback
      removedIndex = _weightHistory.indexWhere((entry) => entry.id == entryId);
      if (removedIndex != -1) {
        removedEntry = _weightHistory[removedIndex];

        // Remove from local state optimistically
        _weightHistory.removeAt(removedIndex);

        // Update current weight if needed
        if (_weightHistory.isNotEmpty) {
          final mostRecent = _weightHistory.last;
          if (_currentWeight != mostRecent.weight) {
            previousWeight = _currentWeight;
            _currentWeight = mostRecent.weight;
            _calculateMetrics();
          }
        } else {
          previousWeight = _currentWeight;
          _currentWeight = null;
          _calculateMetrics();
        }

        notifyListeners(); // Immediate UI update
      }

      // Persist to storage
      final success = await _userRepository.deleteWeightEntry(entryId);

      if (!success) {
        throw Exception('Failed to delete weight entry');
      }

      // Invalidate summary cache
      _invalidateSummaryCache();
    } catch (e) {
      // Rollback: Re-add entry
      if (removedEntry != null && removedIndex != -1) {
        _weightHistory.insert(removedIndex, removedEntry);

        if (previousWeight != null) {
          _currentWeight = previousWeight;
          _calculateMetrics();
        }

        notifyListeners();
      }

      _errorMessage = 'Error deleting weight: $e';
      debugPrint('Error in deleteWeightEntry: $e');
      rethrow;
    }
  }

  /// Update the user's target weight goal
  Future<void> updateTargetWeight(double targetWeight) async {
    UserProfile? originalProfile;

    try {
      if (_userProfile != null) {
        // Save original for rollback
        originalProfile = _userProfile;

        // Update local state optimistically
        _userProfile = _userProfile!.copyWith(goalWeight: targetWeight);
        _calculateMetrics(); // Recalculate progress with new target
        notifyListeners(); // Immediate UI update

        // Persist to storage
        await _userRepository.saveUserProfile(_userProfile!);
      } else {
        // If no profile exists yet, create a new one with this goal weight
        final userId = DateTime.now().millisecondsSinceEpoch.toString();
        _userProfile = UserProfile(
          id: userId,
          isMetric: _isMetric,
          goalWeight: targetWeight,
        );

        _calculateMetrics();
        notifyListeners();

        await _userRepository.saveUserProfile(_userProfile!);
      }

      // Invalidate summary cache
      _invalidateSummaryCache();
    } catch (e) {
      // Rollback: Restore original profile
      if (originalProfile != null) {
        _userProfile = originalProfile;
        _calculateMetrics();
        notifyListeners();
      }

      _errorMessage = 'Error updating target weight: $e';
      debugPrint('Error in updateTargetWeight: $e');
      rethrow;
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