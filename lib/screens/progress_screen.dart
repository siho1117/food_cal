import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../config/design_system/theme.dart';
import '../data/models/user_profile.dart';
import '../widgets/progress/body_mass_index.dart';
import '../widgets/progress/current_weight_widget.dart';
import '../widgets/progress/target_weight_widget.dart';
import '../widgets/progress/tdee_calculator_widget.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  UserProfile? _userProfile;
  double? _currentWeight;
  double? _targetWeight;
  
  void _onTargetWeightUpdated(double weight, bool isMetric) {
    setState(() {
      _targetWeight = weight;
    });
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
              // Row 2: Target Weight Widget
              TargetWeightWidget(
                targetWeight: _targetWeight,
                currentWeight: _currentWeight,
                isMetric: _userProfile?.isMetric ?? true,
                onWeightUpdated: _onTargetWeightUpdated,
              ),
              
              const SizedBox(height: 20),
              
              // Row 3: TDEE Calculator Widget
              TDEECalculatorWidget(
                userProfile: _userProfile,
                currentWeight: _currentWeight,
              ),
              
              // Space for bottom navigation
              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}