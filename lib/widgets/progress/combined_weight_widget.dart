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
                            Text(
                              'Weight Journey',
                              style: AppTextStyles.getSubHeadingStyle().copyWith(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryBlue,
                              ),
                            ),
                            if (targetWeight != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: progressColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: progressColor.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'Progress toward goal',
                                  style: AppTextStyles.getBodyStyle().copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: progressColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Speedometer or Empty State
                        targetWeight != null 
                          ? _buildSpeedometerView(currentWeight!, targetWeight, remainingPercentage, progressColor, weightToGoText)
                          : _buildEmptyState(),
                        
                        const SizedBox(height: 24),
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: _buildActionButton(
                                'Update Weight',
                                AppTheme.primaryBlue,
                                Icons.add_circle_outline,
                                () => _showWeightDialog(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildActionButton(
                                'Set Target',
                                Colors.green[600]!,
                                Icons.flag_outlined,
                                () => _showTargetDialog(),
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
      },
    );
  }

  Widget _buildSpeedometerView(
    double currentWeight,
    double targetWeight,
    double remainingPercentage,
    Color progressColor,
    String weightToGoText,
  ) {
    return Column(
      children: [
        // Speedometer Gauge
        SizedBox(
          width: 180,
          height: 90,
          child: AnimatedBuilder(
            animation: _speedometerController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(180, 90),
                painter: SpeedometerPainter(
                  remainingPercentage: remainingPercentage * _needleAnimation.value,
                  progressColor: progressColor,
                ),
              );
            },
          ),
        ),
        
        // Speedometer Labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Close',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Far',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Weight Info Row
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Current Weight
              Expanded(
                child: _buildInfoItem(
                  'Current',
                  _formatWeight(currentWeight),
                  AppTheme.primaryBlue,
                  Icons.monitor_weight_rounded,
                ),
              ),
              
              // Divider
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              
              // To Goal
              Expanded(
                child: _buildInfoItem(
                  'To Goal',
                  weightToGoText,
                  progressColor,
                  Icons.flag_outlined,
                ),
              ),
              
              // Divider
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
              ),
              
              // Target Weight
              Expanded(
                child: _buildInfoItem(
                  'Target',
                  _formatWeight(targetWeight),
                  Colors.green[600]!,
                  Icons.radio_button_checked,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, Color color, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 16,
          color: color.withOpacity(0.7),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 11,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 120,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.grey[300]!,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.add,
              color: Colors.grey[500],
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Set a target weight to see your journey',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color color, IconData icon, VoidCallback onTap) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color,
            color.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWeightDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Weight'),
        content: Text('Weight dialog coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showTargetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Set Target'),
        content: Text('Target dialog coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the speedometer
class SpeedometerPainter extends CustomPainter {
  final double remainingPercentage;
  final Color progressColor;

  SpeedometerPainter({
    required this.remainingPercentage,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 20;
    
    // Draw the speedometer arc background
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );
    
    // Draw gradient speedometer arc
    final rect = Rect.fromCircle(center: center, radius: radius);
    final gradient = SweepGradient(
      startAngle: math.pi,
      endAngle: 2 * math.pi,
      colors: [
        Colors.green[600]!,
        Colors.lightGreen[500]!,
        Colors.yellow[600]!,
        Colors.orange[500]!,
        Colors.red[500]!,
      ],
    );
    
    final speedometerPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..strokeWidth = 12
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    canvas.drawArc(
      rect,
      math.pi,
      math.pi,
      false,
      speedometerPaint,
    );
    
    // Calculate needle position
    final normalizedPercentage = (remainingPercentage / 20).clamp(0.0, 1.0);
    final needleAngle = math.pi + (math.pi * normalizedPercentage);
    final needleLength = radius - 10;
    final needleEnd = Offset(
      center.dx + needleLength * math.cos(needleAngle),
      center.dy + needleLength * math.sin(needleAngle),
    );
    
    // Draw the needle
    final needlePaint = Paint()
      ..color = Colors.grey[800]!
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    canvas.drawLine(center, needleEnd, needlePaint);
    
    // Draw center circle
    final centerPaint = Paint()
      ..color = Colors.grey[800]!;
    
    canvas.drawCircle(center, 6, centerPaint);
    
    // Draw remaining percentage text
    final textSpan = TextSpan(
      text: '${remainingPercentage.toStringAsFixed(1)}%',
      style: TextStyle(
        color: progressColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
    
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - 35,
      ),
    );
  }

  @override
  bool shouldRepaint(SpeedometerPainter oldDelegate) {
    return oldDelegate.remainingPercentage != remainingPercentage || 
           oldDelegate.progressColor != progressColor;
  }
}