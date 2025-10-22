// lib/config/design_system/gradient_background.dart
import 'package:flutter/material.dart';
import 'theme.dart';

/// Flexible gradient background widget with multiple preset support
/// Automatically adapts to light/dark mode
/// 
/// Usage:
/// ```dart
/// GradientBackground(
///   gradientName: 'home',  // or 'warm', 'cool', 'minimal'
///   child: Scaffold(...),
/// )
/// ```
class GradientBackground extends StatelessWidget {
  final Widget child;
  final String gradientName;
  final Alignment? begin;
  final Alignment? end;
  
  const GradientBackground({
    super.key,
    required this.child,
    this.gradientName = 'home', // Default to home gradient
    this.begin,
    this.end,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.getGradient(
          gradientName,
          brightness,
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

/// Convenience constructors for specific gradients
extension GradientBackgroundPresets on GradientBackground {
  /// Home screen gradient (purple/pink → blue in light, dark purple in dark mode)
  static Widget home({required Widget child}) {
    return GradientBackground(
      gradientName: 'home',
      child: child,
    );
  }
  
  /// Warm gradient (coral → gold in light, dark burgundy in dark mode)
  static Widget warm({required Widget child}) {
    return GradientBackground(
      gradientName: 'warm',
      child: child,
    );
  }
  
  /// Cool gradient (mint → teal in light, dark teal in dark mode)
  static Widget cool({required Widget child}) {
    return GradientBackground(
      gradientName: 'cool',
      child: child,
    );
  }
  
  /// Minimal gradient (beige → white in light, dark gray in dark mode)
  static Widget minimal({required Widget child}) {
    return GradientBackground(
      gradientName: 'minimal',
      child: child,
    );
  }
}