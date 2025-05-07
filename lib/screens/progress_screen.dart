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
import '../config/theme.dart';

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

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      // Load user profile for unit preference
      final userProfile = await _userRepository.getUserProfile();

      // Load latest weight entry
      final latestWeight = await _userRepository.getLatestWeightEntry();

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
        });
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
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
        child: SingleChildScrollView(
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

              // Current Weight Widget
              CurrentWeightWidget(
                onWeightUpdated: _onWeightUpdated,
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

              // TDEE Calculator Widget
              TDEECalculatorWidget(
                userProfile: _userProfile,
                currentWeight: _currentWeight,
              ),

              const SizedBox(height: 20),

              // BMR Calculator Widget
              BasalMetabolicRateWidget(
                userProfile: _userProfile,
                currentWeight: _currentWeight,
              ),

              const SizedBox(height: 20),

              // BMI and Body Fat widgets now in a column instead of a row for better layout
              _buildBodyCompositionWidgets(),

              const SizedBox(height: 80), // Extra space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // Extracted method to build the body composition widgets (BMI and Body Fat)
  Widget _buildBodyCompositionWidgets() {
    return FutureBuilder<double?>(
      future: _userRepository.calculateBMI(),
      builder: (context, snapshot) {
        final bmiValue = snapshot.data;
        String classification = "Not set";

        if (bmiValue != null) {
          classification = _userRepository.getBMIClassification(bmiValue);
        }

        // Extract profile data needed for body fat calculation
        final String? gender = _userProfile?.gender;
        final int? age = _userProfile?.age;

        // Calculate body fat using the formula in utils
        double? bodyFatValue;
        String bodyFatClassification = "Not set";

        if (bmiValue != null) {
          bodyFatValue = Formula.calculateBodyFat(
            bmi: bmiValue,
            age: age,
            gender: gender,
          );

          if (bodyFatValue != null) {
            bodyFatClassification = Formula.getBodyFatClassification(
              bodyFatValue, gender);
          }
        }

        // Using a Column instead of Row for better vertical layout
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BMI Widget
            BMIWidget(
              bmiValue: bmiValue,
              classification: classification,
            ),

            const SizedBox(height: 20),

            // Body Fat Widget
            BodyFatPercentageWidget(
              bodyFatPercentage: bodyFatValue,
              classification: bodyFatClassification,
              isEstimated: true,
            ),
          ],
        );
      },
    );
  }
}