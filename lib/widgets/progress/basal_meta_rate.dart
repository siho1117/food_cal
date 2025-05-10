import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';
import '../../data/models/user_profile.dart';

class BasalMetabolicRateWidget extends StatefulWidget {
  final UserProfile? userProfile;
  final double? currentWeight;

  const BasalMetabolicRateWidget({
    Key? key,
    required this.userProfile,
    required this.currentWeight,
  }) : super(key: key);

  @override
  State<BasalMetabolicRateWidget> createState() => _BasalMetabolicRateWidgetState();
}

class _BasalMetabolicRateWidgetState extends State<BasalMetabolicRateWidget> {
  bool _isLoading = true;
  double? _bmr;
  List<String> _missingData = [];
  
  @override
  void initState() {
    super.initState();
    _calculateBMR();
  }
  
  @override
  void didUpdateWidget(BasalMetabolicRateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile || 
        oldWidget.currentWeight != widget.currentWeight) {
      _calculateBMR();
    }
  }

  // Calculate BMR and check for missing data
  void _calculateBMR() {
    setState(() {
      _isLoading = true;
    });

    // Calculate BMR using the Mifflin-St Jeor Equation
    if (widget.currentWeight == null || 
        widget.userProfile?.height == null || 
        widget.userProfile?.age == null ||
        widget.userProfile?.gender == null) {
      // Check which data is missing
      _missingData = [];
      
      if (widget.userProfile == null) {
        _missingData.add("Profile");
      } else {
        if (widget.currentWeight == null) _missingData.add("Weight");
        if (widget.userProfile!.height == null) _missingData.add("Height");
        if (widget.userProfile!.age == null) _missingData.add("Age");
        if (widget.userProfile!.gender == null) _missingData.add("Gender");
      }
      
      _bmr = null;
    } else {
      // Calculate BMR
      if (widget.userProfile!.gender == 'Male') {
        _bmr = (10 * widget.currentWeight!) +
            (6.25 * widget.userProfile!.height!) -
            (5 * widget.userProfile!.age!) +
            5;
      } else if (widget.userProfile!.gender == 'Female') {
        _bmr = (10 * widget.currentWeight!) +
            (6.25 * widget.userProfile!.height!) -
            (5 * widget.userProfile!.age!) -
            161;
      } else {
        // Average of male and female formulas for other genders
        final maleBMR = (10 * widget.currentWeight!) +
            (6.25 * widget.userProfile!.height!) -
            (5 * widget.userProfile!.age!) +
            5;
        final femaleBMR = (10 * widget.currentWeight!) +
            (6.25 * widget.userProfile!.height!) -
            (5 * widget.userProfile!.age!) -
            161;
        _bmr = (maleBMR + femaleBMR) / 2;
      }
      
      _missingData = [];
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showBMRInfoDialog() {
    // Using AlertDialog.new constructor to be explicit and avoid potential issues
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
            const Text('About BMR'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BMR Definition (moved from the card)
              const Text(
                'Your Basal Metabolic Rate (BMR) is the number of calories your body needs to perform basic, life-sustaining functions while at rest. This includes breathing, circulation, cell production, and nutrient processing.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // Current BMR Value
              Text(
                'Your BMR: ${_bmr?.round() ?? 0} calories',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              
              // Daily Calories Information (moved from the card)
              const Text(
                'Your actual daily calorie needs are higher than your BMR since you are not always at rest. Your Total Daily Energy Expenditure (TDEE) accounts for your activity level on top of your BMR.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: 16),
              
              // Formula Section
              const Text(
                'The Mifflin-St Jeor Equation:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'For men:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Text('BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5'),
                    const SizedBox(height: 12),
                    const Text(
                      'For women:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const Text('BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Weight Management Guidelines
              const Text(
                'Using BMR for weight management:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              const Text(
                '• To lose weight: Consume fewer calories than your TDEE\n'
                '• To maintain weight: Consume equal calories to your TDEE\n'
                '• To gain weight: Consume more calories than your TDEE',
                style: TextStyle(fontSize: 14, height: 1.4),
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

  // Get an appropriate BMR comparison message
  String _getBMRComparisonText() {
    if (_bmr == null) return '';
    
    final String gender = widget.userProfile?.gender ?? 'Unknown';
    
    // Average BMR ranges by gender
    final double avgMaleBMR = 1650;  // Average BMR for adult men
    final double avgFemaleBMR = 1400; // Average BMR for adult women
    final double avgBMR = (avgMaleBMR + avgFemaleBMR) / 2;
    
    // Determine reference value based on gender
    double referenceValue;
    if (gender == 'Male') {
      referenceValue = avgMaleBMR;
    } else if (gender == 'Female') {
      referenceValue = avgFemaleBMR;
    } else {
      referenceValue = avgBMR;
    }
    
    // Calculate percentage difference from average
    final double difference = ((_bmr! - referenceValue) / referenceValue) * 100;
    
    // Generate appropriate message
    if (difference.abs() < 5) {
      return 'Your BMR is average for your demographic';
    } else if (difference > 0) {
      return 'Your BMR is ${difference.round().abs()}% higher than average';
    } else {
      return 'Your BMR is ${difference.round().abs()}% lower than average';
    }
  }
  
  // Get icon based on BMR level
  IconData _getBMRIcon() {
    if (_bmr == null) return Icons.bolt_outlined;
    
    final String gender = widget.userProfile?.gender ?? 'Unknown';
    final double avgMaleBMR = 1650;
    final double avgFemaleBMR = 1400;
    
    double referenceValue;
    if (gender == 'Male') {
      referenceValue = avgMaleBMR;
    } else if (gender == 'Female') {
      referenceValue = avgFemaleBMR;
    } else {
      referenceValue = (avgMaleBMR + avgFemaleBMR) / 2;
    }
    
    // Return icon based on comparison to average
    if (_bmr! > referenceValue * 1.15) {
      return Icons.local_fire_department; // Much higher
    } else if (_bmr! > referenceValue * 1.05) {
      return Icons.trending_up; // Higher
    } else if (_bmr! < referenceValue * 0.85) {
      return Icons.ac_unit; // Much lower
    } else if (_bmr! < referenceValue * 0.95) {
      return Icons.trending_down; // Lower
    } else {
      return Icons.bolt; // Average
    }
  }

  @override
  Widget build(BuildContext context) {
    // If loading, return the loading state widget
    if (_isLoading) {
      return MasterWidget(
        title: 'Basal Metabolic Rate',
        icon: Icons.bolt_rounded,
        isLoading: true,
        child: const SizedBox(),
      );
    }
    
    // If missing data, show error state with warning message
    if (_missingData.isNotEmpty) {
      return MasterWidget(
        title: 'Basal Metabolic Rate',
        icon: Icons.bolt_rounded,
        trailing: MasterWidget.createInfoButton(
          onPressed: _showBMRInfoDialog,
          color: AppTheme.textDark,
        ),
        hasError: true,
        errorMessage: 'To calculate your BMR, please update your profile with: ${_missingData.join(", ")}',
        onRetry: () {
          Navigator.of(context).pushNamed('/settings');
        },
        child: const SizedBox(),
      );
    }
    
    final comparisonText = _getBMRComparisonText();
    final bmrIcon = _getBMRIcon();
    
    // Determine color based on BMR icon
    Color bmrColor;
    if (bmrIcon == Icons.local_fire_department || bmrIcon == Icons.trending_up) {
      bmrColor = AppTheme.coralAccent;
    } else if (bmrIcon == Icons.ac_unit || bmrIcon == Icons.trending_down) {
      bmrColor = AppTheme.primaryBlue;
    } else {
      bmrColor = AppTheme.goldAccent;
    }
    
    // Main content when we have data - STREAMLINED VERSION
    return MasterWidget(
      title: 'Basal Metabolic Rate',
      icon: Icons.bolt_rounded,
      trailing: MasterWidget.createInfoButton(
        onPressed: _showBMRInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main BMR value display
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BMR numerical value
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _bmr?.round().toString() ?? '0',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      Text(
                        ' cal',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color.fromRGBO(
                            AppTheme.primaryBlue.red,
                            AppTheme.primaryBlue.green,
                            AppTheme.primaryBlue.blue,
                            0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  Text(
                    'calories burned daily at rest',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Only keep the comparison card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(
                  bmrColor.red,
                  bmrColor.green,
                  bmrColor.blue,
                  0.05,
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color.fromRGBO(
                    bmrColor.red,
                    bmrColor.green,
                    bmrColor.blue,
                    0.1,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(
                        bmrColor.red,
                        bmrColor.green,
                        bmrColor.blue,
                        0.1,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      bmrIcon,
                      color: bmrColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          comparisonText,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: bmrColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'BMR varies based on age, gender, weight, height, and muscle mass',
                          style: TextStyle(
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Prompt to tap info icon for more details
            Center(
              child: Text(
                'Tap the info icon for more details about BMR',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}