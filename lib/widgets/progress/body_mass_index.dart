// lib/widgets/progress/body_mass_index.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';

class BMIWidget extends StatelessWidget {
  final double? bmiValue;
  final String classification;

  const BMIWidget({
    Key? key,
    required this.bmiValue,
    required this.classification,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get color based on BMI classification
    Color getBmiColor() {
      if (bmiValue == null) return Colors.grey;
      if (bmiValue! < 18.5) return Colors.blue;
      if (bmiValue! < 25.0) return Colors.green;
      if (bmiValue! < 30.0) return Colors.orange;
      return Colors.red;
    }

    final Color bmiColor = getBmiColor();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'BMI',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Colors.grey[600],
                ),
              ],
            ),
            
            // Just show BMI value and classification for now
            const Spacer(),
            
            // BMI value
            Text(
              bmiValue?.toStringAsFixed(1) ?? '--',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: bmiColor,
              ),
            ),
            
            // Classification badge
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: bmiColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: bmiColor.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Text(
                classification,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: bmiColor,
                ),
              ),
            ),
            
            const Spacer(),
          ],
        ),
      ),
    );
  }
}