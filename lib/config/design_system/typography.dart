// lib/config/design_system/typography.dart
import 'package:flutter/material.dart';

/// System Font Typography (True Platform-Native)
/// - No explicit fontFamily: Flutter uses OS default (SF on iOS, Roboto on Android, system on Web)
/// - Zero Google Fonts, zero size overhead
/// - OS handles CJK/RTL fallbacks automatically
class AppTypography {
  AppTypography._();

  // Base style: let platform choose the correct system font
  static const TextStyle _base = TextStyle();

  // ───────── LOCALE ADAPTATION ─────────
  /// Adjusts letter-spacing for CJK languages (Chinese, Japanese, Korean)
  /// CJK characters don't benefit from Latin letter-spacing and look stretched
  /// when aggressive tracking (>0.25) is applied.
  static TextStyle forLocale(TextStyle base, Locale locale) {
    final lang = locale.languageCode.toLowerCase();
    final isCJK = lang == 'zh' || lang == 'ja' || lang == 'ko';

    // Remove aggressive tracking for CJK; keep subtle tracking for Latin
    final ls = base.letterSpacing ?? 0;
    if (isCJK && ls > 0.25) {
      return base.copyWith(letterSpacing: 0);
    }
    return base;
  }

  // ───────── DISPLAY (Headings) ─────────
  static TextStyle displayXLarge = _base.copyWith(
    fontSize: 42,
    fontWeight: FontWeight.w900,
    height: 1.2,
    letterSpacing: 2.0,
  );

  static TextStyle displayLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: 1.5,
  );

  static TextStyle displayMedium = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static TextStyle displaySmall = _base.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 0.25,
  );

  // ───────── BODY (Paragraphs) ─────────
  static TextStyle bodyLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.6,
    letterSpacing: 0.15,
  );

  static TextStyle bodyMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    letterSpacing: 0.25,
  );

  static TextStyle bodySmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
  );

  // ───────── LABEL (Buttons / UI) ─────────
  static TextStyle labelLarge = _base.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0.5,
  );

  static TextStyle labelMedium = _base.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  static TextStyle labelSmall = _base.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    letterSpacing: 0.5,
  );

  // ───────── DATA (Numbers / Metrics) ─────────
  static TextStyle dataXLarge = _base.copyWith(
    fontSize: 48,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
  );

  static TextStyle dataLarge = _base.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.2,
    letterSpacing: -0.25,
  );

  static TextStyle dataMedium = _base.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  static TextStyle dataSmall = _base.copyWith(
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.3,
  );

  // ───────── UTILITY ─────────
  static TextStyle overline = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.3,
    letterSpacing: 1.5,
    // Uppercasing should be applied to the string, not here.
  );

  static TextStyle caption = _base.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    letterSpacing: 0.4,
  );
}

/// Convenience extension for applying locale-aware text style adjustments
/// Usage: AppTypography.displayLarge.adaptFor(context)
extension LocaleAdaptiveTextStyle on TextStyle {
  TextStyle adaptFor(BuildContext context) =>
      AppTypography.forLocale(this, Localizations.localeOf(context));
}