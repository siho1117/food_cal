// lib/widgets/loading/animations/animated_cost_indicator.dart
import 'package:flutter/material.dart';

/// Animated cost indicator widget with gentle pulse animation
/// Used during food recognition preview to draw attention to cost input option
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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    // Create animation controller with 1.8 second duration
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Create scale animation: 1.0 → 1.1 → 1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
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
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Text(
          widget.text,
          style: widget.textStyle,
        ),
      ),
    );
  }
}
