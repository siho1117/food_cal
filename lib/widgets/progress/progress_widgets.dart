import 'package:flutter/material.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/weight_data.dart';
import '../../utils/formula.dart';
import '../progress/bmi_widget.dart';
import '../progress/weight_entry_widget.dart';
import '../progress/weight_history_graph_widget.dart';

/// A widget that handles all data loading and calculations for progress metrics
/// Acts as the parent for all visualization widgets on the progress screen
class ProgressWidgets extends StatefulWidget {
  const ProgressWidgets({Key? key}) : super(key: key);

  @override
  State<ProgressWidgets> createState() => _ProgressWidgetsState();
}

class _ProgressWidgetsState extends State<ProgressWidgets> {
  final UserRepository _userRepository = UserRepository();
  
  // User data
  UserProfile? _userProfile;
  double? _currentWeight;
  bool _isMetric = true;
  List<WeightData> _weightHistory = [];
  
  // Calculated metrics
  double? _bmiValue;
  String _bmiClassification = 'Not available';
  
  // UI state
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Load all necessary user data and calculate metrics
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

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
      
      if (userProfile?.height != null && currentWeight != null) {
        bmi = Formula.calculateBMI(
          height: userProfile!.height,
          weight: currentWeight,
        );
        
        if (bmi != null) {
          bmiClassification = Formula.getBMIClassification(bmi);
        }
      }
      
      // Update the state with loaded and calculated data
      if (mounted) {
        setState(() {
          _userProfile = userProfile;
          _currentWeight = currentWeight;
          _isMetric = isMetric;
          _weightHistory = weightHistory;
          
          _bmiValue = bmi;
          _bmiClassification = bmiClassification;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error loading data: $e';
          _isLoading = false;
        });
      }
    }
  }
  
  /// Handle new weight entry from the weight entry widget
  Future<void> _onWeightEntered(double weight, bool isMetric) async {
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
      await _loadUserData();
      
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error saving weight: $e';
        });
      }
    }
  }

  /// Manually refresh all data
  Future<void> _refreshData() async {
    await _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Data',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current stats section
        Text(
          'CURRENT STATS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Weight Entry Widget
        WeightEntryWidget(
          currentWeight: _currentWeight,
          isMetric: _isMetric,
          onWeightEntered: _onWeightEntered,
        ),
        
        const SizedBox(height: 16),
        
        // BMI Widget
        BMIWidget(
          bmiValue: _bmiValue,
          classification: _bmiClassification,
        ),
        
        const SizedBox(height: 30),
        
        // History section
        Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Weight History Graph
        WeightHistoryGraphWidget(
          weightHistory: _weightHistory,
          isMetric: _isMetric,
        ),
      ],
    );
  }
}