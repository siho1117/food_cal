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
              // BMR Definition
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
              
              // Daily Calories Information
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

  @override
  Widget build(BuildContext context) {
    // If loading, return the loading state widget
    if (_isLoading) {
      return MasterWidget(
        title: 'BMR',
        icon: Icons.bolt_rounded, // Required for backward compatibility but not displayed
        isLoading: true,
        child: const SizedBox(),
      );
    }
    
    // If missing data, show error state with warning message
    if (_missingData.isNotEmpty) {
      return MasterWidget(
        title: 'BMR',
        icon: Icons.bolt_rounded, // Required for backward compatibility but not displayed
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
    
    // Main content when we have data - SIMPLIFIED VERSION
    return MasterWidget(
      title: 'BMR',
      icon: Icons.bolt_rounded, // Required for backward compatibility but not displayed
      trailing: MasterWidget.createInfoButton(
        onPressed: _showBMRInfoDialog,
        color: AppTheme.textDark,
      ),
      child: Padding(
        // Reduced vertical padding to 8px, matching BMI widget
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              // BMR numerical value with smaller font size
              Text(
                _bmr?.round().toString() ?? '0',
                style: const TextStyle(
                  fontSize: 30, // Reduced from 36
                  fontWeight: FontWeight.bold,
                  color: Colors.black, // Standard text color
                ),
              ),
              
              // Unit
              const Text(
                ' cal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}