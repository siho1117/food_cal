import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';
import '../../data/models/user_profile.dart';
import '../../utils/formula.dart';
import '../../data/repositories/user_repository.dart';

class TDEECalculatorWidget extends StatefulWidget {
  final UserProfile? userProfile;
  final double? currentWeight;

  const TDEECalculatorWidget({
    Key? key,
    required this.userProfile,
    required this.currentWeight,
  }) : super(key: key);

  @override
  State<TDEECalculatorWidget> createState() => _TDEECalculatorWidgetState();
}

class _TDEECalculatorWidgetState extends State<TDEECalculatorWidget> {
  final UserRepository _userRepository = UserRepository();
  bool _isLoading = true;
  double? _tdee;
  List<String> _missingData = [];
  Map<String, int> _calorieGoals = {};

  @override
  void initState() {
    super.initState();
    _calculateValues();
  }

  @override
  void didUpdateWidget(TDEECalculatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile ||
        oldWidget.currentWeight != widget.currentWeight) {
      _calculateValues();
    }
  }

  void _calculateValues() {
    setState(() {
      _isLoading = true;
    });

    // Calculate BMR first (but don't store it as we show it in a different widget)
    final bmr = Formula.calculateBMR(
      weight: widget.currentWeight,
      height: widget.userProfile?.height,
      age: widget.userProfile?.age,
      gender: widget.userProfile?.gender,
    );

    // Calculate TDEE using the temporary BMR value
    _tdee = Formula.calculateTDEE(
      bmr: bmr,
      activityLevel: widget.userProfile?.activityLevel,
    );

    _missingData = Formula.getMissingData(
      profile: widget.userProfile,
      currentWeight: widget.currentWeight,
    );

    _calorieGoals = Formula.getCalorieTargets(_tdee);

    setState(() {
      _isLoading = false;
    });
  }

  void _showTDEEInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              'About TDEE',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TDEE Definition
              Text(
                'Total Daily Energy Expenditure (TDEE) is the total number of calories you burn each day based on your Basal Metabolic Rate (BMR) and physical activity level.',
                style: TextStyle(
                  fontSize: 14, 
                  height: 1.4,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              
              // Current TDEE Value
              Text(
                'Your TDEE: ${_tdee?.round() ?? 0} calories/day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Activity Level
              Text(
                'Activity Level: ${Formula.getActivityLevelText(widget.userProfile?.activityLevel)}',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  color: AppTheme.textDark,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Calorie Targets Section
              Text(
                'Calorie Targets:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Weight Loss Target
              _buildCalorieTargetRow(
                icon: Icons.trending_down,
                label: 'Weight Loss',
                calories: _calorieGoals['lose'] ?? 0,
                color: AppTheme.textDark,
                iconColor: Colors.green,
              ),
              
              const SizedBox(height: 8),
              
              // Maintenance Target
              _buildCalorieTargetRow(
                icon: Icons.horizontal_rule,
                label: 'Maintenance',
                calories: _calorieGoals['maintain'] ?? 0,
                color: AppTheme.textDark,
                iconColor: AppTheme.primaryBlue,
              ),
              
              const SizedBox(height: 8),
              
              // Weight Gain Target
              _buildCalorieTargetRow(
                icon: Icons.trending_up,
                label: 'Weight Gain',
                calories: _calorieGoals['gain'] ?? 0,
                color: AppTheme.textDark,
                iconColor: const Color(0xFFFFA726), // Orange
              ),
              
              const SizedBox(height: 20),
              
              // Activity Levels Explanation
              Text(
                'Activity Levels:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActivityLevelInfo(
                      'Sedentary (1.2)',
                      'Little or no exercise, desk job',
                      Icons.airline_seat_recline_normal,
                    ),
                    const SizedBox(height: 8),
                    _buildActivityLevelInfo(
                      'Lightly Active (1.375)',
                      'Light exercise/sports 1-3 days/week',
                      Icons.directions_walk,
                    ),
                    const SizedBox(height: 8),
                    _buildActivityLevelInfo(
                      'Moderately Active (1.55)',
                      'Moderate exercise/sports 3-5 days/week',
                      Icons.directions_run,
                    ),
                    const SizedBox(height: 8),
                    _buildActivityLevelInfo(
                      'Very Active (1.725)',
                      'Hard exercise/sports 6-7 days/week',
                      Icons.fitness_center,
                    ),
                    const SizedBox(height: 8),
                    _buildActivityLevelInfo(
                      'Extra Active (1.9)',
                      'Very hard exercise, physical job or training twice a day',
                      Icons.sports_martial_arts,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalorieTargetRow({
    required IconData icon,
    required String label,
    required int calories,
    required Color color,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
        Text(
          '$calories cal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLevelInfo(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.primaryBlue,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  // Get icon based on activity level
  IconData _getActivityIcon() {
    final activityLevel = widget.userProfile?.activityLevel ?? 1.2;
    
    if (activityLevel < 1.4) return Icons.battery_1_bar;
    if (activityLevel < 1.6) return Icons.battery_2_bar;
    if (activityLevel < 1.8) return Icons.battery_3_bar;
    if (activityLevel < 2.0) return Icons.battery_4_bar;
    return Icons.battery_full;
  }
  
  // Get activity level color
  Color _getActivityLevelColor() {
    final activityLevel = widget.userProfile?.activityLevel ?? 1.4;
    
    if (activityLevel < 1.4) return Colors.grey; // Sedentary
    if (activityLevel < 1.6) return Colors.green; // Lightly active
    if (activityLevel < 1.8) return const Color(0xFFFFA726); // Moderately active (orange)
    return AppTheme.primaryBlue; // Very active / Extra active (changed to primaryBlue)
  }
  
  // Show activity level selection dialog
  void _showActivityLevelDialog() async {
    // Default to current activity level or 1.4 if none set
    double selectedLevel = widget.userProfile?.activityLevel ?? 1.4;
    
    // Activity level display data
    final activityLevels = [
      {
        'level': 1.2, 
        'text': 'Sedentary', 
        'icon': Icons.airline_seat_recline_normal, 
        'desc': 'Little or no exercise'
      },
      {
        'level': 1.375, 
        'text': 'Lightly Active', 
        'icon': Icons.directions_walk, 
        'desc': 'Light exercise 1-3 days/week'
      },
      {
        'level': 1.55, 
        'text': 'Moderately Active', 
        'icon': Icons.directions_run, 
        'desc': 'Moderate exercise 3-5 days/week'
      },
      {
        'level': 1.725, 
        'text': 'Very Active', 
        'icon': Icons.fitness_center, 
        'desc': 'Hard exercise 6-7 days/week'
      },
      {
        'level': 1.9, 
        'text': 'Extra Active', 
        'icon': Icons.sports_martial_arts, 
        'desc': 'Very hard physical job or training'
      },
    ];
    
    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.fitness_center,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              'Select Activity Level',
              style: TextStyle(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: activityLevels.map((level) {
              final isSelected = (level['level'] as double) == selectedLevel;
              
              return ListTile(
                leading: Icon(
                  level['icon'] as IconData,
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey[600],
                ),
                title: Text(
                  level['text'] as String,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                  ),
                ),
                subtitle: Text(
                  level['desc'] as String,
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
                selected: isSelected,
                onTap: () {
                  Navigator.of(context).pop(level['level'] as double);
                },
                trailing: isSelected 
                  ? Icon(Icons.check_circle, color: AppTheme.primaryBlue) 
                  : null,
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
            ),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
    
    // If a level was selected and it's different from current
    if (result != null && result != selectedLevel && widget.userProfile != null) {
      // Save the new activity level to user profile
      final updatedProfile = widget.userProfile!.copyWith(
        activityLevel: result,
      );
      
      await _userRepository.saveUserProfile(updatedProfile);
      
      // Recalculate the values with the new activity level
      _calculateValues();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return MasterWidget(
        title: 'TDEE',
        icon: Icons.local_fire_department, // Required for backward compatibility but not displayed
        isLoading: true,
        child: const SizedBox(),
      );
    }

    // Missing data state
    if (_missingData.isNotEmpty) {
      return MasterWidget(
        title: 'TDEE',
        icon: Icons.local_fire_department, // Required for backward compatibility but not displayed
        trailing: MasterWidget.createInfoButton(
          onPressed: _showTDEEInfoDialog,
          color: AppTheme.textDark,
        ),
        hasError: true,
        errorMessage: 'To calculate your TDEE, please update your profile with: ${_missingData.join(", ")}',
        onRetry: () => Navigator.of(context).pushNamed('/settings'),
        child: const SizedBox(),
      );
    }

    // Get activity level text and color
    final activityText = Formula.getActivityLevelText(widget.userProfile?.activityLevel);
    final activityColor = _getActivityLevelColor();
    final activityIcon = _getActivityIcon();
    
    // Create activity level badge - tappable
    final Widget activityBadge = InkWell(
      onTap: _showActivityLevelDialog,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Color.fromRGBO(
            activityColor.red,
            activityColor.green,
            activityColor.blue,
            0.1,
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color.fromRGBO(
              activityColor.red,
              activityColor.green,
              activityColor.blue,
              0.2,
            ),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              activityIcon,
              size: 14,
              color: activityColor,
            ),
            const SizedBox(width: 6),
            Text(
              activityText,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: activityColor,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.edit,
              size: 12,
              color: activityColor.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
    
    // Normal state with data
    return MasterWidget(
      title: 'TDEE',
      icon: Icons.local_fire_department, // Required for backward compatibility but not displayed
      trailing: MasterWidget.createInfoButton(
        onPressed: _showTDEEInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // TDEE value with cal unit
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  // TDEE numerical value - reduced size
                  Text(
                    _tdee?.round().toString() ?? '0',
                    style: const TextStyle(
                      fontSize: 30, // Reduced from 36
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  
                  // Unit
                  const Text(
                    ' cal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              
              // Activity level badge - tappable
              const SizedBox(height: 8),
              activityBadge,
            ],
          ),
        ),
      ),
    );
  }
}