import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';

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
                      Icons.accessibility_new,
                      color: AppTheme.primaryBlue,
                      size: 20,
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
          
          // Body Fat value display
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Center(
              child: Column(
                children: [
                  // Animated Body Fat value
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final displayedValue = widget.bodyFatPercentage != null 
                        ? (widget.bodyFatPercentage! * _progressAnimation.value).toStringAsFixed(1)
                        : "—";
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            displayedValue,
                            style: AppTextStyles.getNumericStyle().copyWith(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
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
                      );
                    },
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
          ),
          
          // Body Fat Range visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
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