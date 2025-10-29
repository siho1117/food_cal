// lib/widgets/settings/preferences_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/theme.dart';
import 'language_selector_dialog.dart';
import 'theme_selector_dialog.dart';

class PreferencesWidget extends StatelessWidget {
  const PreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Also watch LanguageProvider and ThemeProvider for changes
        final languageProvider = Provider.of<LanguageProvider>(context);
        final themeProvider = Provider.of<ThemeProvider>(context);
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Language preference
              _buildPreferenceItem(
                context,
                settingsProvider,
                icon: Icons.language,
                title: 'Language',
                value: languageProvider.currentLanguageName,
                leadingEmoji: languageProvider.currentLanguageFlag,
                onTap: () => _showLanguageDialog(context),
              ),

              const Divider(height: 1),

              // Theme preference
              _buildPreferenceItem(
                context,
                settingsProvider,
                icon: Icons.palette,
                title: 'Theme',
                value: themeProvider.getGradientDisplayName(themeProvider.selectedGradient),
                leadingEmoji: themeProvider.getGradientEmoji(themeProvider.selectedGradient),
                onTap: () => _showThemeDialog(context),
              ),

              const Divider(height: 1),

              // Units preference with inline toggle
              _buildPreferenceItem(
                context,
                settingsProvider,
                icon: Icons.straighten,
                title: 'Units',
                value: settingsProvider.isMetric ? 'Metric' : 'Imperial',
                trailing: Switch(
                  value: settingsProvider.isMetric,
                  onChanged: (value) => _toggleUnits(context, settingsProvider),
                  activeColor: AppTheme.primaryBlue,
                ),
                onTap: () => _toggleUnits(context, settingsProvider),
              ),

              const Divider(height: 1),

              // Monthly weight goal
              _buildPreferenceItem(
                context,
                settingsProvider,
                icon: Icons.speed,
                title: 'Monthly Weight Goal',
                value: settingsProvider.formattedMonthlyGoal,
                onTap: () => _showWeightGoalDialog(context, settingsProvider),
                isLast: true,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPreferenceItem(
    BuildContext context,
    SettingsProvider settingsProvider, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
    Widget? trailing,
    String? leadingEmoji,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            // Leading emoji or icon
            if (leadingEmoji != null)
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  leadingEmoji,
                  style: const TextStyle(fontSize: 24),
                ),
              )
            else
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppTheme.primaryBlue, size: 20),
              ),
            
            const SizedBox(width: 16),
            
            // Title and value
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Trailing widget or chevron
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.chevron_right,
                color: Colors.grey[400],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ThemeSelectorDialog(),
    );
  }

  void _toggleUnits(BuildContext context, SettingsProvider settingsProvider) {
    final newValue = !settingsProvider.isMetric;
    settingsProvider.updateUnitPreference(newValue);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Units changed to ${newValue ? 'Metric' : 'Imperial'}'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWeightGoalDialog(BuildContext context, SettingsProvider settingsProvider) {
    final TextEditingController controller = TextEditingController();
    
    // Pre-fill with current goal if it exists
    if (settingsProvider.userProfile?.monthlyWeightGoal != null) {
      final currentGoal = settingsProvider.userProfile!.monthlyWeightGoal!;
      controller.text = currentGoal.abs().toStringAsFixed(1);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Monthly Weight Goal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How much weight do you want to lose per month?',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: settingsProvider.isMetric ? 'Goal (kg)' : 'Goal (lbs)',
                hintText: '0.5',
                border: const OutlineInputBorder(),
                suffixText: settingsProvider.isMetric ? 'kg' : 'lbs',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recommended: 0.5-1 ${settingsProvider.isMetric ? 'kg' : 'lbs'} per month',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final input = double.tryParse(controller.text);
              if (input != null && input > 0) {
                // Store as negative (weight loss)
                final goalInKg = settingsProvider.isMetric 
                    ? -input 
                    : -input * 0.453592; // Convert lbs to kg
                    
                await settingsProvider.updateMonthlyWeightGoal(goalInKg);
                
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Monthly weight goal updated'),
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