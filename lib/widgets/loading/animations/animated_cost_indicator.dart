// lib/widgets/loading/animations/animated_cost_indicator.dart
import 'package:flutter/material.dart';

/// Animated cost indicator widget with natural drop bounce effect
/// Used during food recognition preview to draw attention to cost input option
///
/// **Animation**: Natural drop bounce with decay
/// - Translate Y: 0 → -6px → 0 → -3px → 0 → -1px → 0
/// - Duration: 1.5 seconds
/// - Effect: Like dropping a ball - bounces with decreasing height
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
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with 1.5 second duration for natural bounce
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Create natural drop bounce: 0 → -6 → 0 → -3 → 0 → -1 → 0
    _bounceAnimation = TweenSequence<double>([
      // First bounce - rise up (largest)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -6.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      // First drop
      TweenSequenceItem(
        tween: Tween<double>(begin: -6.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
      // Second bounce - rise up (medium)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -3.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      // Second drop
      TweenSequenceItem(
        tween: Tween<double>(begin: -3.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 12,
      ),
      // Third bounce - rise up (small)
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: -1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 8,
      ),
      // Third drop - settle
      TweenSequenceItem(
        tween: Tween<double>(begin: -1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 8,
      ),
      // Rest period before next cycle
      TweenSequenceItem(
        tween: ConstantTween<double>(0.0),
        weight: 30,
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
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _bounceAnimation.value),
            child: Text(
              widget.text,
              style: widget.textStyle,
            ),
          );
        },
      ),
    );
  }
}
