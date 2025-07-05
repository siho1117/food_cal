// lib/widgets/progress/circular_bmi_bodyfat_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';

class CircularBMIBodyFatWidget extends StatefulWidget {
  final double? bmiValue;
  final String bmiClassification;
  final double? bodyFatPercentage;
  final String bodyFatClassification;
  final bool isEstimated;

  const CircularBMIBodyFatWidget({
    Key? key,
    required this.bmiValue,
    required this.bmiClassification,
    required this.bodyFatPercentage,
    required this.bodyFatClassification,
    this.isEstimated = true,
  }) : super(key: key);

  @override
  State<CircularBMIBodyFatWidget> createState() => _CircularBMIBodyFatWidgetState();
}

class _CircularBMIBodyFatWidgetState extends State<CircularBMIBodyFatWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _bmiAnimation;
  late Animation<double> _bodyFatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // BMI animation starts first
    _bmiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    // Body Fat animation starts slightly after BMI
    _bodyFatAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutBack,
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fadeController.forward();
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted) {
            _animationController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // Get color based on BMI classification
  Color _getBMIColor() {
    if (widget.bmiValue == null) return Colors.grey.shade400;

    if (widget.bmiValue! < 18.5) return const Color(0xFF3B82F6);   // Blue - Underweight
    if (widget.bmiValue! < 25.0) return const Color(0xFF1E40AF);   // Deep Blue - Normal
    if (widget.bmiValue! < 30.0) return const Color(0xFF7C3AED);   // Purple - Overweight
    return const Color(0xFF9333EA);                                // Purple - Obese
  }

  // Get color based on body fat classification
  Color _getBodyFatColor() {
    if (widget.bodyFatPercentage == null) return Colors.grey.shade400;

    switch (widget.bodyFatClassification.toLowerCase()) {
      case 'essential': return const Color(0xFF10B981);   // Green
      case 'athletic': return const Color(0xFF059669);    // Dark Green
      case 'fitness': return const Color(0xFFF59E0B);     // Amber
      case 'average': return const Color(0xFFEF4444);     // Red
      case 'above avg': return const Color(0xFFDC2626);   // Dark Red
      case 'obese': return const Color(0xFF991B1B);       // Very Dark Red
      default: return Colors.grey.shade400;
    }
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.s),
        ),
        title: Text(
          'Body Composition Info', 
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI (Body Mass Index)',
                style: AppTextStyles.getBodyStyle().copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: Dimensions.xs),
              Text(
                'BMI is calculated using weight and height to assess if you\'re in a healthy weight range.',
                style: AppTextStyles.getBodyStyle(),
              ),
              SizedBox(height: Dimensions.s),
              Text(
                'Body Fat Percentage',
                style: AppTextStyles.getBodyStyle().copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: Dimensions.xs),
              Text(
                'Body fat percentage shows the proportion of fat in your total body mass.',
                style: AppTextStyles.getBodyStyle(),
              ),
              if (widget.isEstimated) ...[
                SizedBox(height: Dimensions.s),
                Container(
                  padding: EdgeInsets.all(Dimensions.xs),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4299E1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.xxs),
                  ),
                  child: Text(
                    'Note: Body fat is estimated based on BMI. For accurate measurements, consider DEXA scans or bioelectrical impedance.',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
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

  @override
  Widget build(BuildContext context) {
    final bmiColor = _getBMIColor();
    final bodyFatColor = _getBodyFatColor();

    return AnimatedBuilder(
      animation: _fadeController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Card(
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
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.assessment_rounded,
                                color: AppTheme.primaryBlue,
                                size: Dimensions.m,
                              ),
                            ),
                            SizedBox(width: Dimensions.xs),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Body Composition',
                                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                                    fontSize: Dimensions.getTextSize(context, size: TextSize.medium),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'BMI & Body Fat Analysis',
                                  style: AppTextStyles.getBodyStyle().copyWith(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.info_outline_rounded, 
                            size: Dimensions.getIconSize(context, size: IconSize.small),
                          ),
                          onPressed: _showInfoDialog,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                    
                    SizedBox(height: Dimensions.l),
                    
                    // Circular Progress Rings with Zone Indicators
                    SizedBox(
                      height: 180,
                      child: AnimatedBuilder(
                        animation: _animationController,
                        builder: (context, child) {
                          return Center(
                            child: CustomPaint(
                              size: const Size(180, 180),
                              painter: CircularRingsZoneIndicatorsPainter(
                                bmiValue: widget.bmiValue,
                                bmiProgress: _bmiAnimation.value,
                                bmiColor: bmiColor,
                                bodyFatValue: widget.bodyFatPercentage,
                                bodyFatProgress: _bodyFatAnimation.value,
                                bodyFatColor: bodyFatColor,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    
                    SizedBox(height: Dimensions.l),
                    
                    // Metrics Summary
                    Container(
                      padding: EdgeInsets.all(Dimensions.s),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // BMI Section
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: bmiColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: Dimensions.xs),
                                    Text(
                                      'BMI',
                                      style: AppTextStyles.getBodyStyle().copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.xs),
                                Text(
                                  widget.bmiValue?.toStringAsFixed(1) ?? '--',
                                  style: AppTextStyles.getNumericStyle().copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: bmiColor,
                                  ),
                                ),
                                SizedBox(height: Dimensions.xxs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bmiColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.bmiClassification,
                                    style: AppTextStyles.getBodyStyle().copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: bmiColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Divider
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey[300],
                          ),
                          
                          // Body Fat Section
                          Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: bodyFatColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    SizedBox(width: Dimensions.xs),
                                    Text(
                                      'Body Fat',
                                      style: AppTextStyles.getBodyStyle().copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: Dimensions.xs),
                                Text(
                                  widget.bodyFatPercentage != null 
                                    ? '${widget.bodyFatPercentage!.toStringAsFixed(1)}%'
                                    : '--%',
                                  style: AppTextStyles.getNumericStyle().copyWith(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: bodyFatColor,
                                  ),
                                ),
                                SizedBox(height: Dimensions.xxs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: bodyFatColor.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.bodyFatClassification,
                                    style: AppTextStyles.getBodyStyle().copyWith(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: bodyFatColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Zone Indicator Legend
                    SizedBox(height: Dimensions.s),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.green[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: Dimensions.xs),
                        Text(
                          'Green dots indicate healthy zones',
                          style: AppTextStyles.getBodyStyle().copyWith(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    
                    if (widget.isEstimated) ...[
                      SizedBox(height: Dimensions.s),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.grey[500],
                          ),
                          SizedBox(width: Dimensions.xs),
                          Expanded(
                            child: Text(
                              'Body fat percentage is estimated based on BMI calculation',
                              style: AppTextStyles.getBodyStyle().copyWith(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// Custom Painter for Circular Rings with Zone Indicators
class CircularRingsZoneIndicatorsPainter extends CustomPainter {
  final double? bmiValue;
  final double bmiProgress;
  final Color bmiColor;
  final double? bodyFatValue;
  final double bodyFatProgress;
  final Color bodyFatColor;

  CircularRingsZoneIndicatorsPainter({
    required this.bmiValue,
    required this.bmiProgress,
    required this.bmiColor,
    required this.bodyFatValue,
    required this.bodyFatProgress,
    required this.bodyFatColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.38; // BMI ring
    final innerRadius = size.width * 0.27; // Body Fat ring
    
    // Calculate progress values (0.0 to 1.0)
    final bmiVisualProgress = bmiValue != null 
      ? math.min((bmiValue! - 15) / 25, 1.0) * bmiProgress
      : 0.0;
    final bodyFatVisualProgress = bodyFatValue != null 
      ? math.min(bodyFatValue! / 35, 1.0) * bodyFatProgress
      : 0.0;

    // Paint styles
    final bmiBackgroundPaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke;
      
    final bmiProgressPaint = Paint()
      ..color = bmiColor
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final bodyFatBackgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
      
    final bodyFatProgressPaint = Paint()
      ..color = bodyFatColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final zoneIndicatorPaint = Paint()
      ..color = Colors.green[600]!
      ..style = PaintingStyle.fill;

    // Draw BMI ring background
    canvas.drawCircle(center, outerRadius, bmiBackgroundPaint);
    
    // Draw BMI healthy zone indicators (Normal BMI: 18.5-24.9, roughly 35%-75% of scale)
    final bmiHealthyStart = 0.35; // 35%
    final bmiHealthyEnd = 0.75;   // 75%
    for (int i = 0; i < 8; i++) {
      final angle = (bmiHealthyStart + (i / 7) * (bmiHealthyEnd - bmiHealthyStart)) * 2 * math.pi - math.pi / 2;
      final indicatorPosition = Offset(
        center.dx + (outerRadius + 12) * math.cos(angle),
        center.dy + (outerRadius + 12) * math.sin(angle),
      );
      canvas.drawCircle(indicatorPosition, 3, zoneIndicatorPaint);
    }
    
    // Draw BMI progress arc
    final bmiSweepAngle = 2 * math.pi * bmiVisualProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2, // Start from top
      bmiSweepAngle,
      false,
      bmiProgressPaint,
    );
    
    // Draw Body Fat ring background
    canvas.drawCircle(center, innerRadius, bodyFatBackgroundPaint);
    
    // Draw Body Fat healthy zone indicators (Essential+Athletic+Fitness: roughly 25%-70% of scale)
    final bodyFatHealthyStart = 0.25; // 25%
    final bodyFatHealthyEnd = 0.70;   // 70%
    for (int i = 0; i < 6; i++) {
      final angle = (bodyFatHealthyStart + (i / 5) * (bodyFatHealthyEnd - bodyFatHealthyStart)) * 2 * math.pi - math.pi / 2;
      final indicatorPosition = Offset(
        center.dx + (innerRadius + 10) * math.cos(angle),
        center.dy + (innerRadius + 10) * math.sin(angle),
      );
      canvas.drawCircle(indicatorPosition, 2, zoneIndicatorPaint);
    }
    
    // Draw Body Fat progress arc
    final bodyFatSweepAngle = 2 * math.pi * bodyFatVisualProgress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -math.pi / 2, // Start from top
      bodyFatSweepAngle,
      false,
      bodyFatProgressPaint,
    );
    
    // Draw center content
    final centerTextStyle = TextStyle(
      color: Colors.grey[700],
      fontSize: 14,
      fontWeight: FontWeight.w600,
    );
    
    final healthTextPainter = TextPainter(
      text: TextSpan(text: 'Health', style: centerTextStyle),
      textDirection: TextDirection.ltr,
    );
    healthTextPainter.layout();
    healthTextPainter.paint(
      canvas, 
      Offset(center.dx - healthTextPainter.width / 2, center.dy - 20)
    );
    
    final scoreTextPainter = TextPainter(
      text: TextSpan(text: 'Score', style: centerTextStyle.copyWith(fontSize: 12)),
      textDirection: TextDirection.ltr,
    );
    scoreTextPainter.layout();
    scoreTextPainter.paint(
      canvas, 
      Offset(center.dx - scoreTextPainter.width / 2, center.dy + 5)
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CircularRingsZoneIndicatorsPainter || 
           oldDelegate.bmiProgress != bmiProgress ||
           oldDelegate.bodyFatProgress != bodyFatProgress ||
           oldDelegate.bmiColor != bmiColor ||
           oldDelegate.bodyFatColor != bodyFatColor;
  }
}