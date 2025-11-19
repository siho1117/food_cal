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

/// NOTE: Cost picker has been moved to lib/widgets/loading/cost_picker_overlay.dart
/// Use showCostPickerOverlay() instead of showCurrencyPickerDialog()
/// This provides consistent UI across both preview and edit modes
