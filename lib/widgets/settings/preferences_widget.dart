// lib/widgets/settings/preferences_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/language_provider.dart';
import '../../config/design_system/theme.dart';
import 'language_selector_dialog.dart';

class PreferencesWidget extends StatelessWidget {
  const PreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        // Also watch LanguageProvider for language changes
        final languageProvider = Provider.of<LanguageProvider>(context);
        
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
      borderRadius: BorderRadius.vertical(
        top: title == 'Language' ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: leadingEmoji != null
                  ? Text(
                      leadingEmoji,
                      style: const TextStyle(fontSize: 24),
                    )
                  : Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            trailing ?? const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // =============================================================================
  // DIALOG METHODS
  // =============================================================================

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  void _toggleUnits(BuildContext context, SettingsProvider settingsProvider) async {
    try {
      await settingsProvider.updateUnitPreference(!settingsProvider.isMetric);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Units changed to ${settingsProvider.isMetric ? 'Metric' : 'Imperial'}',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showWeightGoalDialog(BuildContext context, SettingsProvider settingsProvider) {
    bool isGain = true;
    double selectedAmount = 2.0; // Default 2kg/month
    final isMetric = settingsProvider.isMetric;
    
    // Set initial values if goal exists
    if (settingsProvider.userProfile?.monthlyWeightGoal != null) {
      final goal = settingsProvider.userProfile!.monthlyWeightGoal!;
      isGain = goal > 0;
      selectedAmount = goal.abs();
      // Convert to imperial if needed
      if (!isMetric) {
        selectedAmount = selectedAmount * 2.20462;
      }
    }

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.speed, color: AppTheme.primaryBlue),
                SizedBox(width: 8),
                Text('Monthly Weight Goal'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set your monthly weight change target:',
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                
                // Gain/Lose toggle
                Row(
                  children: [
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Lose'),
                        selected: !isGain,
                        onSelected: (selected) {
                          setState(() => isGain = !selected);
                        },
                        selectedColor: AppTheme.coralAccent,
                        labelStyle: TextStyle(
                          color: !isGain ? Colors.white : Colors.grey[700],
                          fontWeight: !isGain ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ChoiceChip(
                        label: const Text('Gain'),
                        selected: isGain,
                        onSelected: (selected) {
                          setState(() => isGain = selected);
                        },
                        selectedColor: AppTheme.coralAccent,
                        labelStyle: TextStyle(
                          color: isGain ? Colors.white : Colors.grey[700],
                          fontWeight: isGain ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Amount slider
                Text(
                  '${selectedAmount.toStringAsFixed(1)} ${isMetric ? 'kg' : 'lbs'}/month',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Slider(
                  value: selectedAmount,
                  min: 0.5,
                  max: isMetric ? 4.0 : 8.8,
                  divisions: isMetric ? 35 : 83,
                  activeColor: AppTheme.coralAccent,
                  onChanged: (value) {
                    setState(() => selectedAmount = value);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  // Convert to kg if imperial
                  double goalInKg = isMetric ? selectedAmount : selectedAmount / 2.20462;
                  // Apply sign based on gain/lose
                  goalInKg = isGain ? goalInKg : -goalInKg;
                  
                  await settingsProvider.updateMonthlyWeightGoal(goalInKg);
                  if (dialogContext.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.coralAccent,
                ),
                child: const Text('Save', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }
}