import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';
import '../../data/models/user_profile.dart';
import '../../utils/formula.dart';

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
              color: AppTheme.accentColor,
            ),
            const SizedBox(width: 8),
            const Text('About TDEE'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TDEE Definition
              const Text(
                'Total Daily Energy Expenditure (TDEE) is the total number of calories you burn each day based on your Basal Metabolic Rate (BMR) and physical activity level.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // Current TDEE Value
              Text(
                'Your TDEE: ${_tdee?.round() ?? "Unknown"} calories/day',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              
              // Activity Levels Explanation
              const Text(
                'Activity Levels:',
                style: TextStyle(fontWeight: FontWeight.w500),
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
              const SizedBox(height: 16),
              
              // TDEE Calculation
              const Text(
                'How TDEE is calculated:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TDEE = BMR × Activity Multiplier\n\n'
                  'For example, if your BMR is 1,600 calories and you are moderately active (1.55 multiplier), your TDEE would be:\n'
                  '1,600 × 1.55 = 2,480 calories per day',
                  style: TextStyle(height: 1.4),
                ),
              ),
              const SizedBox(height: 16),
              
              // Calorie Targets Explanation
              const Text(
                'Calorie Targets:',
                style: TextStyle(fontWeight: FontWeight.w500),
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
                  children: const [
                    Text('• Weight Loss: TDEE - 500 calories/day (approximately 0.5kg or 1lb per week)'),
                    SizedBox(height: 8),
                    Text('• Maintenance: Equal to your TDEE'),
                    SizedBox(height: 8),
                    Text('• Weight Gain: TDEE + 500 calories/day (approximately 0.5kg or 1lb per week)'),
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
              foregroundColor: AppTheme.accentColor,
            ),
            child: const Text('CLOSE'),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelInfo(String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppTheme.accentColor,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
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
  
  // Get activity level text
  String _getActivityLevelText() {
    return Formula.getActivityLevelText(widget.userProfile?.activityLevel);
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (_isLoading) {
      return MasterWidget(
        title: 'Daily Calorie Needs (TDEE)',
        icon: Icons.local_fire_department,
        accentColor: AppTheme.accentColor,
        isLoading: true,
        child: const SizedBox(),
      );
    }

    // Missing data state
    if (_missingData.isNotEmpty) {
      return MasterWidget(
        title: 'Daily Calorie Needs (TDEE)',
        icon: Icons.local_fire_department,
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

    // Normal state with data
    final activityText = _getActivityLevelText();
    final activityIcon = _getActivityIcon();
    
    // Create activity level badge
    final Widget activityBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          AppTheme.accentColor.red,
          AppTheme.accentColor.green,
          AppTheme.accentColor.blue,
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activityIcon,
            size: 14,
            color: AppTheme.accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            activityText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.accentColor,
            ),
          ),
        ],
      ),
    );
    
    return MasterWidget(
      title: 'Daily Calorie Needs (TDEE)',
      icon: Icons.local_fire_department,
      accentColor: AppTheme.accentColor,
      trailing: MasterWidget.createInfoButton(
        onPressed: _showTDEEInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TDEE Value display
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TDEE numerical value
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _tdee?.round().toString() ?? '0',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      Text(
                        ' cal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(
                            AppTheme.accentColor.red,
                            AppTheme.accentColor.green,
                            AppTheme.accentColor.blue,
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Activity level badge
                  const SizedBox(height: 10),
                  activityBadge,
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Calorie Targets
            Text(
              'CALORIE TARGETS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                letterSpacing: 0.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Calorie target cards row
            Row(
              children: [
                // Weight Loss
                Expanded(
                  child: _buildCalorieCard(
                    label: 'Weight Loss',
                    value: _calorieGoals['lose'] ?? 0,
                    color: Colors.green,
                    icon: Icons.trending_down,
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Maintenance
                Expanded(
                  child: _buildCalorieCard(
                    label: 'Maintain',
                    value: _calorieGoals['maintain'] ?? 0,
                    color: AppTheme.primaryBlue,
                    icon: Icons.horizontal_rule,
                  ),
                ),
                
                const SizedBox(width: 10),
                
                // Weight Gain
                Expanded(
                  child: _buildCalorieCard(
                    label: 'Weight Gain',
                    value: _calorieGoals['gain'] ?? 0,
                    color: const Color(0xFFFFA726), // Orange
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalorieCard({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Color.fromRGBO(
          color.red,
          color.green,
          color.blue,
          0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Color.fromRGBO(
            color.red,
            color.green,
            color.blue,
            0.2,
          ),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          
          const SizedBox(height: 6),
          
          // Label
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          
          const SizedBox(height: 6),
          
          // Value
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}