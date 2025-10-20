// lib/config/design_system/typography.dart
import 'package:flutter/material.dart';

/// System Font Typography Configuration
/// Uses platform-native fonts for multi-language support
/// iOS: SF Pro Display/Text
/// Android: Roboto + Noto Sans CJK
/// Web: system-ui fallback
/// 
/// NO Google Fonts dependency required - zero app size overhead
/// Automatic support for English, Chinese, Japanese, Korean, Thai, Arabic, etc.
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // ─────────────────────────────────────────────────────────────
  // Base System Font Definition
  // ─────────────────────────────────────────────────────────────
  
  /// System font family - uses native fonts on each platform
  /// This single declaration works for ALL languages
  static const String _systemFont = '-apple-system';
  static const List<String> _fontFamilyFallback = [
    'SF Pro Display',      // iOS primary
    'SF Pro Text',         // iOS text
    'Roboto',              // Android primary
    'Noto Sans',           // Android CJK fallback
    'system-ui',           // Web fallback
    'sans-serif',          // Ultimate fallback
  ];

  /// Base text style with system font
  static const TextStyle _baseStyle = TextStyle(
    fontFamily: _systemFont,
    fontFamilyFallback: _fontFamilyFallback,
  );

  // ─────────────────────────────────────────────────────────────
  // DISPLAY STYLES - Large headings, branding, screen titles
  // ─────────────────────────────────────────────────────────────

  /// Display Extra Large - App branding, hero text
  /// Usage: Splash screen app name, major branding
  static TextStyle displayXLarge = _baseStyle.copyWith(
    fontSize: 42,
    fontWeight: FontWeight.w900,  // Black weight
    height: 1.2,
    letterSpacing: 2.0,
  );

  /// Display Large - Primary screen titles
  /// Usage: Main screen headers (HOME, SETTINGS, PROGRESS)
  static TextStyle displayLarge = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,  // Bold
    height: 1.2,
    letterSpacing: 1.5,
  );

  /// Display Medium - Secondary screen titles
  /// Usage: Section headers, card titles
  static TextStyle displayMedium = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.3,
    letterSpacing: 0.5,
  );

  /// Display Small - Subsection headers
  /// Usage: Widget titles, group headers
  static TextStyle displaySmall = _baseStyle.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.3,
    letterSpacing: 0.25,
  );

  // ─────────────────────────────────────────────────────────────
  // BODY STYLES - Regular content, paragraphs, descriptions
  // ─────────────────────────────────────────────────────────────

  /// Body Large - Primary body text
  /// Usage: Main content, descriptions, long text
  static TextStyle bodyLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.6,
    letterSpacing: 0.15,
  );

  /// Body Medium - Secondary body text
  /// Usage: Supporting text, captions, metadata
  static TextStyle bodyMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.5,
    letterSpacing: 0.25,
  );

  /// Body Small - Tertiary body text
  /// Usage: Fine print, hints, footnotes, timestamps
  static TextStyle bodySmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.4,
    letterSpacing: 0.4,
  );

  // ─────────────────────────────────────────────────────────────
  // LABEL STYLES - UI elements, buttons, form fields
  // ─────────────────────────────────────────────────────────────

  /// Label Large - Large buttons, important form labels
  /// Usage: Primary action buttons, main form fields
  static TextStyle labelLarge = _baseStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.25,
    letterSpacing: 0.5,
  );

  /// Label Medium - Medium buttons, tabs, chips
  /// Usage: Secondary buttons, tab labels, navigation
  static TextStyle labelMedium = _baseStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.3,
    letterSpacing: 0.5,
  );

  /// Label Small - Small buttons, badges, tags
  /// Usage: Tertiary buttons, status badges, small UI elements
  static TextStyle labelSmall = _baseStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.3,
    letterSpacing: 0.5,
  );

  // ─────────────────────────────────────────────────────────────
  // DATA STYLES - Numbers, metrics, statistics
  // ─────────────────────────────────────────────────────────────

  /// Data Display Extra Large - Hero numbers
  /// Usage: Main calorie count, weight display
  static TextStyle dataXLarge = _baseStyle.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,  // Bold
    height: 1.2,
    letterSpacing: -0.5,  // Tighter for numbers
  );

  /// Data Display Large - Primary metrics
  /// Usage: Daily totals, nutrition values
  static TextStyle dataLarge = _baseStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.2,
    letterSpacing: -0.25,
  );

  /// Data Display Medium - Secondary metrics
  /// Usage: Card statistics, progress numbers
  static TextStyle dataMedium = _baseStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.3,
    letterSpacing: 0,
  );

  /// Data Display Small - Inline numbers
  /// Usage: Small stats, inline values
  static TextStyle dataSmall = _baseStyle.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,  // Medium
    height: 1.3,
    letterSpacing: 0,
  );

  // ─────────────────────────────────────────────────────────────
  // UTILITY STYLES - Special use cases
  // ─────────────────────────────────────────────────────────────

  /// Overline - Labels, tags, categories
  /// Usage: Section labels, category tags, timestamps
  static TextStyle overline = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,  // SemiBold
    height: 1.3,
    letterSpacing: 1.5,
    // Note: Use .toUpperCase() on the text string for uppercase
  );

  /// Caption - Very small supporting text
  /// Usage: Image captions, legal text, helper text
  static TextStyle caption = _baseStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,  // Regular
    height: 1.4,
    letterSpacing: 0.4,
  );

  // ─────────────────────────────────────────────────────────────
  // USAGE EXAMPLES
  // ─────────────────────────────────────────────────────────────
  
  /// Example 1: App Branding
  /// Text(
  ///   'FOOD CAL',
  ///   style: AppTypography.displayXLarge.copyWith(
  ///     color: AppTheme.primaryBlue,
  ///   ),
  /// )
  
  /// Example 2: Screen Title
  /// Text(
  ///   AppLocalizations.of(context)!.settingsTitle,
  ///   style: AppTypography.displayLarge.copyWith(
  ///     color: AppTheme.primaryBlue,
  ///   ),
  /// )
  
  /// Example 3: Body Text
  /// Text(
  ///   'Track your daily nutrition intake and reach your goals',
  ///   style: AppTypography.bodyLarge.copyWith(
  ///     color: AppTheme.textDark,
  ///   ),
  /// )
  
  /// Example 4: Button Label
  /// Text(
  ///   AppLocalizations.of(context)!.save,
  ///   style: AppTypography.labelLarge.copyWith(
  ///     color: Colors.white,
  ///   ),
  /// )
  
  /// Example 5: Calorie Display
  /// Text(
  ///   '1,847',
  ///   style: AppTypography.dataLarge.copyWith(
  ///     color: AppTheme.primaryBlue,
  ///   ),
  /// )
  
  /// Example 6: Mixed Language (English + Chinese)
  /// Text(
  ///   'Calories / 卡路里',
  ///   style: AppTypography.bodyMedium.copyWith(
  ///     color: Colors.grey[700],
  ///   ),
  /// )
  /// System font automatically handles the Chinese characters!
}