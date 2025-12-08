// lib/widgets/settings/feedback_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/widget_theme.dart';
import '../../l10n/generated/app_localizations.dart';

class FeedbackWidget extends StatelessWidget {
  final VoidCallback? onSendFeedback; // Optional callback for additional actions

  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const FeedbackWidget({
    super.key,
    this.onSendFeedback,
  });

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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showFeedbackDialog(context, settingsProvider),
                  borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: AppWidgetTheme.iconContainerMedium,
                          height: AppWidgetTheme.iconContainerMedium,
                          decoration: BoxDecoration(
                            color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
                            borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
                          ),
                          child: Icon(
                            Icons.feedback,
                            color: textColor,
                            size: AppWidgetTheme.iconSizeMedium,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.sendFeedback,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: textColor,
                                ),
                              ),
                              Text(
                                l10n.helpUsImprove,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: textColor.withValues(
                                    alpha: AppWidgetTheme.opacityVeryHigh,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: textColor.withValues(
                            alpha: AppWidgetTheme.opacityHigh,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context, SettingsProvider settingsProvider) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController feedbackController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Row(
            children: [
              const Icon(
                Icons.feedback,
                color: AppColors.textDark,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(l10n.sendFeedback),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.feedbackAppreciated,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: feedbackController,
                decoration: InputDecoration(
                  hintText: l10n.yourFeedbackHere,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.textDark),
                  ),
                ),
                maxLines: 5,
                enabled: !isLoading,
              ),
              if (isLoading) ...[
                const SizedBox(height: 16),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final feedback = feedbackController.text.trim();
                      if (feedback.isNotEmpty) {
                        setState(() {
                          isLoading = true;
                        });

                        try {
                          // Send feedback through provider
                          await settingsProvider.sendFeedback(feedback);

                          if (context.mounted) {
                            final l10n = AppLocalizations.of(context)!;
                            Navigator.of(context).pop();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(l10n.thankYouForFeedback),
                                  ],
                                ),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );

                            // Call additional callback if provided
                            if (onSendFeedback != null) {
                              onSendFeedback!();
                            }
                          }
                        } catch (e) {
                          setState(() {
                            isLoading = false;
                          });

                          if (context.mounted) {
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
                                    Text('Error: $e'),
                                  ],
                                ),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } else {
                        // Show message for empty feedback
                        final l10n = AppLocalizations.of(context)!;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.enterFeedbackFirst),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.textDark,
              ),
              child: Text(l10n.send),
            ),
          ],
        ),
      ),
    );
  }
}