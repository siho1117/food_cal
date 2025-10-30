// lib/widgets/progress/energy_metrics_widget.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme_design.dart';
import '../../config/design_system/typography.dart';
import '../../data/models/user_profile.dart';

class EnergyMetricsWidget extends StatefulWidget {
  final UserProfile? userProfile;
  final double? currentWeight;
  final VoidCallback? onSettingsTap;

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

  Map<String, dynamic> _calculateEnergy() {
    final profile = widget.userProfile;
    final weight = widget.currentWeight;

    if (profile == null || weight == null) {
      return {'missingData': ['profile', 'weight']};
    }

    final age = profile.age;
    final gender = profile.gender;
    final height = profile.height;
    final activityLevel = profile.activityLevel ?? 1.2;

    if (age == null || gender == null || height == null) {
      return {'missingData': ['age', 'gender', 'height']};
    }

    double bmr;
    if (gender.toLowerCase() == 'male') {
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    final tdee = bmr * activityLevel;

    final calorieGoals = {
      'maintain': tdee.round(),
      'mildLoss': (tdee - 250).round(),
      'weightLoss': (tdee - 500).round(),
      'gain': (tdee + 500).round(),
    };

    return {
      'bmr': bmr,
      'tdee': tdee,
      'activityLevel': activityLevel,
      'calorieGoals': calorieGoals,
    };
  }

  @override
  Widget build(BuildContext context) {
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
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Column(
            children: [
              _buildSplitCard(context, bmr, tdee, activityLevel, missingData),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: _showGoals ? null : 0,
                child: _showGoals
                    ? _buildGoalsSection(context, calorieGoals)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSplitCard(BuildContext context, double? bmr, double? tdee, 
      double? activityLevel, List<String>? missingData) {
    if (missingData != null) {
      return _buildMissingDataCard(context, missingData);
    }

    final activityDiff = (tdee ?? 0) - (bmr ?? 0);

    return Card(
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildMetricSection(
                    title: 'BMR',
                    value: bmr?.round() ?? 0,
                    description: 'Basal metabolic\nrate',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF0D4033),
                        Color(0xFF0A3329),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  color: Colors.white.withValues(alpha: 0.2),
                ),
                Expanded(
                  child: _buildMetricSection(
                    title: 'TDEE',
                    value: tdee?.round() ?? 0,
                    description: 'Total daily energy\nexpenditure',
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFCF9340),
                        Color(0xFFB8822E),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: AppLegacyColors.secondaryBeige.withValues(alpha: 0.3),
              border: Border(
                top: BorderSide(
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
                      color: AppLegacyColors.goldAccent,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Activity adds +${activityDiff.round()} calories',
                      style: AppTypography.bodyMedium.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppLegacyColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showGoals = !_showGoals;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _showGoals ? 'Hide Goals' : 'View Calorie Goals',
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppLegacyColors.primaryBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: _showGoals ? 0.5 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 14,
                            color: AppLegacyColors.primaryBlue,
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
    );
  }

  Widget _buildMetricSection({
    required String title,
    required int value,
    required String description,
    required LinearGradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(gradient: gradient),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.displaySmall.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.9),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: AppTypography.labelLarge.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsSection(BuildContext context, Map<String, int>? goals) {
    if (goals == null) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(top: 12),
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: AppLegacyColors.primaryBlue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Calorie Goals',
                  style: AppTypography.displaySmall.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppLegacyColors.primaryBlue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalRow('Maintain Weight', goals['maintain']!, AppLegacyColors.primaryBlue, '✓'),
            _buildGoalRow('Mild Loss (-0.25kg/week)', goals['mildLoss']!, const Color(0xFF3B82F6), '↘'),
            _buildGoalRow('Weight Loss (-0.5kg/week)', goals['weightLoss']!, AppLegacyColors.coralAccent, '↓'),
            _buildGoalRow('Weight Gain (+0.5kg/week)', goals['gain']!, AppLegacyColors.goldAccent, '↑'),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalRow(String label, int calories, Color color, String emoji) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ),
          Text(
            '$calories cal',
            style: AppTypography.labelLarge.copyWith(
              fontSize: 15,
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
      elevation: 6,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Complete Your Profile',
              style: AppTypography.displaySmall.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppLegacyColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your ${missingData.join(", ")} to calculate BMR & TDEE',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: widget.onSettingsTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppLegacyColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                'Go to Settings',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}