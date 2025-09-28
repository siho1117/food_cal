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
    super.key,
    this.showBackButton = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use existing provider from app level instead of creating new one
    return Scaffold(
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'SETTINGS',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                              letterSpacing: 1.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.refresh,
                              color: AppTheme.primaryBlue,
                            ),
                            onPressed: () => settingsProvider.refreshData(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],

                    // Profile Section
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
                      child: const ProfileSectionWidget(),
                    ),

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