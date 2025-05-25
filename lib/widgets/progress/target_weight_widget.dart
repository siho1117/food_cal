// lib/widgets/progress/target_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../utils/formula.dart';
import '../../providers/progress_data.dart';

class TargetWeightWidget extends StatelessWidget {
  const TargetWeightWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressData>(
      builder: (context, progressData, child) {
        final targetWeight = progressData.userProfile?.goalWeight;
        final currentWeight = progressData.currentWeight;
        final isMetric = progressData.isMetric;
        
        // Calculate progress
        double? progressValue;
        String progressText = '';
        String remainingText = '';
        Color progressColor = Colors.grey;
        
        if (targetWeight != null && currentWeight != null) {
          // Calculate progress percentage
          progressValue = Formula.calculateGoalProgress(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
          );
          
          // Calculate remaining weight
          final remaining = Formula.getRemainingWeightToGoal(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
          );
          
          // Get direction text
          remainingText = Formula.getWeightChangeDirectionText(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            isMetric: isMetric,
          );
          
          // Format progress as percentage
          progressText = '${(progressValue * 100).round()}%';
          
          // Set color based on progress
          if (progressValue >= 0.9) {
            progressColor = Colors.green[600]!;
          } else if (progressValue >= 0.6) {
            progressColor = Colors.orange[400]!;
          } else if (progressValue >= 0.3) {
            progressColor = AppTheme.goldAccent;
          } else {
            progressColor = AppTheme.coralAccent;
          }
        }
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Dimensions.s),
          ),
          child: InkWell(
            onTap: () => _showTargetWeightDialog(context, progressData),
            borderRadius: BorderRadius.circular(Dimensions.s),
            child: Padding(
              padding: EdgeInsets.all(Dimensions.m),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.flag,
                            size: Dimensions.m,
                            color: targetWeight != null ? progressColor : Colors.grey[400],
                          ),
                          SizedBox(width: Dimensions.xs),
                          Text(
                            'Target Weight',
                            style: AppTextStyles.getSubHeadingStyle().copyWith(
                              fontSize: Dimensions.getTextSize(context, size: TextSize.medium),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Icon(
                        Icons.edit,
                        size: Dimensions.getIconSize(context, size: IconSize.small),
                        color: Colors.grey[500],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: Dimensions.m),
                  
                  // Content based on whether a target is set
                  targetWeight == null
                      ? _buildEmptyState()
                      : _buildTargetContent(
                          context,
                          targetWeight,
                          isMetric,
                          progressValue,
                          progressText,
                          remainingText,
                          progressColor,
                        ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Set a target weight to track progress',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTargetContent(
    BuildContext context,
    double targetWeight,
    bool isMetric,
    double? progressValue,
    String progressText,
    String remainingText,
    Color progressColor,
  ) {
    // Format weight with proper units
    final weightValue = isMetric ? targetWeight : targetWeight * 2.20462;
    final units = isMetric ? 'kg' : 'lbs';
    final displayWeight = '${weightValue.toStringAsFixed(1)} $units';
    
    return Column(
      children: [
        // Target weight value
        Text(
          displayWeight,
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: progressColor,
          ),
        ),
        
        SizedBox(height: Dimensions.s),
        
        // Progress indicators
        if (progressValue != null) ...[
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
              minHeight: 10,
            ),
          ),
          
          SizedBox(height: Dimensions.s),
          
          // Progress text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                progressText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                ),
              ),
            ],
          ),
          
          SizedBox(height: Dimensions.s),
          
          // Remaining weight
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: Dimensions.xs,
              horizontal: Dimensions.s,
            ),
            decoration: BoxDecoration(
              color: progressColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(Dimensions.xs),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  progressValue < 1.0 ? Icons.trending_down : Icons.check_circle,
                  size: 16,
                  color: progressColor,
                ),
                SizedBox(width: Dimensions.xs),
                Text(
                  remainingText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: progressColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  void _showTargetWeightDialog(BuildContext context, ProgressData progressData) {
    // Current values
    final isMetric = progressData.isMetric;
    double initialWeight = progressData.userProfile?.goalWeight ?? 
                          (progressData.currentWeight ?? (isMetric ? 70.0 : 154.0));
    
    // For the number pickers
    int wholeNumber;
    int decimalNumber;
    
    // Convert to display units if needed
    if (!isMetric) {
      initialWeight = initialWeight * 2.20462; // Convert kg to lbs
    }
    
    // Split into whole and decimal parts
    wholeNumber = initialWeight.floor();
    decimalNumber = ((initialWeight - wholeNumber) * 10).round();
    
    // Variables to track during dialog
    bool dialogIsMetric = isMetric;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Set Target Weight',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Unit toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'lbs',
                      style: TextStyle(
                        color: !dialogIsMetric ? Colors.black : Colors.grey,
                        fontWeight: !dialogIsMetric ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    Switch(
                      value: dialogIsMetric,
                      onChanged: (value) {
                        setState(() {
                          // Convert value when switching units
                          if (value) {
                            // Convert from lbs to kg
                            final currentValue = wholeNumber + (decimalNumber / 10);
                            final convertedValue = currentValue / 2.20462;
                            wholeNumber = convertedValue.floor();
                            decimalNumber = ((convertedValue - wholeNumber) * 10).round();
                          } else {
                            // Convert from kg to lbs
                            final currentValue = wholeNumber + (decimalNumber / 10);
                            final convertedValue = currentValue * 2.20462;
                            wholeNumber = convertedValue.floor();
                            decimalNumber = ((convertedValue - wholeNumber) * 10).round();
                          }
                          dialogIsMetric = value;
                        });
                      },
                      activeColor: AppTheme.primaryBlue,
                    ),
                    Text(
                      'kg',
                      style: TextStyle(
                        color: dialogIsMetric ? Colors.black : Colors.grey,
                        fontWeight: dialogIsMetric ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
                
                SizedBox(height: Dimensions.m),
                
                // Weight display
                Text(
                  'Select target weight',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                
                SizedBox(height: Dimensions.s),
                
                // Weight value display
                Text(
                  '$wholeNumber.$decimalNumber ${dialogIsMetric ? 'kg' : 'lbs'}',
                  style: AppTextStyles.getNumericStyle().copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                
                SizedBox(height: Dimensions.m),
                
                // Weight picker
                SizedBox(
                  height: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Whole number
                      SizedBox(
                        width: 80,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          looping: false,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              wholeNumber = index + (dialogIsMetric ? 30 : 66);
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: wholeNumber - (dialogIsMetric ? 30 : 66),
                          ),
                          children: List.generate(
                            dialogIsMetric ? 221 : 485, // Range depends on unit
                            (index) => Center(
                              child: Text(
                                dialogIsMetric ? '${index + 30}' : '${index + 66}',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Decimal point
                      const Text(
                        '.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      
                      // Decimal part
                      SizedBox(
                        width: 60,
                        child: CupertinoPicker(
                          itemExtent: 40,
                          looping: true,
                          onSelectedItemChanged: (index) {
                            setState(() {
                              decimalNumber = index;
                            });
                          },
                          scrollController: FixedExtentScrollController(
                            initialItem: decimalNumber,
                          ),
                          children: List.generate(
                            10,
                            (index) => Center(
                              child: Text(
                                '$index',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Unit
                      SizedBox(
                        width: 50,
                        child: Center(
                          child: Text(
                            dialogIsMetric ? 'kg' : 'lbs',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: Dimensions.s),
                
                // Health tip
                Container(
                  padding: EdgeInsets.all(Dimensions.xs),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(Dimensions.xxs),
                    border: Border.all(
                      color: Colors.amber[100]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb,
                        size: 16,
                        color: Colors.amber[700],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Healthy weight loss/gain is 0.5-1 kg (1-2 lbs) per week.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Combine the whole and decimal parts
                  final targetValue = wholeNumber + (decimalNumber / 10);
                  
                  // Convert to metric (kg) if needed for storage
                  final metricValue = dialogIsMetric ? targetValue : targetValue / 2.20462;
                  
                  // Update profile with new target weight
                  progressData.updateTargetWeight(metricValue);
                  
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryBlue,
                ),
                child: Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }
}