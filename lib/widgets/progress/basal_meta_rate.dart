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
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _progressAnimation;
  
  bool _isLoading = true;
  double? _bmr;
  List<String> _missingData = [];
  
  @override
  void initState() {
    super.initState();
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );
    
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Calculate initial values
    _calculateBMR();
    
    // Start animations
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
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeInAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildContentWidget(),
          ),
        );
      },
    );
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
      padding: const EdgeInsets.all(16),
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
          // Header with icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
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

          const SizedBox(height: 20),

          // Missing data message
          Container(
            padding: const EdgeInsets.all(12),
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
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed('/settings');
                  },
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('Update Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          // Header with icon and title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppTheme.primaryBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
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

          const SizedBox(height: 20),

          // BMR Value display with visual indicator
          Row(
            children: [
              // Left side: animated circular indicator
              _buildCircularIndicator(),
              
              const SizedBox(width: 20),
              
              // Right side: BMR value and description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BMR value with animation
                    AnimatedBuilder(
                      animation: _progressAnimation,
                      builder: (context, child) {
                        final displayedValue = (_bmr! * _progressAnimation.value).round();
                        return Text(
                          '$displayedValue',
                          style: AppTextStyles.getNumericStyle().copyWith(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryBlue,
                          ),
                        );
                      },
                    ),
                    const Text(
                      'calories/day',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // BMR formula indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _getFormulaText(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // BMR description at the bottom
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.goldAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'BMR is the calories your body burns at complete rest without any activity. It\'s the energy needed for basic functions like breathing, circulation, and cell production.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCircularIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey[100]!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryBlue.withOpacity(0.2),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AnimatedBuilder(
        animation: _progressAnimation,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Circular progress indicator
              SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: _progressAnimation.value,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                ),
              ),
              
              // Fire icon in the center
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.bolt,
                    color: AppTheme.primaryBlue,
                    size: 28,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  // Get appropriate formula text based on the user's gender
  Widget _getFormulaText() {
    final gender = widget.userProfile?.gender ?? 'Unknown';
    
    // Define the formula text based on gender
    String formulaText;
    if (gender == 'Male') {
      formulaText = 'Mifflin-St Jeor (Male)';
    } else if (gender == 'Female') {
      formulaText = 'Mifflin-St Jeor (Female)';
    } else {
      formulaText = 'Mifflin-St Jeor (Average)';
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.science_outlined,
          color: AppTheme.primaryBlue.withOpacity(0.7),
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          formulaText,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue.withOpacity(0.9),
          ),
        ),
      ],
    );
  }
}