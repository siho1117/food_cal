// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import '../widgets/progress/current_weight_widget.dart';
import '../widgets/progress/target_weight_widget.dart';
import '../widgets/progress/body_mass_index.dart';
import '../widgets/progress/body_fat_widget.dart';
import '../widgets/progress/tdee_calculator_widget.dart';
import '../widgets/progress/basal_meta_rate.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user_profile.dart';
import '../utils/formula.dart';
import '../config/design_system/theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  double _currentWeight = 70.0; // Default in kg
  double? _targetWeight; // Target weight in kg
  bool _isMetric = true;
  final UserRepository _userRepository = UserRepository();
  UserProfile? _userProfile; // Store user profile
  bool _isLoading = true;
  double? _bmiValue;
  String _bmiClassification = "Not set";

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Load user profile for unit preference
      final userProfile = await _userRepository.getUserProfile();

      // Load latest weight entry
      final latestWeight = await _userRepository.getLatestWeightEntry();
      
      // Pre-calculate BMI to avoid async loading later
      final bmiValue = await _userRepository.calculateBMI();
      String bmiClassification = "Not set";
      
      if (bmiValue != null) {
        bmiClassification = _userRepository.getBMIClassification(bmiValue);
      }

      if (mounted) {
        setState(() {
          _userProfile = userProfile; // Store the user profile

          if (userProfile != null) {
            _isMetric = userProfile.isMetric;
            _targetWeight = userProfile.goalWeight; // Load target weight
          }

          if (latestWeight != null) {
            _currentWeight = latestWeight.weight; // Always in kg
          }
          
          _bmiValue = bmiValue;
          _bmiClassification = bmiClassification;
          
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Method to handle weight updates from child widgets
  void _onWeightUpdated() {
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Text
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'PROGRESS TRACKER',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Track your health and fitness journey',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Row layout for Current Weight and BMI widgets
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Current Weight Widget - half width
                          Expanded(
                            child: CurrentWeightWidget(
                              onWeightUpdated: _onWeightUpdated,
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // BMI Widget - half width
                          Expanded(
                            child: BMIWidget(
                              bmiValue: _bmiValue,
                              classification: _bmiClassification,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Target Weight Widget
                    TargetWeightWidget(
                      targetWeight: _targetWeight,
                      currentWeight: _currentWeight,
                      isMetric: _isMetric,
                      onWeightUpdated: (weight, isMetric) async {
                        setState(() {
                          _targetWeight = weight;
                          _isMetric = isMetric;
                        });
                        
                        // Update user profile
                        if (_userProfile != null) {
                          final updatedProfile = _userProfile!.copyWith(
                            goalWeight: weight,
                            isMetric: isMetric,
                          );
                          await _userRepository.saveUserProfile(updatedProfile);
                          setState(() {
                            _userProfile = updatedProfile;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 20),

                    // Row layout for Body Fat and BMR widgets (two columns)
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Body Fat Widget - half width
                          Expanded(
                            child: _buildBodyFatWidget(),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // BMR Widget - half width
                          Expanded(
                            child: BasalMetabolicRateWidget(
                              userProfile: _userProfile,
                              currentWeight: _currentWeight,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // TDEE Widget (full width)
                    TDEECalculatorWidget(
                      userProfile: _userProfile,
                      currentWeight: _currentWeight,
                    ),

                    const SizedBox(height: 80), // Extra space for bottom nav
                  ],
                ),
              ),
      ),
    );
  }

  // Extracted method to build the body fat widget
  Widget _buildBodyFatWidget() {
    // Extract profile data needed for body fat calculation
    final String? gender = _userProfile?.gender;
    final int? age = _userProfile?.age;

    // Calculate body fat using the formula in utils
    double? bodyFatValue;
    String bodyFatClassification = "Not set";

    if (_bmiValue != null) {
      bodyFatValue = Formula.calculateBodyFat(
        bmi: _bmiValue,
        age: age,
        gender: gender,
      );

      if (bodyFatValue != null) {
        bodyFatClassification = Formula.getBodyFatClassification(
          bodyFatValue, gender);
      }
    }

    return BodyFatPercentageWidget(
      bodyFatPercentage: bodyFatValue,
      classification: bodyFatClassification,
      isEstimated: true,
    );
  }
}