import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';

class BodyFatPercentageWidget extends StatefulWidget {
  final double? bodyFatPercentage;
  final String classification;
  final bool isEstimated;

  const BodyFatPercentageWidget({
    Key? key,
    required this.bodyFatPercentage,
    required this.classification,
    this.isEstimated = true,
  }) : super(key: key);

  @override
  State<BodyFatPercentageWidget> createState() => _BodyFatPercentageWidgetState();
}

class _BodyFatPercentageWidgetState extends State<BodyFatPercentageWidget> {
  // Get appropriate color based on body fat classification
  Color _getColorForBodyFat() {
    if (widget.bodyFatPercentage == null) return Colors.grey;

    switch (widget.classification.toLowerCase()) {
      case 'essential':
        return const Color(0xFF90CAF9);  // Light Blue
      case 'athletic':
        return const Color(0xFF4CAF50);  // Green
      case 'fitness':
        return const Color(0xFF8BC34A);  // Light Green
      case 'average':
        return const Color(0xFFFFC107);  // Amber
      case 'above avg':
        return const Color(0xFFFF9800);  // Orange
      case 'obese':
        return const Color(0xFFF44336);  // Red
      default:
        return Colors.grey;
    }
  }

  void _showBodyFatInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: _getColorForBodyFat(),
            ),
            const SizedBox(width: 8),
            const Text('About Body Fat'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Body Fat Definition
              const Text(
                'Body fat percentage is the total mass of fat divided by total body mass. Essential fat is necessary for health, while storage fat accumulates when excess energy is consumed.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // Current Value
              RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    const TextSpan(text: 'Your body fat: ', style: TextStyle(fontWeight: FontWeight.bold)),
                    TextSpan(
                      text: '${widget.bodyFatPercentage?.toStringAsFixed(1) ?? "Unknown"}% ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getColorForBodyFat(),
                      ),
                    ),
                    TextSpan(text: '(${widget.classification})'),
                    if (widget.isEstimated)
                      const TextSpan(
                        text: ' - Estimated',
                        style: TextStyle(fontStyle: FontStyle.italic, fontSize: 14),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Body Fat Categories
              const Text(
                'Body Fat Categories (Adult):',
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
                  children: [
                    _buildCategoryRow('Men', 'Women', isBold: true),
                    const Divider(),
                    _buildCategoryRow('3-5%', '10-13%', label: 'Essential', color: const Color(0xFF90CAF9)),
                    _buildCategoryRow('6-13%', '14-20%', label: 'Athletic', color: const Color(0xFF4CAF50)),
                    _buildCategoryRow('14-17%', '21-24%', label: 'Fitness', color: const Color(0xFF8BC34A)),
                    _buildCategoryRow('18-25%', '25-31%', label: 'Average', color: const Color(0xFFFFC107)),
                    _buildCategoryRow('26-30%', '32-37%', label: 'Above Average', color: const Color(0xFFFF9800)),
                    _buildCategoryRow('31%+', '38%+', label: 'Obese', color: const Color(0xFFF44336)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Estimation method
              if (widget.isEstimated) ...[
                const Text(
                  'Estimation Method:',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This body fat percentage is estimated using the Deurenberg equation based on BMI, age, and gender. For more accurate measurements, consider using specialized tools like calipers, bioelectrical impedance scales, or DEXA scans.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
              ],
              
              // Health implications
              const Text(
                'Health Implications:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                'Very low body fat can affect hormone production and immunity, while high body fat increases risk for cardiovascular disease, diabetes, and other health issues. A healthy range balances performance and health.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: _getColorForBodyFat(),
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getColorForBodyFat();
    
    // Create classification badge
    final Widget classificationBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          primaryColor.red,
          primaryColor.green,
          primaryColor.blue,
          0.2, // Increased from 0.1 for better visibility
        ),
        borderRadius: BorderRadius.circular(12),
        // Add a subtle border for definition
        border: Border.all(
          color: Color.fromRGBO(
            primaryColor.red,
            primaryColor.green,
            primaryColor.blue,
            0.5, // Semi-opaque border for definition
          ),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.classification,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              // Darker text color for better contrast
              color: Color.fromRGBO(
                primaryColor.red ~/ 2,
                primaryColor.green ~/ 2,
                primaryColor.blue ~/ 2,
                1.0, // Make text darker than the badge color
              ),
            ),
          ),
          if (widget.isEstimated) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Est',
                style: TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
          ],
        ],
      ),
    );

    // Use the updated MasterWidget without icon
    return MasterWidget(
      title: 'Body Fat %',
      icon: Icons.accessibility_new, // Required for backward compatibility but not displayed
      trailing: MasterWidget.createInfoButton(
        onPressed: _showBodyFatInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        // Reduced vertical padding to 8px, matching BMI widget
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Body Fat value with percentage sign - simplified display
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // Value in reduced font size (from 36 to 30)
                  Text(
                    widget.bodyFatPercentage?.toStringAsFixed(1) ?? '0.0',
                    style: TextStyle(
                      fontSize: 30, // Reduced from 36
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // Standard text color
                    ),
                  ),
                  
                  // Percentage sign
                  Text(
                    ' %',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              
              // Small space before classification badge
              const SizedBox(height: 4),
              
              // Classification badge
              classificationBadge,
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCategoryRow(String men, String women, {String? label, Color? color, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Men value (30%)
          SizedBox(
            width: 60,
            child: Text(
              men,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          
          // Women value (30%)
          SizedBox(
            width: 60,
            child: Text(
              women,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          
          // Label (40%)
          if (label != null) ...[
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: [
                  if (color != null) ...[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}