/// Temporary accent color palette extracted from reference image
/// These colors are for discussion and planning purposes
/// TODO: Integrate into the app's design system once usage is decided

import 'package:flutter/material.dart';

/// Vibrant accent colors from Memphis-style design reference
class TempAccentColors {
  TempAccentColors._();

  // Coral/Salmon - Top-left starburst, center-right blobs, bottom-right blob
  static const Color coral = Color(0xFFFF7B6B);

  // Bright Orange - Far right blob edge
  static const Color brightOrange = Color(0xFFFF8C42);

  // Golden Yellow - Bottom-left curve, star tips
  static const Color goldenYellow = Color(0xFFF5A623);

  // Pale Yellow - Star body center
  static const Color paleYellow = Color(0xFFFFDA85);

  // Bright Green - Top-right lightning, bottom-left blob
  static const Color brightGreen = Color(0xFF00D26A);

  // Electric Blue - Left arrows, bottom-right arrow
  static const Color electricBlue = Color(0xFF4169E1);

  // Periwinkle - Center arrow
  static const Color periwinkle = Color(0xFF8B9FFF);

  // Soft Pink - Top-center large blob
  static const Color softPink = Color(0xFFE8A0BF);

  // Hot Pink/Magenta - Right-side flower
  static const Color hotPink = Color(0xFFE84C8A);

  /// All colors as a list for easy iteration
  static const List<Color> all = [
    coral,
    brightOrange,
    goldenYellow,
    paleYellow,
    brightGreen,
    electricBlue,
    periwinkle,
    softPink,
    hotPink,
  ];

  /// Color names for reference
  static const List<String> names = [
    'Coral',
    'Bright Orange',
    'Golden Yellow',
    'Pale Yellow',
    'Bright Green',
    'Electric Blue',
    'Periwinkle',
    'Soft Pink',
    'Hot Pink',
  ];
}
