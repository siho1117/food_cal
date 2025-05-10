// lib/widgets/progress/target_weight_widget.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/widgets/master_widget.dart';
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

class _TargetWeightWidgetState extends State<TargetWeightWidget> {
  final UserRepository _userRepository = UserRepository();

  @override
  Widget build(BuildContext context) {
    // Calculate progress and states
    final double progress = _calculateProgress();
    final String progressText = _getProgressText();
    final bool hasGoal = widget.targetWeight != null;
    final bool isOverBudget = _getRemainingWeight() < 0;

    // Determine if goal is for weight loss or gain
    final bool isLoss = hasGoal ? widget.currentWeight! > widget.targetWeight! : true;
    final Color goalColor = isLoss ? AppTheme.coralAccent : AppTheme.goldAccent;
    
    // Use MasterWidget.progressWidget for a progress-focused layout
    return MasterWidget.progressWidget(
      title: 'Weight Goal',
      icon: Icons.flag_rounded,
      progress: hasGoal ? progress : 0.0,
      progressText: hasGoal ? '${(progress * 100).round()}% complete' : null,
      progressColor: hasGoal ? goalColor : Colors.grey,
      trailing: IconButton(
        icon: Icon(
          Icons.edit,
          color: AppTheme.primaryBlue.withOpacity(0.7),
          size: 20,
        ),
        onPressed: _showTargetWeightDialog,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
      child: hasGoal
          ? _buildGoalContent(isLoss, goalColor, progressText, isOverBudget)
          : _buildNoGoalContent(),
    );
  }
  
  // Build content when a goal is set
  Widget _buildGoalContent(
    bool isLoss, 
    Color goalColor, 
    String progressText, 
    bool isOverBudget
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Weight information
        Row(
          children: [
            // Target weight
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Goal Weight',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatWeight(widget.targetWeight),
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: goalColor,
                    ),
                  ),
                ],
              ),
            ),

            // Current weight
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Current Weight',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatWeight(widget.currentWeight),
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),

        // Remaining goal indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: isOverBudget
                    ? Colors.red[50]
                    : Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isOverBudget
                      ? Colors.red[200]!
                      : Colors.green[200]!,
                  width: 1,
                ),
              ),
              child: Text(
                progressText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isOverBudget
                      ? Colors.red[700]
                      : Colors.green[700],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  // Build content when no goal is set
  Widget _buildNoGoalContent() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryBlue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 16,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Set a weight goal to track your progress',
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.primaryBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Show dialog to set/update weight goal
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

  // Format weight with proper units
  String _formatWeight(double? weight) {
    if (weight == null) return 'Not set';

    return Formula.formatWeight(
      weight: weight,
      isMetric: widget.isMetric,
    );
  }
}