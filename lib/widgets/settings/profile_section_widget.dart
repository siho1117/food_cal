// lib/widgets/settings/profile_section_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../common/user_avatar_widget.dart';
import 'emoji_avatar_picker_dialog.dart';

class ProfileSectionWidget extends StatelessWidget {
  const ProfileSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, child) {
        // Get user name from profile (or null if not set)
        final userName = settingsProvider.userProfile?.name;
        final hasName = userName != null && userName.isNotEmpty;

        return _buildTransparentCard(
          context: context,
          userName: userName,
          hasName: hasName,
          themeProvider: themeProvider,
          settingsProvider: settingsProvider,
          l10n: l10n,
        );
      },
    );
  }

  Widget _buildTransparentCard({
    required BuildContext context,
    required String? userName,
    required bool hasName,
    required ThemeProvider themeProvider,
    required SettingsProvider settingsProvider,
    required AppLocalizations l10n,
  }) {
    // Get theme-adaptive colors using widget theme
    final borderColor = AppWidgetTheme.getBorderColor(
      themeProvider.selectedGradient,
      GlassCardStyle.borderOpacity,
    );
    final textColor = AppWidgetTheme.getTextColor(
      themeProvider.selectedGradient,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXL),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: GlassCardStyle.blurSigma,
          sigmaY: GlassCardStyle.blurSigma,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
            borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXL),
            border: Border.all(
              color: borderColor,
              width: GlassCardStyle.borderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showEditNameDialog(context, settingsProvider),
              borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusXL),
              splashColor: textColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              highlightColor: textColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22),
                child: Row(
                  children: [
                    // Avatar circle with gradient letter or empty icon - separate tap handler
                    UserAvatarWidget(
                      profile: settingsProvider.userProfile,
                      size: 68.0,
                      isInteractive: true,
                      onTap: () => showEmojiAvatarPicker(context),
                      useAnimation: true, // Animated in settings
                    ),

                    const SizedBox(width: AppWidgetTheme.spaceLG),

                    // Name section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            hasName ? userName! : l10n.tapToEdit,
                            style: TextStyle(
                              fontSize: AppWidgetTheme.fontSizeXL,
                              fontWeight: FontWeight.w600,
                              color: hasName
                                  ? textColor
                                  : textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                              shadows: AppWidgetTheme.textShadows,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow icon
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: AppWidgetTheme.fontSizeLG,
                      color: textColor.withValues(alpha: AppWidgetTheme.opacityVeryHigh),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final currentName = settingsProvider.userProfile?.name ?? '';
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
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
              Image.asset(
                'assets/emojis/icon/balance_scale_3d.png',
                width: 28,
                height: 28,
              ),
              const SizedBox(width: 12),
              Text(
                l10n.editName,
                style: AppDialogTheme.titleStyle,
              ),
            ],
          ),

          content: TextField(
            controller: controller,
            autofocus: true,
            style: AppDialogTheme.inputTextStyle,
            decoration: AppDialogTheme.inputDecoration(),
          ),

          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: AppDialogTheme.cancelButtonStyle,
              child: Text(l10n.cancel),
            ),

            const SizedBox(width: AppDialogTheme.buttonGap),

            FilledButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty) {
                  await settingsProvider.updateName(newName);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              style: AppDialogTheme.primaryButtonStyle,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}