// lib/widgets/common/cost_picker_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../main.dart';
import '../../config/design_system/dialog_theme.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// UNIVERSAL COST PICKER OVERLAY
// ═══════════════════════════════════════════════════════════════════════════════
//
// This is the single source of truth for cost input across the entire app.
// Used in both:
//   1. Preview mode - After AI food recognition (8-second preview period)
//   2. Edit mode - When editing existing food items in the log
//
// Why overlay instead of dialog?
//   - Guaranteed z-index control (no z-fighting with other overlays)
//   - Direct overlay insertion bypasses Flutter's dialog system
//   - Consistent behavior across different UI contexts
//
// Features:
//   - Dual-column NumberPicker for dollars and cents ($0.00 - $999.99)
//   - Optional manual input field for amounts > $999
//   - Tap outside to cancel
//   - Returns Future<double?> for async/await pattern
//
// ═══════════════════════════════════════════════════════════════════════════════

/// Global overlay entry for cost picker (singleton pattern)
OverlayEntry? _costPickerOverlay;

/// Shows a cost picker overlay on top of all UI elements.
///
/// This function creates and displays a cost input dialog using Flutter's
/// overlay system for guaranteed z-index control.
///
/// **Parameters:**
/// - [initialValue] - The starting cost value to display (default: 0.0)
/// - [showManualInput] - Whether to show manual text input field (default: true)
/// - [maxDollars] - Maximum dollar value for number picker (default: 999)
///
/// **Returns:**
/// - [Future<double?>] - The selected cost value, or null if cancelled
///
/// **Usage:**
/// ```dart
/// final cost = await showCostPickerOverlay(
///   initialValue: 5.99,
///   showManualInput: true,
///   maxDollars: 999,
/// );
/// if (cost != null) {
///   print('User selected: \$${cost.toStringAsFixed(2)}');
/// }
/// ```
Future<double?> showCostPickerOverlay({
  required double initialValue,
  bool showManualInput = true,
  int maxDollars = 999,
}) async {
  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) {
    debugPrint('❌ [CostPicker] Overlay state unavailable');
    return null;
  }

  // Remove any existing cost picker overlay
  _costPickerOverlay?.remove();
  _costPickerOverlay = null;

  // Create a completer to wait for result
  final completer = Completer<double?>();

  // Create overlay with cost picker dialog
  _costPickerOverlay = OverlayEntry(
    builder: (context) => Material(
      type: MaterialType.transparency,
      child: Container(
        color: Colors.black.withValues(alpha: 0.5),
        child: Center(
          child: _CostPickerOverlayContent(
            initialValue: initialValue,
            showManualInput: showManualInput,
            maxDollars: maxDollars,
            onResult: (result) {
              completer.complete(result);
              _hideCostPickerOverlay();
            },
          ),
        ),
      ),
    ),
  );

  // Insert overlay on top
  overlayState.insert(_costPickerOverlay!);

  // Wait for result
  return completer.future;
}

/// Removes the cost picker overlay from the screen.
///
/// This is called automatically when user selects a value or cancels,
/// but can also be called manually if needed.
void _hideCostPickerOverlay() {
  _costPickerOverlay?.remove();
  _costPickerOverlay = null;
}

/// Internal widget that renders the cost picker UI.
///
/// This is a private StatefulWidget that manages:
/// - Dual NumberPicker columns (dollars and cents)
/// - Optional manual text input field
/// - Save/Cancel buttons
/// - Value selection logic
///
/// **State management:**
/// - [selectedDollars] - Current dollar value (0-999)
/// - [selectedCents] - Current cents value (0-99)
/// - [useManualInput] - Flag to determine which input method to use
/// - [manualInputController] - TextEditingController for manual input field
class _CostPickerOverlayContent extends StatefulWidget {
  final double initialValue;
  final bool showManualInput;
  final int maxDollars;
  final Function(double?) onResult;

  const _CostPickerOverlayContent({
    required this.initialValue,
    required this.showManualInput,
    required this.maxDollars,
    required this.onResult,
  });

  @override
  State<_CostPickerOverlayContent> createState() => _CostPickerOverlayContentState();
}

class _CostPickerOverlayContentState extends State<_CostPickerOverlayContent> {
  late int selectedDollars;
  late int selectedCents;
  late TextEditingController manualInputController;
  late bool useManualInput;

  @override
  void initState() {
    super.initState();
    // Split initial value into dollars and cents
    selectedDollars = widget.initialValue.floor();
    selectedCents = ((widget.initialValue - selectedDollars) * 100).round();

    // Initialize manual input controller
    manualInputController = TextEditingController();
    useManualInput = widget.initialValue > widget.maxDollars;

    if (useManualInput) {
      manualInputController.text = widget.initialValue.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    manualInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get keyboard height to adjust dialog position
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        // Tapping outside cancels
        widget.onResult(null);
      },
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Center(
          child: SingleChildScrollView(
            child: GestureDetector(
              onTap: () {
                // Dismiss keyboard when tapping on dialog background
                FocusScope.of(context).unfocus();
              },
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
                padding: AppDialogTheme.contentPadding,
                decoration: BoxDecoration(
                  color: AppDialogTheme.backgroundColor,
                  borderRadius: AppDialogTheme.shape.borderRadius,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    Text(
                      'Add Cost per Serving',
                      style: AppDialogTheme.titleStyle,
                    ),
                    const SizedBox(height: 24),
                    // Dual-column picker
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Dollar picker
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$',
                              style: AppDialogTheme.bodyStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            NumberPicker(
                              value: selectedDollars > widget.maxDollars ? 0 : selectedDollars,
                              minValue: 0,
                              maxValue: widget.maxDollars,
                              onChanged: (value) => setState(() {
                                selectedDollars = value;
                                useManualInput = false;
                              }),
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
                          ],
                        ),
                        // Decimal point
                        Padding(
                          padding: const EdgeInsets.only(top: 32, left: 8, right: 8),
                          child: Text(
                            '.',
                            style: AppDialogTheme.titleStyle.copyWith(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        // Cents picker
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'cents',
                              style: AppDialogTheme.bodyStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            NumberPicker(
                              value: selectedCents,
                              minValue: 0,
                              maxValue: 99,
                              onChanged: (value) => setState(() {
                                selectedCents = value;
                                useManualInput = false;
                              }),
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
                                return int.parse(numberText).toString().padLeft(2, '0');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    // Optional manual input section
                    if (widget.showManualInput) ...[
                      const SizedBox(height: 16),
                      // Divider
                      Container(
                        height: 1,
                        color: AppDialogTheme.inputBorderColor,
                      ),
                      const SizedBox(height: 16),
                      // Manual input field
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Or enter amount over \$${widget.maxDollars}:',
                            style: AppDialogTheme.bodyStyle.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: manualInputController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            style: AppDialogTheme.inputTextStyle,
                            decoration: AppDialogTheme.inputDecoration(
                              hintText: 'e.g., 1234.56',
                            ).copyWith(
                              prefixText: '\$ ',
                              prefixStyle: AppDialogTheme.inputTextStyle,
                            ),
                            onChanged: (value) {
                              if (value.isNotEmpty) {
                                setState(() => useManualInput = true);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    // Action buttons matching existing design
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => widget.onResult(null),
                          style: AppDialogTheme.cancelButtonStyle,
                          child: const Text('Cancel'),
                        ),
                        const SizedBox(width: AppDialogTheme.buttonGap),
                        FilledButton(
                          onPressed: () {
                            double? result;

                            if (useManualInput && manualInputController.text.isNotEmpty) {
                              // Use manual input
                              result = double.tryParse(manualInputController.text);
                            } else {
                              // Use picker values
                              result = selectedDollars + (selectedCents / 100.0);
                            }

                            widget.onResult(result);
                          },
                          style: AppDialogTheme.primaryButtonStyle,
                          child: const Text('Save'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
