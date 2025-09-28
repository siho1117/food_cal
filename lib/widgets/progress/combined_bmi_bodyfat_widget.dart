// lib/widgets/progress/combined_bmi_bodyfat_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';

class CombinedBMIBodyFatWidget extends StatefulWidget {
  final double? bmiValue;
  final String bmiClassification;
  final double? bodyFatPercentage;
  final String bodyFatClassification;
  final bool isEstimated;

  const CombinedBMIBodyFatWidget({
    super.key,
    required this.bmiValue,
    required this.bmiClassification,
    required this.bodyFatPercentage,
    required this.bodyFatClassification,
    this.isEstimated = true,
  });

  @override
  State<CombinedBMIBodyFatWidget> createState() => _CombinedBMIBodyFatWidgetState();
}

class _CombinedBMIBodyFatWidgetState extends State<CombinedBMIBodyFatWidget>
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
          borderRadius: BorderRadius.circular(12.0),
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
              const SizedBox(height: 8),
              Text(
                'BMI is calculated using weight and height to assess if you\'re in a healthy weight range.',
                style: AppTextStyles.getBodyStyle(),
              ),
              const SizedBox(height: 16),
              Text(
                'Body Fat Percentage',
                style: AppTextStyles.getBodyStyle().copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Body fat percentage shows the proportion of fat in your total body mass.',
                style: AppTextStyles.getBodyStyle(),
              ),
              if (widget.isEstimated) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4299E1).withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
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
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withAlpha(26),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.assessment_rounded,
                                color: AppTheme.primaryBlue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Body Composition',
                                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                                    fontSize: 16,
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
                          icon: const Icon(
                            Icons.info_outline_rounded, 
                            size: 18,
                          ),
                          onPressed: _showInfoDialog,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: Colors.grey[500],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Main Content Layout: Circle with left spacing, cards flush to padding edge
                    Row(
                      children: [
                        // Left spacing for circle
                        const SizedBox(width: 16),
                        
                        // Left Side - Concentric Circles with left spacing
                        SizedBox(
                          width: 180,
                          height: 180,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(180, 180),
                                painter: CircularRingsZoneIndicatorsPainter(
                                  bmiValue: widget.bmiValue,
                                  bmiProgress: _bmiAnimation.value,
                                  bmiColor: bmiColor,
                                  bodyFatValue: widget.bodyFatPercentage,
                                  bodyFatProgress: _bodyFatAnimation.value,
                                  bodyFatColor: bodyFatColor,
                                ),
                              );
                            },
                          ),
                        ),
                        
                        // Flexible gap between circle and cards
                        const Spacer(),
                        
                        // Right Side - Classifications flush to widget padding edge
                        SizedBox(
                          width: 100,
                          child: Column(
                            children: [
                              // BMI Classification (Top)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    left: BorderSide(
                                      color: bmiColor,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'BMI',
                                          style: AppTextStyles.getBodyStyle().copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: bmiColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.bmiValue?.toStringAsFixed(1) ?? '--',
                                      style: AppTextStyles.getNumericStyle().copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: bmiColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: bmiColor.withAlpha(26),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.bmiClassification,
                                        style: AppTextStyles.getBodyStyle().copyWith(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w600,
                                          color: bmiColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 10),
                              
                              // Body Fat Classification (Bottom)
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border(
                                    left: BorderSide(
                                      color: bodyFatColor,
                                      width: 3,
                                    ),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Body Fat',
                                          style: AppTextStyles.getBodyStyle().copyWith(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: bodyFatColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      widget.bodyFatPercentage != null 
                                        ? '${widget.bodyFatPercentage!.toStringAsFixed(1)}%'
                                        : '--',
                                      style: AppTextStyles.getNumericStyle().copyWith(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: bodyFatColor,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: bodyFatColor.withAlpha(26),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.bodyFatClassification,
                                        style: AppTextStyles.getBodyStyle().copyWith(
                                          fontSize: 8,
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
                      ],
                    ),
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
    const outerRadius = 75.0; // BMI ring (original size)
    const innerRadius = 50.0; // Body Fat ring (original size)
    
    // Calculate progress values for visual representation
    final bmiVisualProgress = bmiValue != null 
        ? math.min(1.0, (bmiValue! / 40.0)) * bmiProgress // Max BMI scale of 40
        : 0.0;
    
    final bodyFatVisualProgress = bodyFatValue != null 
        ? math.min(1.0, (bodyFatValue! / 50.0)) * bodyFatProgress // Max body fat scale of 50%
        : 0.0;

    // Paint configurations (original stroke width)
    final bmiBackgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
      
    final bodyFatBackgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke;
      
    final bmiProgressPaint = Paint()
      ..color = bmiColor
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
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
    const bmiHealthyStart = 0.35; // 35%
    const bmiHealthyEnd = 0.75;   // 75%
    for (int i = 0; i < 8; i++) { // Original number of indicators
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
    const bodyFatHealthyStart = 0.25; // 25%
    const bodyFatHealthyEnd = 0.70;   // 70%
    for (int i = 0; i < 6; i++) { // Original number of indicators
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
    
    // Draw center content (original size)
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

    // NO RING LABELS - removed as requested
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