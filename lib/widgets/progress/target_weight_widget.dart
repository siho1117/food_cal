import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/animations/animation_helpers.dart';
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
  // Add optional external animation controller
  final AnimationController? animationController;

  const TargetWeightWidget({
    Key? key,
    required this.targetWeight,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightUpdated,
    this.animationController, // Optional external controller
  }) : super(key: key);

  @override
  State<TargetWeightWidget> createState() => _TargetWeightWidgetState();
}

class _TargetWeightWidgetState extends State<TargetWeightWidget> with SingleTickerProviderStateMixin {
  final UserRepository _userRepository = UserRepository();
  
  // Animation controller and animation
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _usingExternalController = false;

  @override
  void initState() {
    super.initState();
    
    // Use external controller if provided, otherwise create our own
    if (widget.animationController != null) {
      _animationController = widget.animationController!;
      _usingExternalController = true;
    } else {
      _animationController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      );
      // Start the animation if using internal controller
      _animationController.forward();
    }
    
    // Use AnimationHelpers for progress animation
    _progressAnimation = AnimationHelpers.createProgressAnimation(
      controller: _animationController,
      curve: Curves.easeOutCubic,
    );
  }
  
  @override
  void didUpdateWidget(TargetWeightWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Handle changes in external controller
    if (widget.animationController != oldWidget.animationController) {
      if (!_usingExternalController) {
        // Dispose old controller if we created it
        _animationController.dispose();
      }
      
      if (widget.animationController != null) {
        _animationController = widget.animationController!;
        _usingExternalController = true;
      } else {
        _animationController = AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1500),
        );
        _usingExternalController = false;
        _animationController.forward();
      }
      
      // Recreate animation with new controller
      _progressAnimation = AnimationHelpers.createProgressAnimation(
        controller: _animationController,
        curve: Curves.easeOutCubic,
      );
    }
    
    // Reset and restart animation if data changes and using internal controller
    if ((oldWidget.targetWeight != widget.targetWeight || 
        oldWidget.currentWeight != widget.currentWeight) && 
        !_usingExternalController) {
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    // Only dispose the controller if we created it
    if (!_usingExternalController) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress and states
    final double progress = _calculateProgress();
    final bool hasGoal = widget.targetWeight != null;

    // Determine if goal is for weight loss or gain
    final bool isLoss = hasGoal ? widget.currentWeight! > widget.targetWeight! : true;
    final Color goalColor = isLoss ? Colors.green : AppTheme.goldAccent;
    
    // Fixed text color for header
    final Color textColor = AppTheme.textDark;
    
    // Use MasterWidget with standardized header
    return MasterWidget(
      title: 'Weight Goal',
      icon: Icons.flag_rounded,
      textColor: textColor,
      iconColor: textColor,
      animationController: widget.animationController, // Pass the controller to MasterWidget too
      // Use standardized edit button
      trailing: MasterWidget.createEditButton(
        onPressed: _showTargetWeightDialog,
        color: textColor,
      ),
      child: hasGoal
          ? _buildGoalJourneyContent(isLoss, goalColor, progress)
          : _buildNoGoalContent(),
    );
  }
  
  // Build journey-focused goal content with reduced spacing BETWEEN items
  Widget _buildGoalJourneyContent(
    bool isLoss, 
    Color goalColor, 
    double progress
  ) {
    // Calculate remaining weight
    final double remainingWeight = _getRemainingWeight().abs();
    
    // Determine direction icon
    final IconData directionIcon = isLoss ? Icons.arrow_downward : Icons.arrow_upward;
    
    // Estimate weeks to completion (based on recommended 0.5-1kg/week)
    final int estimatedWeeks = (remainingWeight / (widget.isMetric ? 0.75 : 1.65)).ceil();
    final String timeframeText = estimatedWeeks <= 1 
        ? 'Almost there!'
        : '$estimatedWeeks ${estimatedWeeks == 1 ? 'week' : 'weeks'} to goal';
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0), // Reduced from 20
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target weight display
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 22,
                  color: goalColor,
                ),
                const SizedBox(width: 8),
                Text(
                  'TARGET',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                    letterSpacing: 1.0,
                  ),
                ),
                const Spacer(),
                // Target weight value
                Text(
                  _formatWeight(widget.targetWeight),
                  style: AppTextStyles.getNumericStyle().copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: goalColor,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10), // Reduced from 24
          
          // Journey path visual - FIXED HEIGHT
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Stack(
              children: [
                // Background track
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                
                // Progress track - animated
                Align(
                  alignment: Alignment.centerLeft,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return FractionallySizedBox(
                        widthFactor: progress * _progressAnimation.value,
                        child: Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: goalColor,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Start indicator
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                
                // Goal indicator
                Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: goalColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.flag,
                      size: 8,
                      color: goalColor,
                    ),
                  ),
                ),
                
                // Progress position indicator
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progress * _progressAnimation.value,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: goalColor,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10), // Reduced from 24
          
          // Progress stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left: Completion percentage
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PROGRESS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(progress * 100).round()}%',
                      style: AppTextStyles.getNumericStyle().copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: goalColor,
                      ),
                    ),
                  ],
                ),
                
                // Right: Remaining weight
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'REMAINING',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[500],
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          directionIcon,
                          size: 16,
                          color: goalColor,
                        ),
                        const SizedBox(width: 4),
                        AnimationHelpers.buildAnimatedCounter(
                          animation: _progressAnimation,
                          targetValue: remainingWeight,
                          style: AppTextStyles.getNumericStyle().copyWith(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: goalColor,
                          ),
                          decimalPlaces: 1,
                          suffix: widget.isMetric ? ' kg' : ' lbs',
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 10), // Reduced from 16
          
          // Time estimate (safe, healthy weight change)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Text(
                    timeframeText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Build content when no goal is set
  Widget _buildNoGoalContent() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state illustration
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.flag_outlined,
              size: 56,
              color: Colors.grey[400],
            ),
          ),
          
          const SizedBox(height: 12), // Reduced from 20
          
          // Message
          Text(
            'Set a Weight Goal',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 6), // Reduced from 10
          
          Text(
            'Tap the pencil icon to set a target weight and start tracking your progress.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12), // Reduced from 20
          
          // Visual prompt
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.edit,
                size: 16,
                color: AppTheme.primaryBlue,
              ),
              const SizedBox(width: 4),
              Text(
                'Set Target Weight',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Icon(
                Icons.arrow_right,
                size: 20,
                color: AppTheme.primaryBlue,
              ),
            ],
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