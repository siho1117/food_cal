// lib/widgets/settings/profile_section_widget.dart
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';

class ProfileSectionWidget extends StatelessWidget {
  const ProfileSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Get user name from profile (or null if not set)
        final userName = settingsProvider.userProfile?.name;
        final hasName = userName != null && userName.isNotEmpty;
        
        return _buildTransparentCard(
          userName: userName,
          hasName: hasName,
          onTap: () => _handleProfileTap(context, settingsProvider),
        );
      },
    );
  }

  Widget _buildTransparentCard({
    required String? userName,
    required bool hasName,
    required VoidCallback onTap,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15), // Transparent to show gradient
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 4,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(28),
              splashColor: Colors.white.withOpacity(0.1),
              highlightColor: Colors.white.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    // Avatar circle with gradient letter or empty icon
                    _buildAvatar(userName, hasName),
                    
                    const SizedBox(width: 16),
                    
                    // Name section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hasName ? userName! : 'Name',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: hasName 
                                  ? Colors.white 
                                  : Colors.white.withOpacity(0.6),
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap to edit',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.8),
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(0, 1),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Edit icon
                    Icon(
                      Icons.edit_rounded,
                      size: 20,
                      color: Colors.white.withOpacity(0.9),
                      shadows: const [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
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

  Widget _buildAvatar(String? userName, bool hasName) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: hasName 
            ? Colors.white.withOpacity(0.95)  // White circle for letter
            : Colors.white.withOpacity(0.3),   // Semi-transparent for empty
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: hasName 
            ? _buildGradientLetter(userName!)
            : Icon(
                Icons.person,
                size: 28,
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildGradientLetter(String userName) {
    // Get first character and uppercase it
    final letter = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    
    // TODO: Connect to theme provider's gradient when theme system is ready
    // For now, using hardcoded gradient matching the mockup
    const gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF667EEA), // Purple-blue
        Color(0xFF764BA2), // Purple
      ],
    );
    
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
    // TODO: Show dialog or navigate to profile edit screen
    // For now, show a simple dialog to edit name
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