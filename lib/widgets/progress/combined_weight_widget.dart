// lib/widgets/progress/combined_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/progress_data.dart';

class CombinedWeightWidget extends StatefulWidget {
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightEntered;

  const CombinedWeightWidget({
    Key? key,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightEntered,
  }) : super(key: key);

  @override
  State<CombinedWeightWidget> createState() => _CombinedWeightWidgetState();
}

class _CombinedWeightWidgetState extends State<CombinedWeightWidget>
    with TickerProviderStateMixin {
  late AnimationController _speedometerController;
  late AnimationController _fadeController;
  late Animation<double> _needleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _speedometerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Initialize animations AFTER controllers are created
    _needleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _speedometerController,
        curve: const Interval(0.3, 1.0, curve: Curves.elasticOut),
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
            _speedometerController.forward();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _speedometerController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  double _calculateRemainingPercentage(double? current, double? target) {
    if (current == null || target == null) return 0.0;
    return ((current - target).abs() / current * 100);
  }

  Color _getProgressColor(double remainingPercentage) {
    if (remainingPercentage <= 5) return Colors.green[600]!;
    if (remainingPercentage <= 10) return Colors.lightGreen[600]!;
    if (remainingPercentage <= 15) return Colors.orange[500]!;
    return AppTheme.primaryBlue;
  }

  String _formatWeight(double? weight) {
    if (weight == null) {
      return widget.isMetric ? '-- kg' : '-- lbs';
    }
    
    final displayWeight = widget.isMetric ? weight : weight * 2.20462;
    final unit = widget.isMetric ? 'kg' : 'lbs';
    
    return '${displayWeight.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressData>(
      builder: (context, progressData, child) {
        final targetWeight = progressData.userProfile?.goalWeight;
        final currentWeight = widget.currentWeight;
        
        final remainingPercentage = _calculateRemainingPercentage(currentWeight, targetWeight);
        final progressColor = _getProgressColor(remainingPercentage);
        
        String weightToGoText = '--';
        
        if (targetWeight != null && currentWeight != null) {
          final weightDifference = (currentWeight - targetWeight).abs();
          final unit = widget.isMetric ? 'kg' : 'lbs';
          final displayDifference = widget.isMetric ? weightDifference : weightDifference * 2.20462;
          weightToGoText = '${displayDifference.toStringAsFixed(1)} $unit to go';
        }

        return AnimatedBuilder(
          animation: _fadeController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white,
                        Colors.grey[50]!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
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
                                    color: progressColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.monitor_weight_rounded,
                                    color: progressColor,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Current Weight',
                                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    Text(
                                      'Keep going!',
                                      style: AppTextStyles.getBodyStyle().copyWith(
                                        fontSize: 12,
                                        color: progressColor,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.add_circle_outline,
                                    color: AppTheme.primaryBlue,
                                    size: 28,
                                  ),
                                  onPressed: () {
                                    // Add weight entry logic here
                                  },
                                  tooltip: 'Add Weight Entry',
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.flag_outlined,
                                    color: Colors.grey[600],
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    // Set target weight logic here
                                  },
                                  tooltip: 'Set Target Weight',
                                ),
                              ],
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Segmented Progress Arc (replacing speedometer)
                        SizedBox(
                          height: 120,
                          child: AnimatedBuilder(
                            animation: _speedometerController,
                            builder: (context, child) {
                              return CustomPaint(
                                size: const Size(240, 120),
                                painter: SegmentedProgressArcPainter(
                                  progress: remainingPercentage * _needleAnimation.value,
                                  progressColor: progressColor,
                                ),
                              );
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Weight Display
                        Column(
                          children: [
                            Text(
                              _formatWeight(currentWeight),
                              style: AppTextStyles.getNumericStyle().copyWith(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (targetWeight != null)
                              Text(
                                'Target: ${_formatWeight(targetWeight)}',
                                style: AppTextStyles.getBodyStyle().copyWith(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: progressColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: progressColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                weightToGoText,
                                style: AppTextStyles.getBodyStyle().copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: progressColor,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Progress Percentage (using original calculation)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.trending_up,
                                  size: 18,
                                  color: progressColor,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '${(100 - remainingPercentage).toInt()}% Complete',
                                  style: AppTextStyles.getBodyStyle().copyWith(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: progressColor,
                                  ),
                                ),
                              ],
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
      },
    );
  }
}

// Custom Painter for Segmented Progress Arc (replacing SpeedometerPainter)
class SegmentedProgressArcPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final int segments = 20;

  SegmentedProgressArcPainter({
    required this.progress,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height * 0.85);
    final radius = size.width * 0.32;
    final segmentAngle = 180 / segments; // 180 degrees total arc (half circle)
    final startAngle = 180.0; // Start from left side
    
    // Calculate progress (original logic: lower percentage means closer to goal)
    // For visual: higher progress should fill more segments
    final visualProgress = (100 - progress) / 100; // Invert for visual progress
    final activeSegments = (visualProgress * segments).floor();
    final partialProgress = (visualProgress * segments) - activeSegments;

    // Paint for segments
    final activePaint = Paint()
      ..color = progressColor
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    final inactivePaint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
      
    final nextPaint = Paint()
      ..color = progressColor.withOpacity(0.5)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Draw each segment
    for (int i = 0; i < segments; i++) {
      final angle = (startAngle + (i * segmentAngle)) * math.pi / 180;
      
      // Calculate start and end points for each segment
      final innerRadius = radius - 6;
      final outerRadius = radius + 6;
      
      final startInner = Offset(
        center.dx + innerRadius * math.cos(angle),
        center.dy + innerRadius * math.sin(angle),
      );
      
      final startOuter = Offset(
        center.dx + outerRadius * math.cos(angle),
        center.dy + outerRadius * math.sin(angle),
      );

      Paint segmentPaint;
      if (i < activeSegments) {
        segmentPaint = activePaint;
      } else if (i == activeSegments && partialProgress > 0) {
        segmentPaint = nextPaint;
      } else {
        segmentPaint = inactivePaint;
      }

      canvas.drawLine(startInner, startOuter, segmentPaint);
    }

    // Draw center dot
    final centerPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(center, 4, centerPaint);
    
    // Draw 0% and 100% markers
    final textStyle = TextStyle(
      color: Colors.grey[600],
      fontSize: 11,
      fontWeight: FontWeight.w500,
    );
    
    // 0% marker (left side)
    final startTextPainter = TextPainter(
      text: TextSpan(text: '0%', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    startTextPainter.layout();
    
    final startTextAngle = startAngle * math.pi / 180;
    final startTextOffset = Offset(
      center.dx + (radius + 18) * math.cos(startTextAngle) - startTextPainter.width / 2,
      center.dy + (radius + 18) * math.sin(startTextAngle) - startTextPainter.height / 2,
    );
    startTextPainter.paint(canvas, startTextOffset);
    
    // 100% marker (right side)
    final endTextPainter = TextPainter(
      text: TextSpan(text: '100%', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    endTextPainter.layout();
    
    final endTextAngle = (startAngle + 180) * math.pi / 180;
    final endTextOffset = Offset(
      center.dx + (radius + 18) * math.cos(endTextAngle) - endTextPainter.width / 2,
      center.dy + (radius + 18) * math.sin(endTextAngle) - endTextPainter.height / 2,
    );
    endTextPainter.paint(canvas, endTextOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! SegmentedProgressArcPainter || 
           oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor;
  }
}