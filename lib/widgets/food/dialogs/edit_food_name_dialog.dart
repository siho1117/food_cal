// lib/widgets/food/dialogs/edit_food_name_dialog.dart
import 'package:flutter/material.dart';
import '../../../config/design_system/dialog_theme.dart';
import '../../../l10n/generated/app_localizations.dart';

/// Dialog for editing the food name in the food card.
///
/// This is a stateful dialog with proper TextEditingController lifecycle
/// management to prevent memory leaks.
///
/// **Returns:**
/// - [String?] - The new food name if saved, or null if cancelled
///
/// **Usage:**
/// ```dart
/// final result = await showDialog<String>(
///   context: context,
///   builder: (context) => EditFoodNameDialog(
///     initialValue: 'Pizza',
///   ),
/// );
/// if (result != null) {
///   // User saved a new name
///   debugPrint('New name: $result');
/// }
/// ```
class EditFoodNameDialog extends StatefulWidget {
  final String initialValue;

  const EditFoodNameDialog({
    super.key,
    required this.initialValue,
  });

  @override
  State<EditFoodNameDialog> createState() => _EditFoodNameDialogState();
}

class _EditFoodNameDialogState extends State<EditFoodNameDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      title: Text(
        l10n.editFoodName,
        style: AppDialogTheme.titleStyle,
      ),
      content: SingleChildScrollView(
        child: TextField(
          controller: _controller,
          autofocus: true,
          style: AppDialogTheme.inputTextStyle,
          decoration: AppDialogTheme.inputDecoration(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          style: AppDialogTheme.cancelButtonStyle,
          child: Text(l10n.cancel),
        ),
        const SizedBox(width: AppDialogTheme.buttonGap),
        FilledButton(
          onPressed: () {
            final newName = _controller.text.trim();
            Navigator.pop(context, newName);
          },
          style: AppDialogTheme.primaryButtonStyle,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
