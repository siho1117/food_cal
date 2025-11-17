// lib/widgets/common/animated_ellipsis_widget.dart
import 'package:flutter/material.dart';

/// A widget that displays animated ellipsis (...) for loading states
/// Dots appear sequentially: . → .. → ... → repeat
class AnimatedEllipsisWidget extends StatefulWidget {
  final TextStyle? textStyle;

  const AnimatedEllipsisWidget({
    super.key,
    this.textStyle,
  });

  @override
  State<AnimatedEllipsisWidget> createState() => _AnimatedEllipsisWidgetState();
}

class _AnimatedEllipsisWidgetState extends State<AnimatedEllipsisWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _animation = IntTween(begin: 0, end: 3).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        String dots = '';
        switch (_animation.value) {
          case 0:
            dots = '';
            break;
          case 1:
            dots = '.';
            break;
          case 2:
            dots = '..';
            break;
          case 3:
            dots = '...';
            break;
        }

        return Text(
          dots,
          style: widget.textStyle ??
              const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
        );
      },
    );
  }
}
