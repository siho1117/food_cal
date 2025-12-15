// lib/widgets/common/circular_progress_painter.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Shared custom painter for circular progress indicators
/// Used across multiple widgets for consistent circular progress visualization
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color? backgroundColor;
  final double strokeWidth;

  CircularProgressPainter({
    required this.progress,
    required this.progressColor,
    this.backgroundColor,
    this.strokeWidth = 4.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - strokeWidth;

    // Draw background circle (if provided)
    if (backgroundColor != null) {
      final bgPaint = Paint()
        ..color = backgroundColor!
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, radius, bgPaint);
    }

    // Draw progress arc
    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
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
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
           oldDelegate.progressColor != progressColor ||
           oldDelegate.backgroundColor != backgroundColor ||
           oldDelegate.strokeWidth != strokeWidth;
  }
}
