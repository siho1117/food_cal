// lib/widgets/settings/profile_section_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/design_system/theme.dart';

class ProfileSectionWidget extends StatelessWidget {
  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const ProfileSectionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Column(
          children: [
            // Profile Picture with inline edit functionality
            _buildProfilePicture(context, settingsProvider),
            
            const SizedBox(height: 20),

            // Profile Completion Card
            _buildProfileCompletionCard(settingsProvider),
          ],
        );
      },
    );
  }

  Widget _buildProfilePicture(BuildContext context, SettingsProvider settingsProvider) {
    return InkWell(
      onTap: () => _showAvatarOptions(context, settingsProvider),
      borderRadius: BorderRadius.circular(60),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar with edit button
            Stack(
              children: [
                // Avatar circle
                CircleAvatar(
                  radius: 50,
                  // ✅ FIXED: Use withValues instead of withOpacity
                  backgroundColor: AppTheme.primaryBlue.withValues(alpha: 0.1),
                  backgroundImage: settingsProvider.avatarUrl != null 
                      ? NetworkImage(settingsProvider.avatarUrl!) 
                      : null,
                  child: settingsProvider.avatarUrl == null
                      ? const Icon(Icons.person, size: 50, color: Colors.grey)
                      : null,
                ),
                // Edit button overlay
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Label
            const Text(
              'Edit Profile Picture',
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCompletionCard(SettingsProvider settingsProvider) {
    final completionPercentage = settingsProvider.profileCompletionPercentage;
    final missingData = settingsProvider.getMissingProfileData();
    final isComplete = settingsProvider.isProfileComplete;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            // ✅ FIXED: Use withValues instead of withOpacity
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isComplete 
                      // ✅ FIXED: Use withValues instead of withOpacity
                      ? Colors.green.withValues(alpha: 0.1)
                      // ✅ FIXED: Use withValues instead of withOpacity
                      : AppTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  isComplete ? Icons.check_circle : Icons.person,
                  color: isComplete ? Colors.green : AppTheme.primaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isComplete ? 'Profile Complete!' : 'Profile Setup',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isComplete ? Colors.green : AppTheme.primaryBlue,
                      ),
                    ),
                    Text(
                      isComplete 
                          ? 'All information is complete'
                          : '${(completionPercentage * 100).round()}% complete',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (!isComplete) ...[
            const SizedBox(height: 16),

            // Progress bar
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: FractionallySizedBox(
                widthFactor: completionPercentage,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        // ✅ FIXED: Use withValues instead of withOpacity
                        AppTheme.primaryBlue.withValues(alpha: 0.7),
                        AppTheme.primaryBlue,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Missing data info
            Text(
              'Complete these fields:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              missingData.join(', '),
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ]
        ],
      ),
    );
  }

  // =============================================================================
  // INLINE AVATAR SELECTION
  // =============================================================================

  void _showAvatarOptions(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.photo_camera, color: AppTheme.primaryBlue),
            const SizedBox(width: 8),
            const Text('Profile Picture'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose how to update your profile picture:'),
            const SizedBox(height: 20),
            
            // Avatar options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Camera option
                _buildAvatarOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _selectFromCamera(context, settingsProvider);
                  },
                ),
                
                // Gallery option
                _buildAvatarOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _selectFromGallery(context, settingsProvider);
                  },
                ),
                
                // Remove option
                _buildAvatarOption(
                  icon: Icons.delete,
                  label: 'Remove',
                  color: Colors.red,
                  onTap: () {
                    Navigator.pop(context);
                    _removeAvatar(context, settingsProvider);
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    final optionColor = color ?? AppTheme.primaryBlue;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // ✅ FIXED: Use withValues instead of withOpacity
          color: optionColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          // ✅ FIXED: Use withValues instead of withOpacity
          border: Border.all(color: optionColor.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: optionColor),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: optionColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _selectFromCamera(BuildContext context, SettingsProvider settingsProvider) {
    // In a real app, you would use image_picker to get image from camera
    // For demo purposes, we'll set a placeholder
    settingsProvider.updateAvatarUrl('https://source.unsplash.com/100x100?face&random=1');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera feature coming soon! Used placeholder image.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _selectFromGallery(BuildContext context, SettingsProvider settingsProvider) {
    // In a real app, you would use image_picker to get image from gallery
    // For demo purposes, we'll set a placeholder
    settingsProvider.updateAvatarUrl('https://source.unsplash.com/100x100?portrait&random=2');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery feature coming soon! Used placeholder image.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _removeAvatar(BuildContext context, SettingsProvider settingsProvider) {
    settingsProvider.updateAvatarUrl(null);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile picture removed'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}