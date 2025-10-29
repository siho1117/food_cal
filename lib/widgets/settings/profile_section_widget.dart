// lib/widgets/settings/profile_section_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dialog_theme.dart';

class ProfileSectionWidget extends StatelessWidget {
  const ProfileSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
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
          onTap: () => _handleProfileTap(context, settingsProvider),
        );
      },
    );
  }

  Widget _buildTransparentCard({
    required BuildContext context,
    required String? userName,
    required bool hasName,
    required ThemeProvider themeProvider,
    required VoidCallback onTap,
  }) {
    final brightness = Theme.of(context).brightness;
    final borderColor = themeProvider.getBorderColor(brightness);
    final textColor = themeProvider.getTextColor(brightness);
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(52), // Pill shape
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Fully transparent to show gradient
            borderRadius: BorderRadius.circular(52), // Pill shape
            border: Border.all(
              color: borderColor,
              width: AppWidgetDesign.cardBorderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(52), // Pill shape
              splashColor: textColor.withValues(alpha: 0.1),
              highlightColor: textColor.withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 22, 24, 22), // Reduced from 24,28,24,28 (slightly shorter)
                child: Row(
                  children: [
                    // Avatar circle with gradient letter or empty icon
                    _buildAvatar(context, userName, hasName, themeProvider),
                    
                    const SizedBox(width: 16),
                    
                    // Name section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Minimize height
                        children: [
                          Text(
                            hasName ? userName! : 'Tap to edit',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: hasName 
                                  ? textColor
                                  : textColor.withValues(alpha: 0.6),
                              shadows: AppWidgetDesign.textShadows,
                            ),
                          ),
                          // No subtitle - cleaner design
                        ],
                      ),
                    ),
                    
                    // ✅ Mono tone arrow icon (matches theme)
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 18,
                      color: textColor.withValues(alpha: 0.6), // Subtle, matches text
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

  Widget _buildAvatar(
    BuildContext context, 
    String? userName, 
    bool hasName,
    ThemeProvider themeProvider,
  ) {
    final brightness = Theme.of(context).brightness;
    final textColor = themeProvider.getTextColor(brightness);
    
    // Determine solid color based on theme (no opacity)
    // Theme 01 (Light Gray) uses black, others use white
    final gradientName = themeProvider.selectedGradient;
    final solidAvatarColor = gradientName == '01' 
        ? Colors.black      // Solid black for Theme 01
        : Colors.white;     // Solid white for Theme 02-09
    
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: hasName 
            ? solidAvatarColor                      // Solid black or white (no opacity)
            : textColor.withValues(alpha: 0.25),    // Subtle adaptive background when no name
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1), // Softer shadow
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: hasName 
            ? _buildGradientLetter(context, userName!, themeProvider)
            : Icon(
                Icons.person,
                size: 28,
                color: textColor, // ✅ Matches text color (adaptive)
              ),
      ),
    );
  }

  Widget _buildGradientLetter(
    BuildContext context, 
    String userName,
    ThemeProvider themeProvider,
  ) {
    // Get first character and uppercase it
    final letter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    
    // Get gradient from theme provider
    final brightness = Theme.of(context).brightness;
    final gradient = themeProvider.getCurrentGradient(brightness);
    
    return ShaderMask(
      shaderCallback: (bounds) => gradient.createShader(bounds),
      blendMode: BlendMode.srcIn,
      child: Text(
        letter,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white, // This color gets replaced by gradient
        ),
      ),
    );
  }

  void _handleProfileTap(BuildContext context, SettingsProvider settingsProvider) {
    // Show dialog to edit name
    _showEditNameDialog(context, settingsProvider);
  }

  void _showEditNameDialog(BuildContext context, SettingsProvider settingsProvider) {
    final currentName = settingsProvider.userProfile?.name ?? '';
    final controller = TextEditingController(text: currentName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        // Apply dialog styling from AppDialogTheme
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        
        // Title with proper styling
        title: const Text(
          'Edit Name',
          style: AppDialogTheme.titleStyle,
        ),
        
        // Content with styled TextField
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppDialogTheme.inputTextStyle,
          decoration: AppDialogTheme.inputDecoration(),
        ),
        
        // Actions with proper button styling and spacing
        actions: [
          // Cancel button (TextButton)
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: AppDialogTheme.cancelButtonStyle,
            child: const Text('Cancel'),
          ),
          
          // Small gap between buttons
          const SizedBox(width: AppDialogTheme.buttonGap),
          
          // Save button (FilledButton)
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
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}