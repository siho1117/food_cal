import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../l10n/generated/app_localizations.dart';

class GenderSelectionDialog extends StatelessWidget {
  const GenderSelectionDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const GenderSelectionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    // This is the stored key, e.g., "male", "female"
    final currentGenderKey = settingsProvider.userProfile?.gender;

    // Define gender options with keys and translated labels
    final genderOptions = {
      'male': l10n.male,
      'female': l10n.female,
      'other': l10n.other,
      'preferNotToSay': l10n.preferNotToSay,
    };

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDialogTheme.backdropBlurSigmaX,
        sigmaY: AppDialogTheme.backdropBlurSigmaY,
      ),
      child: AlertDialog(
        shape: AppDialogTheme.shape,
        backgroundColor: AppDialogTheme.backgroundColor,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: Row(
          children: [
            Image.asset(
              'assets/emojis/icon/dna_3d.png',
              width: 28,
              height: 28,
            ),
            const SizedBox(width: 12),
            Text(l10n.gender, style: AppDialogTheme.titleStyle),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genderOptions.entries.map((entry) {
            final genderKey = entry.key;
            final genderLabel = entry.value;
            // Compare key with key
            final isSelected = genderKey == currentGenderKey;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                genderLabel,
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppDialogTheme.colorPrimaryDark
                      : AppDialogTheme.colorTextSecondary,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check, color: AppDialogTheme.colorPrimaryDark)
                  : null,
              onTap: () async {
                try {
                  // Save the key
                  await settingsProvider.updateGender(genderKey);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.genderUpdated), behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${l10n.error}: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            style: AppDialogTheme.cancelButtonStyle,
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}