import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
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

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animation when widget is built
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
    // Calculate progress toward goal
    final double progress = _calculateProgress();
    final String progressText = _getProgressText();
    final bool hasGoal = widget.targetWeight != null;
    final bool isOverBudget = _getRemainingWeight() < 0;

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
          // Header
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
                      Icons.flag_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Weight Goal',
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
                    Icons.edit,
                    color: AppTheme.primaryBlue.withOpacity(0.7),
                    size: 20,
                  ),
                  onPressed: _showTargetWeightDialog,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                              color: hasGoal ? AppTheme.accentColor : Colors.grey,
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

                const SizedBox(height: 24),

                // Progress indicator
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Progress bar
                        LinearProgressIndicator(
                          value: hasGoal ? progress * _progressAnimation.value : 0.0,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            hasGoal ? AppTheme.accentColor : Colors.grey,
                          ),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),

                        const SizedBox(height: 12),

                        // Progress text
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              hasGoal
                                  ? '${(progress * 100 * _progressAnimation.value).toInt()}% complete'
                                  : 'No goal set',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: hasGoal ? AppTheme.accentColor : Colors.grey,
                              ),
                            ),
                            if (hasGoal && widget.currentWeight != null)
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
                  },
                ),

                // Set goal message (if no goal yet)
                if (!hasGoal)
                  Container(
                    margin: const EdgeInsets.only(top: 12),
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
                            'Tap the edit button to set your weight goal',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
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

  // Format weight with proper units
  String _formatWeight(double? weight) {
    if (weight == null) return 'Not set';

    return Formula.formatWeight(
      weight: weight,
      isMetric: widget.isMetric,
    );
  }
}