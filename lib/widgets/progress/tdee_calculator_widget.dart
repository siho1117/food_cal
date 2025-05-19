import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/user_profile.dart';
import '../../utils/formula.dart';
import '../../data/repositories/user_repository.dart';
import '../activity_level_info_dialog.dart';

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

    // Short delay to prevent UI flicker
    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      
      setState(() {
        // Reset values
        _missingData = [];
        _tdee = null;
        _calorieGoals = {};
        
        // Check for missing data
        _missingData = Formula.getMissingData(
          profile: widget.userProfile,
          currentWeight: widget.currentWeight,
        );
        
        // If no missing data, calculate values
        if (_missingData.isEmpty) {
          // Calculate BMR first
          final bmr = Formula.calculateBMR(
            weight: widget.currentWeight,
            height: widget.userProfile?.height,
            age: widget.userProfile?.age,
            gender: widget.userProfile?.gender,
          );

          // Calculate TDEE using the BMR value
          _tdee = Formula.calculateTDEE(
            bmr: bmr,
            activityLevel: widget.userProfile?.activityLevel,
          );

          // Calculate calorie targets
          _calorieGoals = Formula.getCalorieTargets(_tdee);
        }
        
        _isLoading = false;
      });
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
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 14, 
                  height: 1.4,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: Dimensions.m),
              
              // Current TDEE Value
              if (_tdee != null)
                Container(
                  padding: EdgeInsets.all(Dimensions.s),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlueBackground,
                    borderRadius: BorderRadius.circular(Dimensions.xs),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(width: Dimensions.xs),
                      Text(
                        'Your TDEE: ${_tdee?.round() ?? 0} calories/day',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Dimensions.m),
              
              // Activity Level
              if (widget.userProfile?.activityLevel != null)
                Text(
                  'Activity Level: ${Formula.getActivityLevelText(widget.userProfile?.activityLevel)}',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: AppTheme.textDark,
                  ),
                ),
              SizedBox(height: Dimensions.m),
              
              // Calorie Targets Section
              Text(
                'Calorie Targets:',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: Dimensions.s),
              
              // Weight Loss Target
              _buildCalorieTargetRow(
                icon: Icons.trending_down,
                label: 'Weight Loss',
                calories: _calorieGoals['lose'] ?? 0,
                color: Colors.green,
              ),
              SizedBox(height: Dimensions.xs),
              
              // Maintenance Target
              _buildCalorieTargetRow(
                icon: Icons.horizontal_rule,
                label: 'Maintenance',
                calories: _calorieGoals['maintain'] ?? 0,
                color: AppTheme.primaryBlue,
              ),
              SizedBox(height: Dimensions.xs),
              
              // Weight Gain Target
              _buildCalorieTargetRow(
                icon: Icons.trending_up,
                label: 'Weight Gain',
                calories: _calorieGoals['gain'] ?? 0,
                color: AppTheme.goldAccent,
              ),
              
              SizedBox(height: Dimensions.m),
              
              // Activity Levels Explanation
              Text(
                'Activity Levels:',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: Dimensions.xs),
              Container(
                padding: EdgeInsets.all(Dimensions.s),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(Dimensions.xs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildActivityLevelInfo(
                      'Sedentary (1.2)',
                      'Little or no exercise, desk job',
                      Icons.airline_seat_recline_normal,
                    ),
                    SizedBox(height: Dimensions.xs),
                    _buildActivityLevelInfo(
                      'Lightly Active (1.375)',
                      'Light exercise/sports 1-3 days/week',
                      Icons.directions_walk,
                    ),
                    SizedBox(height: Dimensions.xs),
                    _buildActivityLevelInfo(
                      'Moderately Active (1.55)',
                      'Moderate exercise/sports 3-5 days/week',
                      Icons.directions_run,
                    ),
                    SizedBox(height: Dimensions.xs),
                    _buildActivityLevelInfo(
                      'Very Active (1.725)',
                      'Hard exercise/sports 6-7 days/week',
                      Icons.fitness_center,
                    ),
                    SizedBox(height: Dimensions.xs),
                    _buildActivityLevelInfo(
                      'Extra Active (1.9)',
                      'Very hard exercise, physical job or training twice a day',
                      Icons.sports_martial_arts,
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.m),
              
              // Formula
              Text(
                'TDEE Formula:',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppTheme.textDark,
                ),
              ),
              SizedBox(height: Dimensions.xs),
              Container(
                padding: EdgeInsets.all(Dimensions.s),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(Dimensions.xs),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Text(
                  'TDEE = BMR × Activity Multiplier',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textDark,
                  ),
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
            child: Text(
              'CLOSE',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        SizedBox(width: Dimensions.xs),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textDark,
            ),
          ),
        ),
        Text(
          '$calories cal',
          style: AppTextStyles.getNumericStyle().copyWith(
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
        SizedBox(width: Dimensions.xs),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppTheme.textDark,
                ),
              ),
              Text(
                description,
                style: AppTextStyles.getBodyStyle().copyWith(
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
    return Icons.battery_4_bar;
  }
  
  // Get activity level color
  Color _getActivityLevelColor() {
    final activityLevel = widget.userProfile?.activityLevel ?? 1.4;
    
    if (activityLevel < 1.4) return Colors.grey; // Sedentary
    if (activityLevel < 1.6) return Colors.green; // Lightly active
    if (activityLevel < 1.8) return AppTheme.goldAccent; // Moderately active
    return AppTheme.primaryBlue; // Very active / Extra active
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
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                color: AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 18,
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
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppTheme.primaryBlue : AppTheme.textDark,
                  ),
                ),
                subtitle: Text(
                  level['desc'] as String,
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 12,
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
            child: Text(
              'CANCEL',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with info button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TDEE',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info_outline, size: 18),
                onPressed: _showTDEEInfoDialog,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Content based on state
          if (_isLoading) 
            // Loading state
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_missingData.isNotEmpty) 
            // Missing data state
            Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 36,
                  color: Colors.orange,
                ),
                const SizedBox(height: 8),
                Text(
                  'Missing Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'To calculate your TDEE, please update your profile with: ${_missingData.join(", ")}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(context).pushNamed('/settings'),
                  child: Text('Update Profile'),
                ),
              ],
            )
          else 
            // Normal state with TDEE value and activity level
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TDEE Value
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_tdee?.round() ?? 0}',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      SizedBox(width: Dimensions.xxs),
                      Text(
                        'cal',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: Dimensions.s),
                  
                  // Activity level badge - tappable
                  if (widget.userProfile?.activityLevel != null)
                    InkWell(
                      onTap: _showActivityLevelDialog,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _getActivityLevelColor().withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getActivityLevelColor().withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getActivityIcon(),
                              size: 14,
                              color: _getActivityLevelColor(),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              Formula.getActivityLevelText(widget.userProfile?.activityLevel),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: _getActivityLevelColor(),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.edit,
                              size: 12,
                              color: _getActivityLevelColor().withOpacity(0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  SizedBox(height: Dimensions.m),
                  
                  // Divider
                  Divider(color: Colors.grey[300]),
                  
                  SizedBox(height: Dimensions.s),
                  
                  // Calorie targets (only show two for compact layout)
                  Text(
                    'Calorie Targets:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  
                  SizedBox(height: Dimensions.xs),
                  
                  // Loss target
                  _buildCalorieTargetRow(
                    icon: Icons.trending_down,
                    label: 'Weight Loss',
                    calories: _calorieGoals['lose'] ?? 0,
                    color: Colors.green,
                  ),
                  
                  SizedBox(height: Dimensions.xxs),
                  
                  // Maintenance target
                  _buildCalorieTargetRow(
                    icon: Icons.horizontal_rule,
                    label: 'Maintenance',
                    calories: _calorieGoals['maintain'] ?? 0,
                    color: AppTheme.primaryBlue,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}