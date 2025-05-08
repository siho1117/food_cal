// lib/widgets/progress/tdee_calculator_widget.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../data/models/user_profile.dart';
import '../activity_level_info_dialog.dart';
import '../../utils/formula.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/layouts/card_layout.dart';
import '../../config/layouts/header_layout.dart';
import '../../config/layouts/content_layout.dart';
import '../../config/builders/value_builder.dart';
import '../../config/decorations/box_decorations.dart';

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

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return CardLayout.card(
        header: _buildHeader(),
        isLoading: true,
        child: const SizedBox(height: 200),
      );
    }

    if (_missingData.isNotEmpty) {
      return CardLayout.messageCard(
        title: 'Missing Profile Data',
        message: 'To calculate your TDEE, please update your profile with: ${_missingData.join(", ")}',
        icon: Icons.info_outline,
        color: Colors.orange,
        actionText: 'Update Profile',
        onAction: () => Navigator.of(context).pushNamed('/settings'),
      );
    }

    return CardLayout.card(
      header: _buildHeader(),
      child: Column(
        children: [
          // TDEE Value Display
          _buildTdeeDisplay(),
          
          const SizedBox(height: 20),
          
          // TDEE Goal Cards
          _buildCalorieGoals(),
          
          const SizedBox(height: 16),
          
          // Description
          ContentLayout.infoBox(
            message: 'TDEE is the total calories you burn daily based on your BMR and physical activity level.',
            icon: Icons.info_outline,
            color: AppTheme.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return HeaderLayout.withInfo(
      title: 'Daily Calorie Needs (TDEE)',
      icon: Icons.local_fire_department,
      iconColor: AppTheme.accentColor,
      onInfoTap: () => showActivityLevelInfoDialog(context),
    );
  }

  Widget _buildTdeeDisplay() {
    final activityText = Formula.getActivityLevelText(widget.userProfile?.activityLevel);
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          children: [
            // TDEE Value
            ValueBuilder.buildCalorieDisplay(
              calories: (_tdee! * _progressAnimation.value).round(),
              color: AppTheme.accentColor,
              showUnit: true,
            ),
            
            const SizedBox(height: 12),
            
            // Activity level badge
            Container(
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
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCalorieGoals() {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            HeaderLayout.sectionHeader(
              title: 'Calorie Targets',
              fontSize: 14,
              color: Colors.grey[600],
            ),
            
            const SizedBox(height: 12),
            
            // Weight Loss
            _buildCalorieItem(
              label: 'Weight Loss', 
              value: (_calorieGoals['lose']! * _progressAnimation.value).round(),
              icon: Icons.trending_down,
              color: Colors.green,
              description: '500 calorie deficit',
              recommended: true,
            ),
            
            const SizedBox(height: 10),
            
            // Maintenance
            _buildCalorieItem(
              label: 'Maintenance', 
              value: (_calorieGoals['maintain']! * _progressAnimation.value).round(),
              icon: Icons.horizontal_rule,
              color: AppTheme.primaryBlue,
              description: 'Maintain current weight',
            ),
            
            const SizedBox(height: 10),
            
            // Weight Gain
            _buildCalorieItem(
              label: 'Weight Gain', 
              value: (_calorieGoals['gain']! * _progressAnimation.value).round(),
              icon: Icons.trending_up,
              color: AppTheme.goldAccent,
              description: '500 calorie surplus',
            ),
          ],
        );
      },
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
          '$value',
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