// lib/widgets/settings/personal_details_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/design_system/theme_design.dart';

class PersonalDetailsWidget extends StatelessWidget {
  const PersonalDetailsWidget({super.key});

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
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                spreadRadius: 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildDetailItem(
                context,
                settingsProvider,
                icon: Icons.cake,
                title: 'Date of Birth',
                value: settingsProvider.calculatedAge,
                onTap: () => _showDatePicker(context, settingsProvider),
              ),
              const Divider(height: 1),
              _buildDetailItem(
                context,
                settingsProvider,
                icon: Icons.height,
                title: 'Height',
                value: settingsProvider.formattedHeight,
                onTap: () => _showHeightDialog(context, settingsProvider),
              ),
              const Divider(height: 1),
              _buildDetailItem(
                context,
                settingsProvider,
                icon: Icons.monitor_weight,
                title: 'Current Weight',
                value: settingsProvider.formattedWeight,
                onTap: () => _showWeightDialog(context, settingsProvider),
              ),
              const Divider(height: 1),
              _buildDetailItem(
                context,
                settingsProvider,
                icon: Icons.person,
                title: 'Gender',
                value: settingsProvider.userProfile?.gender ?? 'Not set',
                onTap: () => _showGenderDialog(context, settingsProvider),
              ),
              const Divider(height: 1),
              _buildDetailItem(
                context,
                settingsProvider,
                icon: Icons.fitness_center,
                title: 'Activity Level',
                value: settingsProvider.activityLevelText,
                onTap: () => _showActivityLevelDialog(context, settingsProvider),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    SettingsProvider settingsProvider, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppLegacyColors.primaryBlue,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 13,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  void _showDatePicker(BuildContext context, SettingsProvider settingsProvider) {
    final currentDate = settingsProvider.userProfile?.birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    
    showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) async {
      if (date != null) {
        try {
          // Calculate age from selected date
          final now = DateTime.now();
          int age = now.year - date.year;
          if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
            age--;
          }
          
          await settingsProvider.updateDateOfBirth(date, age);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Date of birth updated'), behavior: SnackBarBehavior.floating),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      }
    });
  }

  void _showHeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    final heightController = TextEditingController();
    final isMetric = settingsProvider.isMetric;
    final currentHeight = settingsProvider.userProfile?.height;
    
    if (currentHeight != null) {
      final displayHeight = isMetric ? currentHeight : currentHeight / 2.54;
      heightController.text = displayHeight.toStringAsFixed(isMetric ? 0 : 1);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Height (${isMetric ? 'cm' : 'inches'})'),
        content: TextField(
          controller: heightController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: InputDecoration(
            labelText: 'Height',
            suffixText: isMetric ? 'cm' : 'in',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = heightController.text.trim();
              if (input.isNotEmpty) {
                final inputHeight = double.tryParse(input);
                if (inputHeight != null && inputHeight > 0) {
                  final heightInCm = isMetric ? inputHeight : inputHeight * 2.54;
                  
                  try {
                    await settingsProvider.updateHeight(heightInCm);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Height updated'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showWeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    final weightController = TextEditingController();
    final isMetric = settingsProvider.isMetric;
    final currentWeight = settingsProvider.currentWeight;
    
    if (currentWeight != null) {
      final displayWeight = isMetric ? currentWeight : currentWeight * 2.20462;
      weightController.text = displayWeight.toStringAsFixed(1);
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Weight (${isMetric ? 'kg' : 'lbs'})'),
        content: TextField(
          controller: weightController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
          decoration: InputDecoration(
            labelText: 'Weight',
            suffixText: isMetric ? 'kg' : 'lbs',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final input = weightController.text.trim();
              if (input.isNotEmpty) {
                final inputWeight = double.tryParse(input);
                if (inputWeight != null && inputWeight > 0) {
                  final weightInKg = isMetric ? inputWeight : inputWeight / 2.20462;
                  
                  try {
                    await settingsProvider.updateWeight(weightInKg, isMetric);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Weight updated'), behavior: SnackBarBehavior.floating),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                      );
                    }
                  }
                }
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showGenderDialog(BuildContext context, SettingsProvider settingsProvider) {
    final genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
    final currentGender = settingsProvider.userProfile?.gender;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gender'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders.map((gender) {
            final isSelected = gender == currentGender;
            return ListTile(
              title: Text(gender, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
              trailing: isSelected ? const Icon(Icons.check, color: AppLegacyColors.primaryBlue) : null,
              onTap: () async {
                try {
                  await settingsProvider.updateGender(gender);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gender updated'), behavior: SnackBarBehavior.floating),
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
            );
          }).toList(),
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

  void _showActivityLevelDialog(BuildContext context, SettingsProvider settingsProvider) {
    final activityLevels = {
      1.2: 'Sedentary (little/no exercise)',
      1.375: 'Lightly active (light exercise 1-3 days/week)',
      1.55: 'Moderately active (moderate exercise 3-5 days/week)',
      1.725: 'Very active (hard exercise 6-7 days/week)',
      1.9: 'Super active (very hard exercise, physical job)',
    };
    
    final currentLevel = settingsProvider.userProfile?.activityLevel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Level'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: activityLevels.entries.map((entry) {
              final isSelected = entry.key == currentLevel;
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: AppLegacyColors.primaryBlue) : null,
                onTap: () async {
                  try {
                    await settingsProvider.updateActivityLevel(entry.key);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Activity level updated'), behavior: SnackBarBehavior.floating),
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
              );
            }).toList(),
          ),
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
}