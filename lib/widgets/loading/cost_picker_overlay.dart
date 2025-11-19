// lib/widgets/loading/cost_picker_overlay.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../main.dart';
import '../../config/design_system/dialog_theme.dart';

/// Global overlay entry for cost picker
OverlayEntry? _costPickerOverlay;

/// Shows a cost picker overlay on top of everything
/// Returns the selected cost or null if cancelled
///
/// This is the universal cost picker used in both:
/// - Preview mode (after food recognition)
/// - Food log editing (when editing existing items)
Future<double?> showCostPickerOverlay({
  required double initialValue,
  bool showManualInput = true,
  int maxDollars = 999,
}) async {
  final overlayState = navigatorKey.currentState?.overlay;
  if (overlayState == null) {
    debugPrint('❌ Overlay state is null');
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
              debugPrint('💰 Cost picker result: ${result != null ? "\$${result.toStringAsFixed(2)}" : "cancelled"}');
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
  debugPrint('✅ Cost picker overlay inserted');

  // Wait for result
  return completer.future;
}

/// Hide cost picker overlay
void _hideCostPickerOverlay() {
  if (_costPickerOverlay != null) {
    _costPickerOverlay?.remove();
    _costPickerOverlay = null;
    debugPrint('✅ Cost picker overlay removed');
  }
}

/// Cost picker overlay content widget
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
    return GestureDetector(
      onTap: () {
        // Tapping outside cancels
        widget.onResult(null);
      },
      child: Center(
        child: GestureDetector(
          onTap: () {
            // Prevent taps on dialog from closing it
          },
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 40),
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
    );
  }
}
