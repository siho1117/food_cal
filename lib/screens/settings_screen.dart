// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/profile_section_widget.dart';
import '../widgets/settings/personal_details_widget.dart';
import '../widgets/settings/preferences_widget.dart';
import '../widgets/settings/feedback_widget.dart';
import '../config/design_system/theme_background.dart';
import '../widgets/common/custom_app_bar.dart';

class SettingsScreen extends StatefulWidget {
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: ThemeBackground.getGradient(themeProvider.selectedGradient),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            // Use CustomAppBar when NOT showing back button (bottom nav flow)
            // Use default AppBar when showing back button (push navigation flow)
            appBar: widget.showBackButton
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: Colors.white,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                : const CustomAppBar(currentPage: 'settings'),
            body: Consumer<SettingsProvider>(
              builder: (context, settingsProvider, child) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Section
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
        );
      },
    );
  }
}