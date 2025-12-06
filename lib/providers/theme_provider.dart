// lib/providers/theme_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/design_system/theme_background.dart';  // ✅ NEW: Using ThemeBackground

class ThemeProvider extends ChangeNotifier {
  // Storage key
  static const String _gradientKey = 'selected_gradient';
  
  // Current selected gradient (default: '01' - light gray)
  String _selectedGradient = '01';
  
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
      final savedGradient = prefs.getString(_gradientKey);
      
      // ✅ NEW: Validate using ThemeBackground
      _selectedGradient = ThemeBackground.getValidThemeId(savedGradient);
      
      debugPrint('✅ Loaded gradient preference: $_selectedGradient');
    } catch (e) {
      debugPrint('❌ Error loading gradient preference: $e');
      _selectedGradient = ThemeBackground.defaultThemeId; // Fallback to default
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Change the selected gradient and save to storage
  Future<void> setGradient(String gradientName) async {
    // ✅ NEW: Validate using ThemeBackground
    if (!ThemeBackground.isValidTheme(gradientName)) {
      debugPrint('⚠️ Invalid gradient name: $gradientName, using default');
      gradientName = ThemeBackground.defaultThemeId;
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

  /// Get the current gradient (no brightness parameter needed)
  /// ✅ NEW: Using ThemeBackground.getGradient()
  LinearGradient getCurrentGradient() {
    return ThemeBackground.getGradient(_selectedGradient);
  }

  /// Get the gradient colors
  /// ✅ NEW: Using ThemeBackground.gradients
  List<Color> getCurrentGradientColors() {
    return ThemeBackground.gradients[_selectedGradient] ?? 
           ThemeBackground.gradients[ThemeBackground.defaultThemeId]!;
  }

  /// Get all available gradient names (01-09)
  /// ✅ NEW: Using ThemeBackground.availableThemes
  List<String> get availableGradients => ThemeBackground.availableThemes;

  /// Get display name for gradient (just returns the number)
  String getGradientDisplayName(String gradientName) {
    return 'Theme $gradientName';
  }

  /// Get gradient description (simple description)
  String getGradientDescription(String gradientName) {
    switch (gradientName) {
      case '01':
        return 'Light Gray - Minimal';
      case '02':
        return 'Light Blue - Calm';
      case '03':
        return 'Pink - Soft';
      case '04':
        return 'Yellow - Bright';
      case '05':
        return 'Green - Fresh';
      case '06':
        return 'Orange - Warm';
      case '07':
        return 'Cyan - Cool';
      case '08':
        return 'Purple - Elegant';
      case '09':
        return 'Brown - Earth';
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
        return '🔵'; // Blue circle
      case '03':
        return '🩷'; // Pink heart
      case '04':
        return '🟡'; // Yellow circle
      case '05':
        return '🟢'; // Green circle
      case '06':
        return '🟠'; // Orange circle
      case '07':
        return '🩵'; // Light blue
      case '08':
        return '🟣'; // Purple circle
      case '09':
        return '🤎'; // Brown heart
      default:
        return '🎨'; // Palette for unknown
    }
  }

}