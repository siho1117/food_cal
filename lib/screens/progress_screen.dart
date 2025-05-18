import 'package:flutter/material.dart';
import '../config/design_system/theme.dart';
import '../widgets/progress/body_mass_index.dart';
import '../widgets/progress/current_weight_widget.dart';
import '../widgets/progress/target_weight_widget.dart';
import '../widgets/progress/basal_meta_rate.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

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
              // Row 1: Current Weight and BMI
              Row(
                children: [
                  // Current Weight Widget
                  Expanded(
                    child: CurrentWeightWidget(
                      initialWeight: null,
                      isMetric: true,
                      onWeightUpdated: (weight, isMetric) {
                        // Empty callback that does nothing
                        // This is just to satisfy the parameter requirement
                      },
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // BMI Widget
                  const Expanded(
                    child: BMIWidget(
                      bmiValue: null,
                      classification: "Not set",
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Row 2: Target Weight Widget
              TargetWeightWidget(
                targetWeight: null,
                currentWeight: null,
                isMetric: true,
                onWeightUpdated: (weight, isMetric) {
                  // Empty callback
                },
              ),
              
              const SizedBox(height: 20),
              
              // Row 3: Basal Metabolic Rate Widget
              const BasalMetabolicRateWidget(
                userProfile: null,
                currentWeight: null,
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