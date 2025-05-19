import 'package:flutter/material.dart';
import '../../../config/design_system/theme.dart';
import '../../../config/design_system/dimensions.dart';
import '../../../config/design_system/text_styles.dart';
import '../../../utils/formula.dart';

class BMRWidget extends StatefulWidget {
  final double? height;
  final double? weight;
  final int? age;
  final String? gender;
  final bool isMetric;
  final VoidCallback? onSettingsTap;

  const BMRWidget({
    Key? key,
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    this.isMetric = true,
    this.onSettingsTap,
  }) : super(key: key);

  @override
  State<BMRWidget> createState() => _BMRWidgetState();
}

class _BMRWidgetState extends State<BMRWidget> {
  double? _bmr;
  List<String> _missingData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _isLoading = true;
      });
      _calculateBMR();
    }
  }

  void _calculateBMR() {
    // Reset values
    _missingData = [];
    _bmr = null;
    
    // Check for missing inputs
    if (widget.weight == null) _missingData.add("Weight");
    if (widget.height == null) _missingData.add("Height");
    if (widget.age == null) _missingData.add("Age");
    if (widget.gender == null) _missingData.add("Gender");
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          // If any data is missing, we can't calculate BMR
          if (_missingData.isNotEmpty) {
            _isLoading = false;
            return;
          }

          // Calculate BMR using the Formula utility class
          _bmr = Formula.calculateBMR(
            weight: widget.weight,
            height: widget.height,
            age: widget.age,
            gender: widget.gender,
          );
          
          _isLoading = false;
        });
      }
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
            Text(
              'About BMR',
              style: AppTextStyles.getSubHeadingStyle().copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryBlue,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BMR Definition
              Text(
                'Your Basal Metabolic Rate (BMR) is the number of calories your body needs to perform basic, life-sustaining functions while at rest. This includes breathing, circulation, cell production, and nutrient processing.',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 14, 
                  height: 1.4,
                ),
              ),
              SizedBox(height: Dimensions.m),
              
              // Current BMR Value
              if (_bmr != null)
                Container(
                  padding: EdgeInsets.all(Dimensions.s),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlueBackground,
                    borderRadius: BorderRadius.circular(Dimensions.xs),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 18,
                        color: AppTheme.primaryBlue,
                      ),
                      SizedBox(width: Dimensions.xs),
                      Text(
                        'Your BMR: ${_bmr?.round() ?? 0} calories',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: Dimensions.m),
              
              // Daily Calories Information
              Text(
                'Your actual daily calorie needs are higher than your BMR since you are not always at rest. Your Total Daily Energy Expenditure (TDEE) accounts for your activity level on top of your BMR.',
                style: AppTextStyles.getBodyStyle().copyWith(
                  fontSize: 14, 
                  height: 1.4,
                ),
              ),
              SizedBox(height: Dimensions.m),
              
              // Formula Section
              Text(
                'The Mifflin-St Jeor Equation:',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: Dimensions.xs),
              Container(
                padding: EdgeInsets.all(Dimensions.s),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(Dimensions.xs),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'For men:',
                      style: AppTextStyles.getBodyStyle().copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'BMR = (10 × weight) + (6.25 × height) - (5 × age) + 5',
                      style: AppTextStyles.getBodyStyle(),
                    ),
                    SizedBox(height: Dimensions.s),
                    Text(
                      'For women:',
                      style: AppTextStyles.getBodyStyle().copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'BMR = (10 × weight) + (6.25 × height) - (5 × age) - 161',
                      style: AppTextStyles.getBodyStyle(),
                    ),
                  ],
                ),
              ),
              SizedBox(height: Dimensions.m),
              
              // Weight Management Guidelines
              Text(
                'Using BMR for weight management:',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: Dimensions.xs),
              _buildBulletPoint('To lose weight: Consume fewer calories than your TDEE'),
              SizedBox(height: Dimensions.xxs),
              _buildBulletPoint('To maintain weight: Consume equal calories to your TDEE'),
              SizedBox(height: Dimensions.xxs),
              _buildBulletPoint('To gain weight: Consume more calories than your TDEE'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primaryBlue,
            ),
            child: Text(
              'CLOSE',
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '• ',
          style: AppTextStyles.getBodyStyle().copyWith(
            color: AppTheme.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
          // Header with info button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Basal Metabolic Rate',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              IconButton(
                icon: Icon(Icons.info_outline, size: 18),
                onPressed: _showBMRInfoDialog,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: Colors.grey[600],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Content based on state
          if (_isLoading)
            // Loading state
            const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else if (_missingData.isNotEmpty)
            // Error state - missing data
            Column(
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
                  'Please update: ${_missingData.join(", ")}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: widget.onSettingsTap ?? () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                  child: Text('Update Profile'),
                ),
              ],
            )
          else
            // Normal state with BMR value
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // BMR Value
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${_bmr?.round() ?? 0}',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'cal',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primaryBlue.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Explanation badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlueBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.getBorderFor(AppTheme.primaryBlue),
                        width: 1,
                      ),
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
                        Text(
                          'Calories needed at complete rest',
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
            ),
        ],
      ),
    );
  }
}