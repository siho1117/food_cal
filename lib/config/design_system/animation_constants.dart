// lib/config/design_system/animation_constants.dart

/// Animation duration constants for consistent timing across the app
class AnimationDurations {
  AnimationDurations._(); // Private constructor to prevent instantiation

  /// Very fast animations (200ms) - for quick feedback
  static const Duration fast = Duration(milliseconds: 200);

  /// Medium animations (600ms) - for standard UI transitions
  static const Duration medium = Duration(milliseconds: 600);

  /// Slow animations (800ms) - for emphasis
  static const Duration slow = Duration(milliseconds: 800);

  /// Very slow animations (1200ms) - for major state changes
  static const Duration verySlow = Duration(milliseconds: 1200);

  /// Extra slow animations (1500ms) - for elaborate effects
  static const Duration extraSlow = Duration(milliseconds: 1500);
}
