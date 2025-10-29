// lib/providers/theme_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/design_system/theme_design.dart';

class ThemeProvider extends ChangeNotifier {
  // Storage key
  static const String _gradientKey = 'selected_gradient';
  
  // Current selected gradient (default: '03' - purple)
  String _selectedGradient = '03';
  
  // Loading state
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // Getter for selected gradient
  String get selectedGradient => _selectedGradient;

  /// Initialize and load saved gradient preference
  Future<void> loadGradient() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _selectedGradient = prefs.getString(_gradientKey) ?? '03';
      
      debugPrint('✅ Loaded gradient preference: $_selectedGradient');
    } catch (e) {
      debugPrint('❌ Error loading gradient preference: $e');
      _selectedGradient = '03'; // Fallback to default (purple)
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change the selected gradient and save to storage
  Future<void> setGradient(String gradientName) async {
    // Validate gradient name exists
    if (!_isValidGradient(gradientName)) {
      debugPrint('⚠️ Invalid gradient name: $gradientName, using default');
      gradientName = '03';
    }

    _selectedGradient = gradientName;
    notifyListeners();

    // Save to SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_gradientKey, gradientName);
      debugPrint('✅ Saved gradient preference: $gradientName');
    } catch (e) {
      debugPrint('❌ Error saving gradient preference: $e');
    }
  }

  /// Get the current gradient for the specified brightness
  LinearGradient getCurrentGradient(Brightness brightness) {
    return AppTheme.getGradient(_selectedGradient, brightness);
  }

  /// Get the gradient colors for the specified brightness
  List<Color> getCurrentGradientColors(Brightness brightness) {
    return AppTheme.getGradientColors(_selectedGradient, brightness);
  }

  /// Get adaptive border color for current gradient
  Color getBorderColor(Brightness brightness) {
    return AppTheme.getBorderColor(_selectedGradient, brightness);
  }

  /// Get adaptive text color for current gradient
  Color getTextColor(Brightness brightness) {
    return AppTheme.getTextColor(_selectedGradient, brightness);
  }

  /// Get the first color of the current gradient (useful for app bar)
  Color getTopColor(Brightness brightness, {double opacity = 0.7}) {
    final colors = getCurrentGradientColors(brightness);
    return colors.first.withOpacity(opacity);
  }

  /// Check if gradient name is valid
  bool _isValidGradient(String name) {
    return AppTheme.gradientsLight.containsKey(name);
  }

  /// Get all available gradient names (01-09)
  List<String> get availableGradients => 
      AppTheme.gradientsLight.keys.toList()..sort(); // Sort to ensure 01, 02, 03... order

  /// Get display name for gradient (just returns the number)
  String getGradientDisplayName(String gradientName) {
    return 'Theme $gradientName';
  }

  /// Get gradient description (simple description)
  String getGradientDescription(String gradientName) {
    switch (gradientName) {
      case '01':
        return 'Light minimal gray';
      case '02':
        return 'Dark midnight';
      case '03':
        return 'Purple blue';
      case '04':
        return 'Warm sunrise';
      case '05':
        return 'Soft coral';
      case '06':
        return 'Ocean blue';
      case '07':
        return 'Fresh mint';
      case '08':
        return 'Warm peach';
      case '09':
        return 'Cool teal';
      default:
        return 'Custom theme';
    }
  }

  /// Get emoji for gradient (for theme selector)
  String getGradientEmoji(String gradientName) {
    switch (gradientName) {
      case '01':
        return '⚪'; // White circle for minimal
      case '02':
        return '⬛'; // Black square for midnight
      case '03':
        return '🟣'; // Purple circle
      case '04':
        return '🟡'; // Yellow circle for sunrise
      case '05':
        return '🌸'; // Flower for coral
      case '06':
        return '🔵'; // Blue circle for ocean
      case '07':
        return '🟢'; // Green circle for mint
      case '08':
        return '🧡'; // Orange heart for warm
      case '09':
        return '💠'; // Diamond for cool teal
      default:
        return '🎨'; // Palette for unknown
    }
  }
}