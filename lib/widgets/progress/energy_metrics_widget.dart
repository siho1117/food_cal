// lib/widgets/progress/energy_metrics_widget.dart
import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/dimensions.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/user_profile.dart';
import '../../utils/formula.dart';

class EnergyMetricsWidget extends StatelessWidget {
  final UserProfile? userProfile;
  final double? currentWeight;
  final VoidCallback? onSettingsTap;

  const EnergyMetricsWidget({
    Key? key,
    required this.userProfile,
    required this.currentWeight,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate BMR & TDEE
    final calculationResults = _calculateEnergy();
    final missingData = calculationResults['missingData'] as List<String>?;
    final bmr = calculationResults['bmr'] as double?;
    final tdee = calculationResults['tdee'] as double?;
    final activityLevel = calculationResults['activityLevel'] as double?;
    final calorieGoals = calculationResults['calorieGoals'] as Map<String, int>?;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Dimensions.s),
      ),
      child: Padding(
        padding: EdgeInsets.all(Dimensions.m),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Daily Energy Needs',
                  style: AppTextStyles.getSubHeadingStyle().copyWith(
                    fontSize: Dimensions.getTextSize(context, size: TextSize.medium),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    size: Dimensions.getIconSize(context, size: IconSize.small),
                  ),
                  onPressed: () => _showInfoDialog(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  color: Colors.grey[500],
                ),
              ],
            ),
            
            SizedBox(height: Dimensions.s),
            
            // Show error state if missing data
            if (missingData != null && missingData.isNotEmpty)
              _buildMissingDataState(context, missingData)
            else
              _buildEnergyContent(context, bmr, tdee, activityLevel, calorieGoals),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMissingDataState(BuildContext context, List<String> missingData) {
    return Column(
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
        const SizedBox(height: 12),
        TextButton(
          onPressed: onSettingsTap ?? () {
            Navigator.of(context).pushNamed('/settings');
          },
          child: Text('Update Profile'),
        ),
      ],
    );
  }
  
  Widget _buildEnergyContent(
    BuildContext context, 
    double? bmr, 
    double? tdee,
    double? activityLevel,
    Map<String, int>? calorieGoals,
  ) {
    return Column(
      children: [
        // BMR and TDEE overview
        Row(
          children: [
            // BMR metric
            Expanded(
              child: _buildEnergyMetric(
                title: 'BMR',
                value: bmr?.round() ?? 0,
                description: 'Calories at rest',
                color: AppTheme.coralAccent,
              ),
            ),
            
            // Divider
            Container(
              height: 70,
              width: 1,
              color: Colors.grey[300],
            ),
            
            // TDEE metric
            Expanded(
              child: _buildEnergyMetric(
                title: 'TDEE',
                value: tdee?.round() ?? 0,
                description: 'Daily calories',
                color: AppTheme.primaryBlue,
                isPrimary: true,
              ),
            ),
          ],
        ),
        
        SizedBox(height: Dimensions.s),
        
        // Activity level indicator
        if (activityLevel != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getActivityLevelColor(activityLevel).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getActivityLevelColor(activityLevel).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getActivityIcon(activityLevel),
                  size: 14,
                  color: _getActivityLevelColor(activityLevel),
                ),
                const SizedBox(width: 6),
                Text(
                  Formula.getActivityLevelText(activityLevel),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _getActivityLevelColor(activityLevel),
                  ),
                ),
              ],
            ),
          ),
          
        SizedBox(height: Dimensions.m),
          
        // Divider
        Divider(color: Colors.grey[300]),
        
        SizedBox(height: Dimensions.s),
        
        // Calorie targets
        if (calorieGoals != null) ...[
          Text(
            'Calorie Targets',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          
          SizedBox(height: Dimensions.xs),
          
          // Grid of calorie targets for different goals
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            childAspectRatio: 2.5,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            padding: EdgeInsets.zero,
            children: [
              _buildCalorieTarget('Weight Loss', calorieGoals['lose'] ?? 0, Colors.green, Icons.trending_down),
              _buildCalorieTarget('Maintain', calorieGoals['maintain'] ?? 0, AppTheme.primaryBlue, Icons.trending_flat),
              _buildCalorieTarget('Mild Loss', calorieGoals['lose_mild'] ?? 0, Colors.lightGreen, Icons.trending_down),
              _buildCalorieTarget('Weight Gain', calorieGoals['gain'] ?? 0, AppTheme.goldAccent, Icons.trending_up),
            ],
          ),
          
          SizedBox(height: Dimensions.xs),
          
          // Note about calories
          Container(
            padding: EdgeInsets.all(Dimensions.xs),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(Dimensions.xxs),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.grey[600]),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Weight loss: 500 cal deficit • Mild loss: 250 cal deficit • Gain: 500 cal surplus',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildEnergyMetric({
    required String title,
    required int value,
    required String description,
    required Color color,
    bool isPrimary = false,
  }) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '$value',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: isPrimary ? 28 : 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          description,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildCalorieTarget(String title, int calories, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
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
      ),
    );
  }
  
  // Get icon based on activity level
  IconData _getActivityIcon(double activityLevel) {
    if (activityLevel < 1.4) return Icons.battery_1_bar;
    if (activityLevel < 1.6) return Icons.battery_2_bar;
    if (activityLevel < 1.8) return Icons.battery_3_bar;
    return Icons.battery_4_bar;
  }
  
  // Get activity level color
  Color _getActivityLevelColor(double activityLevel) {
    if (activityLevel < 1.4) return Colors.grey; // Sedentary
    if (activityLevel < 1.6) return Colors.green; // Lightly active
    if (activityLevel < 1.8) return AppTheme.goldAccent; // Moderately active
    return AppTheme.primaryBlue; // Very active / Extra active
  }
  
  // Calculate BMR and TDEE
  Map<String, dynamic> _calculateEnergy() {
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
    final bmr = Formula.calculateBMR(
      weight: currentWeight,
      height: userProfile!.height,
      age: userProfile!.age,
      gender: userProfile!.gender,
    );
    
    // Get activity level
    final activityLevel = userProfile!.activityLevel ?? 1.2;
    
    // Calculate TDEE (Total Daily Energy Expenditure)
    final tdee = bmr! * activityLevel;
    
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
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: AppTheme.primaryBlue,
            ),
            const SizedBox(width: 8),
            Text(
              'About Energy Metrics',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
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
                'The number of calories your body needs to perform essential life-sustaining functions while at complete rest.',
              ),
              
              SizedBox(height: Dimensions.s),
              
              _buildInfoSection(
                'TDEE (Total Daily Energy Expenditure)',
                'Your total daily calorie burn, which combines your BMR with additional calories burned through physical activity and digestion.',
              ),
              
              SizedBox(height: Dimensions.s),
              
              _buildInfoSection(
                'Weight Loss',
                'To lose weight, consume fewer calories than your TDEE. A deficit of 500 calories per day can lead to approximately 1 pound (0.45 kg) of weight loss per week.',
              ),
              
              SizedBox(height: Dimensions.s),
              
              _buildInfoSection(
                'Weight Gain',
                'To gain weight, consume more calories than your TDEE. A surplus of 500 calories per day can lead to approximately 1 pound (0.45 kg) of weight gain per week.',
              ),
              
              SizedBox(height: Dimensions.s),
              
              _buildInfoSection(
                'Activity Levels',
                '• Sedentary: Little to no exercise\n'
                '• Light: Light exercise 1-3 days/week\n'
                '• Moderate: Moderate exercise 3-5 days/week\n'
                '• Active: Hard exercise 6-7 days/week\n'
                '• Very Active: Very hard daily exercise or physical job',
              ),
              
              SizedBox(height: Dimensions.s),
              
              Container(
                padding: EdgeInsets.all(Dimensions.xs),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(Dimensions.xxs),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'These are estimates. Individual metabolism varies. Consult a healthcare professional for personalized advice.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                  ],
                ),
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
            child: const Text('CLOSE'),
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
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          content,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}