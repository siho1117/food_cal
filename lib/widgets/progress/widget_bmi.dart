import 'package:flutter/material.dart';

// TODO: Add localization
// Required translation keys: bmi, current, target, underweight, normal, overweight, obese
// See bmi_widget_translations.txt for key definitions

class BmiWidget extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final double height; // in cm
  final LinearGradient gradient;
  final Color textColor;
  final Color? borderColor;

  const BmiWidget({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.height,
    required this.gradient,
    required this.textColor,
    this.borderColor,
  });

  double _calculateBmi(double weight, double heightCm) {
    final heightM = heightCm / 100;
    return weight / (heightM * heightM);
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25.0) {
      return 'Normal';
    } else if (bmi < 30.0) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentBmi = _calculateBmi(currentWeight, height);
    final targetBmi = _calculateBmi(targetWeight, height);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 280),
      decoration: BoxDecoration(
        border: Border.all(
          color: borderColor ?? Colors.white.withOpacity(0.5),
          width: 4,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14), // Further reduced
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'BMI',
              style: TextStyle(
                fontSize: 13, // Reduced from 14
                fontWeight: FontWeight.w500,
                letterSpacing: 0.2,
                color: textColor,
              ),
            ),
          ),
          const SizedBox(height: 12), // Reduced from 16

          // BMI Stack
          Column(
            children: [
              // Current BMI Section
              _BmiSection(
                label: 'Current',
                value: currentBmi.toStringAsFixed(1),
                category: _getBmiCategory(currentBmi),
                textColor: textColor,
                backgroundColor: Colors.transparent, // No background
              ),
              const SizedBox(height: 8), // Reduced from 12

              // Target BMI Section
              _BmiSection(
                label: 'Target',
                value: targetBmi.toStringAsFixed(1),
                category: _getBmiCategory(targetBmi),
                textColor: textColor,
                backgroundColor: Colors.transparent, // No background
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BmiSection extends StatelessWidget {
  final String label;
  final String value;
  final String category;
  final Color textColor;
  final Color backgroundColor;

  const _BmiSection({
    required this.label,
    required this.value,
    required this.category,
    required this.textColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8), // Further reduced
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 8, // Reduced from 9
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3, // Reduced letter spacing
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 4), // Reduced from 6
          Text(
            value,
            style: TextStyle(
              fontSize: 24, // Reduced from 28
              fontWeight: FontWeight.w600,
              height: 1.0,
              color: textColor,
            ),
          ),
          const SizedBox(height: 3), // Reduced from 4
          Text(
            category,
            style: TextStyle(
              fontSize: 9, // Reduced from 10
              fontWeight: FontWeight.w500,
              color: textColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}