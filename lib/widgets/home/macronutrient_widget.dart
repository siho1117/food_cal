// lib/widgets/home/macronutrient_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../l10n/generated/app_localizations.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/accent_colors.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';

class MacronutrientWidget extends StatefulWidget {
  const MacronutrientWidget({super.key});

  @override
  State<MacronutrientWidget> createState() => _MacronutrientWidgetState();
}

class _MacronutrientWidgetState extends State<MacronutrientWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  String? _previousDataHash;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkForRefresh(Map<String, double> consumed, Map<String, int> target) {
    final currentHash =
        '${consumed.values.join(',')}_${target.values.join(',')}';
    if (_previousDataHash != null &&
        _previousDataHash != currentHash &&
        mounted) {
      _controller.reset();
      _controller.forward();
    }
    _previousDataHash = currentHash;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<HomeProvider, ThemeProvider>(
      builder: (context, homeProvider, themeProvider, child) {
        final consumed = homeProvider.consumedMacros;
        final target = homeProvider.targetMacros;
        final progress = homeProvider.macroProgressPercentages;

        _checkForRefresh(consumed, target);

        // Get theme-adaptive colors
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );

        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return AnimatedBuilder(
          animation: _animation,
          builder: (context, child) => Row(
            children: [
              // Protein Card
              Expanded(
                child: _buildMacroCard(
                  context: context,
                  name: AppLocalizations.of(context)!.protein,
                  current: consumed['protein']!,
                  target: target['protein']!.toDouble(),
                  progress: progress['protein']!,
                  color: AccentColors.coral,
                  borderColor: borderColor,
                  textColor: textColor,
                  icon: Icons.set_meal,
                ),
              ),

              const SizedBox(width: 10),

              // Carbs Card
              Expanded(
                child: _buildMacroCard(
                  context: context,
                  name: AppLocalizations.of(context)!.carbs,
                  current: consumed['carbs']!,
                  target: target['carbs']!.toDouble(),
                  progress: progress['carbs']!,
                  color: AccentColors.brightGreen,
                  borderColor: borderColor,
                  textColor: textColor,
                  icon: Icons.local_pizza,
                ),
              ),

              const SizedBox(width: 10),

              // Fat Card
              Expanded(
                child: _buildMacroCard(
                  context: context,
                  name: AppLocalizations.of(context)!.fat,
                  current: consumed['fat']!,
                  target: target['fat']!.toDouble(),
                  progress: progress['fat']!,
                  color: AccentColors.goldenYellow,
                  borderColor: borderColor,
                  textColor: textColor,
                  icon: Icons.grain_rounded,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMacroCard({
    required BuildContext context,
    required String name,
    required double current,
    required double target,
    required double progress,
    required Color color,
    required Color borderColor,
    required Color textColor,
    IconData? icon,
  }) {
    final animatedProgress = progress * _animation.value;
    final animatedCurrent = current * _animation.value;
    final animatedTarget = target * _animation.value;
    
    // Calculate percentage from raw values (can go beyond 100%)
    final actualPercentage = animatedTarget > 0 
        ? (animatedCurrent / animatedTarget) 
        : 0.0;
    final displayPercentage = (actualPercentage * 100).round();

    return Opacity(
      opacity: _animation.value,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.1), // Subtle depth for readability
          borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          border: Border.all(
            color: borderColor,
            width: AppWidgetTheme.cardBorderWidth,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        child: Column(
          children: [
            // 1. Circular Progress with Percentage inside
            SizedBox(
              width: 56,
              height: 56,
              child: Stack(
                children: [
                  // Progress Ring (capped at 100%)
                  CustomPaint(
                    size: const Size(56, 56),
                    painter: _CircularProgressPainter(
                      progress: animatedProgress,
                      color: color,
                      backgroundColor: textColor.withValues(alpha: 0.3),
                    ),
                  ),

                  // Percentage in Center (can show beyond 100%)
                  Center(
                    child: Text(
                      '$displayPercentage%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                        shadows: AppWidgetTheme.textShadows,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 2. Current Value with Icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(
                    icon,
                    size: 20,
                    color: textColor,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  animatedCurrent.round().toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                    height: 1.0,
                    shadows: AppWidgetTheme.textShadows,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2),

            // 3. Target
            Text(
              '/ ${target.round()}g',
              style: TextStyle(
                fontSize: 12,
                color: textColor.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
                shadows: AppWidgetTheme.textShadows,
              ),
            ),

            const SizedBox(height: 8),

            // 4. Macro Name (Bottom)
            Text(
              name.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                color: textColor.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                shadows: AppWidgetTheme.textShadows,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// CIRCULAR PROGRESS PAINTER
// ═══════════════════════════════════════════════════════════════

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Background circle (theme-adaptive)
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc (capped at 100% = full circle)
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    
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
           oldDelegate.color != color ||
           oldDelegate.backgroundColor != backgroundColor;
  }
}