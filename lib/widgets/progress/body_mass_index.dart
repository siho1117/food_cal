import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/components/value_builder.dart';
import '../../config/components/box_decorations.dart';
import '../../config/widgets/master_widget.dart';

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
    
    // Setup animations using the animation helper
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _progressAnimation = AnimationHelpers.createProgressAnimation(
      controller: _animationController,
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

    return MasterWidget(
      title: 'Body Mass Index',
      icon: Icons.monitor_weight_rounded,
      accentColor: AppTheme.primaryBlue,
      badge: ValueBuilder.buildBadge(
        text: widget.classification,
        color: primaryColor,
      ),
      animate: true,
      animationType: WidgetAnimationType.slideUp,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BMI value display
          Center(
            child: Column(
              children: [
                // Animated BMI value
                AnimationHelpers.buildAnimatedCounter(
                  animation: _progressAnimation,
                  targetValue: widget.bmiValue ?? 0,
                  style: AppTextStyles.getNumericStyle().copyWith(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  decimalPlaces: 1,
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
          
          const SizedBox(height: 16),
          
          // BMI Range visualization
          Column(
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
                        left: (MediaQuery.of(context).size.width - 80) * 
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
              
              // Description box using BoxDecorations
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecorations.infoBox(
                  color: primaryColor,
                  opacity: 0.05,
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