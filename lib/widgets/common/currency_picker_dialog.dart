// lib/widgets/common/currency_picker_dialog.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// Universal currency picker dialog with blur background
/// - Allows selecting dollars (0-999) and cents (00-99) via scroll picker
/// - Includes manual text input for direct entry
/// - Two-way sync between picker and text input
/// - Uses CupertinoPicker for smooth iOS-style scrolling
/// - Displays currency symbol ($) in both picker and input
/// - Configurable title and icon for different use cases
///
/// **Use cases:**
/// - Budget setting (home page)
/// - Food item cost input (food card)
/// - Any other currency input in the app
class CurrencyPickerDialog extends StatefulWidget {
  final double initialValue;
  final String title;
  final AnimatedEmojiData icon;
  final Future<void> Function(double value) onSave;
  final int maxValue;

  const CurrencyPickerDialog({
    super.key,
    required this.initialValue,
    required this.title,
    required this.icon,
    required this.onSave,
    this.maxValue = 999,
  });

  @override
  State<CurrencyPickerDialog> createState() => _CurrencyPickerDialogState();
}

class _CurrencyPickerDialogState extends State<CurrencyPickerDialog> {
  late FixedExtentScrollController _dollarController;
  late FixedExtentScrollController _centController;
  late TextEditingController _manualInputController;
  final FocusNode _manualInputFocus = FocusNode();

  static const int minValue = 0;

  // Style constants
  static const _pickerTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );

  static const _inputTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Color(0xFF1F2937),
  );

  @override
  void initState() {
    super.initState();
    final dollars = widget.initialValue.floor();
    final cents = ((widget.initialValue - dollars) * 100).round();

    _dollarController = FixedExtentScrollController(
      initialItem: dollars.clamp(minValue, widget.maxValue),
    );
    _centController = FixedExtentScrollController(
      initialItem: cents.clamp(0, 99),
    );
    _manualInputController = TextEditingController(
      text: widget.initialValue.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _dollarController.dispose();
    _centController.dispose();
    _manualInputController.dispose();
    _manualInputFocus.dispose();
    super.dispose();
  }

  double get _currentValue {
    // Try to parse manual input first
    final manualValue = double.tryParse(_manualInputController.text);
    if (manualValue != null && manualValue >= 0) {
      return manualValue;
    }
    // Fall back to picker values
    final dollars = _dollarController.selectedItem;
    final cents = _centController.selectedItem / 100.0;
    return dollars + cents;
  }

  void _updateManualInput() {
    final dollars = _dollarController.selectedItem;
    final cents = _centController.selectedItem / 100.0;
    final value = dollars + cents;
    if (!_manualInputFocus.hasFocus) {
      _manualInputController.text = value.toStringAsFixed(2);
    }
  }

  void _updatePickersFromManualInput() {
    final value = double.tryParse(_manualInputController.text);
    if (value != null && value >= 0 && value <= widget.maxValue + 0.99) {
      final dollars = value.floor();
      final cents = ((value - dollars) * 100).round();

      _dollarController.jumpToItem(dollars.clamp(minValue, widget.maxValue));
      _centController.jumpToItem(cents.clamp(0, 99));
    }
  }

  void _handleSave() async {
    try {
      await widget.onSave(_currentValue);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDialogTheme.backdropBlurSigmaX,
        sigmaY: AppDialogTheme.backdropBlurSigmaY,
      ),
      child: AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: Row(
          children: [
            AnimatedEmoji(
              widget.icon,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              widget.title,
              style: AppDialogTheme.titleStyle,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyPicker(),
            const SizedBox(height: 16),
            _buildManualInput(),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: AppDialogTheme.cancelButtonStyle,
                child: Text(AppLocalizations.of(context)!.cancel),
              ),
              const SizedBox(width: AppDialogTheme.buttonGap),
              FilledButton(
                onPressed: _handleSave,
                style: AppDialogTheme.primaryButtonStyle,
                child: Text(AppLocalizations.of(context)!.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyPicker() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Currency symbol
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: Text(
              '\$',
              style: _pickerTextStyle,
            ),
          ),
          // Dollar picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _dollarController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {
                  _updateManualInput();
                });
              },
              children: List.generate(
                widget.maxValue - minValue + 1,
                (index) => Center(
                  child: Text(
                    '${minValue + index}',
                    style: _pickerTextStyle,
                  ),
                ),
              ),
            ),
          ),
          // Decimal point
          const Text(
            '.',
            style: _pickerTextStyle,
          ),
          // Cents picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _centController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {
                  _updateManualInput();
                });
              },
              children: List.generate(
                100,
                (index) => Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: _pickerTextStyle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManualInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppLocalizations.of(context)!.orEnterAmount(widget.maxValue.toString()),
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _manualInputController,
          focusNode: _manualInputFocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textAlign: TextAlign.center,
          style: _inputTextStyle,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppDialogTheme.colorPrimaryDark, width: 2),
            ),
            prefixIcon: const Padding(
              padding: EdgeInsets.only(left: 16, top: 12, bottom: 12),
              child: Text(
                '\$',
                style: _inputTextStyle,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            hintText: '0.00',
            hintStyle: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade400,
            ),
          ),
          onChanged: (value) {
            _updatePickersFromManualInput();
          },
          onSubmitted: (value) {
            _updatePickersFromManualInput();
            _manualInputFocus.unfocus();
          },
        ),
      ],
    );
  }
}
