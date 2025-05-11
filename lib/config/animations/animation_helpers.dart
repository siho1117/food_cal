import 'package:flutter/material.dart';

/// Helper class for creating standard animations throughout the app.
///
/// This class reduces code duplication by providing factory methods
/// for common animation patterns used in widgets.
class AnimationHelpers {
  // Private constructor to prevent instantiation
  AnimationHelpers._();
  
  /// Factory method to create a standard progress animation
  static Animation<double> createProgressAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeOutCubic,
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Factory method to create a standard fade animation
  static Animation<double> createFadeAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeOut,
    double begin = 0.0,
    double end = 1.0,
    double? beginInterval,
    double? endInterval,
  }) {
    if (beginInterval != null && endInterval != null) {
      return Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(beginInterval, endInterval, curve: curve),
        ),
      );
    }
    
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Factory method to create a standard scale animation
  static Animation<double> createScaleAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeOutBack,
    double begin = 0.9,
    double end = 1.0,
    double? beginInterval,
    double? endInterval,
  }) {
    if (beginInterval != null && endInterval != null) {
      return Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(beginInterval, endInterval, curve: curve),
        ),
      );
    }
    
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Factory method to create a standard slide animation
  static Animation<Offset> createSlideAnimation({
    required AnimationController controller,
    Curve curve = Curves.easeOutCubic,
    Offset begin = const Offset(0, 0.2),
    Offset end = Offset.zero,
    double? beginInterval,
    double? endInterval,
  }) {
    if (beginInterval != null && endInterval != null) {
      return Tween<Offset>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: controller,
          curve: Interval(beginInterval, endInterval, curve: curve),
        ),
      );
    }
    
    return Tween<Offset>(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Factory method to create a standard color animation
  static Animation<Color?> createColorAnimation({
    required AnimationController controller,
    required Color begin,
    required Color end,
    Curve curve = Curves.easeInOut,
  }) {
    return ColorTween(begin: begin, end: end).animate(
      CurvedAnimation(
        parent: controller,
        curve: curve,
      ),
    );
  }
  
  /// Creates a standard set of entrance animations (fade and scale)
  static Map<String, Animation<dynamic>> createEntranceAnimations({
    required AnimationController controller,
    double initialScale = 0.9,
    Offset? initialSlide,
  }) {
    final Map<String, Animation<dynamic>> animations = {
      'fade': createFadeAnimation(
        controller: controller,
        curve: Curves.easeOut,
      ),
      'scale': createScaleAnimation(
        controller: controller,
        curve: Curves.easeOutBack,
        begin: initialScale,
      ),
    };
    
    if (initialSlide != null) {
      final slideAnimation = createSlideAnimation(
        controller: controller,
        begin: initialSlide,
      );
      animations['slide'] = slideAnimation;
    }
    
    return animations;
  }
  
  /// Helper to build an animated numeric counter
  static Widget buildAnimatedCounter({
    required Animation<double> animation,
    required num targetValue,
    required TextStyle style,
    int decimalPlaces = 1,
    String? suffix,
    String? prefix,
    TextAlign textAlign = TextAlign.center,
  }) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final currentValue = targetValue * animation.value;
        final formattedValue = decimalPlaces > 0
            ? currentValue.toStringAsFixed(decimalPlaces)
            : currentValue.round().toString();
        
        return Text(
          '${prefix ?? ''}$formattedValue${suffix ?? ''}',
          style: style,
          textAlign: textAlign,
        );
      },
    );
  }
  
  /// Apply multiple animations to a widget
  static Widget applyAnimations({
    required Widget child,
    required Map<String, Animation<dynamic>> animations,
  }) {
    Widget result = child;
    
    // Apply animations in the correct order: slide -> scale -> fade
    if (animations.containsKey('slide')) {
      final slideAnimation = animations['slide'] as Animation<Offset>;
      result = SlideTransition(
        position: slideAnimation,
        child: result,
      );
    }
    
    if (animations.containsKey('scale')) {
      final scaleAnimation = animations['scale'] as Animation<double>;
      result = ScaleTransition(
        scale: scaleAnimation,
        child: result,
      );
    }
    
    if (animations.containsKey('fade')) {
      final fadeAnimation = animations['fade'] as Animation<double>;
      result = FadeTransition(
        opacity: fadeAnimation,
        child: result,
      );
    }
    
    return result;
  }
  
  /// NEW METHOD: Coordinate refresh animations across multiple widgets
  /// This method handles restarting animations when refresh occurs
  static void coordinateRefreshAnimations({
    required AnimationController controller,
    Duration delay = const Duration(milliseconds: 300),
    bool forward = true,
  }) {
    // Reset the animation controller
    controller.reset();
    
    // Add a short delay before running animations (feels smoother)
    Future.delayed(delay, () {
      if (forward && !controller.isAnimating) {
        controller.forward();
      }
    });
  }
  
  /// NEW METHOD: Create staggered animations for a list of child widgets
  static List<Widget> createStaggeredAnimations({
    required List<Widget> children,
    required AnimationController controller,
    double staggerDuration = 0.1, // 10% delay between each child
    Curve curve = Curves.easeOut,
    bool includeScale = true,
    bool includeFade = true,
    bool includeSlide = false,
  }) {
    final int childCount = children.length;
    final List<Widget> animatedChildren = [];
    
    for (int i = 0; i < childCount; i++) {
      // Calculate start and end for this child's animation interval
      final double startInterval = i * staggerDuration;
      final double endInterval = startInterval + 0.6; // 60% animation duration
      
      // Create animation map for this child
      final Map<String, Animation<dynamic>> animations = {};
      
      if (includeFade) {
        animations['fade'] = createFadeAnimation(
          controller: controller,
          beginInterval: startInterval,
          endInterval: endInterval,
        );
      }
      
      if (includeScale) {
        animations['scale'] = createScaleAnimation(
          controller: controller,
          beginInterval: startInterval,
          endInterval: endInterval,
        );
      }
      
      if (includeSlide) {
        animations['slide'] = createSlideAnimation(
          controller: controller,
          beginInterval: startInterval,
          endInterval: endInterval,
        );
      }
      
      // Apply animations to this child
      final animatedChild = applyAnimations(
        child: children[i],
        animations: animations,
      );
      
      animatedChildren.add(animatedChild);
    }
    
    return animatedChildren;
  }
}