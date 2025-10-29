// lib/config/design_system/dialog_theme.dart
import 'package:flutter/material.dart';
import 'theme_design.dart';  // ✅ NEW: Using theme_design instead of theme

/// Dialog styling constants following the Dialog Style Guide
/// 
/// All dialogs in the app should use these constants for consistency.
/// Reference: DIALOG_STYLE_GUIDE.md
class AppDialogTheme {
  AppDialogTheme._(); // Private constructor to prevent instantiation

  // ═══════════════════════════════════════════════════════════════
  // DIALOG CONTAINER
  // ═══════════════════════════════════════════════════════════════
  
  /// Background color for dialog
  /// Always white for readability on all gradient backgrounds
  static const Color backgroundColor = Colors.white;
  
  /// Border radius for dialog container
  static const double borderRadius = 20.0;
  
  /// Shape for dialog container
  static final RoundedRectangleBorder shape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadius),
  );

  // ═══════════════════════════════════════════════════════════════
  // TITLE TEXT
  // ═══════════════════════════════════════════════════════════════
  
  /// Font size for dialog title
  static const double titleFontSize = 20.0;
  
  /// Font weight for dialog title
  static const FontWeight titleFontWeight = FontWeight.w600;
  
  /// Text color for dialog title
  static const Color titleColor = AppColors.textDark;  // ✅ Using AppColors
  
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
  static const double bodyFontSize = 16.0;
  
  /// Font weight for dialog body text
  static const FontWeight bodyFontWeight = FontWeight.w400;
  
  /// Text color for dialog body/message
  static Color get bodyColor => Colors.grey.shade700;
  
  /// Complete text style for dialog body
  static TextStyle get bodyStyle => TextStyle(
    fontSize: bodyFontSize,
    fontWeight: bodyFontWeight,
    color: bodyColor,
  );

  // ═══════════════════════════════════════════════════════════════
  // INPUT FIELDS (TextField)
  // ═══════════════════════════════════════════════════════════════
  
  /// Font size for input field text
  static const double inputFontSize = 16.0;
  
  /// Text color for input field
  static const Color inputTextColor = AppColors.textDark;  // ✅ Using AppColors
  
  /// Border radius for input fields
  static const double inputBorderRadius = 12.0;
  
  /// Default border color (unfocused)
  static Color get inputBorderColor => Colors.grey.shade300;
  
  /// Focused border color
  static const Color inputFocusedBorderColor = AppColors.textDark;  // ✅ Using AppColors
  
  /// Default border width
  static const double inputBorderWidth = 1.0;
  
  /// Focused border width
  static const double inputFocusedBorderWidth = 2.0;
  
  /// Content padding for input fields
  static const EdgeInsets inputContentPadding = EdgeInsets.symmetric(
    horizontal: 16.0,
    vertical: 12.0,
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
        borderSide: BorderSide(color: inputBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(color: inputBorderColor),
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
  
  /// Font size for all buttons
  static const double buttonFontSize = 16.0;
  
  /// Border radius for all buttons
  static const double buttonBorderRadius = 12.0;
  
  /// Padding for primary/filled buttons
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: 24.0,
    vertical: 12.0,
  );
  
  /// Gap between action buttons
  static const double buttonGap = 8.0;

  // ═══════════════════════════════════════════════════════════════
  // BUTTONS - CANCEL/SECONDARY (TextButton)
  // ═══════════════════════════════════════════════════════════════
  
  /// Text color for cancel button
  static Color get cancelButtonColor => Colors.grey.shade600;
  
  /// Text style for cancel button
  static TextStyle get cancelButtonTextStyle => TextStyle(
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
  static const Color primaryButtonBackgroundColor = AppColors.textDark;  // ✅ Using AppColors
  
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
  static Color get destructiveButtonBackgroundColor => Colors.red.shade600;
  
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
  static const EdgeInsets contentPadding = EdgeInsets.fromLTRB(24, 20, 24, 24);
  
  /// Padding around dialog actions
  static const EdgeInsets actionsPadding = EdgeInsets.fromLTRB(24, 0, 24, 20);
  
  /// Spacing between elements (e.g., between title and content)
  static const double elementSpacing = 16.0;
}