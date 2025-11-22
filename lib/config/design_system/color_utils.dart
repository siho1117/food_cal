import 'dart:math';
import 'package:flutter/material.dart';
import 'accent_colors.dart';

/// Color manipulation utilities for creating color harmonies and contrasts
///
/// Provides utilities for generating complementary colors, inverted colors,
/// and other color transformations useful for dynamic theming.
class ColorUtils {
  /// Get complementary color (opposite on color wheel)
  ///
  /// Rotates hue by 180 degrees for maximum contrast.
  /// This is "Option 1" - creates the strongest visual contrast.
  ///
  /// Example:
  /// - Blue (#6EA1F7) → Orange/Yellow
  /// - Orange (#FFC675) → Blue
  /// - Green (#B3C5AC) → Red/Purple
  ///
  /// Usage:
  /// ```dart
  /// final cardColor = ColorUtils.getComplementaryColor(backgroundColor);
  /// ```
  static Color getComplementaryColor(Color color) {
    // Convert RGB to HSL
    final hslColor = HSLColor.fromColor(color);

    // Rotate hue by 180 degrees (opposite on color wheel)
    final complementaryHue = (hslColor.hue + 180) % 360;

    // Create new color with rotated hue
    final complementary = hslColor.withHue(complementaryHue);

    return complementary.toColor();
  }

  /// Get color with inverted lightness
  ///
  /// Keeps the same hue and saturation but flips the lightness.
  /// This is "Option 2" - creates contrast while maintaining color family.
  ///
  /// Example:
  /// - Dark blue → Light blue (same hue, opposite brightness)
  /// - Light green → Dark green (same hue, opposite brightness)
  ///
  /// Usage:
  /// ```dart
  /// final cardColor = ColorUtils.getInvertedLightness(backgroundColor);
  /// ```
  static Color getInvertedLightness(Color color) {
    final hslColor = HSLColor.fromColor(color);

    // Invert lightness: 0.2 → 0.8, 0.8 → 0.2, 0.5 → 0.5
    final invertedLightness = 1.0 - hslColor.lightness;

    // Create new color with inverted lightness
    final inverted = hslColor.withLightness(invertedLightness);

    return inverted.toColor();
  }

  /// Adjust color saturation
  ///
  /// Increases or decreases color saturation while keeping hue and lightness.
  ///
  /// Usage:
  /// ```dart
  /// // Make color more vibrant
  /// final vibrant = ColorUtils.adjustSaturation(color, 0.2);
  ///
  /// // Make color more muted
  /// final muted = ColorUtils.adjustSaturation(color, -0.3);
  /// ```
  static Color adjustSaturation(Color color, double delta) {
    final hslColor = HSLColor.fromColor(color);

    // Clamp saturation between 0.0 and 1.0
    final newSaturation = (hslColor.saturation + delta).clamp(0.0, 1.0);

    return hslColor.withSaturation(newSaturation).toColor();
  }

  /// Adjust color lightness
  ///
  /// Increases or decreases color lightness while keeping hue and saturation.
  ///
  /// Usage:
  /// ```dart
  /// // Make color lighter
  /// final lighter = ColorUtils.adjustLightness(color, 0.2);
  ///
  /// // Make color darker
  /// final darker = ColorUtils.adjustLightness(color, -0.2);
  /// ```
  static Color adjustLightness(Color color, double delta) {
    final hslColor = HSLColor.fromColor(color);

    // Clamp lightness between 0.0 and 1.0
    final newLightness = (hslColor.lightness + delta).clamp(0.0, 1.0);

    return hslColor.withLightness(newLightness).toColor();
  }

  /// Get analogous color (adjacent on color wheel)
  ///
  /// Shifts hue by specified degrees (typically 30-60) for harmonious colors.
  ///
  /// Usage:
  /// ```dart
  /// // Get color 30 degrees clockwise on color wheel
  /// final analogous = ColorUtils.getAnalogousColor(color, 30);
  ///
  /// // Get color 30 degrees counter-clockwise
  /// final analogousReverse = ColorUtils.getAnalogousColor(color, -30);
  /// ```
  static Color getAnalogousColor(Color color, double degrees) {
    final hslColor = HSLColor.fromColor(color);

    // Rotate hue by specified degrees
    final newHue = (hslColor.hue + degrees) % 360;

    return hslColor.withHue(newHue).toColor();
  }

  /// Get triadic color (120 degrees on color wheel)
  ///
  /// Returns one of two triadic colors that form an equilateral triangle
  /// on the color wheel with the input color.
  ///
  /// Usage:
  /// ```dart
  /// // Get first triadic color (120° clockwise)
  /// final triadic1 = ColorUtils.getTriadicColor(color, clockwise: true);
  ///
  /// // Get second triadic color (120° counter-clockwise)
  /// final triadic2 = ColorUtils.getTriadicColor(color, clockwise: false);
  /// ```
  static Color getTriadicColor(Color color, {bool clockwise = true}) {
    final hslColor = HSLColor.fromColor(color);

    // Rotate hue by 120 degrees (or -120 for counter-clockwise)
    final rotation = clockwise ? 120.0 : -120.0;
    final newHue = (hslColor.hue + rotation) % 360;

    return hslColor.withHue(newHue).toColor();
  }

  /// Blend two colors together
  ///
  /// Linearly interpolates between two colors.
  ///
  /// Usage:
  /// ```dart
  /// // 50% mix of both colors
  /// final blended = ColorUtils.blendColors(color1, color2, 0.5);
  ///
  /// // 25% color1, 75% color2
  /// final blended = ColorUtils.blendColors(color1, color2, 0.75);
  /// ```
  static Color blendColors(Color color1, Color color2, double ratio) {
    return Color.lerp(color1, color2, ratio.clamp(0.0, 1.0))!;
  }

  /// Find the nearest accent color from the palette
  ///
  /// Uses weighted RGB distance to find the closest match from
  /// AccentColors.all palette. This accounts for human color perception.
  ///
  /// Usage:
  /// ```dart
  /// final complementary = ColorUtils.getComplementaryColor(backgroundColor);
  /// final accentColor = ColorUtils.findNearestAccentColor(complementary);
  /// ```
  static Color findNearestAccentColor(Color color) {
    Color nearestColor = AccentColors.all.first;
    double minDistance = double.infinity;

    for (final accentColor in AccentColors.all) {
      final distance = _colorDistance(color, accentColor);
      if (distance < minDistance) {
        minDistance = distance;
        nearestColor = accentColor;
      }
    }

    return nearestColor;
  }

  /// Calculate weighted color distance (accounts for human perception)
  /// Based on: https://www.compuphase.com/cmetric.htm
  static double _colorDistance(Color c1, Color c2) {
    final rmean = (c1.r + c2.r) / 2;
    final r = c1.r - c2.r;
    final g = c1.g - c2.g;
    final b = c1.b - c2.b;

    // Weighted Euclidean distance
    return sqrt(
      (2 + rmean / 256) * r * r +
          4 * g * g +
          (2 + (255 - rmean) / 256) * b * b,
    );
  }

  /// Get color name for debugging
  static String getAccentColorName(Color color) {
    final index = AccentColors.all.indexOf(color);
    if (index >= 0 && index < AccentColors.names.length) {
      return AccentColors.names[index];
    }
    return 'Unknown';
  }
}
