// lib/widgets/settings/legal_documents_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/typography.dart';
import '../../l10n/generated/app_localizations.dart';

class LegalDocumentsWidget extends StatelessWidget {
  const LegalDocumentsWidget({super.key});

  // TODO: Replace these with your actual URLs after hosting on GitHub Pages
  static const String privacyPolicyUrl = 'https://YOUR-USERNAME.github.io/YOUR-REPO/privacy.html';
  static const String termsOfServiceUrl = 'https://YOUR-USERNAME.github.io/YOUR-REPO/terms.html';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
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
                  _buildLegalItem(
                    context,
                    textColor,
                    borderColor,
                    iconAsset: 'assets/emojis/icon/memo_3d.png',
                    title: l10n.privacyPolicy,
                    onTap: () => _launchUrl(context, privacyPolicyUrl, l10n.privacyPolicy),
                  ),
                  Divider(
                    height: 1,
                    thickness: 1,
                    color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
                  ),
                  _buildLegalItem(
                    context,
                    textColor,
                    borderColor,
                    iconAsset: 'assets/emojis/icon/memo_3d.png',
                    title: l10n.termsOfService,
                    onTap: () => _launchUrl(context, termsOfServiceUrl, l10n.termsOfService),
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

  Widget _buildLegalItem(
    BuildContext context,
    Color textColor,
    Color borderColor, {
    required String iconAsset,
    required String title,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: 1.0,
      ),
      leading: Image.asset(
        iconAsset,
        width: 32,
        height: 32,
        fit: BoxFit.contain,
      ),
      title: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: textColor,
        ),
      ),
      trailing: Icon(
        Icons.open_in_new,
        color: textColor.withValues(
          alpha: AppWidgetTheme.opacityHigh,
        ),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(BuildContext context, String urlString, String documentName) async {
    try {
      final uri = Uri.parse(urlString);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, // Opens in browser
        );
      } else {
        if (context.mounted) {
          _showErrorSnackBar(context, 'Could not open $documentName');
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Error opening $documentName: $e');
      }
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
