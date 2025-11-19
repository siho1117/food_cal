import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import '../../config/design_system/dialog_theme.dart';

/// Shows a dialog with an integer number picker
/// Returns the selected value or null if cancelled
Future<int?> showNumberPickerDialog({
  required BuildContext context,
  required String title,
  required int initialValue,
  required int minValue,
  required int maxValue,
  int step = 1,
}) async {
  int selectedValue = initialValue;

  return showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppDialogTheme.backgroundColor,
            shape: AppDialogTheme.shape,
            contentPadding: AppDialogTheme.contentPadding,
            actionsPadding: AppDialogTheme.actionsPadding,
            title: Text(
              title,
              style: AppDialogTheme.titleStyle,
            ),
            content: NumberPicker(
              value: selectedValue,
              minValue: minValue,
              maxValue: maxValue,
              step: step,
              onChanged: (value) => setState(() => selectedValue = value),
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
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppDialogTheme.cancelButtonStyle,
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(selectedValue),
                style: AppDialogTheme.primaryButtonStyle,
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Shows a dialog with a decimal number picker
/// Returns the selected value or null if cancelled
Future<double?> showDecimalPickerDialog({
  required BuildContext context,
  required String title,
  required double initialValue,
  required double minValue,
  required double maxValue,
  int decimalPlaces = 1,
}) async {
  double selectedValue = initialValue;

  return showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppDialogTheme.backgroundColor,
            shape: AppDialogTheme.shape,
            contentPadding: AppDialogTheme.contentPadding,
            actionsPadding: AppDialogTheme.actionsPadding,
            title: Text(
              title,
              style: AppDialogTheme.titleStyle,
            ),
            content: DecimalNumberPicker(
              value: selectedValue,
              minValue: minValue,
              maxValue: maxValue,
              decimalPlaces: decimalPlaces,
              onChanged: (value) => setState(() => selectedValue = value),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppDialogTheme.cancelButtonStyle,
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(selectedValue),
                style: AppDialogTheme.primaryButtonStyle,
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// Custom decimal number picker widget
class DecimalNumberPicker extends StatelessWidget {
  final double value;
  final double minValue;
  final double maxValue;
  final int decimalPlaces;
  final ValueChanged<double> onChanged;

  const DecimalNumberPicker({
    super.key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.decimalPlaces,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Convert to integer representation for picker
    int intValue = (value * 10).round();
    int intMin = (minValue * 10).round();
    int intMax = (maxValue * 10).round();

    return NumberPicker(
      value: intValue,
      minValue: intMin,
      maxValue: intMax,
      onChanged: (newValue) {
        onChanged(newValue / 10.0);
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
        return displayValue.toStringAsFixed(decimalPlaces);
      },
    );
  }
}

/// Shows a dialog with a dual-column currency picker (dollars and cents)
/// Returns the selected value or null if cancelled
Future<double?> showCurrencyPickerDialog({
  required BuildContext context,
  required String title,
  required double initialValue,
  required int maxDollars,
}) async {
  return showDialog<double>(
    context: context,
    builder: (BuildContext dialogContext) {
      return _CurrencyPickerDialog(
        title: title,
        initialValue: initialValue,
        maxDollars: maxDollars,
      );
    },
  );
}

/// Stateful widget for currency picker dialog to properly manage TextEditingController lifecycle
class _CurrencyPickerDialog extends StatefulWidget {
  final String title;
  final double initialValue;
  final int maxDollars;

  const _CurrencyPickerDialog({
    required this.title,
    required this.initialValue,
    required this.maxDollars,
  });

  @override
  State<_CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<_CurrencyPickerDialog> {
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

    // Initialize controller
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
    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      title: Text(
        widget.title,
        style: AppDialogTheme.titleStyle,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
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
                        // Pad cents with leading zero if needed (e.g., "05" instead of "5")
                        return int.parse(numberText).toString().padLeft(2, '0');
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Divider
            Container(
              height: 1,
              color: AppDialogTheme.inputBorderColor,
            ),
            const SizedBox(height: 16),
            // Manual input section
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
        ),
      ),
      actionsAlignment: MainAxisAlignment.end,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          style: AppDialogTheme.cancelButtonStyle,
          child: const Text('Cancel'),
        ),
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

            Navigator.of(context).pop(result);
          },
          style: AppDialogTheme.primaryButtonStyle,
          child: const Text('OK'),
        ),
      ],
    );
  }
}
