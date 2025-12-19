// lib/widgets/settings/personal_details_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'height_scroll_dialog.dart';
import 'monthly_goal_dialog.dart';
import 'date_of_birth_dialog.dart';
import 'gender_selection_dialog.dart';
import '../../utils/constants/unit_constants.dart';
import '../progress/weight_edit_dialog.dart';
import '../../providers/progress_data.dart';

class PersonalDetailsWidget extends StatelessWidget {
  const PersonalDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer3<SettingsProvider, ThemeProvider, ProgressData>(
      builder: (context, settingsProvider, themeProvider, progressData, child) {
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
                iconAsset: 'assets/emojis/icon/birthday_cake_3d.png',
                title: l10n.dateOfBirth,
                value: _formatAge(settingsProvider.userProfile?.birthDate, context),
                onTap: () => DateOfBirthDialog.show(context, settingsProvider),
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
                iconAsset: 'assets/emojis/icon/straight_ruler_3d.png',
                title: l10n.height,
                value: _formatHeight(settingsProvider.userProfile?.height, settingsProvider.isMetric, context),
                onTap: () => _showHeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildWeightRow(
                context,
                settingsProvider,
                progressData,
                textColor,
                borderColor,
                l10n,
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
                iconAsset: _getMonthlyGoalEmoji(settingsProvider.userProfile?.monthlyWeightGoal),
                title: l10n.monthlyWeightGoal,
                value: _formatMonthlyGoal(settingsProvider.userProfile?.monthlyWeightGoal, settingsProvider.isMetric, context),
                onTap: () => _showWeightGoalDialog(context, settingsProvider),
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
                iconAsset: 'assets/emojis/icon/dna_3d.png',
                title: l10n.gender,
                value: _translateGender(settingsProvider.userProfile?.gender, context),
                onTap: () => GenderSelectionDialog.show(context),
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
    IconData? icon,
    String? iconAsset,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: 1.0,
      ),
      leading: iconAsset != null
          ? Image.asset(
              iconAsset,
              width: 32,
              height: 32,
              fit: BoxFit.contain,
            )
          : Container(
              width: AppWidgetTheme.iconContainerMedium,
              height: AppWidgetTheme.iconContainerMedium,
              decoration: BoxDecoration(
                color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
                borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
              ),
              child: Icon(
                icon!,
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

  Widget _buildWeightRow(
    BuildContext context,
    SettingsProvider settingsProvider,
    ProgressData progressData,
    Color textColor,
    Color borderColor,
    AppLocalizations l10n,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: 1.0,
      ),
      leading: Image.asset(
        'assets/emojis/icon/bullseye_3d.png',
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
      title: Row(
        children: [
          // Starting Label
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: AppWidgetTheme.spaceSM),
              child: Text(
                l10n.starting,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ),
          // Current Label
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceSM),
              child: Text(
                l10n.current,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ),
          // Goal Label
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: AppWidgetTheme.spaceSM),
              child: Text(
                l10n.goal,
                style: AppTypography.labelMedium.copyWith(
                  color: textColor,
                ),
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          // Starting Value
          Expanded(
            child: GestureDetector(
              onTap: () => _showWeightDialog(context, settingsProvider, initialMode: WeightMode.start),
              child: Padding(
                padding: const EdgeInsets.only(right: AppWidgetTheme.spaceSM),
                child: Text(
                  _formatWeightValue(
                    progressData.startingWeight,
                    settingsProvider.isMetric,
                    context,
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Current Value
          Expanded(
            child: GestureDetector(
              onTap: () => _showWeightDialog(context, settingsProvider),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppWidgetTheme.spaceSM),
                child: Text(
                  _formatWeightValue(
                    progressData.currentWeight,
                    settingsProvider.isMetric,
                    context,
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          // Goal Weight Value
          Expanded(
            child: GestureDetector(
              onTap: () => _showWeightDialog(context, settingsProvider, initialMode: WeightMode.target),
              child: Padding(
                padding: const EdgeInsets.only(left: AppWidgetTheme.spaceSM),
                child: Text(
                  _formatWeightValue(
                    progressData.targetWeight,
                    settingsProvider.isMetric,
                    context,
                  ),
                  style: AppTypography.bodyMedium.copyWith(
                    color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthlyGoalEmoji(double? monthlyGoal) {
    // Negative = weight loss (inbox_tray), Positive = weight gain (outbox_tray)
    if (monthlyGoal == null || monthlyGoal < 0) {
      return 'assets/emojis/icon/inbox_tray_3d.png';
    } else {
      return 'assets/emojis/icon/outbox_tray_3d.png';
    }
  }

  String _formatAge(DateTime? birthDate, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (birthDate == null) return l10n.notSet;

    final now = DateTime.now();
    int age = now.year - birthDate.year;

    // Adjust age if birthday hasn't occurred yet this year
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    return '$age ${l10n.years}';
  }

  String _formatHeight(double? heightInCm, bool isMetric, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (heightInCm == null) return l10n.notSet;

    if (isMetric) {
      return '${heightInCm.round()} ${l10n.cm}';
    } else {
      // Convert to feet and inches
      final heightData = UnitConstants.cmToFeetAndInches(heightInCm);
      return '${heightData.feet} ${l10n.ft} ${heightData.inches} ${l10n.inchesUnit}';
    }
  }

  String _translateGender(String? genderKey, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (genderKey == null) return l10n.notSet;

    // Map gender keys to localized strings
    final genderMap = {
      'male': l10n.male,
      'female': l10n.female,
      'other': l10n.other,
      'preferNotToSay': l10n.preferNotToSay,
      // Backward compatibility with old stored values
      'Male': l10n.male,
      'Female': l10n.female,
      'Other': l10n.other,
      'Prefer not to say': l10n.preferNotToSay,
      '男性': l10n.male,
      '女性': l10n.female,
      '其他': l10n.other,
      '不願透露': l10n.preferNotToSay,
    };

    return genderMap[genderKey] ?? genderKey;
  }

  String _formatWeightValue(double? weightInKg, bool isMetric, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (weightInKg == null) return l10n.notSet;

    if (isMetric) {
      return '${weightInKg.toStringAsFixed(1)} ${l10n.kg}';
    } else {
      final weightInLbs = UnitConstants.kgToLbs(weightInKg);
      return '${weightInLbs.toStringAsFixed(1)} ${l10n.lbs}';
    }
  }

  String _formatMonthlyGoal(double? monthlyGoal, bool isMetric, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (monthlyGoal == null) return l10n.notSet;

    final absValue = monthlyGoal.abs();
    final label = monthlyGoal < 0 ? l10n.lose : l10n.gain;

    // Convert to lbs if needed (monthly goal is stored in kg)
    final displayValue = isMetric ? absValue : UnitConstants.kgToLbs(absValue);
    final unit = isMetric ? l10n.kg : l10n.lbs;

    return '${displayValue.toStringAsFixed(1)} $unit/${l10n.month} ($label)';
  }

  void _showHeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => HeightScrollDialog(
        settingsProvider: settingsProvider,
      ),
    );
  }

  void _showWeightDialog(BuildContext context, SettingsProvider settingsProvider, {WeightMode initialMode = WeightMode.current}) {
    final progressData = context.read<ProgressData>();

    showWeightEditDialog(
      context: context,
      initialWeight: settingsProvider.currentWeight ?? 70.0,
      isMetric: settingsProvider.isMetric,
      targetWeight: progressData.targetWeight,
      startingWeight: progressData.startingWeight,
      initialMode: initialMode,
      onAddWeight: (weight, isMetric) async {
        await progressData.addWeightEntry(weight, isMetric);

        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.weightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveTarget: (targetWeight) async {
        await progressData.updateTargetWeight(targetWeight);

        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.targetWeightUpdatedSuccessfully),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      onSaveStartingWeight: (startingWeight) async {
        await settingsProvider.updateStartingWeight(startingWeight);

        // Reload progress data to refresh the UI with new starting weight
        await progressData.refreshData();

        if (context.mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.startingWeightUpdated),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _showWeightGoalDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => MonthlyGoalDialog(
        settingsProvider: settingsProvider,
      ),
    );
  }

}