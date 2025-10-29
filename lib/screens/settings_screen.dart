// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/profile_section_widget.dart';
import '../widgets/settings/personal_details_widget.dart';
import '../widgets/settings/preferences_widget.dart';
import '../widgets/settings/feedback_widget.dart';
import '../config/design_system/theme_design.dart';  // ✅ For AppColors if needed
import '../config/design_system/theme_background.dart';

class SettingsScreen extends StatefulWidget {
  // Parameter to check if we should show back button
  final bool showBackButton;

  const SettingsScreen({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Wrap with Consumer<ThemeProvider> to get dynamic gradient
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          // ✅ NEW: Direct gradient decoration using ThemeBackground
          decoration: BoxDecoration(
            gradient: ThemeBackground.getGradient(themeProvider.selectedGradient),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent, // Make transparent to show gradient
            // Add an app bar with back button when needed
            appBar: widget.showBackButton
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: AppColors.textDark,  // ✅ Using AppColors
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        color: AppColors.textDark,  // ✅ Using AppColors
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : null,
            body: SafeArea(
              child: Consumer<SettingsProvider>(
                builder: (context, settingsProvider, child) {
                  // Content without loading/error checks
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Section - NO WHITE CONTAINER WRAPPER
                        const ProfileSectionWidget(),

                        const SizedBox(height: 20),

                        // Personal Details
                        const PersonalDetailsWidget(),

                        const SizedBox(height: 20),

                        // Preferences (language, theme, units)
                        const PreferencesWidget(),

                        const SizedBox(height: 20),

                        // Feedback Widget
                        const FeedbackWidget(),

                        // Bottom padding for navigation bar
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}