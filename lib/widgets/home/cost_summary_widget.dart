// lib/widgets/home/cost_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';
import '../dialogs/budget_edit_dialog.dart';

class CostSummaryWidget extends StatefulWidget {
  const CostSummaryWidget({super.key});

  @override
  State<CostSummaryWidget> createState() => _CostSummaryWidgetState();
}

class _CostSummaryWidgetState extends State<CostSummaryWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  void _checkForRefresh(double totalCost, double budget) {
    final currentHash = '$totalCost-$budget';
    if (_previousDataHash != null && _previousDataHash != currentHash && mounted) {
      _controller.reset();
      _controller.forward();
    }
    _previousDataHash = currentHash;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, ThemeProvider>(
      builder: (context, homeProvider, themeProvider, child) {
        final totalCost = homeProvider.totalFoodCost;
        final dailyBudget = homeProvider.dailyFoodBudget;
        final progress = (totalCost / dailyBudget).clamp(0.0, 1.0);
        final isOverBudget = homeProvider.isOverFoodBudget;

        _checkForRefresh(totalCost, dailyBudget);

        // Get theme-adaptive colors
        final borderColor = AppColors.getBorderColorForTheme(
          themeProvider.selectedGradient,
          AppEffects.borderOpacity,
        );
        final textColor = AppColors.getTextColorForTheme(
          themeProvider.selectedGradient,
        );

        return GestureDetector(
          onTap: () => _showBudgetEditDialog(context, homeProvider, dailyBudget),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
              border: Border.all(
                color: borderColor,
                width: AppDimensions.cardBorderWidth,
              ),
            ),
            child: Padding(
              padding: AppDimensions.cardPadding,
              child: Column(
                children: [
                  // Title
                  Text(
                    'Food Cost',
                    style: TextStyle(
                      fontSize: 20,
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                      shadows: AppEffects.textShadows,
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main content: Cost + Progress Ring
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Left: Cost display
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Animated cost
                            AnimatedBuilder(
                              animation: _animation,
                              builder: (context, child) {
                                final animatedCost = totalCost * _animation.value;
                                return Text(
                                  '\$${animatedCost.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: isOverBudget 
                                      ? const Color(0xFFFF6B6B)
                                      : textColor,
                                    letterSpacing: -1,
                                    height: 1.0,
                                    shadows: AppEffects.textShadows,
                                  ),
                                );
                              },
                            ),
                            
                            const SizedBox(height: 8),
                            
                            // Budget amount
                            Text(
                              '/ \$${dailyBudget.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor.withValues(alpha: 0.7),
                                shadows: AppEffects.textShadows,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(width: 32),
                      
                      // Right: Circular progress
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          final animatedProgress = progress * _animation.value;
                          return _buildCircularProgress(
                            animatedProgress,
                            isOverBudget,
                            textColor,
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(double progress, bool isOverBudget, Color textColor) {
    return CustomPaint(
      size: const Size(100, 100),
      painter: _CircularProgressPainter(
        progress: progress,
        isOverBudget: isOverBudget,
        baseColor: textColor,
      ),
      child: SizedBox(
        width: 100,
        height: 100,
        child: Center(
          child: Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isOverBudget 
                ? const Color(0xFFFF6B6B)
                : progress >= 0.9
                  ? const Color(0xFFF97316)
                  : textColor,
              shadows: AppEffects.textShadows,
            ),
          ),
        ),
      ),
    );
  }

  void _showBudgetEditDialog(BuildContext context, HomeProvider homeProvider, double currentBudget) {
    showDialog(
      context: context,
      builder: (context) => BudgetEditDialog(
        currentBudget: currentBudget,
        homeProvider: homeProvider,
        title: 'Update Daily Budget',
        showAdvancedOptions: false,
      ),
    );
  }
}

/// Custom painter for circular progress indicator
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final bool isOverBudget;
  final Color baseColor;

  _CircularProgressPainter({
    required this.progress,
    required this.isOverBudget,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;
    
    // Background circle
    final bgPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress arc
    final progressPaint = Paint()
      ..color = _getProgressColor()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10
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

  Color _getProgressColor() {
    if (isOverBudget) return const Color(0xFFFF6B6B); // Soft red
    if (progress >= 0.9) return const Color(0xFFF97316); // Orange
    return baseColor.withValues(alpha: 0.9); // Theme color
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.isOverBudget != isOverBudget ||
           oldDelegate.baseColor != baseColor;
  }
}