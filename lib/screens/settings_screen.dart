// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/settings/profile_section_widget.dart';
import '../widgets/settings/personal_details_widget.dart';
import '../widgets/settings/preferences_widget.dart';
import '../widgets/settings/feedback_widget.dart';
import '../config/design_system/theme.dart';
import '../config/design_system/gradient_background.dart';

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
        return GradientBackground(
          gradientName: themeProvider.selectedGradient, // Dynamic gradient
          child: Scaffold(
            backgroundColor: Colors.transparent, // Make transparent to show gradient
            // Add an app bar with back button when needed
            appBar: widget.showBackButton
                ? AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      color: AppTheme.primaryBlue,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    title: const Text(
                      'Settings',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
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
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const PersonalDetailsWidget(),
                        ),

                        const SizedBox(height: 20),

                        // Preferences
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const PreferencesWidget(),
                        ),

                        const SizedBox(height: 20),

                        // Feedback
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const FeedbackWidget(),
                        ),

                        const SizedBox(height: 20),
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