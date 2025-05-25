// lib/widgets/settings/personal_details_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../config/design_system/theme.dart';
import '../../data/models/weight_data.dart';

class PersonalDetailsWidget extends StatelessWidget {
  const PersonalDetailsWidget({Key? key}) : super(key: key);

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
                color: Colors.black.withOpacity(0.05),
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
                icon: Icons.directions_run,
                title: 'Activity Level',
                value: settingsProvider.activityLevelText,
                onTap: () => _showActivityDialog(context, settingsProvider),
                isLast: true,
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
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: title == 'Date of Birth' ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.1),
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
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  // =============================================================================
  // INLINE DIALOG METHODS - All consolidated here
  // =============================================================================

  void _showDatePicker(BuildContext context, SettingsProvider settingsProvider) async {
    final now = DateTime.now();
    final initialDate = settingsProvider.userProfile?.birthDate ?? DateTime(now.year - 30);
    
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryBlue,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Calculate age
      int age = now.year - picked.year;
      if (now.month < picked.month || (now.month == picked.month && now.day < picked.day)) {
        age--;
      }

      try {
        await settingsProvider.updateDateOfBirth(picked, age);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Date of birth updated'), behavior: SnackBarBehavior.floating),
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
  }

  void _showHeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    final heightController = TextEditingController();
    bool isMetric = settingsProvider.isMetric;
    
    // Set initial value
    if (settingsProvider.userProfile?.height != null) {
      final height = settingsProvider.userProfile!.height!;
      if (isMetric) {
        heightController.text = height.round().toString();
      } else {
        final inches = height / 2.54;
        final feet = (inches / 12).floor();
        final remainingInches = (inches % 12).round();
        heightController.text = '$feet.$remainingInches';
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Height'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unit toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Imperial', style: TextStyle(color: !isMetric ? Colors.black : Colors.grey)),
                  Switch(
                    value: isMetric,
                    onChanged: (value) => setState(() => isMetric = value),
                    activeColor: AppTheme.primaryBlue,
                  ),
                  Text('Metric', style: TextStyle(color: isMetric ? Colors.black : Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              // Height input
              TextField(
                controller: heightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: InputDecoration(
                  labelText: isMetric ? 'Height (cm)' : 'Height (ft.in)',
                  hintText: isMetric ? 'e.g., 170' : 'e.g., 5.8',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final input = heightController.text.trim();
                if (input.isEmpty) return;

                double? heightInCm;
                if (isMetric) {
                  heightInCm = double.tryParse(input);
                } else {
                  final parts = input.split('.');
                  if (parts.length == 2) {
                    final feet = int.tryParse(parts[0]) ?? 0;
                    final inches = int.tryParse(parts[1]) ?? 0;
                    heightInCm = ((feet * 12) + inches) * 2.54;
                  }
                }

                if (heightInCm != null && heightInCm > 0) {
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
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _showWeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    final weightController = TextEditingController();
    bool isMetric = settingsProvider.isMetric;
    
    // Set initial value
    if (settingsProvider.currentWeight != null) {
      final weight = settingsProvider.currentWeight!;
      if (isMetric) {
        weightController.text = weight.toStringAsFixed(1);
      } else {
        final lbs = weight * 2.20462;
        weightController.text = lbs.toStringAsFixed(1);
      }
    }

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Unit toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Imperial', style: TextStyle(color: !isMetric ? Colors.black : Colors.grey)),
                  Switch(
                    value: isMetric,
                    onChanged: (value) => setState(() => isMetric = value),
                    activeColor: AppTheme.primaryBlue,
                  ),
                  Text('Metric', style: TextStyle(color: isMetric ? Colors.black : Colors.grey)),
                ],
              ),
              const SizedBox(height: 20),
              // Weight input
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                decoration: InputDecoration(
                  labelText: isMetric ? 'Weight (kg)' : 'Weight (lbs)',
                  hintText: isMetric ? 'e.g., 70.5' : 'e.g., 155.0',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final input = weightController.text.trim();
                if (input.isEmpty) return;

                final inputWeight = double.tryParse(input);
                if (inputWeight != null && inputWeight > 0) {
                  // Convert to kg if needed
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
              },
              child: const Text('Save'),
            ),
          ],
        ),
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
              trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryBlue) : null,
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showActivityDialog(BuildContext context, SettingsProvider settingsProvider) {
    final activities = [
      {'level': 1.2, 'title': 'Sedentary', 'description': 'Little or no exercise'},
      {'level': 1.375, 'title': 'Light', 'description': 'Light exercise 1-3 days/week'},
      {'level': 1.55, 'title': 'Moderate', 'description': 'Moderate exercise 3-5 days/week'},
      {'level': 1.725, 'title': 'Active', 'description': 'Hard exercise 6-7 days/week'},
      {'level': 1.9, 'title': 'Very Active', 'description': 'Very hard daily exercise'},
    ];
    
    final currentLevel = settingsProvider.userProfile?.activityLevel;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activity Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: activities.map((activity) {
            final isSelected = activity['level'] == currentLevel;
            return ListTile(
              title: Text(
                activity['title'] as String,
                style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              ),
              subtitle: Text(activity['description'] as String),
              trailing: isSelected ? Icon(Icons.check_circle, color: AppTheme.primaryBlue) : null,
              onTap: () async {
                try {
                  await settingsProvider.updateActivityLevel(activity['level'] as double);
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
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }
}