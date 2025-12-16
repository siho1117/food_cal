// lib/widgets/settings/personal_details_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'height_scroll_dialog.dart';
import 'weight_scroll_dialog.dart';

class PersonalDetailsWidget extends StatelessWidget {
  const PersonalDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, child) {
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          GlassCardStyle.borderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassCardStyle.blurSigma,
              sigmaY: GlassCardStyle.blurSigma,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                border: Border.all(
                  color: borderColor,
                  width: GlassCardStyle.borderWidth,
                ),
              ),
              child: Column(
            children: [
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.cake,
                title: l10n.dateOfBirth,
                value: settingsProvider.calculatedAge,
                onTap: () => _showDatePicker(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.height,
                title: l10n.height,
                value: settingsProvider.formattedHeight,
                onTap: () => _showHeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.monitor_weight,
                title: l10n.currentWeight,
                value: settingsProvider.formattedWeight,
                onTap: () => _showWeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.flag,
                title: l10n.startingWeight,
                value: settingsProvider.formattedStartingWeight,
                onTap: () => _showStartingWeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.person,
                title: l10n.gender,
                value: settingsProvider.userProfile?.gender ?? l10n.notSet,
                onTap: () => _showGenderDialog(context, settingsProvider),
              ),
            ],
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    SettingsProvider settingsProvider,
    Color textColor, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: AppWidgetTheme.spaceSM,
      ),
      leading: Container(
        width: AppWidgetTheme.iconContainerMedium,
        height: AppWidgetTheme.iconContainerMedium,
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
          borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
        ),
        child: Icon(
          icon,
          color: textColor,
          size: AppWidgetTheme.iconSizeMedium,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: textColor,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTypography.bodyMedium.copyWith(
          color: textColor.withValues(
            alpha: AppWidgetTheme.opacityVeryHigh,
          ),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor.withValues(
          alpha: AppWidgetTheme.opacityHigh,
        ),
      ),
      onTap: onTap,
    );
  }


  void _showDatePicker(BuildContext context, SettingsProvider settingsProvider) {
    final currentDate = settingsProvider.userProfile?.birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    
    showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) async {
      if (date != null) {
        try {
          // Calculate age from selected date
          final now = DateTime.now();
          int age = now.year - date.year;
          if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
            age--;
          }
          
          await settingsProvider.updateDateOfBirth(date, age);
          if (context.mounted) {
            final l10n = AppLocalizations.of(context)!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.dateOfBirthUpdated), behavior: SnackBarBehavior.floating),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      }
    });
  }

  void _showHeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => HeightScrollDialog(
        settingsProvider: settingsProvider,
      ),
    );
  }

  void _showWeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => WeightScrollDialog(
        settingsProvider: settingsProvider,
        type: WeightDialogType.current,
      ),
    );
  }

  void _showStartingWeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => WeightScrollDialog(
        settingsProvider: settingsProvider,
        type: WeightDialogType.starting,
      ),
    );
  }

  void _showGenderDialog(BuildContext context, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final genders = [l10n.male, l10n.female, l10n.other, l10n.preferNotToSay];
    final currentGender = settingsProvider.userProfile?.gender;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: AppDialogTheme.shape,
        backgroundColor: AppDialogTheme.backgroundColor,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: Text(
          l10n.gender,
          style: AppDialogTheme.titleStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders.map((gender) {
            final isSelected = gender == currentGender;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                gender,
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppDialogTheme.colorPrimaryDark
                      : AppDialogTheme.colorTextSecondary,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppDialogTheme.colorPrimaryDark)
                  : null,
              onTap: () async {
                try {
                  await settingsProvider.updateGender(gender);
                  if (context.mounted) {
                    final l10n = AppLocalizations.of(context)!;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.genderUpdated), behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
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