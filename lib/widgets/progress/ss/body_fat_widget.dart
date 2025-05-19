import 'package:flutter/material.dart';

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

  // Get color based on body fat classification
  Color _getColorForBodyFat() {
    if (bodyFatPercentage == null) return Colors.grey;

    switch (classification.toLowerCase()) {
      case 'essential':
        return Colors.blue;
      case 'athletic':
        return Colors.green;
      case 'fitness':
        return Colors.lightGreen;
      case 'average':
        return Colors.orange;
      case 'above avg':
        return Colors.deepOrange;
      case 'obese':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _showBodyFatInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Body Fat'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body fat percentage is the total mass of fat divided by total body mass. Essential fat is necessary for health, while storage fat accumulates when excess energy is consumed.',
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 16),
            Text('Body Fat Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            _buildCategory('Essential', 'Men: 3-5%, Women: 10-13%', Colors.blue),
            _buildCategory('Athletic', 'Men: 6-13%, Women: 14-20%', Colors.green),
            _buildCategory('Fitness', 'Men: 14-17%, Women: 21-24%', Colors.lightGreen),
            _buildCategory('Average', 'Men: 18-25%, Women: 25-31%', Colors.orange),
            _buildCategory('Above Avg', 'Men: 26-30%, Women: 32-37%', Colors.deepOrange),
            _buildCategory('Obese', 'Men: 31%+, Women: 38%+', Colors.red),
            SizedBox(height: 16),
            if (isEstimated)
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue.withOpacity(0.1),
                child: Text(
                  'Note: This is an estimated value based on BMI. For more accurate measurements, consider specialized tools.',
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ),
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
          Text(range, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyFatColor = _getColorForBodyFat();

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
                'Body Fat %',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, size: 18),
                onPressed: () => _showBodyFatInfoDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Body fat value
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
              SizedBox(width: 4),
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
          
          // Classification
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
                SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Est',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
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
}