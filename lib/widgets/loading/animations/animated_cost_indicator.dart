// lib/widgets/loading/animations/animated_cost_indicator.dart
import 'package:flutter/material.dart';

/// Animated cost indicator widget with pulsing glow effect
/// Used during food recognition preview to draw attention to cost input option
///
/// **Animation**: Glowing shadow that pulses from subtle to prominent
/// - Shadow blur: 4.0 → 16.0 → 4.0
/// - Duration: 2.0 seconds (smooth, luxurious feel)
/// - Effect: Premium, eye-catching without being distracting
class AnimatedCostIndicator extends StatefulWidget {
  final String text;
  final TextStyle? textStyle;
  final VoidCallback? onTap;

  const AnimatedCostIndicator({
    super.key,
    required this.text,
    this.textStyle,
    this.onTap,
  });

  @override
  State<AnimatedCostIndicator> createState() => _AnimatedCostIndicatorState();
}

class _AnimatedCostIndicatorState extends State<AnimatedCostIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with 2.0 second duration (slower for luxury feel)
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Create glow animation: 4.0 → 16.0 → 4.0
    // This animates the shadow blur radius for the glowing effect
    _glowAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 4.0, end: 16.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 16.0, end: 4.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
    ]).animate(_controller);

    // Start animation and repeat
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Text(
            widget.text,
            style: widget.textStyle?.copyWith(
              shadows: [
                // Primary glow - golden/amber color for premium feel
                Shadow(
                  blurRadius: _glowAnimation.value,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.8), // Gold
                  offset: const Offset(0, 0),
                ),
                // Secondary glow - white for extra brightness
                Shadow(
                  blurRadius: _glowAnimation.value * 0.6,
                  color: Colors.white.withValues(alpha: 0.5),
                  offset: const Offset(0, 0),
                ),
                // Tertiary glow - softer gold for depth
                Shadow(
                  blurRadius: _glowAnimation.value * 1.5,
                  color: const Color(0xFFFFD700).withValues(alpha: 0.4),
                  offset: const Offset(0, 0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
