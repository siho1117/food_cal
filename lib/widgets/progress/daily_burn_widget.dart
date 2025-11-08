// lib/widgets/exercise/daily_burn_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../config/design_system/typography.dart'; // UPDATED: Import typography
import '../../data/models/user_profile.dart';
import '../../utils/progress/health_metrics.dart';

class DailyBurnWidget extends StatefulWidget {
  final UserProfile? userProfile;
  final double? currentWeight;
  final int totalCaloriesBurned; // Today's burned calories
  final int weeklyCaloriesBurned; // This week's burned calories

  const DailyBurnWidget({
    super.key,
    required this.userProfile,
    required this.currentWeight,
    this.totalCaloriesBurned = 0,
    this.weeklyCaloriesBurned = 0,
  });

  @override
  State<DailyBurnWidget> createState() => _DailyBurnWidgetState();
}

class _DailyBurnWidgetState extends State<DailyBurnWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _dailyProgressAnimation;
  late Animation<double> _weeklyProgressAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    ));
    
    // Staggered progress animations
    _dailyProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));
    
    _weeklyProgressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));
    
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

  @override
  Widget build(BuildContext context) {
    // Calculate burn recommendations
    final burnRecommendation = _calculateBurnRecommendation();
    final dailyBurnGoal = burnRecommendation['daily_burn'] as int;
    final weeklyBurnGoal = burnRecommendation['weekly_burn'] as int;
    
    // Calculate progress percentages
    final dailyProgress = dailyBurnGoal > 0 
        ? (widget.totalCaloriesBurned / dailyBurnGoal).clamp(0.0, 1.0)
        : 0.0;
    final weeklyProgress = weeklyBurnGoal > 0 
        ? (widget.weeklyCaloriesBurned / weeklyBurnGoal).clamp(0.0, 1.0)
        : 0.0;

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
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
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.local_fire_department,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Calorie Burn',
                                  style: AppTypography.displaySmall.copyWith( // UPDATED
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  'Track your exercise',
                                  style: AppTypography.bodySmall.copyWith( // UPDATED
                                    fontSize: 11,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Progress cards
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        return Column(
                          children: [
                          // Daily Progress Card
                          _buildProgressCard(
                            label: "Today's Progress",
                            current: widget.totalCaloriesBurned,
                            target: dailyBurnGoal,
                            progress: dailyProgress,
                            animation: _dailyProgressAnimation,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
                            ),
                            borderColor: const Color(0xFF667EEA).withValues(alpha: 0.1),
                            accentColor: const Color(0xFF667EEA),
                            progressGradient: const LinearGradient(
                              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          // Weekly Progress Card
                          _buildProgressCard(
                            label: "Weekly Progress",
                            current: widget.weeklyCaloriesBurned,
                            target: weeklyBurnGoal,
                            progress: weeklyProgress,
                            animation: _weeklyProgressAnimation,
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFEF7FF), Color(0xFFF3E8FF)],
                            ),
                            borderColor: const Color(0xFFF093FB).withValues(alpha: 0.1),
                            accentColor: const Color(0xFFF093FB),
                            progressGradient: const LinearGradient(
                              colors: [Color(0xFFF093FB), Color(0xFFF5576C)],
                            ),
                          ),
                        ],
                      );
                      },
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

  Widget _buildProgressCard({
    required String label,
    required int current,
    required int target,
    required double progress,
    required Animation<double> animation,
    required LinearGradient gradient,
    required Color borderColor,
    required Color accentColor,
    required LinearGradient progressGradient,
  }) {
    final progressPercentage = (progress * 100).round();
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Progress Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith( // UPDATED
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Numbers
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _formatNumber(current),
                        style: AppTypography.dataSmall.copyWith( // UPDATED
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: accentColor,
                        ),
                      ),
                      Text(
                        ' / ',
                        style: AppTypography.bodyMedium.copyWith( // UPDATED
                          fontSize: 16,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                      Text(
                        _formatNumber(target),
                        style: AppTypography.bodyMedium.copyWith( // UPDATED
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      Text(
                        ' cal',
                        style: AppTypography.bodySmall.copyWith( // UPDATED
                          fontSize: 11,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Percentage
                  Text(
                    '$progressPercentage% complete',
                    style: AppTypography.bodySmall.copyWith( // UPDATED
                      fontSize: 11,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Circular Progress
            AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return CustomPaint(
                  size: const Size(60, 60),
                  painter: CircularProgressPainter(
                    progress: progress * animation.value,
                    progressGradient: progressGradient,
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                  child: SizedBox(
                    width: 60,
                    height: 60,
                    child: Center(
                      child: Text(
                        '${(progressPercentage * animation.value).round()}%',
                        style: AppTypography.labelMedium.copyWith( // UPDATED
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateBurnRecommendation() {
    try {
      // Calculate BMR for use in exercise recommendations
      final bmr = HealthMetrics.calculateBMR(
        weight: widget.currentWeight,
        height: widget.userProfile?.height,
        age: widget.userProfile?.age,
        gender: widget.userProfile?.gender,
      );

      // Calculate recommended exercise burn
      return HealthMetrics.calculateRecommendedExerciseBurn(
        monthlyWeightGoal: widget.userProfile?.monthlyWeightGoal,
        bmr: bmr,
        activityLevel: widget.userProfile?.activityLevel,
        age: widget.userProfile?.age,
        gender: widget.userProfile?.gender,
        currentWeight: widget.currentWeight,
      );
    } catch (e) {
      // Return default values if calculation fails
      return {
        'daily_burn': 400,
        'weekly_burn': 2800,
        'light_minutes': 60,
        'moderate_minutes': 35,
        'intense_minutes': 20,
        'recommendation_type': 'default',
        'safety_adjusted': false,
      };
    }
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final LinearGradient progressGradient;
  final Color backgroundColor;

  CircularProgressPainter({
    required this.progress,
    required this.progressGradient,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = progressGradient.createShader(
          Rect.fromCircle(center: center, radius: radius),
        )
        ..strokeWidth = 4
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! CircularProgressPainter ||
        oldDelegate.progress != progress;
  }
}