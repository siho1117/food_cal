// lib/widgets/settings/preferences_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/home_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../l10n/generated/app_localizations.dart';
import 'language_selector_dialog.dart';
import 'theme_selector_dialog.dart';

class PreferencesWidget extends StatelessWidget {
  const PreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Also watch LanguageProvider and ThemeProvider for changes
        final languageProvider = Provider.of<LanguageProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);

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
              // Language preference
              _buildPreferenceItem(
                context,
                settingsProvider,
                textColor,
                borderColor,
                iconAsset: 'assets/emojis/icon/world_map_3d.png',
                title: l10n.language,
                value: languageProvider.currentLanguageName,
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
                iconAsset: 'assets/emojis/icon/glowing_star_3d.png',
                title: l10n.theme,
                value: themeProvider.getGradientDisplayName(themeProvider.selectedGradient),
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
                iconAsset: 'assets/emojis/icon/balance_scale_3d.png',
                title: l10n.units,
                value: settingsProvider.isMetric ? l10n.metric : l10n.imperial,
                trailing: Switch(
                  value: settingsProvider.isMetric,
                  onChanged: (value) => _toggleUnits(context, settingsProvider),
                  activeColor: textColor,
                  trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
                ),
                onTap: () => _toggleUnits(context, settingsProvider),
                isLast: true,
              ),
            ],
          ),
            ),
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
    IconData? icon,
    String? iconAsset,
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
        vertical: 1.0,
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
          : iconAsset != null
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
    // Using targeted refresh (only reloads profile, not food entries/macros)
    if (context.mounted) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await homeProvider.refreshUserProfile();
    }

    if (context.mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(newValue ? l10n.unitsChangedToMetric : l10n.unitsChangedToImperial),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}