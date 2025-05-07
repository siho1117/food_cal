// lib/widgets/progress/basal_meta_rate.dart
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../data/models/user_profile.dart';
import '../../utils/formula.dart';

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

class _BasalMetabolicRateWidgetState extends State<BasalMetabolicRateWidget>
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  
  bool _isLoading = true;
  double? _bmr;
  List<String> _missingData = [];
  
  @override
  void initState() {
    super.initState();
    
    // Setup animation
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
    
    // Calculate initial values
    _calculateBMR();
    
    // Start animation
    _animationController.forward();
  }
  
  @override
  void didUpdateWidget(BasalMetabolicRateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userProfile != widget.userProfile || 
        oldWidget.currentWeight != widget.currentWeight) {
      _calculateBMR();
      // Reset and restart animation for updated values
      _animationController.reset();
      _animationController.forward();
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Calculate BMR and check for missing data
  void _calculateBMR() {
    setState(() {
      _isLoading = true;
    });

    // Calculate BMR using Formula utility
    _bmr = Formula.calculateBMR(
      weight: widget.currentWeight,
      height: widget.userProfile?.height,
      age: widget.userProfile?.age,
      gender: widget.userProfile?.gender,
    );

    // Check which data is missing for BMR calculation
    _missingData = [];
    if (widget.userProfile == null) {
      _missingData.add("Profile");
    } else {
      if (widget.currentWeight == null) _missingData.add("Weight");
      if (widget.userProfile!.height == null) _missingData.add("Height");
      if (widget.userProfile!.age == null) _missingData.add("Age");
      if (widget.userProfile!.gender == null) _missingData.add("Gender");
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
            const Text('BMR Calculation'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BMR (Basal Metabolic Rate) is the number of calories your body needs to maintain basic physiological functions while at rest.',
              ),
              const SizedBox(height: 16),
              const Text(
                'The Mifflin-St Jeor Equation is used to calculate BMR:',
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
                  children: const [
                    Text(
                      'For men:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + 5'),
                    SizedBox(height: 12),
                    Text(
                      'For women:',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text('BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) - 161'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'This represents the minimum energy needed to keep your body functioning, including breathing, circulation, cell production, and basic neurological functions.',
                style: TextStyle(fontStyle: FontStyle.italic),
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
    if (_isLoading) {
      return _buildLoadingState();
    }
    
    // If we have missing data, show error state
    if (_missingData.isNotEmpty) {
      return _buildErrorState();
    }
    
    // Otherwise, show the full content
    return _buildContentWidget();
  }

  Widget _buildLoadingState() {
    return Container(
      height: 180,
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
      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState() {
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
          // Header with styled background
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
                      Icons.bolt_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Basal Metabolic Rate',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showBMRInfoDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Missing data message
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Colors.orange,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Missing profile data',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'To calculate your BMR, please update your profile with: ${_missingData.join(", ")}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/settings');
                      },
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('Update Profile'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        textStyle: const TextStyle(fontSize: 14),
                      ),
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

  Widget _buildContentWidget() {
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
          // Header with styled background
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
                      Icons.bolt_rounded,
                      color: AppTheme.primaryBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Basal Metabolic Rate',
                      style: AppTextStyles.getSubHeadingStyle().copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: _showBMRInfoDialog,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // BMR Value display
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Center(
              child: Column(
                children: [
                  // Animated BMR value
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      final displayedValue = (_bmr! * _progressAnimation.value).round();
                      return Text(
                        '$displayedValue',
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      );
                    },
                  ),
                  
                  // "calories/day" label
                  Text(
                    'calories/day',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Formula badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.science_outlined,
                          color: AppTheme.primaryBlue.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getFormulaText(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Visual representation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _buildBMRVisualizer(),
          ),
          
          // BMR description
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryBlue.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.goldAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'BMR is the calories your body burns at complete rest. It\'s the energy needed for basic functions like breathing, circulation, and cell production.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[800],
                      ),
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
  
  Widget _buildBMRVisualizer() {
    // Factor calculation based on gender and rough average BMR expectations
    double factor = 1.0;
    
    if (_bmr != null) {
      if (widget.userProfile?.gender == 'Male') {
        // For males, compare to rough average of 1800
        factor = (_bmr! / 1800).clamp(0.5, 1.5);
      } else {
        // For females, compare to rough average of 1500
        factor = (_bmr! / 1500).clamp(0.5, 1.5);
      }
    }
    
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // BMR bar
              Positioned(
                left: 0,
                top: 10,
                bottom: 10,
                child: Container(
                  width: (MediaQuery.of(context).size.width - 64) * 
                      factor * _progressAnimation.value,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryBlue.withOpacity(0.7),
                        AppTheme.primaryBlue,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
              
              // Baseline marker (represents an average value)
              Positioned(
                left: (MediaQuery.of(context).size.width - 64) * 0.5,
                top: 0,
                bottom: 0,
                child: Container(
                  width: 2,
                  color: Colors.white,
                ),
              ),
              
              // Low, Average, High labels
              Positioned(
                left: 8,
                bottom: 2,
                child: Text(
                  'Low',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              Positioned(
                left: (MediaQuery.of(context).size.width - 64) * 0.5 - 16,
                bottom: 2,
                child: Text(
                  'Average',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              Positioned(
                right: 8,
                bottom: 2,
                child: Text(
                  'High',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              
              // BMR Value pin
              Positioned(
                left: ((MediaQuery.of(context).size.width - 64) * 
                    factor * _progressAnimation.value) - 12,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'BMR',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  String _getFormulaText() {
    final gender = widget.userProfile?.gender ?? 'Unknown';
    
    // Define the formula text based on gender
    if (gender == 'Male') {
      return 'Mifflin-St Jeor (Male)';
    } else if (gender == 'Female') {
      return 'Mifflin-St Jeor (Female)';
    } else {
      return 'Mifflin-St Jeor (Average)';
    }
  }
}