import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../data/repositories/user_repository.dart';
import '../../utils/formula.dart';
import 'target_weight_dialog.dart';
import '../../data/models/user_profile.dart';

class TargetWeightWidget extends StatelessWidget {
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

  void _showTargetWeightDialog(BuildContext context) async {
    await _createUserProfileIfNeeded(context);
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => TargetWeightDialog(
        initialTargetWeight: targetWeight,
        isMetric: isMetric,
        onWeightSaved: onWeightUpdated,
      ),
    );
  }
  
  Future<void> _createUserProfileIfNeeded(BuildContext context) async {
    final UserRepository userRepository = UserRepository();
    final userProfile = await userRepository.getUserProfile();
    
    if (userProfile == null) {
      final userId = DateTime.now().millisecondsSinceEpoch.toString();
      final newProfile = UserProfile(
        id: userId,
        isMetric: isMetric,
      );
      await userRepository.saveUserProfile(newProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasGoal = targetWeight != null;
    final isLoss = hasGoal && currentWeight != null ? currentWeight! > targetWeight! : false;
    final goalColor = isLoss ? Colors.green : Colors.orange;
    
    // Calculate progress
    double progress = 0.0;
    double? remaining;
    
    if (hasGoal && currentWeight != null) {
      // Set initial weight to current weight + 20% of the goal distance
      // as a rough estimate if we don't have actual starting weight
      final double assumedStartWeight = currentWeight! + 
        (currentWeight! - targetWeight!).abs() * 0.25;
      
      final totalDistance = (assumedStartWeight - targetWeight!).abs();
      final coveredDistance = (assumedStartWeight - currentWeight!).abs();
      
      progress = totalDistance > 0 ? (coveredDistance / totalDistance).clamp(0.0, 1.0) : 0.0;
      remaining = (currentWeight! - targetWeight!).abs();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Target Weight',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 18),
                onPressed: () => _showTargetWeightDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Content
          hasGoal ? _buildGoalDisplay(context, goalColor, progress, remaining) : _buildEmptyState(context),
        ],
      ),
    );
  }
  
  Widget _buildEmptyState(BuildContext context) {
    return InkWell(
      onTap: () => _showTargetWeightDialog(context),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.flag_outlined,
              size: 36,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Set a target weight',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildGoalDisplay(BuildContext context, Color goalColor, double progress, double? remaining) {
    // Format weight values
    final targetDisplay = isMetric ? 
        '${targetWeight?.toStringAsFixed(1)} kg' : 
        '${(targetWeight! * 2.20462).toStringAsFixed(1)} lbs';
    
    // Safe way to determine direction icon with null checks
    IconData directionIcon = Icons.horizontal_rule; // Default
    
    if (currentWeight != null && targetWeight != null) {
      directionIcon = currentWeight! > targetWeight! ? Icons.trending_down : Icons.trending_up;
    }
    
    return Column(
      children: [
        // Target weight value
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: goalColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.flag,
                color: goalColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              targetDisplay,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: goalColor,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Progress bar
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Progress percentage
            Text(
              'Progress: ${(progress * 100).round()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(goalColor),
                minHeight: 10,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Remaining weight
        if (remaining != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(directionIcon, size: 16, color: goalColor),
              const SizedBox(width: 8),
              Text(
                '${remaining.toStringAsFixed(1)} ${isMetric ? 'kg' : 'lbs'} to go',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: goalColor,
                ),
              ),
            ],
          ),
      ],
    );
  }
}