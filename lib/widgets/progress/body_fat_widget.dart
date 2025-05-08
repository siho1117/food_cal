import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/builders/value_builder.dart';
import '../../config/layouts/card_layout.dart';
import '../../config/decorations/box_decorations.dart';

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

class _BodyFatPercentageWidgetState extends State<BodyFatPercentageWidget>
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
  void didUpdateWidget(BodyFatPercentageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.bodyFatPercentage != widget.bodyFatPercentage || 
        oldWidget.classification != widget.classification) {
      // Reset and restart animation for updated values
      _animationController.reset();
      _animationController.forward();
    }
  }

  // Get appropriate color based on body fat classification
  Color _getColorForBodyFat() {
    if (widget.bodyFatPercentage == null) return Colors.grey;

    switch (widget.classification.toLowerCase()) {
      case 'essential':
        return AppTheme.goldAccent;
      case 'athletic':
      case 'fitness':
        return AppTheme.primaryBlue;
      case 'average':
        return AppTheme.mintAccent;
      case 'above avg':
        return AppTheme.coralAccent;
      case 'obese':
        return AppTheme.accentColor;
      default:
        return Colors.grey;
    }
  }
  
  // Get corresponding icon for the body fat classification
  IconData _getBodyFatIcon() {
    if (widget.bodyFatPercentage == null) return Icons.help_outline;
    
    switch (widget.classification.toLowerCase()) {
      case 'essential':
        return Icons.monitor_heart_outlined;
      case 'athletic':
        return Icons.fitness_center;
      case 'fitness':
        return Icons.directions_run;
      case 'average':
        return Icons.people_outline;
      case 'above avg':
        return Icons.trending_up;
      case 'obese':
        return Icons.priority_high;
      default:
        return Icons.help_outline;
    }
  }
  
  // Get appropriate health message for the body fat percentage
  String _getBodyFatMessage() {
    if (widget.bodyFatPercentage == null) return "No data available";
    
    switch (widget.classification.toLowerCase()) {
      case 'essential':
        return "Minimum needed for basic health functions";
      case 'athletic':
        return "Typical for competitive athletes";
      case 'fitness':
        return "Healthy and fit range";
      case 'average':
        return "Common in general population";
      case 'above avg':
        return "Consider exercise and diet improvements";
      case 'obese':
        return "Increased health risks, consult professional";
      default:
        return "Body composition classification";
    }
  }
  
  // Calculate position on the body fat scale (0.0 to 1.0)
  double _getBodyFatPosition() {
    if (widget.bodyFatPercentage == null) return 0.5; // Default to center
    
    // Map body fat percentage range (3-50%) to position (0.0-1.0)
    final normalizedPosition = (widget.bodyFatPercentage! - 3) / 47.0;
    return normalizedPosition.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getColorForBodyFat();
    final bodyFatIcon = _getBodyFatIcon();
    final healthMessage = _getBodyFatMessage();
    final bodyFatPosition = _getBodyFatPosition();

    return CardLayout.card(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecorations.iconContainer(
                  color: AppTheme.primaryBlue,
                ),
                child: Icon(
                  Icons.accessibility_new,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Body Fat Percentage',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              if (widget.isEstimated)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Est.',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
            ],
          ),
          ValueBuilder.buildBadge(
            text: widget.classification,
            color: primaryColor,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Body Fat value display
          Center(
            child: Column(
              children: [
                // Animated Body Fat value with percentage sign
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    AnimationHelpers.buildAnimatedCounter(
                      animation: _progressAnimation,
                      targetValue: widget.bodyFatPercentage ?? 0,
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                      decimalPlaces: 1,
                    ),
                    Text(
                      '%',
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                
                // "body fat" label
                Text(
                  'body fat',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
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
                  gradient: LinearGradient(
                    colors: const [
                      AppTheme.goldAccent,    // Essential
                      AppTheme.primaryBlue,   // Athletic 
                      AppTheme.mintAccent,    // Fitness
                      Colors.grey,            // Average
                      AppTheme.coralAccent,   // Above Avg
                      AppTheme.accentColor,   // Obese
                    ],
                    stops: const [0.05, 0.15, 0.25, 0.40, 0.60, 0.80],
                  ),
                ),
              ),
              
              // Position indicator on the bar
              if (widget.bodyFatPercentage != null)
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.only(
                        left: (MediaQuery.of(context).size.width - 64) * 
                            bodyFatPosition * _progressAnimation.value,
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
                              widget.bodyFatPercentage!.toStringAsFixed(1) + '%',
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
                  _buildRangeLabel("3%", "Essential", AppTheme.goldAccent),
                  _buildRangeLabel("15%", "Athletic", AppTheme.primaryBlue),
                  _buildRangeLabel("25%", "Fitness", AppTheme.mintAccent),
                  _buildRangeLabel("32%", "Average", Colors.grey[600]!),
                  _buildRangeLabel(">32%", "High", AppTheme.coralAccent),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Description box with BoxDecorations.infoBox
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecorations.infoBox(
                  color: primaryColor,
                  opacity: 0.05,
                ),
                child: Row(
                  children: [
                    Icon(
                      bodyFatIcon,
                      color: primaryColor,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        healthMessage,
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