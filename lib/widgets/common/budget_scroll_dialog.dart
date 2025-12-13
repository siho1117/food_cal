// lib/widgets/common/budget_scroll_dialog.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../l10n/generated/app_localizations.dart';

/// Budget scroll picker dialog with blur background
/// - Allows selecting dollars (0-999) and cents (00-99)
/// - Uses CupertinoPicker for smooth iOS-style scrolling
/// - Includes animated money emoji icon in title
class BudgetScrollDialog extends StatefulWidget {
  final double currentBudget;
  final Future<void> Function(double budget) onSave;

  const BudgetScrollDialog({
    super.key,
    required this.currentBudget,
    required this.onSave,
  });

  @override
  State<BudgetScrollDialog> createState() => _BudgetScrollDialogState();
}

class _BudgetScrollDialogState extends State<BudgetScrollDialog> {
  late FixedExtentScrollController _dollarController;
  late FixedExtentScrollController _centController;

  static const int minBudget = 0;
  static const int maxBudget = 999;

  @override
  void initState() {
    super.initState();
    final dollars = widget.currentBudget.floor();
    final cents = ((widget.currentBudget - dollars) * 100).round();

    _dollarController = FixedExtentScrollController(
      initialItem: dollars.clamp(minBudget, maxBudget),
    );
    _centController = FixedExtentScrollController(
      initialItem: cents.clamp(0, 99),
    );
  }

  @override
  void dispose() {
    _dollarController.dispose();
    _centController.dispose();
    super.dispose();
  }

  double get _currentBudget {
    final dollars = _dollarController.selectedItem;
    final cents = _centController.selectedItem / 100.0;
    return dollars + cents;
  }

  void _handleSave() async {
    try {
      await widget.onSave(_currentBudget);
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
    final l10n = AppLocalizations.of(context)!;

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
            const AnimatedEmoji(
              AnimatedEmojis.moneyWithWings,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              l10n.budget,
              style: AppDialogTheme.titleStyle,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBudgetPicker(),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: AppDialogTheme.cancelButtonStyle,
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: AppDialogTheme.buttonGap),
              FilledButton(
                onPressed: _handleSave,
                style: AppDialogTheme.primaryButtonStyle,
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetPicker() {
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
          // Dollar picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _dollarController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {});
              },
              children: List.generate(
                maxBudget - minBudget + 1,
                (index) => Center(
                  child: Text(
                    '${minBudget + index}',
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
          // Cents picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _centController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {});
              },
              children: List.generate(
                100,
                (index) => Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
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
    );
  }
}
