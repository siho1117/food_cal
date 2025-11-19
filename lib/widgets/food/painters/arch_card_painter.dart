// lib/widgets/food/painters/arch_card_painter.dart
import 'package:flutter/material.dart';

/// Custom painter that creates the arch-shaped cutout in the food card.
///
/// This painter creates a rounded rectangle card with an arch-shaped window
/// cutout for displaying the food image.
///
/// **Card dimensions:**
/// - Total card: 340×~620px with 28px corner radius
/// - Arch window: 290×320px with arch top (145px radius) and rounded bottom (20px)
/// - Window margins: 25px left/right, 90px from top
///
/// **Visual structure:**
/// ```
/// ┌─────────────────────────┐
/// │   Colored Card Header   │
/// │  ┌─────────────────┐   │
/// │  │                 │   │  ← Arch window cutout
/// │  │   Image shows   │   │
/// │  │    through      │   │
/// │  └─────────────────┘   │
/// │   Colored Card Body     │
/// └─────────────────────────┘
/// ```
///
/// **Usage:**
/// ```dart
/// CustomPaint(
///   painter: ArchCardPainter(cardColor: Colors.blue),
///   child: Container(), // Empty container for painting
/// )
/// ```
class ArchCardPainter extends CustomPainter {
  final Color cardColor;

  ArchCardPainter({required this.cardColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Constants for arch window dimensions
    const double marginLeft = 25.0;
    const double marginRight = 25.0;
    const double marginTop = 90.0;
    const double windowHeight = 320.0;
    const double archRadius = 145.0;

    // Create arch window shape (rounded rect with arch top)
    final archWindowRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
        marginLeft,
        marginTop,
        size.width - marginRight,
        marginTop + windowHeight,
      ),
      topLeft: Radius.circular(archRadius),
      topRight: Radius.circular(archRadius),
      bottomLeft: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
    );

    // Create main card shape
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(28),
    );

    // Convert to paths
    final cardPath = Path()..addRRect(cardRect);
    final windowPath = Path()..addRRect(archWindowRect);

    // Subtract window from card to create cutout
    final cardWithCutout = Path.combine(
      PathOperation.difference,
      cardPath,
      windowPath,
    );

    // Paint the card with cutout
    final cardPaint = Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(cardWithCutout, cardPaint);
  }

  @override
  bool shouldRepaint(covariant ArchCardPainter oldDelegate) {
    return oldDelegate.cardColor != cardColor;
  }
}
