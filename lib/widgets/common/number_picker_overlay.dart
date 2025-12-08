// lib/widgets/common/number_picker_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../main.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../l10n/generated/app_localizations.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// UNIVERSAL NUMBER PICKER OVERLAY
// ═══════════════════════════════════════════════════════════════════════════════
//
// Overlay-based number picker for use in preview mode where z-index control is critical.
// Similar to cost_picker_overlay.dart but for integer/decimal values.
//
// Why overlay instead of dialog?
//   - Guaranteed z-index control (appears above preview overlay)
//   - Direct overlay insertion bypasses Flutter's dialog system
//   - Consistent behavior across different UI contexts
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Global overlay entry for number picker (singleton pattern)
OverlayEntry? _numberPickerOverlay;

/// Shows an integer number picker overlay on top of all UI elements.
///
/// **Parameters:**
/// - [title] - Title to display in the picker
/// - [initialValue] - The starting value to display
/// - [minValue] - Minimum selectable value
/// - [maxValue] - Maximum selectable value
/// - [step] - Step size for picker (default: 1)
///
/// **Returns:**
/// - [Future<int?>] - The selected value, or null if cancelled
Future<int?> showNumberPickerOverlay({
  required String title,
  required int initialValue,
  required int minValue,
  required int maxValue,
  int step = 1,
}) async {
  try {
    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [NumberPicker] Overlay state unavailable');
      return null;
    }

    // Remove any existing overlay first
    _numberPickerOverlay?.remove();
    _numberPickerOverlay = null;

    // Create completer for async result
    final completer = Completer<int?>();

    // Create new overlay entry with number picker
    _numberPickerOverlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: _NumberPickerOverlayContent(
              title: title,
              initialValue: initialValue,
              minValue: minValue,
              maxValue: maxValue,
              step: step,
              onResult: (result) {
                completer.complete(result);
                _hideNumberPickerOverlay();
              },
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlayState.insert(_numberPickerOverlay!);

    // Return future that completes when user makes selection
    return completer.future;
  } catch (e, stackTrace) {
    debugPrint('❌ [NumberPicker] Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
}

/// Shows a decimal number picker overlay on top of all UI elements.
///
/// **Parameters:**
/// - [title] - Title to display in the picker
/// - [initialValue] - The starting value to display
/// - [minValue] - Minimum selectable value
/// - [maxValue] - Maximum selectable value
/// - [decimalPlaces] - Number of decimal places (default: 1)
///
/// **Returns:**
/// - [Future<double?>] - The selected value, or null if cancelled
Future<double?> showDecimalPickerOverlay({
  required String title,
  required double initialValue,
  required double minValue,
  required double maxValue,
  int decimalPlaces = 1,
}) async {
  try {
    // Get the overlay from the global navigator key
    final overlayState = navigatorKey.currentState?.overlay;

    if (overlayState == null) {
      debugPrint('❌ [DecimalPicker] Overlay state unavailable');
      return null;
    }

    // Remove any existing overlay first
    _numberPickerOverlay?.remove();
    _numberPickerOverlay = null;

    // Create completer for async result
    final completer = Completer<double?>();

    // Create new overlay entry with decimal picker
    _numberPickerOverlay = OverlayEntry(
      builder: (context) => Material(
        type: MaterialType.transparency,
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: _DecimalPickerOverlayContent(
              title: title,
              initialValue: initialValue,
              minValue: minValue,
              maxValue: maxValue,
              decimalPlaces: decimalPlaces,
              onResult: (result) {
                completer.complete(result);
                _hideNumberPickerOverlay();
              },
            ),
          ),
        ),
      ),
    );

    // Insert overlay
    overlayState.insert(_numberPickerOverlay!);

    // Return future that completes when user makes selection
    return completer.future;
  } catch (e, stackTrace) {
    debugPrint('❌ [DecimalPicker] Error showing overlay: $e');
    debugPrint('Stack trace: $stackTrace');
    return null;
  }
}

/// Removes the number picker overlay from the screen.
void _hideNumberPickerOverlay() {
  try {
    if (_numberPickerOverlay != null) {
      _numberPickerOverlay?.remove();
      _numberPickerOverlay = null;
    }
  } catch (e) {
    debugPrint('❌ [NumberPicker] Error removing overlay: $e');
    _numberPickerOverlay = null;
  }
}

/// Internal widget for integer number picker overlay content
class _NumberPickerOverlayContent extends StatefulWidget {
  final String title;
  final int initialValue;
  final int minValue;
  final int maxValue;
  final int step;
  final Function(int?) onResult;

  const _NumberPickerOverlayContent({
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.onResult,
  });

  @override
  State<_NumberPickerOverlayContent> createState() => _NumberPickerOverlayContentState();
}

class _NumberPickerOverlayContentState extends State<_NumberPickerOverlayContent> {
  late int _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return GestureDetector(
      onTap: () => widget.onResult(null), // Tap outside to cancel
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps on dialog from dismissing
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: AppDialogTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Padding(
                    padding: AppDialogTheme.contentPadding,
                    child: Text(
                      widget.title,
                      style: AppDialogTheme.titleStyle,
                    ),
                  ),
                  // Number picker
                  NumberPicker(
                    value: _selectedValue,
                    minValue: widget.minValue,
                    maxValue: widget.maxValue,
                    step: widget.step,
                    onChanged: (value) => setState(() => _selectedValue = value),
                    textStyle: AppDialogTheme.bodyStyle.copyWith(
                      fontSize: 20,
                    ),
                    selectedTextStyle: AppDialogTheme.titleStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDialogTheme.borderRadiusSmall),
                      border: Border.all(
                        color: AppDialogTheme.inputBorderColor,
                        width: AppDialogTheme.inputBorderWidth,
                      ),
                    ),
                  ),
                  // Buttons
                  Padding(
                    padding: AppDialogTheme.actionsPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => widget.onResult(null),
                          style: AppDialogTheme.cancelButtonStyle,
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => widget.onResult(_selectedValue),
                          style: AppDialogTheme.primaryButtonStyle,
                          child: Text(l10n.ok),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Internal widget for decimal number picker overlay content
class _DecimalPickerOverlayContent extends StatefulWidget {
  final String title;
  final double initialValue;
  final double minValue;
  final double maxValue;
  final int decimalPlaces;
  final Function(double?) onResult;

  const _DecimalPickerOverlayContent({
    required this.title,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.decimalPlaces,
    required this.onResult,
  });

  @override
  State<_DecimalPickerOverlayContent> createState() => _DecimalPickerOverlayContentState();
}

class _DecimalPickerOverlayContentState extends State<_DecimalPickerOverlayContent> {
  late double _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Convert to integer representation for picker
    int intValue = (_selectedValue * 10).round();
    int intMin = (widget.minValue * 10).round();
    int intMax = (widget.maxValue * 10).round();

    return GestureDetector(
      onTap: () => widget.onResult(null), // Tap outside to cancel
      child: Container(
        color: Colors.transparent,
        child: Center(
          child: GestureDetector(
            onTap: () {}, // Prevent taps on dialog from dismissing
            child: Container(
              width: 300,
              decoration: BoxDecoration(
                color: AppDialogTheme.backgroundColor,
                borderRadius: BorderRadius.circular(AppDialogTheme.borderRadius),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title
                  Padding(
                    padding: AppDialogTheme.contentPadding,
                    child: Text(
                      widget.title,
                      style: AppDialogTheme.titleStyle,
                    ),
                  ),
                  // Decimal picker (using integer picker with text mapping)
                  NumberPicker(
                    value: intValue,
                    minValue: intMin,
                    maxValue: intMax,
                    onChanged: (newValue) {
                      setState(() {
                        _selectedValue = newValue / 10.0;
                      });
                    },
                    textStyle: AppDialogTheme.bodyStyle.copyWith(
                      fontSize: 20,
                    ),
                    selectedTextStyle: AppDialogTheme.titleStyle.copyWith(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppDialogTheme.borderRadiusSmall),
                      border: Border.all(
                        color: AppDialogTheme.inputBorderColor,
                        width: AppDialogTheme.inputBorderWidth,
                      ),
                    ),
                    textMapper: (numberText) {
                      final double displayValue = int.parse(numberText) / 10.0;
                      return displayValue.toStringAsFixed(widget.decimalPlaces);
                    },
                  ),
                  // Buttons
                  Padding(
                    padding: AppDialogTheme.actionsPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => widget.onResult(null),
                          style: AppDialogTheme.cancelButtonStyle,
                          child: Text(l10n.cancel),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: () => widget.onResult(_selectedValue),
                          style: AppDialogTheme.primaryButtonStyle,
                          child: Text(l10n.ok),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
