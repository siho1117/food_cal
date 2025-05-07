// lib/widgets/progress/tdee_calculator_widget.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../data/models/user_profile.dart';
import '../activity_level_info_dialog.dart';
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
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;

  bool _isLoading = true;
  double? _bmr;
  double? _tdee;
  List<String> _missingData = [];
  Map<String, int> _calorieGoals = {
    'lose': 0,
    'maintain': 0,
    'gain': 0,
  };

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Calculate initial values
    _calculateValues();

    // Start animation
    _animationController.forward();
  }

  @override
  void didUpdateWidget(TDEECalculatorWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile ||
        oldWidget.currentWeight != widget.currentWeight) {
      _calculateValues();
      // Reset and restart animation for updated values
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate TDEE and related values
  void _calculateValues() {
    setState(() {
      _isLoading = true;
    });

    // Use centralized Formula class for calculations
    _bmr = Formula.calculateBMR(
      weight: widget.currentWeight,
      height: widget.userProfile?.height,
      age: widget.userProfile?.age,
      gender: widget.userProfile?.gender,
    );

    _tdee = Formula.calculateTDEE(
      bmr: _bmr,
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
      return _buildLoadingState();
    }

    // If we have missing data, show error state
    if (_missingData.isNotEmpty) {
      return _buildErrorState();
    }

    // Otherwise, show the full content
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildContentWidget(),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Container(
      height: 330,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.accentColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Daily Calorie Needs (TDEE)',
                    style: AppTextStyles.getSubHeadingStyle().copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: AppTheme.primaryBlue.withOpacity(0.7),
                  size: 20,
                ),
                onPressed: _calculateValues,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Missing data message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Missing profile data',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'To calculate your TDEE, please update your profile with: ${_missingData.join(", ")}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Go to Settings tab to complete your profile.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Brief explanation of TDEE
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'TDEE (Total Daily Energy Expenditure) is the total number of calories you burn each day based on your BMR and physical activity level.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Colors.grey[50]!,
          ],
          stops: const [0.7, 1.0],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with styled background
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.02),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: AppTheme.accentColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Daily Calorie Needs (TDEE)',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => showActivityLevelInfoDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Main TDEE display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildTDEEDisplay(),
          ),

          const SizedBox(height: 20),

          // BMR and Activity Level info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBMRAndActivityLevel(),
          ),

          const SizedBox(height: 24),

          // Calorie goals section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title
                const Text(
                  'CALORIE TARGETS',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),

                const SizedBox(height: 10),

                // Calorie goal items
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return _buildCalorieGoalsRow();
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // What is TDEE explanation
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TDEE (Total Daily Energy Expenditure) is the total number of calories you burn each day based on your BMR and physical activity level.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTDEEDisplay() {
    return Center(
      child: Column(
        children: [
          // Animated TDEE value
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final displayedValue = (_tdee! * _progressAnimation.value).round();
              return Text(
                '$displayedValue',
                style: AppTextStyles.getNumericStyle().copyWith(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              );
            },
          ),
          const Text(
            'calories/day',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),

          // Visual representation of the relationship between BMR and TDEE
          if (_bmr != null && _tdee != null) ...[
            const SizedBox(height: 16),
            _buildEnergyProgressBar(),
          ],
        ],
      ),
    );
  }

  Widget _buildEnergyProgressBar() {
    final multiplier = widget.userProfile?.activityLevel ?? 1.2;
    // Calculate the BMR percentage of TDEE (inverse of activity multiplier)
    final bmrPercentage = _bmr! / _tdee!;

    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Labels above the progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Resting (BMR)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 6),
            
            // Progress bar container
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Row(
                children: [
                  // BMR portion
                  Container(
                    width: MediaQuery.of(context).size.width * 
                      bmrPercentage * 
                      _progressAnimation.value * 
                      0.77, // Adjusted for padding
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryBlue,
                          AppTheme.primaryBlue.withOpacity(0.8),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                  ),
                  // Activity portion
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.accentColor.withOpacity(0.8),
                            AppTheme.accentColor,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 6),
            
            // Values below the progress bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(_bmr! * _progressAnimation.value).round()} cal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
                Text(
                  '+${((_tdee! - _bmr!) * _progressAnimation.value).round()} cal',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 4),
            
            // Multiplier factor
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Activity Multiplier: × ${multiplier.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBMRAndActivityLevel() {
    return Row(
      children: [
        // BMR info
        Expanded(
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              final displayedValue = (_bmr! * _progressAnimation.value).round();
              
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMR',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$displayedValue cal',
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                    const Text(
                      'Resting metabolism',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 16),

        // Activity Level
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Activity Level',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  Formula.getActivityLevelText(widget.userProfile?.activityLevel),
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentColor,
                  ),
                ),
                Text(
                  widget.userProfile?.activityLevel != null
                      ? 'Multiplier: ${widget.userProfile!.activityLevel!.toStringAsFixed(2)}'
                      : 'Not set',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalorieGoalsRow() {
    return Row(
      children: [
        _buildCalorieGoalItem(
          'Weight Loss',
          '${(_calorieGoals['lose']! * _progressAnimation.value).round()}',
          Colors.green,
          'minus',
        ),
        _buildCalorieGoalItem(
          'Maintain',
          '${(_calorieGoals['maintain']! * _progressAnimation.value).round()}',
          AppTheme.primaryBlue,
          'neutral',
        ),
        _buildCalorieGoalItem(
          'Weight Gain',
          '${(_calorieGoals['gain']! * _progressAnimation.value).round()}',
          AppTheme.goldAccent,
          'plus',
        ),
      ],
    );
  }

  Widget _buildCalorieGoalItem(
    String label,
    String calories,
    Color color,
    String direction,
  ) {
    IconData directionIcon;
    switch (direction) {
      case 'minus':
        directionIcon = Icons.remove;
        break;
      case 'plus':
        directionIcon = Icons.add;
        break;
      default:
        directionIcon = Icons.horizontal_rule;
        break;
    }

    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Direction icon
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                directionIcon,
                size: 12,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            
            // Label
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            
            // Calorie value
            Text(
              calories,
              style: AppTextStyles.getNumericStyle().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'cal/day',
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}