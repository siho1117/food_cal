// lib/config/design_system/nutrition_colors.dart
import 'package:flutter/material.dart';

/// Nutrition-specific color palette for macros, calories, and health metrics
class NutritionColors {
  NutritionColors._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════
  // MACRONUTRIENT COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Protein color (red tone)
  static const Color proteinColor = Color(0xFFE74C3C);

  /// Carbohydrates color (amber tone)
  static const Color carbsColor = Color(0xFFF39C12);

  /// Fat color (green tone)
  static const Color fatColor = Color(0xFF27AE60);

  // ═══════════════════════════════════════════════════════════════
  // METRIC COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Calories color (blue tone)
  static const Color caloriesColor = Color(0xFF3498DB);

  /// Budget color (purple tone)
  static const Color budgetColor = Color(0xFF8E44AD);

  /// Exercise/Activity color (orange tone)
  static const Color exerciseColor = Color(0xFFE67E22);

  // ═══════════════════════════════════════════════════════════════
  // STATUS COLORS
  // ═══════════════════════════════════════════════════════════════

  /// Primary accent color
  static const Color primary = Color(0xFF3498DB);

  /// Success color (green)
  static const Color success = Color(0xFF27AE60);

  /// Warning color (amber)
  static const Color warning = Color(0xFFF39C12);

  /// Error color (red)
  static const Color error = Color(0xFFE74C3C);
}
