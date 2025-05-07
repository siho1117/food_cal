import 'dart:math' as math;
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
  late Animation<double> _fadeInAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _fillAnimation;

  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    
    _fillAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeOut),
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
  
  // Calculate the fill level (0.0 to 1.0) for visualization
  double _getBodyFatFillLevel() {
    if (widget.bodyFatPercentage == null) return 0.0;
    
    // Calculate based on reasonable body fat range (3% to 50%)
    final fillLevel = widget.bodyFatPercentage! / 50.0;
    return fillLevel.clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = _getColorForBodyFat();
    final bodyFatIcon = _getBodyFatIcon();
    final healthMessage = _getBodyFatMessage();
    final fillLevel = _getBodyFatFillLevel();

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with body fat value
                Row(
                  children: [
                    // Body Fat Value section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title with estimated badge
                          Row(
                            children: [
                              Text(
                                'Body Fat Percentage',
                                style: AppTextStyles.getSubHeadingStyle().copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[700],
                                ),
                              ),
                              if (widget.isEstimated)
                                Container(
                                  margin: const EdgeInsets.only(left: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(8),
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
                          
                          const SizedBox(height: 6),
                          
                          // Body Fat Value with animation
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.bodyFatPercentage != null 
                                  ? (widget.bodyFatPercentage! * _progressAnimation.value).toStringAsFixed(1)
                                  : "—",
                                style: AppTextStyles.getNumericStyle().copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              
                              Text(
                                "%",
                                style: AppTextStyles.getNumericStyle().copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              
                              const SizedBox(width: 8),
                              
                              // Classification
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8, 
                                  vertical: 2,
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
                        ],
                      ),
                    ),
                    
                    // Body fat cylinder visualization
                    SizedBox(
                      height: 60,
                      width: 40,
                      child: CustomPaint(
                        painter: BodyFatCylinderPainter(
                          fillLevel: fillLevel * _fillAnimation.value,
                          fillColor: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Body composition visualization
                Container(
                  width: double.infinity,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      // Essential fat (gold)
                      _buildCompositionSegment(0.07, AppTheme.goldAccent, "Essential"),
                      
                      // Athletic fat (primary blue)
                      _buildCompositionSegment(0.10, AppTheme.primaryBlue, "Athletic"),
                      
                      // Fitness fat (mint green)
                      _buildCompositionSegment(0.08, AppTheme.mintAccent, "Fitness"),
                      
                      // Average fat (grey/neutral)
                      _buildCompositionSegment(0.15, Colors.grey[400]!, "Average"),
                      
                      // Above average (coral)
                      _buildCompositionSegment(0.20, AppTheme.coralAccent, "Above"),
                      
                      // Obese (burgundy)
                      _buildCompositionSegment(0.40, AppTheme.accentColor, "Obese"),
                    ],
                  ),
                ),
                
                // Body Fat indicator
                if (widget.bodyFatPercentage != null)
                  AnimatedBuilder(
                    animation: _fillAnimation,
                    builder: (context, child) {
                      // Calculate position based on body fat percentage (3-50% range)
                      double position = (widget.bodyFatPercentage! - 3) / 47.0;
                      position = position.clamp(0.0, 1.0) * _fillAnimation.value;
                      
                      return Padding(
                        padding: EdgeInsets.only(
                          left: (MediaQuery.of(context).size.width - 72) * position,
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(top: 2),
                          child: Icon(
                            Icons.arrow_drop_up,
                            color: primaryColor,
                            size: 20,
                          ),
                        ),
                      );
                    },
                  ),
                  
                // Range labels
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildRangeLabel("3%", "Essential"),
                      _buildRangeLabel("15%", "Athletes"),
                      _buildRangeLabel("25%", "Fitness"),
                      _buildRangeLabel("32%", "Average"),
                      _buildRangeLabel(">32%", "High"),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Classification description
                Container(
                  padding: const EdgeInsets.all(8),
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
        );
      },
    );
  }
  
  Widget _buildCompositionSegment(double widthPercent, Color color, String label) {
    return Container(
      width: (MediaQuery.of(context).size.width - 72) * widthPercent,
      height: 20,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.zero,
      ),
    );
  }
  
  Widget _buildRangeLabel(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
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

class BodyFatCylinderPainter extends CustomPainter {
  final double fillLevel; // 0.0 to 1.0
  final Color fillColor;
  
  BodyFatCylinderPainter({
    required this.fillLevel,
    required this.fillColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double cornerRadius = width * 0.2;
    
    // Create paths for cylinder
    final cylinderPath = Path()
      ..moveTo(0, cornerRadius)
      ..arcTo(
        Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
        math.pi, 
        -math.pi / 2, 
        false
      )
      ..lineTo(width - cornerRadius, 0)
      ..arcTo(
        Rect.fromLTWH(width - cornerRadius * 2, 0, cornerRadius * 2, cornerRadius * 2),
        -math.pi / 2, 
        -math.pi / 2, 
        false
      )
      ..lineTo(width, height - cornerRadius)
      ..arcTo(
        Rect.fromLTWH(width - cornerRadius * 2, height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        0, 
        -math.pi / 2, 
        false
      )
      ..lineTo(cornerRadius, height)
      ..arcTo(
        Rect.fromLTWH(0, height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        math.pi / 2, 
        -math.pi / 2, 
        false
      )
      ..close();
    
    // Draw cylinder outline
    final outlinePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    
    canvas.drawPath(cylinderPath, outlinePaint);
    
    // Calculate fill height based on level
    final fillHeight = height * (1 - fillLevel);
    
    // Create fill path (only up to the fill level)
    final fillPath = Path()
      ..moveTo(0, fillHeight > cornerRadius ? fillHeight : cornerRadius)
      ..lineTo(0, height - cornerRadius)
      ..arcTo(
        Rect.fromLTWH(0, height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        math.pi, 
        -math.pi / 2, 
        false
      )
      ..lineTo(width - cornerRadius, height)
      ..arcTo(
        Rect.fromLTWH(width - cornerRadius * 2, height - cornerRadius * 2, cornerRadius * 2, cornerRadius * 2),
        math.pi / 2, 
        -math.pi / 2, 
        false
      )
      ..lineTo(width, fillHeight > cornerRadius ? fillHeight : cornerRadius);
    
    // If fill level is above top corner radius, draw top curved part
    if (fillHeight <= cornerRadius) {
      fillPath
        ..arcTo(
          Rect.fromLTWH(width - cornerRadius * 2, 0, cornerRadius * 2, cornerRadius * 2),
          0, 
          -math.pi / 2, 
          false
        )
        ..lineTo(cornerRadius, 0)
        ..arcTo(
          Rect.fromLTWH(0, 0, cornerRadius * 2, cornerRadius * 2),
          -math.pi / 2, 
          -math.pi / 2, 
          false
        );
    } else {
      // Otherwise just connect the sides
      fillPath
        ..lineTo(0, fillHeight);
    }
    
    fillPath.close();
    
    // Draw the fill
    final fillPaint = Paint()
      ..color = fillColor.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(fillPath, fillPaint);
    
    // Draw graduation lines (5 lines)
    final linePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    
    final lineSpacing = height / 6;
    for (int i = 1; i <= 5; i++) {
      final y = lineSpacing * i;
      canvas.drawLine(
        Offset(2, y),
        Offset(width - 2, y),
        linePaint,
      );
    }
    
    // Draw top ellipse if needed for more 3D effect
    final ellipsePaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    
    final ellipseRect = Rect.fromLTWH(0, 0, width, cornerRadius * 0.5);
    canvas.drawOval(ellipseRect, ellipsePaint);
    
    final ellipseOutlinePaint = Paint()
      ..color = Colors.grey[300]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawOval(ellipseRect, ellipseOutlinePaint);
    
    // Draw fill level line for emphasis
    final levelLinePaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    // Only draw if fill level is visible within the cylinder
    if (fillLevel > 0 && fillLevel < 1) {
      canvas.drawLine(
        Offset(2, fillHeight),
        Offset(width - 2, fillHeight),
        levelLinePaint,
      );
    }
  }
  
  @override
  bool shouldRepaint(BodyFatCylinderPainter oldDelegate) {
    return oldDelegate.fillLevel != fillLevel ||
        oldDelegate.fillColor != fillColor;
  }
}