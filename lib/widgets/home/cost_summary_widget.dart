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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), // Much smaller padding
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left: Title
                  Text(
                    'Food Cost',
                    style: TextStyle(
                      fontSize: 14, // Smaller title
                      color: textColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                      shadows: AppEffects.textShadows,
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Center: Cost display
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Animated cost - Much smaller
                        AnimatedBuilder(
                          animation: _animation,
                          builder: (context, child) {
                            final animatedCost = totalCost * _animation.value;
                            return Text(
                              '\$${animatedCost.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 28, // Reduced from 36
                                fontWeight: FontWeight.bold,
                                color: textColor, // No color change
                                letterSpacing: -0.5,
                                height: 1.0,
                                shadows: AppEffects.textShadows,
                              ),
                            );
                          },
                        ),
                        
                        const SizedBox(height: 2),
                        
                        // Budget amount - Much smaller
                        Text(
                          '/ \$${dailyBudget.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12, // Reduced from 14
                            fontWeight: FontWeight.w500,
                            color: textColor.withValues(alpha: 0.7),
                            shadows: AppEffects.textShadows,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(width: 16),
                  
                  // Right: Circular progress - Much smaller
                  AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return _buildCircularProgress(
                        totalCost,
                        dailyBudget,
                        textColor,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularProgress(double totalCost, double dailyBudget, Color textColor) {
    // Calculate actual percentage (can go beyond 100%)
    final actualPercentage = dailyBudget > 0 ? (totalCost / dailyBudget) : 0.0;
    final animatedPercentage = actualPercentage * _animation.value;
    final displayPercentage = (animatedPercentage * 100).round();
    
    // For ring display, cap at 100%
    final ringProgress = animatedPercentage.clamp(0.0, 1.0);
    
    return CustomPaint(
      size: const Size(60, 60), // Much smaller: 80 -> 60
      painter: _CircularProgressPainter(
        progress: ringProgress,
        baseColor: textColor,
      ),
      child: SizedBox(
        width: 60,
        height: 60,
        child: Center(
          child: Text(
            '$displayPercentage%', // Can show beyond 100%
            style: TextStyle(
              fontSize: 14, // Reduced from 18
              fontWeight: FontWeight.bold,
              color: textColor, // No color change
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
  final Color baseColor;

  _CircularProgressPainter({
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5; // Adjusted for smaller size
    
    // Background circle
    final bgPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 // Reduced from 8
      ..strokeCap = StrokeCap.round;
    
    canvas.drawCircle(center, radius, bgPaint);
    
    // Progress arc - NO COLOR CHANGE, always uses baseColor
    final progressPaint = Paint()
      ..color = baseColor.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6 // Reduced from 8
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
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || 
           oldDelegate.baseColor != baseColor;
  }
}