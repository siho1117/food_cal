// lib/widgets/progress/combined_bmi_bodyfat_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';

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
    
    _bmiAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
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

  Color _getBMIColor() {
    if (widget.bmiValue == null) return Colors.grey.shade400;
    if (widget.bmiValue! < 18.5) return const Color(0xFF3B82F6);
    if (widget.bmiValue! < 25.0) return const Color(0xFF1E40AF);
    if (widget.bmiValue! < 30.0) return const Color(0xFF7C3AED);
    return const Color(0xFF9333EA);
  }

  Color _getBodyFatColor() {
    if (widget.bodyFatPercentage == null) return Colors.grey.shade400;
    switch (widget.bodyFatClassification.toLowerCase()) {
      case 'essential': return const Color(0xFF10B981);
      case 'athletic': return const Color(0xFF059669);
      case 'fitness': return const Color(0xFFF59E0B);
      case 'average': return const Color(0xFFEF4444);
      case 'above avg': return const Color(0xFFDC2626);
      case 'obese': return const Color(0xFF991B1B);
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
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppLegacyColors.primaryBlue,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMI (Body Mass Index)',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'BMI is calculated using weight and height to assess if you\'re in a healthy weight range.',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Body Fat Percentage',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Body fat percentage shows the proportion of fat in your total body mass.',
                style: AppTypography.bodyMedium,
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
                    'Note: Body fat is estimated based on BMI. For more accurate measurements, consider professional body composition analysis.',
                    style: AppTypography.bodySmall.copyWith(
                      color: const Color(0xFF2B6CB0),
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
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bmiColor = _getBMIColor();
    final bodyFatColor = _getBodyFatColor();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.assessment_rounded,
                          color: AppLegacyColors.primaryBlue,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Body Composition',
                            style: AppTypography.displaySmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'BMI & Body Fat Analysis',
                            style: AppTypography.bodyMedium.copyWith(
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
              
              Row(
                children: [
                  const SizedBox(width: 20),
                  Expanded(
                    child: SizedBox(
                      height: 180,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          AnimatedBuilder(
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
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                                    style: AppTypography.bodyMedium.copyWith(
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
                                style: AppTypography.labelLarge.copyWith(
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
                                  style: AppTypography.bodySmall.copyWith(
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
                                    style: AppTypography.bodyMedium.copyWith(
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
                                style: AppTypography.labelLarge.copyWith(
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
                                  style: AppTypography.bodySmall.copyWith(
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
    const outerRadius = 75.0;
    const innerRadius = 50.0;
    
    final bmiVisualProgress = bmiValue != null 
        ? math.min(1.0, (bmiValue! / 40.0)) * bmiProgress
        : 0.0;
    
    final bodyFatVisualProgress = bodyFatValue != null 
        ? math.min(1.0, (bodyFatValue! / 50.0)) * bodyFatProgress
        : 0.0;

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, outerRadius, backgroundPaint);
    canvas.drawCircle(center, innerRadius, backgroundPaint);

    final bmiPaint = Paint()
      ..color = bmiColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    final bodyFatPaint = Paint()
      ..color = bodyFatColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: outerRadius),
      -math.pi / 2,
      2 * math.pi * bmiVisualProgress,
      false,
      bmiPaint,
    );

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: innerRadius),
      -math.pi / 2,
      2 * math.pi * bodyFatVisualProgress,
      false,
      bodyFatPaint,
    );
  }

  @override
  bool shouldRepaint(CircularRingsZoneIndicatorsPainter oldDelegate) {
    return oldDelegate.bmiValue != bmiValue || 
           oldDelegate.bmiProgress != bmiProgress ||
           oldDelegate.bodyFatProgress != bodyFatProgress ||
           oldDelegate.bmiColor != bmiColor ||
           oldDelegate.bodyFatColor != bodyFatColor;
  }
}