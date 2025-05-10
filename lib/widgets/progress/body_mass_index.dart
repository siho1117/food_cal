import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';

class BMIWidget extends StatefulWidget {
  final double? bmiValue;
  final String classification;

  const BMIWidget({
    Key? key,
    required this.bmiValue,
    required this.classification,
  }) : super(key: key);

  @override
  State<BMIWidget> createState() => _BMIWidgetState();
}

class _BMIWidgetState extends State<BMIWidget> {
  // Get appropriate color based on BMI classification for the badge
  Color _getColorForBMIBadge() {
    if (widget.bmiValue == null) return Colors.grey;

    if (widget.bmiValue! < 18.5) {
      return const Color(0xFF90CAF9);     // Light blue for Underweight
    } else if (widget.bmiValue! < 25) {
      return const Color(0xFF4CAF50);     // Green for Normal
    } else if (widget.bmiValue! < 30) {
      return const Color(0xFFFFC107);     // Amber for Overweight
    } else {
      return const Color(0xFFF44336);     // Red for Obese
    }
  }

  void _showBMIInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            const Text('About BMI'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BMI Definition
              const Text(
                'Body Mass Index (BMI) is a measure of body fat based on your weight and height. It is used to screen for weight categories that may lead to health problems.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // Current BMI Value
              Text(
                'Your BMI: ${widget.bmiValue?.toStringAsFixed(1) ?? "Not calculated"} (${widget.classification})',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.primaryBlue,
                ),
              ),
              const SizedBox(height: 16),
              
              // BMI Categories
              const Text(
                'BMI Categories:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('• Below 18.5 - Underweight'),
                    SizedBox(height: 4),
                    Text('• 18.5 to 24.9 - Normal weight'),
                    SizedBox(height: 4),
                    Text('• 25.0 to 29.9 - Overweight'),
                    SizedBox(height: 4),
                    Text('• 30.0 and above - Obesity'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // BMI Formula
              const Text(
                'How BMI is calculated:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('BMI = weight(kg) / height(m)²'),
                    SizedBox(height: 6),
                    Text('Example: A person weighing 70kg with height 175cm (1.75m)'),
                    Text('BMI = 70 / (1.75 × 1.75) = 22.9'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Limitations
              const Text(
                'Limitations of BMI:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'BMI does not directly measure body fat and may not be accurate for athletes, the elderly, pregnant women, or highly muscular individuals. It should be used as one of several assessments of health, not the only one.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Create classification badge with improved contrast
    final Color badgeColor = _getColorForBMIBadge();
    final Widget classificationBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        // Higher opacity background for better contrast
        color: Color.fromRGBO(
          badgeColor.red,
          badgeColor.green,
          badgeColor.blue,
          0.2, // Increased from 0.1 to 0.2 for better visibility
        ),
        borderRadius: BorderRadius.circular(12),
        // Add a subtle border for definition
        border: Border.all(
          color: Color.fromRGBO(
            badgeColor.red,
            badgeColor.green,
            badgeColor.blue,
            0.5, // Semi-opaque border for definition
          ),
          width: 1,
        ),
      ),
      child: Text(
        widget.classification,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          // Darker text color for better contrast
          color: Color.fromRGBO(
            badgeColor.red ~/ 2,
            badgeColor.green ~/ 2,
            badgeColor.blue ~/ 2,
            1.0, // Make text darker than the badge color
          ),
        ),
      ),
    );

    return MasterWidget(
      title: 'Body Mass Index',
      icon: Icons.monitor_weight_rounded,
      trailing: MasterWidget.createInfoButton(
        onPressed: _showBMIInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        // Reduced vertical padding to 8px
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // BMI numerical value - without unit
              Text(
                widget.bmiValue?.toStringAsFixed(1) ?? '0.0',
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Standard text color as requested
                ),
              ),
              
              // Classification badge - reduced spacing
              const SizedBox(height: 4),
              classificationBadge,
            ],
          ),
        ),
      ),
    );
  }
}