// lib/widgets/settings/profile_section_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/theme.dart';

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
      borderRadius: BorderRadius.circular(AppWidgetDesign.cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.transparent, // Fully transparent to show gradient
            borderRadius: BorderRadius.circular(AppWidgetDesign.cardBorderRadius),
            border: Border.all(
              color: borderColor,
              width: AppWidgetDesign.cardBorderWidth,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppWidgetDesign.cardBorderRadius),
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
                            hasName ? userName! : 'Name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: hasName 
                                  ? textColor
                                  : textColor.withValues(alpha: 0.6),
                              shadows: AppWidgetDesign.textShadows, // NO SHADOWS
                            ),
                          ),
                          const SizedBox(height: 3), // Slightly reduced
                          Text(
                            'Tap to edit',
                            style: TextStyle(
                              fontSize: 14, // ✅ Bigger - was 12
                              fontWeight: FontWeight.w400,
                              color: textColor.withValues(
                                alpha: AppWidgetDesign.secondaryTextOpacity,
                              ),
                              shadows: AppWidgetDesign.textShadows, // NO SHADOWS
                            ),
                          ),
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
    
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: hasName 
            ? Colors.white.withValues(alpha: 0.95)  // White circle for letter
            : textColor.withValues(alpha: 0.25),    // ✅ Adaptive subtle background
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
        title: const Text('Edit Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isNotEmpty) {
                await settingsProvider.updateName(newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Name updated successfully'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}