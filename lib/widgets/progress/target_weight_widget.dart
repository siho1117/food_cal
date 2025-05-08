// lib/widgets/progress/target_weight_widget.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../config/layouts/card_layout.dart';
import '../../config/layouts/header_layout.dart';
import '../../config/layouts/content_layout.dart';
import '../../config/decorations/box_decorations.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/builders/value_builder.dart';
import '../../config/extensions/num_extensions.dart';
import '../../utils/formula.dart';
import '../../data/repositories/user_repository.dart';
import '../../data/models/user_profile.dart';
import 'target_weight_dialog.dart';

class TargetWeightWidget extends StatefulWidget {
  final double? targetWeight;
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightUpdated;

  const TargetWeightWidget({
    Key? key,
    required this.targetWeight,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightUpdated,
  }) : super(key: key);

  @override
  State<TargetWeightWidget> createState() => _TargetWeightWidgetState();
}

class _TargetWeightWidgetState extends State<TargetWeightWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  final UserRepository _userRepository = UserRepository();

  @override
  void initState() {
    super.initState();

    // Initialize animation using AnimationHelpers
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = AnimationHelpers.createProgressAnimation(
      controller: _animationController,
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TargetWeightWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animate again if target or current weight changes
    if (oldWidget.targetWeight != widget.targetWeight ||
        oldWidget.currentWeight != widget.currentWeight) {
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  // Method to handle showing the target weight dialog
  void _showTargetWeightDialog() async {
    // Create user profile if needed
    await _createUserProfileIfNeeded();
    
    if (!context.mounted) return;
    
    // Show the dialog
    showDialog(
      context: context,
      builder: (context) => TargetWeightDialog(
        initialTargetWeight: widget.targetWeight,
        isMetric: widget.isMetric,
        onWeightSaved: widget.onWeightUpdated,
      ),
    );
  }
  
  // Create a new user profile if one doesn't exist
  Future<void> _createUserProfileIfNeeded() async {
    final userProfile = await _userRepository.getUserProfile();
    
    if (userProfile == null) {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newProfile = UserProfile(
        id: userId,
        isMetric: widget.isMetric,
      );

      await _userRepository.saveUserProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress information
    final double progress = _calculateProgress();
    final String progressText = _getProgressText();
    final bool hasGoal = widget.targetWeight != null;
    final bool isWeightLoss = _isWeightLossGoal();
    final Color targetColor = isWeightLoss ? AppTheme.coralAccent : AppTheme.goldAccent;
    
    // Use CardLayout for consistent card styling
    return CardLayout.card(
      // Use HeaderLayout for consistent header styling
      header: HeaderLayout.withRefresh(
        title: 'Weight Goal',
        icon: Icons.flag_rounded,
        onRefresh: _showTargetWeightDialog,
      ),
      child: hasGoal 
          ? _buildGoalContent(progress, progressText, targetColor)
          : _buildNoGoalContent(),
    );
  }
  
  // Content when a goal is set
  Widget _buildGoalContent(double progress, String progressText, Color goalColor) {
    final bool isOverBudget = _getRemainingWeight() < 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weight information
        Row(
          children: [
            // Target weight
            Expanded(
              child: ValueBuilder.buildValueWithSubtitle(
                value: _formatWeight(widget.targetWeight),
                subtitle: 'Goal Weight',
                valueColor: goalColor,
                align: TextAlign.start,
              ),
            ),

            // Current weight
            Expanded(
              child: ValueBuilder.buildValueWithSubtitle(
                value: _formatWeight(widget.currentWeight),
                subtitle: 'Current Weight',
                valueColor: AppTheme.primaryBlue,
                align: TextAlign.end,
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),

        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return ContentLayout.progressBar(
              progress: progress * _progressAnimation.value,
              label: '${(progress * 100 * _progressAnimation.value).toInt()}% complete',
              valueLabel: progressText,
              color: goalColor,
              height: 8.0,
            );
          },
        ),

        const SizedBox(height: 16),

        // Healthy weight change tip
        ContentLayout.infoBox(
          message: _isWeightLossGoal()
            ? 'Healthy weight loss: 0.5-1 kg (1-2 lbs) per week. Focus on sustainable habits and regular exercise.'
            : 'Healthy weight gain: 0.25-0.5 kg (0.5-1 lb) per week. Pair with strength training for muscle development.',
          icon: Icons.tips_and_updates_outlined,
          color: AppTheme.primaryBlue,
        ),
      ],
    );
  }
  
  // Content when no goal is set
  Widget _buildNoGoalContent() {
    return Column(
      children: [
        // Info message
        ContentLayout.infoBox(
          message: 'Set a weight goal to track your progress',
          icon: Icons.info_outline, 
          color: AppTheme.primaryBlue,
        ),
        
        const SizedBox(height: 16),
        
        // Set goal button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _showTargetWeightDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text('SET WEIGHT GOAL'),
          ),
        ),
      ],
    );
  }

  // Calculate progress percentage
  double _calculateProgress() {
    if (widget.targetWeight == null || widget.currentWeight == null) {
      return 0.0;
    }

    return Formula.calculateGoalProgress(
      currentWeight: widget.currentWeight,
      targetWeight: widget.targetWeight,
    );
  }

  // Get remaining weight text
  String _getProgressText() {
    if (widget.targetWeight == null || widget.currentWeight == null) {
      return 'Set a goal';
    }

    return Formula.getWeightChangeDirectionText(
      currentWeight: widget.currentWeight,
      targetWeight: widget.targetWeight,
      isMetric: widget.isMetric,
    );
  }

  // Get remaining weight value
  double _getRemainingWeight() {
    if (widget.targetWeight == null || widget.currentWeight == null) {
      return 0.0;
    }

    return widget.currentWeight! - widget.targetWeight!;
  }
  
  // Check if this is a weight loss goal
  bool _isWeightLossGoal() {
    if (widget.targetWeight == null || widget.currentWeight == null) {
      return true; // Default to weight loss
    }
    
    return widget.currentWeight! > widget.targetWeight!;
  }

  // Format weight with proper units
  String _formatWeight(double? weight) {
    if (weight == null) return 'Not set';

    return Formula.formatWeight(
      weight: weight,
      isMetric: widget.isMetric,
    );
  }
}