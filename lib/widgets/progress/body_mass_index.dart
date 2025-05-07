import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';

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

class _BMIWidgetState extends State<BMIWidget>
    with SingleTickerProviderStateMixin {
      
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BMIWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bmiValue != widget.bmiValue || 
        oldWidget.classification != widget.classification) {
      // Reset and restart animation for updated values
      _animationController.reset();
      _animationController.forward();
    }
  }

  // Get appropriate color based on BMI classification
  Color _getColorForBMI() {
    if (widget.bmiValue == null) return Colors.grey;

    if (widget.bmiValue! < 18.5) {
      return AppTheme.goldAccent;     // Gold/Yellow for Underweight
    } else if (widget.bmiValue! < 25) {
      return AppTheme.primaryBlue;    // Primary blue for Normal
    } else if (widget.bmiValue! < 30) {
      return AppTheme.coralAccent;    // Coral for Overweight
    } else {
      return AppTheme.accentColor;    // Burgundy for Obese
    }
  }
  
  // Calculate position on the BMI scale (0.0 to 1.0)
  double _getBMIPosition() {
    if (widget.bmiValue == null) return 0.5; // Default to center
    
    // Map BMI range (15-40) to position (0.0-1.0)
    final normalizedPosition = (widget.bmiValue! - 15) / 25;
    return normalizedPosition.clamp(0.0, 1.0);
  }
  
  // Get descriptive text based on BMI classification
  String _getBMIDescription() {
    if (widget.bmiValue == null) return "No data available";
    
    if (widget.bmiValue! < 18.5) {
      return "May indicate undernourishment";
    } else if (widget.bmiValue! < 25) {
      return "Healthy weight range";
    } else if (widget.bmiValue! < 30) {
      return "Higher risk of health issues";
    } else {
      return "Increased health risk";
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getColorForBMI();
    final bmiPosition = _getBMIPosition();
    final description = _getBMIDescription();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          stops: const [0.7, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with styled background
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.02),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.monitor_weight_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Body Mass Index',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, 
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.classification,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // BMI value display
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Center(
              child: Column(
                children: [
                  // Animated BMI value
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final displayedValue = widget.bmiValue != null 
                        ? (widget.bmiValue! * _progressAnimation.value).toStringAsFixed(1)
                        : "—";
                      return Text(
                        displayedValue,
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      );
                    },
                  ),
                  
                  // "kg/m²" label
                  Text(
                    'kg/m²',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // BMI Range visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BMI Range bar
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [
                        AppTheme.goldAccent,     // Underweight
                        AppTheme.primaryBlue,    // Normal
                        AppTheme.coralAccent,    // Overweight
                        AppTheme.accentColor,    // Obese
                      ],
                      stops: [0.15, 0.4, 0.65, 0.9],
                    ),
                  ),
                ),
                
                // Position indicator on the bar
                if (widget.bmiValue != null)
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Container(
                        margin: EdgeInsets.only(
                          left: (MediaQuery.of(context).size.width - 64) * 
                              bmiPosition * _progressAnimation.value,
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
                                widget.bmiValue!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                
                const SizedBox(height: 8),
                
                // Range labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRangeLabel("< 18.5", "Underweight", AppTheme.goldAccent),
                    _buildRangeLabel("18.5-25", "Normal", AppTheme.primaryBlue),
                    _buildRangeLabel("25-30", "Overweight", AppTheme.coralAccent),
                    _buildRangeLabel("> 30", "Obese", AppTheme.accentColor),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description box
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        widget.bmiValue != null && widget.bmiValue! < 25 && widget.bmiValue! >= 18.5
                            ? Icons.check_circle_outline
                            : Icons.info_outline,
                        color: primaryColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRangeLabel(String value, String label, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}