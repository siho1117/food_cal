import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';

class BodyFatPercentageWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final Color bodyFatColor = _getBodyFatColor();
    
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Body Fat %',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              InkWell(
                onTap: () => _showInfoDialog(context),
                child: Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bodyFatPercentage?.toStringAsFixed(1) ?? '--',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: bodyFatColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: bodyFatColor.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: bodyFatColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  classification,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: bodyFatColor,
                  ),
                ),
              ),
              if (isEstimated) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Estimated',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
  
  Color _getBodyFatColor() {
    if (bodyFatPercentage == null) return Colors.grey;

    switch (classification.toLowerCase()) {
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
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Body Fat Percentage',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _getBodyFatColor(),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isEstimated) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.blue[800]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This is an estimated value based on your BMI, age, and gender.',
                          style: TextStyle(fontSize: 12, color: Colors.blue[800]),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              
              Text(
                'Body Fat Categories',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              // Simple categories table
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1.5),
                  1: FlexColumnWidth(1.0),
                  2: FlexColumnWidth(1.0),
                },
                children: [
                  _buildTableRow('Category', 'Men', 'Women', isHeader: true),
                  _buildTableRow('Essential', '3-5%', '10-13%', color: const Color(0xFF90CAF9)),
                  _buildTableRow('Athletic', '6-13%', '14-20%', color: const Color(0xFF4CAF50)),
                  _buildTableRow('Fitness', '14-17%', '21-24%', color: const Color(0xFF8BC34A)),
                  _buildTableRow('Average', '18-25%', '25-31%', color: const Color(0xFFFFC107)),
                  _buildTableRow('Above Avg', '26-30%', '32-37%', color: const Color(0xFFFF9800)),
                  _buildTableRow('Obese', '31%+', '38%+', color: const Color(0xFFF44336)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  TableRow _buildTableRow(String label, String men, String women, {bool isHeader = false, Color? color}) {
    final textStyle = TextStyle(
      fontSize: 14,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
      color: isHeader ? Colors.black : color ?? Colors.black,
    );
    
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(label, style: textStyle),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(men, style: textStyle, textAlign: TextAlign.center),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(women, style: textStyle, textAlign: TextAlign.center),
        ),
      ],
    );
  }
}