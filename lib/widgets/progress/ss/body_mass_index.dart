import 'package:flutter/material.dart';

class BMIWidget extends StatelessWidget {
  final double? bmiValue;
  final String classification;

  const BMIWidget({
    Key? key,
    required this.bmiValue,
    required this.classification,
  }) : super(key: key);

  // Get color based on BMI classification
  Color _getColorForBMI() {
    if (bmiValue == null) return Colors.grey;

    if (bmiValue! < 18.5) return Colors.blue;
    if (bmiValue! < 25.0) return Colors.green;
    if (bmiValue! < 30.0) return Colors.orange;
    return Colors.red;
  }

  void _showBMIInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About BMI'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Mass Index (BMI) is a value derived from the weight and height of a person.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text('BMI Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildCategory('Underweight', 'Below 18.5', Colors.blue),
            _buildCategory('Normal', '18.5 - 24.9', Colors.green),
            _buildCategory('Overweight', '25.0 - 29.9', Colors.orange),
            _buildCategory('Obese', '30.0 and above', Colors.red),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(String name, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(range),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmiColor = _getColorForBMI();

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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BMI',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, size: 18),
                onPressed: () => _showBMIInfoDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // BMI value
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                bmiValue?.toStringAsFixed(1) ?? '--',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: bmiColor,
                ),
              ),
            ],
          ),
          
          // Classification
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: bmiColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              classification,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: bmiColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}