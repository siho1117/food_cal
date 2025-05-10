// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import '../widgets/progress/current_weight_widget.dart';
import '../widgets/progress/target_weight_widget.dart';
// Temporarily comment out problematic widget imports
// import '../widgets/progress/body_mass_index.dart';
// import '../widgets/progress/body_fat_widget.dart';
// import '../widgets/progress/tdee_calculator_widget.dart';
// import '../widgets/progress/basal_meta_rate.dart';
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

              // Message about disabled widgets
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha((0.1 * 255).toInt()),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.orange.withAlpha((0.3 * 255).toInt()),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.orange[700],
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Widgets Temporarily Disabled',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Most progress tracking widgets have been temporarily disabled while we update the header design. Only the weight tracking widgets are available at this time.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),

              // Current Weight Widget (keeping this one)
              CurrentWeightWidget(
                onWeightUpdated: _onWeightUpdated,
              ),

              const SizedBox(height: 20),

              // Target Weight Widget (keeping this one)
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

              // Commented out problematic widgets
              /*
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

              // BMI and Body Fat widgets
              _buildBodyCompositionWidgets(),
              */

              const SizedBox(height: 80), // Extra space for bottom nav
            ],
          ),
        ),
      ),
    );
  }

  // Commented out this method as well since it's not being used
  /*
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
  */
}