import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/builders/value_builder.dart';
import '../../config/layouts/card_layout.dart';
import '../../config/decorations/box_decorations.dart';
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
    
    _progressAnimation = AnimationHelpers.createProgressAnimation(
      controller: _animationController,
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

    // Calculate BMR using the same formula as in Formula.calculateBMR
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
    return CardLayout.card(
      child: Container(
        height: 180,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return CardLayout.card(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecorations.iconContainer(
                  color: AppTheme.primaryBlue,
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
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
              decoration: BoxDecorations.iconContainer(
                color: AppTheme.primaryBlue,
                opacity: 0.1,
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecorations.infoBox(
            color: Colors.orange,
            opacity: 0.1,
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
    );
  }

  Widget _buildContentWidget() {
    return CardLayout.card(
      header: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecorations.iconContainer(
                  color: AppTheme.primaryBlue,
                ),
                child: Icon(
                  Icons.bolt_rounded,
                  color: AppTheme.primaryBlue,
                  size: 20,
                ),
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
              decoration: BoxDecorations.iconContainer(
                color: AppTheme.primaryBlue,
                opacity: 0.1,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        child: Column(
          children: [
            // BMR Value display
            Center(
              child: Column(
                children: [
                  // Animated BMR value
                  AnimationHelpers.buildAnimatedCounter(
                    animation: _progressAnimation,
                    targetValue: _bmr!,
                    style: AppTextStyles.getNumericStyle().copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                    decimalPlaces: 0,
                  ),
                  
                  // "calories/day" label
                  Text(
                    'calories/day',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Formula badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecorations.badge(
                color: AppTheme.primaryBlue,
                opacity: 0.1,
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
            
            const SizedBox(height: 16),
            
            // BMR visualizer
            _buildBMRVisualizer(),
            
            const SizedBox(height: 16),
            
            // BMR description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecorations.infoBox(
                color: AppTheme.primaryBlue,
                opacity: 0.05,
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
          ],
        ),
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
          decoration: BoxDecorations.infoBox(
            color: AppTheme.primaryBlue,
            opacity: 0.05,
            borderOpacity: 0.1,
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
                child: ValueBuilder.buildBadge(
                  text: 'BMR',
                  color: AppTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
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