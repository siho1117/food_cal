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
  late Animation<double> _fadeInAnimation;
  late Animation<double> _sweepAnimation;
  late Animation<double> _valueAnimation;

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
    
    _sweepAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.9, curve: Curves.easeOutCubic),
      ),
    );
    
    _valueAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.9, curve: Curves.easeOutCubic),
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
      return AppTheme.primaryBlue;    // Green for Normal
    } else if (widget.bmiValue! < 30) {
      return AppTheme.coralAccent;    // Coral for Overweight
    } else {
      return AppTheme.accentColor;    // Burgundy for Obese
    }
  }
  
  // Get position in the BMI gauge (0.0 to 1.0)
  double _getBMIPosition() {
    if (widget.bmiValue == null) return 0.5; // Center position
    
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
                // Header with primary value
                Row(
                  children: [
                    // BMI Value section
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // BMI Title
                          Text(
                            'Body Mass Index',
                            style: AppTextStyles.getSubHeadingStyle().copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          // Animated BMI Value
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                widget.bmiValue != null 
                                  ? (widget.bmiValue! * _valueAnimation.value).toStringAsFixed(1)
                                  : "—",
                                style: AppTextStyles.getNumericStyle().copyWith(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              ),
                              
                              const SizedBox(width: 4),
                              
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
                    
                    // Gauge visualization
                    SizedBox(
                      height: 60,
                      width: 60,
                      child: CustomPaint(
                        painter: BMIGaugePainter(
                          bmiPosition: bmiPosition,
                          sweepAnimation: _sweepAnimation.value,
                          bmiColor: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 10),
                
                // BMI Range bar
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: Stack(
                    children: [
                      // Background gradient
                      Container(
                        height: 6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
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
                      
                      // Position indicator (animated)
                      if (widget.bmiValue != null)
                        Positioned(
                          left: (MediaQuery.of(context).size.width - 64) * 
                              bmiPosition * _sweepAnimation.value,
                          top: 0,
                          child: Column(
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryColor.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  widget.bmiValue != null 
                                      ? widget.bmiValue!.toStringAsFixed(1)
                                      : "—",
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
                      
                      // Range labels
                      Positioned(
                        top: 22,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildRangeLabel("Underweight", "<18.5", AppTheme.goldAccent),
                            _buildRangeLabel("Normal", "18.5-25", AppTheme.primaryBlue),
                            _buildRangeLabel("Overweight", "25-30", AppTheme.coralAccent),
                            _buildRangeLabel("Obese", ">30", AppTheme.accentColor),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Description
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
        );
      },
    );
  }
  
  Widget _buildRangeLabel(String text, String range, Color color) {
    return Column(
      children: [
        Text(
          range,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          text,
          style: TextStyle(
            fontSize: 8,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class BMIGaugePainter extends CustomPainter {
  final double bmiPosition; // 0.0 to 1.0
  final double sweepAnimation; // Animation progress 0.0 to 1.0
  final Color bmiColor;
  
  BMIGaugePainter({
    required this.bmiPosition,
    required this.sweepAnimation,
    required this.bmiColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    
    // Calculate start and sweep angles
    final startAngle = -math.pi * 0.75; // Start at top-left
    final totalSweepAngle = math.pi * 1.5; // 270 degrees sweep
    final endAngle = startAngle + totalSweepAngle * sweepAnimation;
    
    // Mapping bmiPosition (0.0-1.0) to the gauge angle
    final bmiAngle = startAngle + totalSweepAngle * bmiPosition * sweepAnimation;
    
    // Background track paint (grey)
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..color = Colors.grey[200]!;
    
    // Value arc paint (bmi color)
    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..color = bmiColor;
    
    // Draw background track arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      totalSweepAngle * sweepAnimation,
      false,
      trackPaint,
    );
    
    // Draw value arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      startAngle,
      (bmiAngle - startAngle),
      false,
      valuePaint,
    );
    
    // Draw center circle with icon
    final centerCirclePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;
    
    final centerBorderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = bmiColor;
    
    // Draw center circle
    canvas.drawCircle(center, radius * 0.6, centerCirclePaint);
    canvas.drawCircle(center, radius * 0.6, centerBorderPaint);
    
    // Draw BMI text in center
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'BMI',
        style: TextStyle(
          color: bmiColor,
          fontSize: radius * 0.5,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas, 
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }
  
  @override
  bool shouldRepaint(BMIGaugePainter oldDelegate) {
    return oldDelegate.bmiPosition != bmiPosition ||
        oldDelegate.sweepAnimation != sweepAnimation ||
        oldDelegate.bmiColor != bmiColor;
  }
}