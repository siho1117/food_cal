import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';

class BodyFatPercentageWidget extends StatelessWidget {
  final double? bodyFatPercentage;
  final String classification;
  final bool isEstimated;

  const BodyFatPercentageWidget({
    super.key,
    required this.bodyFatPercentage,
    required this.classification,
    this.isEstimated = true,
  });

  // Get color based on body fat classification
  Color _getColorForBodyFat() {
    if (bodyFatPercentage == null) return Colors.grey.shade400;

    switch (classification.toLowerCase()) {
      case 'essential': return const Color(0xFF4299E1);   // Blue
      case 'athletic': return const Color(0xFF48BB78);    // Green
      case 'fitness': return const Color(0xFF68D391);     // Light Green
      case 'average': return const Color(0xFFF6E05E);     // Yellow
      case 'above avg': return const Color(0xFFED8936);   // Orange
      case 'obese': return const Color(0xFFF56565);       // Red
      default: return Colors.grey.shade400;
    }
  }
  
  void _showBodyFatInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.s),
        ),
        title: Text(
          'About Body Fat', 
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
              'Body Fat percentage is the total mass of fat divided by total body mass. Essential fat is necessary for health, while storage fat accumulates when excess energy is consumed.',
              style: AppTextStyles.getBodyStyle(),
            ),
            SizedBox(height: Dimensions.s),
            Text(
              'Body Fat Categories:',
              style: AppTextStyles.getBodyStyle().copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: Dimensions.xs),
            _buildCategory('Essential', 'Men: 3-5%, Women: 10-13%', const Color(0xFF4299E1)),
            _buildCategory('Athletic', 'Men: 6-13%, Women: 14-20%', const Color(0xFF48BB78)),
            _buildCategory('Fitness', 'Men: 14-17%, Women: 21-24%', const Color(0xFF68D391)),
            _buildCategory('Average', 'Men: 18-25%, Women: 25-31%', const Color(0xFFF6E05E)),
            _buildCategory('Above Avg', 'Men: 26-30%, Women: 32-37%', const Color(0xFFED8936)),
            _buildCategory('Obese', 'Men: 31%+, Women: 38%+', const Color(0xFFF56565)),
            SizedBox(height: Dimensions.s),
            if (isEstimated)
              Container(
                padding: EdgeInsets.all(Dimensions.xs),
                decoration: BoxDecoration(
                  color: const Color(0xFF4299E1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.xxs),
                ),
                child: Text(
                  'Note: This is an estimated value based on BMI. For more accurate measurements, consider specialized tools like skinfold calipers or DEXA scans.',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
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
            style: AppTextStyles.getBodyStyle().copyWith(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyFatColor = _getColorForBodyFat();

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
                      Icons.accessibility_new_rounded,
                      size: Dimensions.m,
                      color: bodyFatColor,
                    ),
                    SizedBox(width: Dimensions.xs),
                    Text(
                      'Body Fat %',
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
                  onPressed: () => _showBodyFatInfoDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey[500],
                ),
              ],
            ),
            
            SizedBox(height: Dimensions.m),
            
            // Body fat value section
            Center(
              child: Column(
                children: [
                  // Body fat value 
                  Text(
                    bodyFatPercentage?.toStringAsFixed(1) ?? '--',
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 50,
                      fontWeight: FontWeight.bold,
                      color: bodyFatColor,
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.xxs),
                  
                  // Classification and estimated tag
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimensions.m, 
                          vertical: Dimensions.xs,
                        ),
                        decoration: BoxDecoration(
                          color: bodyFatColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(Dimensions.m),
                        ),
                        child: Text(
                          classification.toUpperCase(),
                          style: AppTextStyles.getSubHeadingStyle().copyWith(
                            fontSize: Dimensions.getTextSize(context, size: TextSize.small),
                            fontWeight: FontWeight.bold,
                            color: bodyFatColor,
                          ),
                        ),
                      ),
                      
                      if (isEstimated) ...[
                        SizedBox(width: Dimensions.xs),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimensions.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(Dimensions.xs),
                          ),
                          child: Text(
                            'EST',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  
                  SizedBox(height: Dimensions.m),
                  
                  // Visual scale representation
                  if (bodyFatPercentage != null) ...[
                    Container(
                      width: double.infinity,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.xxs),
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4299E1),  // Blue - Essential
                            Color(0xFF48BB78),  // Green - Athletic
                            Color(0xFF68D391),  // Light Green - Fitness
                            Color(0xFFF6E05E),  // Yellow - Average
                            Color(0xFFED8936),  // Orange - Above Avg
                            Color(0xFFF56565),  // Red - Obese
                          ],
                          stops: [0.1, 0.25, 0.4, 0.6, 0.8, 1.0],
                        ),
                      ),
                    ),
                    
                    // Indicator position
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 20,
                        ),
                        Positioned(
                          // Calculate position based on body fat percentage
                          // This is a simplified calculation, adjust for your needs
                          left: _calculateIndicatorPosition(context),
                          top: -4,
                          child: Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: bodyFatColor,
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
                    
                    // Scale labels for body fat ranges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('5%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('15%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('25%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        Text('35%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
  
  // Helper method to calculate the position of the indicator on the scale
  double _calculateIndicatorPosition(BuildContext context) {
    if (bodyFatPercentage == null) return 0;
    
    // Get available width
    final width = MediaQuery.of(context).size.width - (Dimensions.m * 2) - 32; // Adjust for padding
    
    // Calculate position based on body fat percentage
    // Scale from 0-50% body fat to 0-width position
    final position = (bodyFatPercentage! / 50.0) * width;
    
    // Clamp position to stay within the widget
    return position.clamp(0, width - 16); // Subtract indicator width
  }
}