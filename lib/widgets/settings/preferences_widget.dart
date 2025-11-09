// lib/widgets/settings/preferences_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import 'language_selector_dialog.dart';
import 'theme_selector_dialog.dart';

class PreferencesWidget extends StatelessWidget {
  const PreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Also watch LanguageProvider and ThemeProvider for changes
        final languageProvider = Provider.of<LanguageProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);

        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          AppWidgetTheme.cardBorderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
            border: Border.all(
              color: borderColor,
              width: AppWidgetTheme.cardBorderWidth,
            ),
          ),
          child: Column(
            children: [
              // Language preference
              _buildPreferenceItem(
                context,
                settingsProvider,
                textColor,
                borderColor,
                icon: Icons.language,
                title: 'Language',
                value: languageProvider.currentLanguageName,
                leadingEmoji: languageProvider.currentLanguageFlag,
                onTap: () => _showLanguageDialog(context),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),

              // Theme preference
              _buildPreferenceItem(
                context,
                settingsProvider,
                textColor,
                borderColor,
                icon: Icons.palette,
                title: 'Theme',
                value: themeProvider.getGradientDisplayName(themeProvider.selectedGradient),
                leadingEmoji: themeProvider.getGradientEmoji(themeProvider.selectedGradient),
                onTap: () => _showThemeDialog(context),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),

              // Units preference with inline toggle
              _buildPreferenceItem(
                context,
                settingsProvider,
                textColor,
                borderColor,
                icon: Icons.straighten,
                title: 'Units',
                value: settingsProvider.isMetric ? 'Metric' : 'Imperial',
                trailing: Switch(
                  value: settingsProvider.isMetric,
                  onChanged: (value) => _toggleUnits(context, settingsProvider),
                  activeColor: textColor,
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
                onTap: () => _toggleUnits(context, settingsProvider),
              ),

              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),

              // Monthly weight goal
              _buildPreferenceItem(
                context,
                settingsProvider,
                textColor,
                borderColor,
                icon: Icons.speed,
                title: 'Monthly Weight Goal',
                value: settingsProvider.formattedMonthlyGoal,
                onTap: () => _showWeightGoalDialog(context, settingsProvider),
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    SettingsProvider settingsProvider,
    Color textColor,
    Color borderColor, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
    String? leadingEmoji,
    bool isLast = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: AppWidgetTheme.spaceSM,
      ),
      leading: leadingEmoji != null
          ? Container(
              width: AppWidgetTheme.iconContainerMedium,
              height: AppWidgetTheme.iconContainerMedium,
              alignment: Alignment.center,
              child: Text(
                leadingEmoji,
                style: const TextStyle(fontSize: 24),
              ),
            )
          : Container(
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
      trailing: trailing ??
          Icon(
            Icons.chevron_right,
            color: textColor.withValues(
              alpha: AppWidgetTheme.opacityHigh,
            ),
          ),
      onTap: onTap,
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }

  void _toggleUnits(BuildContext context, SettingsProvider settingsProvider) {
    final newValue = !settingsProvider.isMetric;
    settingsProvider.updateUnitPreference(newValue);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Units changed to ${newValue ? 'Metric' : 'Imperial'}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWeightGoalDialog(BuildContext context, SettingsProvider settingsProvider) {
    final TextEditingController controller = TextEditingController();

    // Pre-fill with current goal if it exists
    if (settingsProvider.userProfile?.monthlyWeightGoal != null) {
      final currentGoal = settingsProvider.userProfile!.monthlyWeightGoal!;
      controller.text = currentGoal.abs().toStringAsFixed(1);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: const Text(
          'Monthly Weight Goal',
          style: AppDialogTheme.titleStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How much weight do you want to lose per month?',
              style: AppDialogTheme.bodyStyle,
            ),
            const SizedBox(height: AppDialogTheme.elementSpacing),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              style: AppDialogTheme.inputTextStyle,
              decoration: AppDialogTheme.inputDecoration(
                hintText: '0.5',
              ).copyWith(
                labelText: settingsProvider.isMetric ? 'Goal (kg)' : 'Goal (lbs)',
                suffixText: settingsProvider.isMetric ? 'kg' : 'lbs',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended: 0.5-1 ${settingsProvider.isMetric ? 'kg' : 'lbs'} per month',
              style: AppDialogTheme.bodyStyle.copyWith(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                style: AppDialogTheme.cancelButtonStyle,
                child: const Text('Cancel'),
              ),
              const SizedBox(width: AppDialogTheme.buttonGap),
              FilledButton(
                onPressed: () async {
                  final input = double.tryParse(controller.text);
                  if (input != null && input > 0) {
                    // Store as negative (weight loss)
                    final goalInKg = settingsProvider.isMetric
                        ? -input
                        : -input * 0.453592; // Convert lbs to kg

                    await settingsProvider.updateMonthlyWeightGoal(goalInKg);

                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Monthly weight goal updated'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                style: AppDialogTheme.primaryButtonStyle,
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}