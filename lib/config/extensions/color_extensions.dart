import 'package:flutter/material.dart';

/// Extension methods on Color to simplify color operations.
///
/// These extensions reduce code duplication for common color
/// transformations like opacity adjustments, darkening/lightening,
/// and creating complementary colors.
extension ColorExtensions on Color {
  /// Get a lighter version of this color
  Color lighter([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Get a darker version of this color
  Color darker([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    
    final hsl = HSLColor.fromColor(this);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    
    return hsl.withLightness(lightness).toColor();
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
  
  /// Create a color with a specific opacity value
  Color withOpacity2(double opacity) {
    return Color.fromRGBO(red, green, blue, opacity);
  }
  
  /// Get a color with standard low opacity (for backgrounds)
  Color get withLowOpacity => withOpacity(0.1);
  
  /// Get a color with standard medium opacity
  Color get withMediumOpacity => withOpacity(0.3);
  
  /// Get a color with standard high opacity
  Color get withHighOpacity => withOpacity(0.7);
  
  /// Create a Material Color swatch from this color
  MaterialColor toMaterialColor() {
    final strengths = <double>[.05, .1, .2, .3, .4, .5, .6, .7, .8, .9];
    final swatch = <int, Color>{};
    final r = red, g = green, b = blue;

    for (final strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(value, swatch);
  }
  
  /// Get appropriate text color (black or white) based on background color
  Color get contrastTextColor {
    return computeLuminance() > 0.5 ? Colors.black : Colors.white;
  }
  
  /// Check if this color is considered dark
  bool get isDark => computeLuminance() < 0.5;
  
  /// Check if this color is considered light
  bool get isLight => computeLuminance() >= 0.5;
  
  /// Convert color to a hex string (with # prefix)
  String get toHex => '#${value.toRadixString(16).substring(2).padLeft(6, '0')}';
  
  /// Create a standard background color with low opacity
  Color get asBackground => withOpacity(0.1);
  
  /// Create a standard border color with medium opacity
  Color get asBorder => withOpacity(0.3);
  
  /// Create a gradient from this color to a target color
  LinearGradient gradientTo(Color targetColor, {
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    return LinearGradient(
      colors: [this, targetColor],
      begin: begin,
      end: end,
    );
  }
  
  /// Create a self-gradient from this color to a lighter or darker version
  LinearGradient selfGradient({
    bool toLighter = true,
    double amount = 0.3,
    AlignmentGeometry begin = Alignment.centerLeft,
    AlignmentGeometry end = Alignment.centerRight,
  }) {
    final targetColor = toLighter ? lighter(amount) : darker(amount);
    
    return LinearGradient(
      colors: [this, targetColor],
      begin: begin,
      end: end,
    );
  }
}