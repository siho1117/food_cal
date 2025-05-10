import 'package:flutter/material.dart';

/// Extension methods on Color for specialized color operations.
///
/// This streamlined version focuses on methods not covered by the AppTheme class,
/// providing only functionality that's truly needed for specialized use cases.
extension ColorExtensions on Color {
  /// Create a self-gradient from this color to a lighter or darker version
  LinearGradient selfGradient({
    bool toLighter = true,
    double amount = 0.3,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    final HSLColor hslColor = HSLColor.fromColor(this);
    final targetLightness = toLighter 
        ? (hslColor.lightness + amount).clamp(0.0, 1.0)
        : (hslColor.lightness - amount).clamp(0.0, 1.0);
    
    final targetColor = hslColor.withLightness(targetLightness).toColor();
    
    return LinearGradient(
      colors: [this, targetColor],
      begin: begin,
      end: end,
    );
  }

  /// Create a gradient from this color to a target color
  LinearGradient gradientTo(
    Color targetColor, {
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: [this, targetColor],
      begin: begin,
      end: end,
    );
  }
  
  /// Get a more saturated version of this color
  Color moresaturated([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation + amount).clamp(0.0, 1.0);
    
    return hsl.withSaturation(saturation).toColor();
  }
  
  /// Get a less saturated version of this color
  Color lessSaturated([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final saturation = (hsl.saturation - amount).clamp(0.0, 1.0);
    
    return hsl.withSaturation(saturation).toColor();
  }
  
  /// Get the complementary color (opposite on color wheel)
  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final hue = (hsl.hue + 180) % 360;
    
    return hsl.withHue(hue).toColor();
  }
  
  /// Convert color to a hex string (with # prefix)
  String get toHex => '#${value.toRadixString(16).substring(2).padLeft(6, '0')}';
}