// lib/widgets/settings/date_of_birth_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/generated/app_localizations.dart';

/// Date of Birth picker dialog with blur background
///
/// A native Material date picker wrapped with blur backdrop effect
/// for consistency with other settings dialogs.
///
/// Features:
/// - Backdrop blur effect
/// - Date range: 1900 to today
/// - Automatic age calculation
/// - Default: 25 years ago if no birth date set
class DateOfBirthDialog {
  /// Show the date of birth picker dialog
  static Future<void> show(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    final currentDate = settingsProvider.userProfile?.birthDate ??
        DateTime.now().subtract(const Duration(days: 365 * 25));

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppDialogTheme.backdropBlurSigmaX,
            sigmaY: AppDialogTheme.backdropBlurSigmaY,
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && context.mounted) {
      try {
        // Calculate age from selected date
        final now = DateTime.now();
        int age = now.year - selectedDate.year;
        if (now.month < selectedDate.month ||
            (now.month == selectedDate.month && now.day < selectedDate.day)) {
          age--;
        }

        await settingsProvider.updateDateOfBirth(selectedDate, age);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.dateOfBirthUpdated),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
