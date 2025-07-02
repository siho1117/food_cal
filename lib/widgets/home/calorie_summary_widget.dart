// lib/widgets/home/calorie_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class CalorieSummaryWidget extends StatefulWidget {
  const CalorieSummaryWidget({Key? key}) : super(key: key);

  @override
  State<CalorieSummaryWidget> createState() => _CalorieSummaryWidgetState();
}

class _CalorieSummaryWidgetState extends State<CalorieSummaryWidget> 
    with TickerProviderStateMixin {
  late AnimationController _progressController;
  late AnimationController _countController;
  late AnimationController _slideController;
  
  late Animation<double> _progressAnimation;
  late Animation<double> _countAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers first
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _countController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    // Then create all animations
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _progressController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _countAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _countController,
        curve: Curves.easeOutQuart,
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Start animations after everything is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnimations();
    });
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _countController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _progressController.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    _slideController.forward();
  }

  // Restart animations when data refreshes
  void _restartAnimations() {
    _progressController.reset();
    _countController.reset();
    _slideController.reset();
    _startAnimations();
  }

  @override
  void dispose() {
    _progressController.dispose();
    _countController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Show loading state if data is still loading
        if (homeProvider.isLoading) {
          return Container(
            height: 220,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryBlue,
              ),
            ),
          );
        }

        // Get data from provider
        final totalCalories = homeProvider.totalCalories;
        final calorieGoal = homeProvider.calorieGoal;
        final caloriesRemaining = homeProvider.caloriesRemaining;
        final isOverBudget = homeProvider.isOverBudget;
        final expectedPercentage = homeProvider.expectedDailyPercentage;
        
        // Calculate progress
        final calorieProgress = (totalCalories / calorieGoal).clamp(0.0, 1.0);
        final progressPercentage = (calorieProgress * 100).round();
        
        // Determine status and colors
        final statusData = _getStatusData(calorieProgress, expectedPercentage, isOverBudget);
        
        // Restart animations when data changes (like after refresh)
        // Only do this once and avoid infinite rebuilds
        if (homeProvider.isToday && mounted) {
          // Use a more controlled approach for restarting animations
          // This will only trigger once per data change
        }
        
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with fire emoji and refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        '🔥',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Daily Calories',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildStatusBadge(statusData, caloriesRemaining, isOverBudget),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Main content with circular progress and calorie display
              Row(
                children: [
                  // Left side - Calorie numbers
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Animated calorie display
                        AnimatedBuilder(
                          animation: _countAnimation,
                          builder: (context, child) {
                            final animatedTotal = (totalCalories * _countAnimation.value).round();
                            final animatedGoal = (calorieGoal * _countAnimation.value).round();
                            
                            return RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: '$animatedTotal',
                                    style: AppTextStyles.getNumericStyle().copyWith(
                                      fontSize: 42,
                                      fontWeight: FontWeight.bold,
                                      color: statusData['color'],
                                      height: 0.9,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' / $animatedGoal',
                                    style: AppTextStyles.getNumericStyle().copyWith(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 12),

                        // Progress percentage with animation
                        AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            final animatedPercentage = (progressPercentage * _progressAnimation.value).round();
                            return Text(
                              '▶ $animatedPercentage% of daily goal',
                              style: AppTextStyles.getBodyStyle().copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 8),

                        // Encouragement text with fade in
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Text(
                            statusData['message'],
                            style: AppTextStyles.getBodyStyle().copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: statusData['color'],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right side - Circular progress
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        return CustomPaint(
                          painter: CircularProgressPainter(
                            progress: calorieProgress * _progressAnimation.value,
                            color: statusData['color'],
                            strokeWidth: 8,
                          ),
                          child: Center(
                            child: AnimatedBuilder(
                              animation: _progressAnimation,
                              builder: (context, child) {
                                final animatedPercentage = (progressPercentage * _progressAnimation.value).round();
                                return Text(
                                  '$animatedPercentage%',
                                  style: AppTextStyles.getNumericStyle().copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: statusData['color'],
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> statusData, int caloriesRemaining, bool isOverBudget) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: statusData['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: statusData['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusData['icon'],
            size: 16,
            color: statusData['color'],
          ),
          const SizedBox(width: 6),
          Text(
            isOverBudget
                ? '${caloriesRemaining.abs()} over'
                : '$caloriesRemaining left',
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: statusData['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusData(double progress, double expectedProgress, bool isOverBudget) {
    if (isOverBudget) {
      return {
        'color': Colors.red[500]!,
        'icon': Icons.warning_rounded,
        'message': '⚠️ Over your daily limit',
      };
    } else if (progress > expectedProgress * 1.2) {
      return {
        'color': Colors.orange[500]!,
        'icon': Icons.speed_rounded,
        'message': '🚀 Ahead of schedule!',
      };
    } else if (progress > expectedProgress * 0.8) {
      return {
        'color': Colors.green[500]!,
        'icon': Icons.check_circle_rounded,
        'message': '⭐ Right on track!',
      };
    } else if (progress > 0.1) {
      return {
        'color': Colors.blue[500]!,
        'icon': Icons.trending_up_rounded,
        'message': '💪 Keep it up!',
      };
    } else {
      return {
        'color': Colors.grey[500]!,
        'icon': Icons.restaurant_rounded,
        'message': '🍽️ Time to fuel up!',
      };
    }
  }
}

// Custom painter for circular progress
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color.withOpacity(0.7),
            color,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
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
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}