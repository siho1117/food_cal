// lib/screens/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings/profile_section_widget.dart';
import '../widgets/settings/personal_details_widget.dart';
import '../widgets/settings/preferences_widget.dart';
import '../widgets/settings/feedback_widget.dart';
import '../config/design_system/theme.dart';

class SettingsScreen extends StatefulWidget {
  // Parameter to check if we should show back button
  final bool showBackButton;

  const SettingsScreen({
    Key? key,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // Provide the SettingsProvider to the widget tree
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider()..loadUserData(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
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
              // Show loading state
              if (settingsProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              // Show error state if needed
              if (settingsProvider.errorMessage != null) {
                return _buildErrorState(context, settingsProvider);
              }

              // Show main content with RefreshIndicator for pull-to-refresh
              return RefreshIndicator(
                onRefresh: () => settingsProvider.refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header - only show this if not showing the appbar
                      if (!widget.showBackButton) ...[
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FOOD CAL',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryBlue,
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'SETTINGS',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Profile Section
                      const ProfileSectionWidget(),

                      const SizedBox(height: 30),

                      // Personal Details Section
                      Text(
                        'PERSONAL DETAILS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const PersonalDetailsWidget(),

                      const SizedBox(height: 30),

                      // Preferences Section
                      Text(
                        'PREFERENCES',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      const PreferencesWidget(),

                      const SizedBox(height: 30),

                      // Feedback Section
                      Text(
                        'FEEDBACK',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Feedback Widget
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              spreadRadius: 0,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: FeedbackWidget(
                          onSendFeedback: () async {
                            // Handle feedback sending through provider
                            // The FeedbackWidget will handle the UI interaction
                          },
                        ),
                      ),

                      const SizedBox(height: 80), // Extra space for bottom nav
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, SettingsProvider settingsProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            settingsProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => settingsProvider.refreshData(),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => settingsProvider.clearError(),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}