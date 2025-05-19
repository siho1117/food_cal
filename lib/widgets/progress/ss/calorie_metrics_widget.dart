import 'package:flutter/material.dart';
import '../../../config/design_system/theme.dart';
import '../../../data/models/user_profile.dart';

class CalorieMetricsWidget extends StatelessWidget {
  final UserProfile? userProfile;
  final double? currentWeight;

  const CalorieMetricsWidget({
    Key? key,
    required this.userProfile,
    required this.currentWeight,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate BMR and TDEE
    final calculationResults = _calculateCalories();
    final missingData = calculationResults['missingData'] as List<String>?;
    final bmr = calculationResults['bmr'] as double?;
    final tdee = calculationResults['tdee'] as double?;
    
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
                'Daily Calories',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, size: 18),
                onPressed: () => _showInfoDialog(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Content - either error or metrics
          missingData != null && missingData.isNotEmpty
              ? _buildErrorState(context, missingData)
              : _buildMetricsDisplay(context, bmr, tdee),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _calculateCalories() {
    // Check for missing data
    List<String> missingData = [];
    if (currentWeight == null) missingData.add('Weight');
    if (userProfile?.height == null) missingData.add('Height');
    if (userProfile?.age == null) missingData.add('Age');
    if (userProfile?.gender == null) missingData.add('Gender');
    
    if (missingData.isNotEmpty) {
      return {'missingData': missingData};
    }
    
    // Calculate BMR (Basal Metabolic Rate)
    double bmr;
    if (userProfile!.gender == 'Male') {
      bmr = (10 * currentWeight!) +
            (6.25 * userProfile!.height!) -
            (5 * userProfile!.age!) +
            5;
    } else if (userProfile!.gender == 'Female') {
      bmr = (10 * currentWeight!) +
            (6.25 * userProfile!.height!) -
            (5 * userProfile!.age!) -
            161;
    } else {
      // Average for other genders
      final maleBmr = (10 * currentWeight!) +
            (6.25 * userProfile!.height!) -
            (5 * userProfile!.age!) +
            5;
      final femaleBmr = (10 * currentWeight!) +
            (6.25 * userProfile!.height!) -
            (5 * userProfile!.age!) -
            161;
      bmr = (maleBmr + femaleBmr) / 2;
    }
    
    // Calculate TDEE (Total Daily Energy Expenditure)
    final activityLevel = userProfile!.activityLevel ?? 1.2;
    final tdee = bmr * activityLevel;
    
    return {
      'bmr': bmr,
      'tdee': tdee,
      'activityLevel': activityLevel,
    };
  }
  
  Widget _buildErrorState(BuildContext context, List<String> missingData) {
    return Center(
      child: Column(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 36,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          Text(
            'Missing Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Please update: ${missingData.join(", ")}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pushNamed(context, '/settings'),
            child: Text('Update Profile'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMetricsDisplay(BuildContext context, double? bmr, double? tdee) {
    final activityLevel = userProfile?.activityLevel ?? 1.2;
    final activityText = _getActivityLevelText(activityLevel);
    
    return Column(
      children: [
        // BMR and TDEE row
        Row(
          children: [
            // BMR
            Expanded(
              child: Column(
                children: [
                  Text(
                    'BMR',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${bmr?.round() ?? 0}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  Text(
                    'calories',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryBlue.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Container(
              height: 60,
              width: 1,
              color: Colors.grey[300],
            ),
            
            // TDEE
            Expanded(
              child: Column(
                children: [
                  Text(
                    'TDEE',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${tdee?.round() ?? 0}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  Text(
                    'calories',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Activity level badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.fitness_center,
                size: 14,
                color: Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                activityText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Divider
        Divider(color: Colors.grey[300]),
        
        const SizedBox(height: 12),
        
        // Calories for goals
        if (tdee != null) ...[
          _buildCalorieGoal('Maintain Weight', tdee.round(), Colors.blue),
          const SizedBox(height: 8),
          _buildCalorieGoal('Lose Weight', (tdee - 500).round(), Colors.green),
          const SizedBox(height: 8),
          _buildCalorieGoal('Gain Weight', (tdee + 500).round(), Colors.orange),
        ],
      ],
    );
  }
  
  Widget _buildCalorieGoal(String label, int calories, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        Text(
          '$calories cal',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  String _getActivityLevelText(double activityLevel) {
    if (activityLevel < 1.3) return 'Sedentary';
    if (activityLevel < 1.5) return 'Light Activity';
    if (activityLevel < 1.7) return 'Moderate Activity';
    if (activityLevel < 1.9) return 'High Activity';
    return 'Very High Activity';
  }
  
  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('About Daily Calories'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'BMR (Basal Metabolic Rate)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'The number of calories your body needs to perform basic life-sustaining functions while at rest.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'TDEE (Total Daily Energy Expenditure)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your total calories burned per day, which includes your BMR plus additional calories burned through physical activity and digestion.',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Text(
                'Activity Levels:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildActivityLevel('Sedentary', '1.2', 'Little or no exercise'),
              _buildActivityLevel('Light', '1.375', 'Light exercise 1-3 days/week'),
              _buildActivityLevel('Moderate', '1.55', 'Moderate exercise 3-5 days/week'),
              _buildActivityLevel('High', '1.725', 'Hard exercise 6-7 days/week'),
              _buildActivityLevel('Very High', '1.9', 'Very hard daily exercise or physical job'),
              const SizedBox(height: 16),
              Text(
                'Formula: TDEE = BMR × Activity Level',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CLOSE'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildActivityLevel(String level, String multiplier, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 50,
            child: Text(multiplier, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: Text('$level - $description', style: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }
}