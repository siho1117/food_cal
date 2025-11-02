// lib/widgets/home/macronutrient_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';
import '../../providers/home_provider.dart';
import '../../providers/theme_provider.dart';

/// Widget-specific design constants
class _MacronutrientDesign {
  static const double triangleSize = 160.0; // ✅ Size of the triangle area
  static const double triangleStrokeWidth = 16.0; // ✅ Thickness: 16.0
}

class MacronutrientWidget extends StatefulWidget {
  const MacronutrientWidget({super.key});

  @override
  State<MacronutrientWidget> createState() => _MacronutrientWidgetState();
}

class _MacronutrientWidgetState extends State<MacronutrientWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Track previous values for refresh detection
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600), // ✅ 30% slower animation
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
        final borderColor = AppColors.getBorderColorForTheme(
          themeProvider.selectedGradient,
          AppEffects.borderOpacity,
        );
        final textColor = AppColors.getTextColorForTheme(
          themeProvider.selectedGradient,
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.50), // ✅ 50% opacity
            borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
            border: Border.all(
              color: borderColor,
              width: AppDimensions.cardBorderWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Opacity(
                    opacity: _animation.value,
                    child: Text(
                      'Macronutrients',
                      style: TextStyle(
                        fontSize: 18,
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                        shadows: AppEffects.textShadows,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Triangle + Legend Layout
                  _buildTriangleWithLegend(
                    consumed,
                    target,
                    progress,
                    textColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTriangleWithLegend(
    Map<String, double> consumed,
    Map<String, int> target,
    Map<String, double> progress,
    Color textColor,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Equilateral triangle on the left
        Opacity(
          opacity: _animation.value,
          child: SizedBox(
            width: _MacronutrientDesign.triangleSize,
            height: _MacronutrientDesign.triangleSize,
            child: CustomPaint(
              painter: _EquilateralTrianglePainter(
                proteinProgress: progress['protein']! * _animation.value,
                carbsProgress: progress['carbs']! * _animation.value,
                fatProgress: progress['fat']! * _animation.value,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Legend on the right
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildLegendItem(
                name: 'Protein',
                consumed: consumed['protein']!,
                target: target['protein']!.toDouble(),
                progress: progress['protein']!,
                color: const Color(0xFFEF4444),
                delay: 0.0,
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                name: 'Carbs',
                consumed: consumed['carbs']!,
                target: target['carbs']!.toDouble(),
                progress: progress['carbs']!,
                color: const Color(0xFF3B82F6),
                delay: 0.15,
              ),
              const SizedBox(height: 8),
              _buildLegendItem(
                name: 'Fat',
                consumed: consumed['fat']!,
                target: target['fat']!.toDouble(),
                progress: progress['fat']!,
                color: const Color(0xFFF97316),
                delay: 0.30,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required String name,
    required double consumed,
    required double target,
    required double progress,
    required Color color,
    required double delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: color,
            width: 3,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: Name and values
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 1),
                Text(
                  '${(consumed * _animation.value).round()}g / ${(target * _animation.value).round()}g',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Right: Percentage
          Text(
            '${(progress * 100 * _animation.value).round()}%',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// EQUILATERAL TRIANGLE PAINTER
// ═══════════════════════════════════════════════════════════════

class _EquilateralTrianglePainter extends CustomPainter {
  final double proteinProgress;
  final double carbsProgress;
  final double fatProgress;

  _EquilateralTrianglePainter({
    required this.proteinProgress,
    required this.carbsProgress,
    required this.fatProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Calculate equilateral triangle vertices
    final padding = size.width * 0.1;
    final availableWidth = size.width - (2 * padding);
    final sideLength = availableWidth;
    
    // Height of equilateral triangle = (sqrt(3) / 2) * side
    final height = (math.sqrt(3) / 2) * sideLength;
    
    // Center the triangle vertically
    final verticalOffset = (size.height - height) / 2;
    
    // Define vertices for proper equilateral triangle
    final top = Offset(size.width / 2, verticalOffset);
    final bottomLeft = Offset(padding, verticalOffset + height);
    final bottomRight = Offset(size.width - padding, verticalOffset + height);

    // Background triangle outline - solid white
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = _MacronutrientDesign.triangleStrokeWidth
      ..strokeJoin = StrokeJoin.round;

    final bgPath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..close();
    canvas.drawPath(bgPath, bgPaint);

    // Draw progress sides
    // Protein: top → bottom-right
    _drawProgressSide(
      canvas: canvas,
      start: top,
      end: bottomRight,
      progress: proteinProgress,
      color: const Color(0xFFEF4444),
    );

    // Carbs: bottom-right → bottom-left
    _drawProgressSide(
      canvas: canvas,
      start: bottomRight,
      end: bottomLeft,
      progress: carbsProgress,
      color: const Color(0xFF3B82F6),
    );

    // Fat: bottom-left → top
    _drawProgressSide(
      canvas: canvas,
      start: bottomLeft,
      end: top,
      progress: fatProgress,
      color: const Color(0xFFF97316),
    );
  }

  void _drawProgressSide({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required double progress,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = _MacronutrientDesign.triangleStrokeWidth
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);

    final pathMetrics = path.computeMetrics();
    final progressPath = Path();

    for (final metric in pathMetrics) {
      final extractPath = metric.extractPath(
        0,
        (metric.length * progress.clamp(0.0, 1.0)),
      );
      progressPath.addPath(extractPath, Offset.zero);
    }

    canvas.drawPath(progressPath, paint);
  }

  @override
  bool shouldRepaint(_EquilateralTrianglePainter oldDelegate) {
    return oldDelegate.proteinProgress != proteinProgress ||
        oldDelegate.carbsProgress != carbsProgress ||
        oldDelegate.fatProgress != fatProgress;
  }
}