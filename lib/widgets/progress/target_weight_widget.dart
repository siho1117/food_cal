// lib/widgets/progress/target_weight_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../utils/formula.dart';
import '../../providers/progress_data.dart';

class TargetWeightWidget extends StatefulWidget {
  const TargetWeightWidget({Key? key}) : super(key: key);

  @override
  State<TargetWeightWidget> createState() => _TargetWeightWidgetState();
}

class _TargetWeightWidgetState extends State<TargetWeightWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProgressData>(
      builder: (context, progressData, child) {
        final targetWeight = progressData.userProfile?.goalWeight;
        final currentWeight = progressData.currentWeight;
        final isMetric = progressData.isMetric;
        
        // Calculate progress
        double progressValue = 0.0;
        String remainingText = '';
        Color progressColor = Colors.grey[600]!;
        
        if (targetWeight != null && currentWeight != null) {
          progressValue = Formula.calculateGoalProgress(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
          );
          
          remainingText = Formula.getWeightChangeDirectionText(
            currentWeight: currentWeight,
            targetWeight: targetWeight,
            isMetric: isMetric,
          );
          
          // Set color based on progress
          if (progressValue >= 0.9) {
            progressColor = Colors.green[600]!;
          } else if (progressValue >= 0.6) {
            progressColor = Colors.orange[500]!;
          } else if (progressValue >= 0.3) {
            progressColor = AppTheme.primaryBlue;
          } else {
            progressColor = Colors.red[500]!;
          }
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _showTargetWeightDialog(context, progressData),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: targetWeight == null
                          ? _buildEmptyState()
                          : _buildTargetContent(
                              targetWeight,
                              isMetric,
                              progressValue,
                              remainingText,
                              progressColor,
                            ),
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

  Widget _buildEmptyState() {
    return Row(
      children: [
        // Empty Progress Ring
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
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
        
        const SizedBox(width: 20),
        
        // Empty State Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Weight',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Set a target',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Tap to set your goal weight',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTargetContent(
    double targetWeight,
    bool isMetric,
    double progressValue,
    String remainingText,
    Color progressColor,
  ) {
    // Format weight with proper units
    final weightValue = isMetric ? targetWeight : targetWeight * 2.20462;
    final units = isMetric ? 'kg' : 'lbs';
    final displayWeight = '${weightValue.toStringAsFixed(1)} $units';
    
    return Row(
      children: [
        // Progress Ring
        SizedBox(
          width: 60,
          height: 60,
          child: Stack(
            children: [
              // Background Circle
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  shape: BoxShape.circle,
                ),
              ),
              
              // Animated Progress Ring
              AnimatedBuilder(
                animation: _progressAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(60, 60),
                    painter: ProgressRingPainter(
                      progress: progressValue * _progressAnimation.value,
                      color: progressColor,
                      backgroundColor: Colors.grey[300]!,
                      strokeWidth: 4.0,
                    ),
                  );
                },
              ),
              
              // Percentage Text in Center
              Center(
                child: AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    final animatedPercentage = (progressValue * _progressAnimation.value * 100).round();
                    return Text(
                      '$animatedPercentage%',
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: progressColor,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 20),
        
        // Target Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Target Weight',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                displayWeight,
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: progressColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                remainingText,
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showTargetWeightDialog(BuildContext context, ProgressData progressData) {
    final isMetric = progressData.isMetric;
    double initialWeight = progressData.userProfile?.goalWeight ?? 
                          (progressData.currentWeight ?? (isMetric ? 70.0 : 154.0));
    
    final weightController = TextEditingController();
    bool localIsMetric = isMetric;
    
    // Set initial value in display units
    final displayWeight = localIsMetric ? initialWeight : initialWeight * 2.20462;
    weightController.text = displayWeight.toStringAsFixed(1);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.all(24),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.flag,
                  color: AppTheme.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Set Target Weight',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unit Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (localIsMetric) {
                            final currentInput = double.tryParse(weightController.text) ?? 70.0;
                            final convertedWeight = currentInput * 2.20462;
                            weightController.text = convertedWeight.toStringAsFixed(1);
                            setState(() => localIsMetric = false);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !localIsMetric ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: !localIsMetric ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Text(
                            'lbs',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: !localIsMetric ? AppTheme.primaryBlue : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (!localIsMetric) {
                            final currentInput = double.tryParse(weightController.text) ?? 154.0;
                            final convertedWeight = currentInput / 2.20462;
                            weightController.text = convertedWeight.toStringAsFixed(1);
                            setState(() => localIsMetric = true);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: localIsMetric ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: localIsMetric ? [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Text(
                            'kg',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: localIsMetric ? AppTheme.primaryBlue : Colors.grey[600],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Weight Input Field
              TextField(
                controller: weightController,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                textAlign: TextAlign.center,
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
                decoration: InputDecoration(
                  hintText: localIsMetric ? '70.0' : '154.0',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 24,
                  ),
                  suffixText: localIsMetric ? 'kg' : 'lbs',
                  suffixStyle: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 18,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final input = weightController.text.trim();
                        if (input.isNotEmpty) {
                          final inputWeight = double.tryParse(input);
                          if (inputWeight != null && inputWeight > 0) {
                            final weightInKg = localIsMetric ? inputWeight : inputWeight / 2.20462;
                            // Here you would call progressData.setTargetWeight(weightInKg)
                            Navigator.of(context).pop();
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Target weight set to ${localIsMetric ? inputWeight.toStringAsFixed(1) : (inputWeight / 2.20462).toStringAsFixed(1)} ${localIsMetric ? 'kg' : 'lbs'}'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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

// Custom painter for the progress ring
class ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}