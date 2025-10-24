// lib/providers/theme_provider.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/design_system/theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Storage key
  static const String _gradientKey = 'selected_gradient';
  
  // Current selected gradient (default: 'home')
  String _selectedGradient = 'home';
  
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
      _selectedGradient = prefs.getString(_gradientKey) ?? 'home';
      
      debugPrint('✅ Loaded gradient preference: $_selectedGradient');
    } catch (e) {
      debugPrint('❌ Error loading gradient preference: $e');
      _selectedGradient = 'home'; // Fallback to default
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
      gradientName = 'home';
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

  /// Get the first color of the current gradient (useful for app bar)
  Color getTopColor(Brightness brightness, {double opacity = 0.7}) {
    final colors = getCurrentGradientColors(brightness);
    return colors.first.withOpacity(opacity);
  }

  /// Check if gradient name is valid
  bool _isValidGradient(String name) {
    return AppTheme.gradientsLight.containsKey(name);
  }

  /// Get all available gradient names
  List<String> get availableGradients => 
      AppTheme.gradientsLight.keys.toList();

  /// Get display name for gradient
  String getGradientDisplayName(String gradientName) {
    switch (gradientName) {
      case 'home':
        return 'Home (Purple)';
      case 'warm':
        return 'Warm (Coral)';
      case 'cool':
        return 'Cool (Teal)';
      case 'minimal':
        return 'Minimal (Beige)';
      default:
        return 'Unknown';
    }
  }

  /// Get gradient description
  String getGradientDescription(String gradientName) {
    switch (gradientName) {
      case 'home':
        return 'Purple and pink tones';
      case 'warm':
        return 'Coral and golden hues';
      case 'cool':
        return 'Mint and teal shades';
      case 'minimal':
        return 'Light and neutral';
      default:
        return '';
    }
  }
}