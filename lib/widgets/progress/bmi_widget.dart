import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';

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
    if (bmiValue == null) return Colors.grey.shade400;

    if (bmiValue! < 18.5) return const Color(0xFF4299E1);   // Blue - Underweight
    if (bmiValue! < 25.0) return const Color(0xFF48BB78);   // Green - Normal
    if (bmiValue! < 30.0) return const Color(0xFFED8936);   // Orange - Overweight
    return const Color(0xFFF56565);                         // Red - Obese
  }
  
  void _showBMIInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.s),
        ),
        title: Text(
          'About BMI', 
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Body Mass Index (BMI) is a value derived from weight and height.',
              style: AppTextStyles.getBodyStyle(),
            ),
            SizedBox(height: Dimensions.s),
            _buildCategory('Underweight', 'Below 18.5', const Color(0xFF4299E1)),
            _buildCategory('Normal', '18.5 - 24.9', const Color(0xFF48BB78)),
            _buildCategory('Overweight', '25.0 - 29.9', const Color(0xFFED8936)),
            _buildCategory('Obese', '30.0 and above', const Color(0xFFF56565)),
          ],
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

  Widget _buildCategory(String name, String range, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: Dimensions.xxs),
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
          SizedBox(width: Dimensions.xs),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.getBodyStyle().copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            range,
            style: AppTextStyles.getBodyStyle(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmiColor = _getColorForBMI();

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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monitor_weight_rounded,
                      size: Dimensions.m,
                      color: bmiColor,
                    ),
                    SizedBox(width: Dimensions.xs),
                    Text(
                      'BMI',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: Dimensions.getTextSize(context, size: TextSize.medium),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline_rounded, 
                    size: Dimensions.getIconSize(context, size: IconSize.small),
                  ),
                  onPressed: () => _showBMIInfoDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey[500],
                ),
              ],
            ),
            
            SizedBox(height: Dimensions.m),
            
            // BMI value section
            Center(
              child: Column(
                children: [
                  // BMI value 
                  Text(
                    bmiValue?.toStringAsFixed(1) ?? '--',
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: bmiColor,
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.xxs),
                  
                  // Classification
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.m, 
                      vertical: Dimensions.xs,
                    ),
                    decoration: BoxDecoration(
                      color: bmiColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(Dimensions.m),
                    ),
                    child: Text(
                      classification.toUpperCase(),
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: Dimensions.getTextSize(context, size: TextSize.small),
                        fontWeight: FontWeight.bold,
                        color: bmiColor,
                      ),
                    ),
                  ),
                  
                  if (bmiValue != null) ...[
                    SizedBox(height: Dimensions.m),
                    
                    // Simple scale visualization
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.xxs),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4299E1),  // Blue
                            Color(0xFF48BB78),  // Green
                            Color(0xFFED8936),  // Orange
                            Color(0xFFF56565),  // Red
                          ],
                          stops: [0.15, 0.4, 0.65, 0.85],
                        ),
                      ),
                    ),
                    
                    // Indicator
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                        ),
                        Positioned(
                          left: ((bmiValue! - 16) / 24 * MediaQuery.of(context).size.width * 0.8)
                              .clamp(0, MediaQuery.of(context).size.width),
                          top: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: bmiColor,
                                width: 3,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: Dimensions.xs),
                    
                    // Scale labels
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('16', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('25', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('40', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}