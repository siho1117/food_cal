import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/widgets/master_widget.dart';
import '../../config/components/state_builder.dart';
import '../../config/components/value_builder.dart';
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

class _TDEECalculatorWidgetState extends State<TDEECalculatorWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  bool _isLoading = true;
  double? _tdee;
  List<String> _missingData = [];
  Map<String, int> _calorieGoals = {};

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _progressAnimation = AnimationHelpers.createProgressAnimation(
      controller: _animationController,
    );
    _calculateValues();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(TDEECalculatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile ||
        oldWidget.currentWeight != widget.currentWeight) {
      _calculateValues();
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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

  void _showActivityLevelInfoDialog() {
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
            const Text('Activity Levels Explained'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildActivityLevelInfo(
                'Sedentary (1.2)',
                'Little or no exercise, desk job',
                Icons.airline_seat_recline_normal,
              ),
              const SizedBox(height: 12),
              _buildActivityLevelInfo(
                'Lightly Active (1.375)',
                'Light exercise/sports 1-3 days/week',
                Icons.directions_walk,
              ),
              const SizedBox(height: 12),
              _buildActivityLevelInfo(
                'Moderately Active (1.55)',
                'Moderate exercise/sports 3-5 days/week',
                Icons.directions_run,
              ),
              const SizedBox(height: 12),
              _buildActivityLevelInfo(
                'Very Active (1.725)',
                'Hard exercise/sports 6-7 days/week',
                Icons.fitness_center,
              ),
              const SizedBox(height: 12),
              _buildActivityLevelInfo(
                'Extra Active (1.9)',
                'Very hard exercise, physical job or training twice a day',
                Icons.sports_martial_arts,
              ),
              const SizedBox(height: 16),
              const Text(
                'Your activity level is used to calculate your TDEE (Total Daily Energy Expenditure), which represents the total calories you burn each day.',
                style: TextStyle(fontStyle: FontStyle.italic),
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
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
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
        accentColor: AppTheme.accentColor,
        subtitle: 'Tap header for activity level details',
        child: StateBuilder.warning(
          title: 'Missing Profile Data',
          message: 'To calculate your TDEE, please update your profile with: ${_missingData.join(", ")}',
          actionLabel: 'Update Profile',
          onAction: () => Navigator.of(context).pushNamed('/settings'),
        ),
      );
    }

    // Normal state with data
    final activityText = Formula.getActivityLevelText(widget.userProfile?.activityLevel);
    
    return MasterWidget.dataWidget(
      title: 'Daily Calorie Needs (TDEE)',
      icon: Icons.local_fire_department,
      accentColor: AppTheme.accentColor,
      subtitle: 'Based on your activity level',
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TDEE Value display
            Center(
              child: Column(
                children: [
                  // Animated TDEE value
                  AnimationHelpers.buildAnimatedCounter(
                    animation: _progressAnimation,
                    targetValue: _tdee ?? 0,
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                    decimalPlaces: 0,
                  ),
                  
                  // "calories/day" label
                  Text(
                    'calories/day',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Activity level badge
            Center(
              child: GestureDetector(
                onTap: _showActivityLevelInfoDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getActivityIcon(),
                        size: 14,
                        color: AppTheme.accentColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        activityText,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppTheme.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Calorie Targets Section
            Text(
              'CALORIE TARGETS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
                letterSpacing: 1.5,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Weight Loss
            _buildCalorieItem(
              label: 'Weight Loss', 
              value: (_calorieGoals['lose'] ?? 0),
              icon: Icons.trending_down,
              color: Colors.green,
              description: '500 calorie deficit',
              recommended: true,
            ),
            
            const SizedBox(height: 10),
            
            // Maintenance
            _buildCalorieItem(
              label: 'Maintenance', 
              value: (_calorieGoals['maintain'] ?? 0),
              icon: Icons.horizontal_rule,
              color: AppTheme.primaryBlue,
              description: 'Maintain current weight',
            ),
            
            const SizedBox(height: 10),
            
            // Weight Gain
            _buildCalorieItem(
              label: 'Weight Gain', 
              value: (_calorieGoals['gain'] ?? 0),
              icon: Icons.trending_up,
              color: AppTheme.goldAccent,
              description: '500 calorie surplus',
            ),
            
            const SizedBox(height: 16),
            
            // Description
            StateBuilder.infoMessage(
              message: 'TDEE is the total calories you burn daily based on your BMR and physical activity level.',
              icon: Icons.info_outline,
              color: AppTheme.accentColor,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCalorieItem({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
    required String description,
    bool recommended = false,
  }) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final animatedValue = (value * _progressAnimation.value).round();
        return Row(
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            
            const SizedBox(width: 12),
            
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label with optional recommended badge
                  Row(
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (recommended) ...[
                        const SizedBox(width: 8),
                        ValueBuilder.buildBadge(
                          text: 'Recommended',
                          color: Colors.green,
                        ),
                      ],
                    ],
                  ),
                  
                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            // Value
            Text(
              '$animatedValue',
              style: AppTextStyles.getNumericStyle().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            
            // Unit
            Text(
              ' cal',
              style: TextStyle(
                fontSize: 14,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        );
      },
    );
  }
  
  IconData _getActivityIcon() {
    final activityLevel = widget.userProfile?.activityLevel ?? 1.2;
    
    if (activityLevel < 1.4) return Icons.battery_1_bar;
    if (activityLevel < 1.6) return Icons.battery_2_bar;
    if (activityLevel < 1.8) return Icons.battery_3_bar;
    if (activityLevel < 2.0) return Icons.battery_4_bar;
    return Icons.battery_full;
  }
}