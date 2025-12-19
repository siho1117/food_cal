// lib/widgets/common/slow_animated_emoji.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:animated_emoji/animated_emoji.dart';

/// A wrapper around AnimatedEmoji that allows controlling animation speed
///
/// This widget provides slower, more subtle animations for emoji avatars
class SlowAnimatedEmoji extends StatefulWidget {
  final AnimatedEmojiData emoji;
  final double size;
  final double speedFactor; // 1.0 = normal, 0.5 = half speed, 2.0 = double speed
  final Widget? errorWidget;

  const SlowAnimatedEmoji({
    super.key,
    required this.emoji,
    this.size = 48,
    this.speedFactor = 0.6, // Default to 60% speed (slower, more subtle)
    this.errorWidget,
  });

  @override
  State<SlowAnimatedEmoji> createState() => _SlowAnimatedEmojiState();
}

class _SlowAnimatedEmojiState extends State<SlowAnimatedEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Create controller with default duration (will be updated when animation loads)
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // Default duration
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationLoaded(Duration originalDuration) {
    // Adjust duration based on speed factor
    // If speedFactor = 0.5, animation takes 2x longer (slower)
    final adjustedDuration = Duration(
      milliseconds: (originalDuration.inMilliseconds / widget.speedFactor).round(),
    );

    _controller.duration = adjustedDuration;
    _controller.repeat();
  }

  @override
  Widget build(BuildContext context) {
    final networkUrl =
        'https://fonts.gstatic.com/s/e/notoemoji/latest/${widget.emoji.id}/lottie.json';

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.network(
        networkUrl,
        controller: _controller,
        onLoaded: (composition) {
          _onAnimationLoaded(composition.duration);
        },
        errorBuilder: widget.errorWidget != null
            ? (context, error, stackTrace) => widget.errorWidget!
            : null,
      ),
    );
  }
}
