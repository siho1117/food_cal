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
  
  // Calculate position on the body fat scale (0.0 to 1.0)
  double _getBodyFatPosition() {
    if (widget.bodyFatPercentage == null) return 0.5; // Default to center
    
    // Map body fat percentage range (3-50%) to position (0.0-1.0)
    final normalizedPosition = (widget.bodyFatPercentage! - 3) / 47.0;
    return normalizedPosition.clamp(0.0, 1.0);
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
    final bodyFatPosition = _getBodyFatPosition();
    
    // Create classification badge
    final Widget classificationBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          primaryColor.red,
          primaryColor.green,
          primaryColor.blue,
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.classification,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: primaryColor,
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

    return MasterWidget(
      title: 'Body Fat %',
      icon: Icons.accessibility_new,
      trailing: MasterWidget.createInfoButton(
        onPressed: _showBodyFatInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Body Fat value display
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Body Fat value with percentage sign
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        widget.bodyFatPercentage?.toStringAsFixed(1) ?? '0.0',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      Text(
                        '%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(
                            primaryColor.red,
                            primaryColor.green,
                            primaryColor.blue,
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Classification badge
                  const SizedBox(height: 10),
                  classificationBadge,
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Body Fat Range visualization
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Body Fat Range bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF90CAF9),  // Light Blue - Essential
                        Color(0xFF4CAF50),  // Green - Athletic
                        Color(0xFF8BC34A),  // Light Green - Fitness
                        Color(0xFFFFC107),  // Amber - Average
                        Color(0xFFFF9800),  // Orange - Above Average
                        Color(0xFFF44336),  // Red - Obese
                      ],
                      stops: [0.05, 0.15, 0.25, 0.4, 0.6, 0.8],
                    ),
                  ),
                ),
                
                // Position indicator on the bar
                if (widget.bodyFatPercentage != null)
                  Container(
                    margin: EdgeInsets.only(
                      left: (MediaQuery.of(context).size.width - 80) * bodyFatPosition,
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.arrow_drop_down,
                          color: primaryColor,
                          size: 24,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, 
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${widget.bodyFatPercentage!.toStringAsFixed(1)}%',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 8),
                
                // Range labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRangeLabel("3-5%", const Color(0xFF90CAF9)),  // Essential
                    _buildRangeLabel("15%", const Color(0xFF4CAF50)),   // Athletic
                    _buildRangeLabel("25%", const Color(0xFF8BC34A)),   // Fitness
                    _buildRangeLabel("30%", const Color(0xFFFFC107)),   // Average
                    _buildRangeLabel("35%", const Color(0xFFFF9800)),   // Above Avg
                    _buildRangeLabel(">40%", const Color(0xFFF44336)),  // Obese
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRangeLabel(String value, Color color) {
    return Text(
      value,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        color: color,
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