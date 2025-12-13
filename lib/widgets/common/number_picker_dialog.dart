import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// Shows a dialog with an integer number picker
/// Returns the selected value or null if cancelled
Future<int?> showNumberPickerDialog({
  required BuildContext context,
  required String title,
  required int initialValue,
  required int minValue,
  required int maxValue,
  int step = 1,
  AnimatedEmojiData? icon,
  String? emoji,
}) async {
  // Calculate the initial index based on value and step
  final totalItems = ((maxValue - minValue) ~/ step) + 1;
  final initialIndex = ((initialValue - minValue) ~/ step).clamp(0, totalItems - 1);

  late FixedExtentScrollController scrollController;
  scrollController = FixedExtentScrollController(initialItem: initialIndex);

  int selectedValue = minValue + (initialIndex * step);

  return showDialog<int>(
    context: context,
    builder: (BuildContext context) {
      final l10n = AppLocalizations.of(context)!;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppDialogTheme.backgroundColor,
            shape: AppDialogTheme.shape,
            contentPadding: AppDialogTheme.contentPadding,
            actionsPadding: AppDialogTheme.actionsPadding,
            title: icon != null
                ? Row(
                    children: [
                      AnimatedEmoji(
                        icon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: AppDialogTheme.titleStyle,
                      ),
                    ],
                  )
                : emoji != null
                    ? Row(
                        children: [
                          Text(
                            emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            title,
                            style: AppDialogTheme.titleStyle,
                          ),
                        ],
                      )
                    : Text(
                        title,
                        style: AppDialogTheme.titleStyle,
                      ),
            content: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: CupertinoPicker(
                scrollController: scrollController,
                itemExtent: 40,
                onSelectedItemChanged: (index) {
                  setState(() {
                    selectedValue = minValue + (index * step);
                  });
                },
                children: List.generate(
                  totalItems,
                  (index) => Center(
                    child: Text(
                      '${minValue + (index * step)}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppDialogTheme.cancelButtonStyle,
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(selectedValue),
                style: AppDialogTheme.primaryButtonStyle,
                child: Text(l10n.ok),
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
  AnimatedEmojiData? icon,
}) async {
  // Split initial value into integer and decimal parts
  final integerPart = initialValue.floor();
  final decimalPart = ((initialValue - integerPart) * 10).round();

  final minInteger = minValue.floor();
  final maxInteger = maxValue.floor();

  late FixedExtentScrollController integerController;
  late FixedExtentScrollController decimalController;

  integerController = FixedExtentScrollController(
    initialItem: (integerPart - minInteger).clamp(0, maxInteger - minInteger),
  );
  decimalController = FixedExtentScrollController(
    initialItem: decimalPart.clamp(0, 9),
  );

  int selectedInteger = integerPart;
  int selectedDecimal = decimalPart;

  return showDialog<double>(
    context: context,
    builder: (BuildContext context) {
      final l10n = AppLocalizations.of(context)!;

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppDialogTheme.backgroundColor,
            shape: AppDialogTheme.shape,
            contentPadding: AppDialogTheme.contentPadding,
            actionsPadding: AppDialogTheme.actionsPadding,
            title: icon != null
                ? Row(
                    children: [
                      AnimatedEmoji(
                        icon,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: AppDialogTheme.titleStyle,
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: AppDialogTheme.titleStyle,
                  ),
            content: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Integer picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: integerController,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedInteger = minInteger + index;
                        });
                      },
                      children: List.generate(
                        (maxInteger - minInteger) + 1,
                        (index) => Center(
                          child: Text(
                            '${minInteger + index}',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Decimal point
                  const Text(
                    '.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  // Decimal picker
                  Expanded(
                    child: CupertinoPicker(
                      scrollController: decimalController,
                      itemExtent: 40,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          selectedDecimal = index;
                        });
                      },
                      children: List.generate(
                        10,
                        (index) => Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.end,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: AppDialogTheme.cancelButtonStyle,
                child: Text(l10n.cancel),
              ),
              FilledButton(
                onPressed: () {
                  final finalValue = selectedInteger + (selectedDecimal / 10.0);
                  Navigator.of(context).pop(finalValue);
                },
                style: AppDialogTheme.primaryButtonStyle,
                child: Text(l10n.ok),
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

// ═══════════════════════════════════════════════════════════════════════════════
// MIGRATION NOTE: Cost Picker Functionality
// ═══════════════════════════════════════════════════════════════════════════════
//
// The cost picker has been consolidated and moved to a unified implementation.
//
// OLD LOCATION (deprecated):
//   - This file previously contained showCurrencyPickerDialog()
//   - Removed: _CurrencyPickerDialog and CostPickerContent classes
//
// NEW LOCATION:
//   - lib/widgets/common/cost_picker_overlay.dart
//
// USAGE:
//   Instead of:
//     showCurrencyPickerDialog(context: context, ...)
//
//   Use:
//     showCostPickerOverlay(initialValue: value, ...)
//
// BENEFITS:
//   - Consistent UI across both preview mode (after photo recognition) and edit mode
//   - Guaranteed z-index control via custom overlay system
//   - Single source of truth - no code duplication
//   - Unified behavior with optional manual input for amounts > $999
//
// ═══════════════════════════════════════════════════════════════════════════════
