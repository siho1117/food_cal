// lib/widgets/progress/energy_metrics_widget.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/user_profile.dart';

class EnergyMetricsWidget extends StatefulWidget {
  final UserProfile? userProfile;
  final double? currentWeight;
  final VoidCallback? onSettingsTap;

  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const EnergyMetricsWidget({
    super.key,
    required this.userProfile,
    required this.currentWeight,
    this.onSettingsTap,
  });

  @override
  State<EnergyMetricsWidget> createState() => _EnergyMetricsWidgetState();
}

class _EnergyMetricsWidgetState extends State<EnergyMetricsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _showGoals = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate BMR & TDEE
    final calculationResults = _calculateEnergy();
    final missingData = calculationResults['missingData'] as List<String>?;
    final bmr = calculationResults['bmr'] as double?;
    final tdee = calculationResults['tdee'] as double?;
    final activityLevel = calculationResults['activityLevel'] as double?;
    final calorieGoals = calculationResults['calorieGoals'] as Map<String, int>?;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: Dimensions.xs),
          child: Column(
            children: [
              // Main split card
              _buildSplitCard(context, bmr, tdee, activityLevel, missingData),
              
              // Expandable goals section
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _showGoals ? null : 0,
                child: _showGoals
                    ? _buildGoalsSection(context, calorieGoals)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitCard(
    BuildContext context,
    double? bmr,
    double? tdee,
    double? activityLevel,
    List<String>? missingData,
  ) {
    if (missingData != null && missingData.isNotEmpty) {
      return _buildMissingDataCard(context, missingData);
    }

    final activityDiff = (tdee ?? 0) - (bmr ?? 0);

    return Card(
      elevation: 8,
      // ✅ FIXED: Use withValues instead of withOpacity (line 117)
      shadowColor: Colors.black.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Split metrics section - More compact
            IntrinsicHeight(
              child: Row(
                children: [
                  // BMR Section (Left)
                  Expanded(
                    child: _buildMetricSection(
                      title: 'BMR',
                      value: bmr?.round() ?? 0,
                      description: 'Base metabolism\ncalories per day',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFE27069), // coralAccent
                          Color(0xFFD4605A), // darker coral
                        ],
                      ),
                    ),
                  ),
                  
                  // TDEE Section (Right)
                  Expanded(
                    child: _buildMetricSection(
                      title: 'TDEE',
                      value: tdee?.round() ?? 0,
                      description: 'Total daily energy\nexpenditure',
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFCF9340), // goldAccent
                          Color(0xFFB8822E), // darker gold
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Footer section - More compact
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                // ✅ FIXED: Use withValues instead of withOpacity (line 171)
                color: AppTheme.secondaryBeige.withValues(alpha: 0.3),
                border: Border(
                  top: BorderSide(
                    // ✅ FIXED: Use withValues instead of withOpacity (line 174)
                    color: Colors.grey.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.flash_on_rounded,
                        size: 14,
                        color: AppTheme.goldAccent,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Activity adds +${activityDiff.round()} calories',
                        style: AppTextStyles.getBodyStyle().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Tap to expand button
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showGoals = !_showGoals;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        // ✅ FIXED: Use withValues instead of withOpacity (line 216)
                        color: AppTheme.primaryBlue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          // ✅ FIXED: Use withValues instead of withOpacity (line 219)
                          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _showGoals ? 'Hide Goals' : 'View Calorie Goals',
                            style: AppTextStyles.getBodyStyle().copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 4),
                          AnimatedRotation(
                            turns: _showGoals ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 14,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricSection({
    required String title,
    required int value,
    required String description,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16), // Reduced padding
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Text(
            title,
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              // ✅ FIXED: Use withValues instead of withOpacity (line 275)
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1,
            ),
          ),
          
          const SizedBox(height: 8), // Reduced spacing
          
          // Value
          Text(
            value.toString(),
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 36, // Slightly smaller
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          
          const SizedBox(height: 6), // Reduced spacing
          
          // Description
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 12,
              // ✅ FIXED: Use withValues instead of withOpacity (line 301)
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, Map<String, int>? calorieGoals) {
    if (calorieGoals == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Card(
        elevation: 4,
        // ✅ FIXED: Use withValues instead of withOpacity (line 317)
        shadowColor: Colors.black.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Goals header
              Row(
                children: [
                  const Icon(
                    Icons.track_changes_rounded,
                    size: 16,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Calorie Goals',
                    style: AppTextStyles.getSubHeadingStyle().copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.info_outline_rounded,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => _showInfoDialog(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Goals grid - Fixed overflow
              LayoutBuilder(
                builder: (context, constraints) {
                  final availableWidth = constraints.maxWidth;
                  final cardWidth = (availableWidth - 8) / 2; // Account for gap
                  
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildGoalCard(
                        'Weight Loss',
                        calorieGoals['lose'] ?? 0,
                        Colors.red[400]!,
                        Icons.trending_down_rounded,
                        cardWidth,
                      ),
                      _buildGoalCard(
                        'Maintain',
                        calorieGoals['maintain'] ?? 0,
                        AppTheme.primaryBlue,
                        Icons.trending_flat_rounded,
                        cardWidth,
                      ),
                      _buildGoalCard(
                        'Mild Loss',
                        calorieGoals['lose_mild'] ?? 0,
                        Colors.lightGreen[600]!,
                        Icons.trending_down_rounded,
                        cardWidth,
                      ),
                      _buildGoalCard(
                        'Weight Gain',
                        calorieGoals['gain'] ?? 0,
                        AppTheme.goldAccent,
                        Icons.trending_up_rounded,
                        cardWidth,
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalCard(String title, int calories, Color color, IconData icon, double width) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        // ✅ FIXED: Use withValues instead of withOpacity (line 413)
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          // ✅ FIXED: Use withValues instead of withOpacity (line 416)
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 12, color: color),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  title,
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '$calories cal',
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissingDataCard(BuildContext context, List<String> missingData) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(20), // Reduced padding
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.orange[300]!,
              Colors.orange[400]!,
            ],
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 36, // Smaller icon
              color: Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              'Missing Information',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Please update: ${missingData.join(", ")}',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 13,
                // ✅ FIXED: Use withValues instead of withOpacity (line 497)
                color: Colors.white.withValues(alpha: 0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: widget.onSettingsTap ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.orange[400],
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              child: Text(
                'Update Settings',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateEnergy() {
    final userProfile = widget.userProfile;
    final currentWeight = widget.currentWeight;

    // Check for missing data
    final List<String> missingData = [];
    if (userProfile == null) {
      missingData.add('profile');
      return {'missingData': missingData};
    }

    if (currentWeight == null) missingData.add('current weight');
    if (userProfile.height == null) missingData.add('height');
    if (userProfile.age == null) missingData.add('age');
    if (userProfile.gender == null) missingData.add('gender');

    if (missingData.isNotEmpty) {
      return {'missingData': missingData};
    }

    // Calculate BMR using Mifflin-St Jeor equation
    final age = userProfile.age!;
    final height = userProfile.height!; // in cm
    final weight = currentWeight!; // in kg
    final gender = userProfile.gender!;

    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Calculate activity level
    final activityLevel = userProfile.activityLevel ?? 1.2;
    
    // Calculate TDEE (Total Daily Energy Expenditure)
    final tdee = bmr * activityLevel;
    
    // Calculate calorie targets
    final maintenance = tdee.round();
    final lose = (maintenance - 500).round(); // 500 calorie deficit
    final loseMild = (maintenance - 250).round(); // 250 calorie deficit
    final gain = (maintenance + 500).round(); // 500 calorie surplus
    
    return {
      'bmr': bmr,
      'tdee': tdee,
      'activityLevel': activityLevel,
      'calorieGoals': {
        'maintain': maintenance,
        'lose': lose,
        'lose_mild': loseMild,
        'gain': gain,
      },
    };
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.info_outline_rounded,
              color: AppTheme.primaryBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'About Energy Metrics',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInfoSection(
                'BMR (Basal Metabolic Rate)',
                'The calories your body needs for essential functions like breathing, circulation, and cell repair while at complete rest.',
              ),
              
              const SizedBox(height: 12),
              
              _buildInfoSection(
                'TDEE (Total Daily Energy Expenditure)',
                'Your complete daily calorie burn including BMR plus calories from physical activity, digestion, and daily movement.',
              ),
              
              const SizedBox(height: 12),
              
              _buildInfoSection(
                'Calorie Goals',
                'Weight loss: 500 cal deficit daily can lead to ~1 lb/week loss\nMild loss: 250 cal deficit for gradual weight loss\nGain: 500 cal surplus for healthy weight gain',
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
              'GOT IT',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: AppTheme.primaryBlue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 12,
            color: Colors.grey[700],
            height: 1.4,
          ),
        ),
      ],
    );
  }
}