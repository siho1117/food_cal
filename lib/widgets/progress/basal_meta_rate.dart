import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/widgets/master_widget.dart';
import '../../config/components/value_builder.dart';
import '../../config/components/state_builder.dart';
import '../../utils/formula.dart';

class BMRWidget extends StatefulWidget {
  final double? height;
  final double? weight;
  final int? age;
  final String? gender;
  final bool isMetric;

  const BMRWidget({
    Key? key,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    this.isMetric = true,
  }) : super(key: key);

  @override
  State<BMRWidget> createState() => _BMRWidgetState();
}

class _BMRWidgetState extends State<BMRWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _valueAnimation;

  double? _bmr;
  List<String> _missingData = [];

  @override
  void initState() {
    super.initState();
    
    // Setup animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _calculateBMR();
  }

  @override
  void didUpdateWidget(BMRWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Recalculate BMR if any of the inputs change
    if (oldWidget.height != widget.height ||
        oldWidget.weight != widget.weight ||
        oldWidget.age != widget.age ||
        oldWidget.gender != widget.gender) {
      _calculateBMR();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _calculateBMR() {
    // Reset missing data
    _missingData = [];
    
    // Check for missing inputs
    if (widget.weight == null) _missingData.add("Weight");
    if (widget.height == null) _missingData.add("Height");
    if (widget.age == null) _missingData.add("Age");
    if (widget.gender == null) _missingData.add("Gender");
    
    // If any data is missing, we can't calculate BMR
    if (_missingData.isNotEmpty) {
      _bmr = null;
      return;
    }

    // Use the Mifflin-St Jeor Equation to calculate BMR
    if (widget.gender!.toLowerCase() == 'male') {
      _bmr = (10 * widget.weight!) +
          (6.25 * widget.height!) -
          (5 * widget.age!) +
          5;
    } else if (widget.gender!.toLowerCase() == 'female') {
      _bmr = (10 * widget.weight!) +
          (6.25 * widget.height!) -
          (5 * widget.age!) -
          161;
    } else {
      // For other genders, use an average of male and female formulas
      final maleBMR = (10 * widget.weight!) +
          (6.25 * widget.height!) -
          (5 * widget.age!) +
          5;
      final femaleBMR = (10 * widget.weight!) +
          (6.25 * widget.height!) -
          (5 * widget.age!) -
          161;
      _bmr = (maleBMR + femaleBMR) / 2;
    }
    
    // Setup animation for BMR value
    _valueAnimation = Tween<double>(
      begin: 0.0,
      end: _bmr,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Reset and play animation
    _animationController.reset();
    _animationController.forward();
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
    // If no valid BMR can be calculated, show missing data state
    if (_missingData.isNotEmpty) {
      return MasterWidget(
        title: 'BMR',
        icon: Icons.local_fire_department,
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

    // Main content with valid BMR
    return MasterWidget(
      title: 'BMR',
      icon: Icons.local_fire_department,
      trailing: MasterWidget.createInfoButton(
        onPressed: _showBMRInfoDialog,
        color: AppTheme.textDark,
      ),
      animationController: _animationController,
      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Animated BMR value display
          ValueBuilder.buildAnimatedCounter(
            animation: _valueAnimation,
            targetValue: _bmr ?? 0,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
            decimalPlaces: 0,
            suffix: ' cal',
          ),
          
          const SizedBox(height: 16),
          
          // Small info text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlueBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppTheme.primaryBlue,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Calories at complete rest',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}