// lib/widgets/settings/preferences_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/design_system/theme.dart';

class PreferencesWidget extends StatelessWidget {
  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const PreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                // ✅ FIXED: Use withValues instead of withOpacity (line 20)
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
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
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: title == 'Units' ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                // ✅ FIXED: Use withValues instead of withOpacity (line 86)
                color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppTheme.primaryBlue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
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
  // INLINE METHODS
  // =============================================================================

  void _toggleUnits(BuildContext context, SettingsProvider settingsProvider) async {
    try {
      await settingsProvider.updateUnitPreference(!settingsProvider.isMetric);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Units changed to ${settingsProvider.isMetric ? 'Metric' : 'Imperial'}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
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
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Monthly Weight Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Goal direction toggle
              Row(
                children: [
                  Expanded(
                    child: _buildGoalTypeButton(
                      label: 'Lose Weight',
                      icon: Icons.trending_down,
                      isSelected: !isGain,
                      color: AppTheme.coralAccent,
                      onTap: () => setState(() => isGain = false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGoalTypeButton(
                      label: 'Gain Weight',
                      icon: Icons.trending_up,
                      isSelected: isGain,
                      color: AppTheme.goldAccent,
                      onTap: () => setState(() => isGain = true),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Amount selection
              Text(
                'Amount per month',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.grey[700]),
              ),
              
              const SizedBox(height: 16),

              // Simple slider for amount
              Slider(
                value: selectedAmount,
                min: 0.5,
                max: 8.0,
                divisions: 15,
                label: '${selectedAmount.toStringAsFixed(1)} ${isMetric ? 'kg' : 'lbs'}',
                activeColor: isGain ? AppTheme.goldAccent : AppTheme.coralAccent,
                onChanged: (value) => setState(() => selectedAmount = value),
              ),

              // Current selection display
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // ✅ FIXED: Use withValues instead of withOpacity (line 203)
                  color: (isGain ? AppTheme.goldAccent : AppTheme.coralAccent).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isGain ? Icons.trending_up : Icons.trending_down,
                      color: isGain ? AppTheme.goldAccent : AppTheme.coralAccent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${isGain ? '+' : '-'}${selectedAmount.toStringAsFixed(1)} ${isMetric ? 'kg' : 'lbs'}/month',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isGain ? AppTheme.goldAccent : AppTheme.coralAccent,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Recommendation text
              Text(
                _getGoalRecommendation(selectedAmount, isGain),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                // Convert to kg if needed and apply direction
                double goalInKg = isMetric ? selectedAmount : selectedAmount / 2.20462;
                if (!isGain) goalInKg = -goalInKg;

                try {
                  await settingsProvider.updateMonthlyWeightGoal(goalInKg);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Weight goal updated'), behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          // ✅ FIXED: Use withValues instead of withOpacity (lines 282 - both instances)
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            // ✅ FIXED: Use withValues instead of withOpacity (line 285)
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGoalRecommendation(double amount, bool isGain) {
    if (amount <= 1.0) {
      return isGain 
          ? 'Slow and steady muscle building approach'
          : 'Gentle, sustainable weight loss';
    } else if (amount <= 3.0) {
      return isGain
          ? 'Balanced approach for most people'
          : 'Moderate weight loss pace';
    } else if (amount <= 5.0) {
      return isGain
          ? 'Faster gains, may include some fat'
          : 'Aggressive weight loss, requires dedication';
    } else {
      return isGain
          ? 'Very fast gains, consult a nutritionist'
          : 'Very aggressive goal, please consult a doctor';
    }
  }
}