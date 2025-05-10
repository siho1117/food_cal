import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';

class ProfilePictureWidget extends StatelessWidget {
  final String? avatarUrl;
  final VoidCallback onTap;

  const ProfilePictureWidget({
    Key? key,
    this.avatarUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar with edit button
            Stack(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                  backgroundImage:
                      avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                  child: avatarUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey,
                        )
                      : null,
                ),

                // Edit button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor, // Changed to burgundy accent
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Label
            const Text(
              'Edit Profile Picture',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}