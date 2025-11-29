// lib/widgets/settings/preferences_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import 'language_selector_dialog.dart';
import 'theme_selector_dialog.dart';
import 'monthly_goal_dialog.dart';

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

  void _toggleUnits(BuildContext context, SettingsProvider settingsProvider) async {
    final newValue = !settingsProvider.isMetric;
    await settingsProvider.updateUnitPreference(newValue);

    // IMPORTANT: Refresh HomeProvider to pick up the updated profile
    if (context.mounted) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.refreshData();
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Units changed to ${newValue ? 'Metric' : 'Imperial'}'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
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