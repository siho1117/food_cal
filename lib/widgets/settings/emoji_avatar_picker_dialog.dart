// lib/widgets/settings/emoji_avatar_picker_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import 'package:provider/provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../utils/emoji_filters.dart';
import '../../l10n/generated/app_localizations.dart';

/// Dialog for selecting an animal emoji avatar
class EmojiAvatarPickerDialog extends StatefulWidget {
  const EmojiAvatarPickerDialog({super.key});

  @override
  State<EmojiAvatarPickerDialog> createState() => _EmojiAvatarPickerDialogState();
}

class _EmojiAvatarPickerDialogState extends State<EmojiAvatarPickerDialog> {
  late List<AnimatedEmojiData> _animalEmojis;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmojis();
  }

  void _loadEmojis() {
    // Load animal emojis in next frame to avoid blocking UI
    Future.microtask(() {
      setState(() {
        _animalEmojis = EmojiFilters.getAnimalEmojis();
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);

    final currentEmojiId = settingsProvider.userProfile?.profileEmojiId;

    // Use standard dialog with backdrop blur like other dialogs
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDialogTheme.backdropBlurSigmaX,
        sigmaY: AppDialogTheme.backdropBlurSigmaY,
      ),
      child: Dialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with title
              _buildHeader(context, l10n),

              // Divider
              const Divider(
                color: AppDialogTheme.colorBorderLight,
                height: 1,
              ),

              // Letter icon sample at top
              _buildLetterSample(context, settingsProvider),

              // Divider
              const Divider(
                color: AppDialogTheme.colorBorderLight,
                height: 1,
              ),

              // Emoji grid
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : _buildEmojiGrid(
                        context,
                        themeProvider,
                        settingsProvider,
                        currentEmojiId,
                      ),
              ),

              // Footer with action buttons
              _buildFooter(context, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          l10n.chooseYourAvatar,
          style: AppDialogTheme.titleStyle,
        ),
      ),
    );
  }

  Widget _buildLetterSample(
    BuildContext context,
    SettingsProvider settingsProvider,
  ) {
    // Get first letter of user's name, or 'A' as default
    final userName = settingsProvider.userProfile?.name ?? 'User';
    final firstLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'A';

    return InkWell(
      onTap: () async {
        // Switch to letter avatar and close dialog
        await settingsProvider.useLetterAvatar();
        if (context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: Provider.of<ThemeProvider>(context).getCurrentGradient(),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(
          AppDialogTheme.colorPrimaryDark,
        ),
      ),
    );
  }

  Widget _buildEmojiGrid(
    BuildContext context,
    ThemeProvider themeProvider,
    SettingsProvider settingsProvider,
    String? currentEmojiId,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: _animalEmojis.length,
        itemBuilder: (context, index) {
          final emoji = _animalEmojis[index];
          final isSelected = currentEmojiId == emoji.id;

          return _buildEmojiItem(
            context,
            emoji,
            isSelected,
            themeProvider,
            settingsProvider,
          );
        },
      ),
    );
  }

  Widget _buildEmojiItem(
    BuildContext context,
    AnimatedEmojiData emoji,
    bool isSelected,
    ThemeProvider themeProvider,
    SettingsProvider settingsProvider,
  ) {
    final gradient = themeProvider.getCurrentGradient();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          // Save selected emoji and enable emoji mode
          await settingsProvider.updateProfileEmoji(emoji.id);

          // Close dialog after selection
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            gradient: isSelected ? gradient : null,
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : AppDialogTheme.colorBorderLight,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: AnimatedEmoji(
              emoji,
              size: 40,
              repeat: true,
              errorWidget: Icon(
                Icons.help_outline,
                size: 32,
                color: AppDialogTheme.colorTextSecondary.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Info text
          Text(
            l10n.tapAnEmojiToSelect,
            style: AppDialogTheme.bodyStyle.copyWith(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 12),

          // Close button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                backgroundColor: AppDialogTheme.colorBorderLight.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                l10n.close,
                style: const TextStyle(
                  fontSize: AppDialogTheme.fontSizeStandard,
                  fontWeight: FontWeight.w600,
                  color: AppDialogTheme.colorPrimaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Helper function to show the emoji avatar picker dialog
Future<void> showEmojiAvatarPicker(BuildContext context) async {
  return showDialog(
    context: context,
    builder: (context) => const EmojiAvatarPickerDialog(),
  );
}
