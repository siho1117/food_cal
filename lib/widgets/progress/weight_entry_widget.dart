import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';

class WeightEntryWidget extends StatelessWidget {
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightEntered;

  const WeightEntryWidget({
    Key? key,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightEntered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.s),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.monitor_weight_rounded,
                  size: Dimensions.m,
                  color: AppTheme.primaryBlue,
                ),
                SizedBox(width: Dimensions.xs),
                Text(
                  'Current Weight',
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: Dimensions.getTextSize(context, size: TextSize.medium),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: Dimensions.m),
            
            // Current weight display
            Center(
              child: Text(
                _formatWeight(currentWeight),
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 50,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ),
            
            SizedBox(height: Dimensions.s),
            
            // Add new weight button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _showWeightEntryDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: Dimensions.s),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Dimensions.xs),
                  ),
                ),
                child: Text(
                  'Add New Weight',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Format weight with appropriate unit
  String _formatWeight(double? weight) {
    if (weight == null) {
      return 'No Data';
    }
    
    // Display in kg or lbs based on user preference
    final displayWeight = isMetric ? weight : weight * 2.20462;
    final unit = isMetric ? 'kg' : 'lbs';
    
    return '${displayWeight.toStringAsFixed(1)} $unit';
  }
  
  // Show dialog to enter new weight
  void _showWeightEntryDialog(BuildContext context) {
    // Start with current weight or default
    double newWeight = currentWeight ?? (isMetric ? 70.0 : 154.0);
    bool localIsMetric = isMetric;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Enter Weight',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Weight input field
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight',
                  suffixText: localIsMetric ? 'kg' : 'lbs',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(Dimensions.xs),
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    try {
                      newWeight = double.parse(value);
                    } catch (e) {
                      // Ignore invalid input
                    }
                  }
                },
                controller: TextEditingController(
                  text: (localIsMetric ? newWeight : newWeight * 2.20462).toStringAsFixed(1)
                ),
              ),
              
              SizedBox(height: Dimensions.s),
              
              // Unit toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'lb',
                    style: TextStyle(
                      color: !localIsMetric ? Colors.black : Colors.grey,
                      fontWeight: !localIsMetric ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  Switch(
                    value: localIsMetric,
                    onChanged: (value) {
                      setState(() {
                        // Convert weight when changing units
                        if (value) {
                          // Convert lbs to kg
                          newWeight = newWeight / 2.20462;
                        } else {
                          // Convert kg to lbs
                          newWeight = newWeight * 2.20462;
                        }
                        localIsMetric = value;
                      });
                    },
                    activeColor: AppTheme.primaryBlue,
                  ),
                  Text(
                    'kg',
                    style: TextStyle(
                      color: localIsMetric ? Colors.black : Colors.grey,
                      fontWeight: localIsMetric ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Always convert to metric for storage
                final metricWeight = localIsMetric ? newWeight : newWeight / 2.20462;
                onWeightEntered(metricWeight, localIsMetric);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}