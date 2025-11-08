// lib/config/design_system/dialog_theme.dart
import 'package:flutter/material.dart';

/// Dialog styling constants following the Dialog Style Guide
///
/// All dialogs in the app should use these constants for consistency.
/// Reference: DIALOG_STYLE_GUIDE.md
///
/// This is part of the NEW design system and is independent from legacy theme files.
class AppDialogTheme {
  AppDialogTheme._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════
  // COLOR PALETTE (Independent from legacy design system)
  // ═══════════════════════════════════════════════════════════════

  /// Primary dark color for text and buttons
  static const Color colorPrimaryDark = Color(0xFF1A1A1A);

  /// Secondary text color (muted/gray)
  static const Color colorTextSecondary = Color(0xFF616161);

  /// Border color for inputs (light gray)
  static const Color colorBorderLight = Color(0xFFE0E0E0);

  /// Cancel/secondary button color
  static const Color colorSecondary = Color(0xFF757575);

  /// Destructive action color (red)
  static const Color colorDestructive = Color(0xFFE53935);

  // ═══════════════════════════════════════════════════════════════
  // SIZING SCALE (Consolidated)
  // ═══════════════════════════════════════════════════════════════

  /// Standard font size for body text, inputs, and buttons
  static const double fontSizeStandard = 16.0;

  /// Title font size
  static const double fontSizeTitle = 20.0;

  /// Border radius for inputs and buttons
  static const double borderRadiusSmall = 12.0;

  /// Border radius for dialog container
  static const double borderRadiusMedium = 20.0;

  /// Standard border width
  static const double borderWidthStandard = 1.0;

  /// Focused border width
  static const double borderWidthFocused = 2.0;

  // ═══════════════════════════════════════════════════════════════
  // SPACING SCALE
  // ═══════════════════════════════════════════════════════════════

  /// Extra small spacing (8px)
  static const double spaceXS = 8.0;

  /// Small spacing (12px)
  static const double spaceSM = 12.0;

  /// Medium spacing (16px)
  static const double spaceMD = 16.0;

  /// Large spacing (24px)
  static const double spaceLG = 24.0;

  // ═══════════════════════════════════════════════════════════════
  // DIALOG CONTAINER
  // ═══════════════════════════════════════════════════════════════

  /// Background color for dialog
  /// Always white for readability on all gradient backgrounds
  static const Color backgroundColor = Colors.white;

  /// Border radius for dialog container
  static const double borderRadius = borderRadiusMedium;

  /// Shape for dialog container
  static final RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadius),
  );

  // ═══════════════════════════════════════════════════════════════
  // TITLE TEXT
  // ═══════════════════════════════════════════════════════════════

  /// Font size for dialog title
  static const double titleFontSize = fontSizeTitle;

  /// Font weight for dialog title
  static const FontWeight titleFontWeight = FontWeight.w600;

  /// Text color for dialog title
  static const Color titleColor = colorPrimaryDark;

  /// Complete text style for dialog title
  static const TextStyle titleStyle = TextStyle(
    fontSize: titleFontSize,
    fontWeight: titleFontWeight,
    color: titleColor,
  );

  // ═══════════════════════════════════════════════════════════════
  // BODY/MESSAGE TEXT
  // ═══════════════════════════════════════════════════════════════

  /// Font size for dialog body/message text
  static const double bodyFontSize = fontSizeStandard;

  /// Font weight for dialog body text
  static const FontWeight bodyFontWeight = FontWeight.w400;

  /// Text color for dialog body/message
  static const Color bodyColor = colorTextSecondary;

  /// Complete text style for dialog body
  static const TextStyle bodyStyle = TextStyle(
    fontSize: bodyFontSize,
    fontWeight: bodyFontWeight,
    color: bodyColor,
  );

  // ═══════════════════════════════════════════════════════════════
  // INPUT FIELDS (TextField)
  // ═══════════════════════════════════════════════════════════════

  /// Font size for input field text
  static const double inputFontSize = fontSizeStandard;

  /// Text color for input field
  static const Color inputTextColor = colorPrimaryDark;

  /// Border radius for input fields
  static const double inputBorderRadius = borderRadiusSmall;

  /// Default border color (unfocused)
  static const Color inputBorderColor = colorBorderLight;

  /// Focused border color
  static const Color inputFocusedBorderColor = colorPrimaryDark;

  /// Default border width
  static const double inputBorderWidth = borderWidthStandard;

  /// Focused border width
  static const double inputFocusedBorderWidth = borderWidthFocused;

  /// Content padding for input fields
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: spaceMD,
    vertical: spaceSM,
  );

  /// Complete text style for input field
  static const TextStyle inputTextStyle = TextStyle(
    fontSize: inputFontSize,
    color: inputTextColor,
  );

  /// Input decoration for text fields
  static InputDecoration inputDecoration({String? hintText}) {
    return InputDecoration(
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(color: inputBorderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: const BorderSide(
          color: inputFocusedBorderColor,
          width: inputFocusedBorderWidth,
        ),
      ),
      contentPadding: inputContentPadding,
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // BUTTONS - GENERAL
  // ═══════════════════════════════════════════════════════════════

  /// Font size for all buttons (same as standard font size)
  static const double buttonFontSize = fontSizeStandard;

  /// Border radius for all buttons
  static const double buttonBorderRadius = borderRadiusSmall;

  /// Padding for primary/filled buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: spaceLG,
    vertical: spaceSM,
  );

  /// Gap between action buttons
  static const double buttonGap = spaceXS;

  // ═══════════════════════════════════════════════════════════════
  // BUTTONS - CANCEL/SECONDARY (TextButton)
  // ═══════════════════════════════════════════════════════════════

  /// Text color for cancel button
  static const Color cancelButtonColor = colorSecondary;

  /// Text style for cancel button
  static const TextStyle cancelButtonTextStyle = TextStyle(
    fontSize: buttonFontSize,
    color: cancelButtonColor,
  );

  /// Complete button style for cancel button
  static ButtonStyle get cancelButtonStyle => TextButton.styleFrom(
    foregroundColor: cancelButtonColor,
    textStyle: const TextStyle(fontSize: buttonFontSize),
  );

  // ═══════════════════════════════════════════════════════════════
  // BUTTONS - PRIMARY/CONFIRM (FilledButton)
  // ═══════════════════════════════════════════════════════════════

  /// Background color for primary button
  static const Color primaryButtonBackgroundColor = colorPrimaryDark;

  /// Text color for primary button
  static const Color primaryButtonTextColor = Colors.white;

  /// Complete button style for primary button
  static ButtonStyle get primaryButtonStyle => FilledButton.styleFrom(
    backgroundColor: primaryButtonBackgroundColor,
    foregroundColor: primaryButtonTextColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: buttonPadding,
    textStyle: const TextStyle(fontSize: buttonFontSize),
  );

  // ═══════════════════════════════════════════════════════════════
  // BUTTONS - DESTRUCTIVE (FilledButton)
  // ═══════════════════════════════════════════════════════════════

  /// Background color for destructive button
  static const Color destructiveButtonBackgroundColor = colorDestructive;

  /// Text color for destructive button
  static const Color destructiveButtonTextColor = Colors.white;

  /// Complete button style for destructive button
  static ButtonStyle get destructiveButtonStyle => FilledButton.styleFrom(
    backgroundColor: destructiveButtonBackgroundColor,
    foregroundColor: destructiveButtonTextColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(buttonBorderRadius),
    ),
    padding: buttonPadding,
    textStyle: const TextStyle(fontSize: buttonFontSize),
  );

  // ═══════════════════════════════════════════════════════════════
  // SPACING & LAYOUT
  // ═══════════════════════════════════════════════════════════════

  /// Padding around dialog content
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(
    spaceLG,
    spaceLG - 4.0,  // 20px
    spaceLG,
    spaceLG,
  );

  /// Padding around dialog actions
  static const EdgeInsets actionsPadding = EdgeInsets.fromLTRB(
    spaceLG,
    0,
    spaceLG,
    spaceLG - 4.0,  // 20px
  );

  /// Spacing between elements (e.g., between title and content)
  static const double elementSpacing = spaceMD;
}