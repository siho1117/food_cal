import 'package:flutter/material.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/animations/animation_helpers.dart';
import '../../config/widgets/master_widget.dart';
import '../../config/components/state_builder.dart';
import '../../config/components/value_builder.dart';
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
    // If loading, return the loading state widget
    if (_isLoading) {
      return MasterWidget(
        title: 'Basal Metabolic Rate',
        icon: Icons.bolt_rounded,
        isLoading: true,
        child: const SizedBox(),
      );
    }
    
    // If missing data, show error state
    if (_missingData.isNotEmpty) {
      return MasterWidget(
        title: 'Basal Metabolic Rate',
        icon: Icons.bolt_rounded,
        subtitle: 'Calories burned at complete rest',
        child: StateBuilder.warning(
          title: 'Missing profile data',
          message: 'To calculate your BMR, please update your profile with: ${_missingData.join(", ")}',
          actionLabel: 'Update Profile',
          onAction: () {
            Navigator.of(context).pushNamed('/settings');
          },
        ),
      );
    }
    
    // Main content when we have data
    return MasterWidget(
      title: 'Basal Metabolic Rate',
      icon: Icons.bolt_rounded,
      subtitle: 'Calories burned at complete rest',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main BMR value display
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Row(
              children: [
                // BMR Value
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animated BMR value
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          AnimationHelpers.buildAnimatedCounter(
                            animation: _progressAnimation,
                            targetValue: _bmr!,
                            style: AppTextStyles.getNumericStyle().copyWith(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryBlue,
                            ),
                            decimalPlaces: 0,
                          ),
                          Text(
                            ' cal',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.primaryBlue.withAlpha((0.7 * 255).toInt()),
                            ),
                          ),
                        ],
                      ),
                      
                      // Description
                      Text(
                        'per day',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Info button
                GestureDetector(
                  onTap: _showBMRInfoDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlue.withAlpha((0.1 * 255).toInt()),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.info_outline,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Formula badge
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ValueBuilder.buildBadge(
              text: _getFormulaText(),
              color: AppTheme.primaryBlue,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // BMR Scale Visualization
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'YOUR BMR COMPARED TO AVERAGE',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                        letterSpacing: 1.0,
                      ),
                    ),
                    GestureDetector(
                      onTap: _showBMRInfoDialog,
                      child: Text(
                        'What does this mean?',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryBlue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // BMR Scale
                _buildImprovedBMRScale(),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Description box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StateBuilder.infoMessage(
              title: 'What is BMR?',
              message: 'BMR is the minimum calories your body burns at complete rest. It\'s the energy needed for basic functions like breathing, circulation, and cell production.',
              icon: Icons.lightbulb_outline,
              color: AppTheme.goldAccent,
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  
  Widget _buildImprovedBMRScale() {
    // Determine position based on gender and BMR
    double relativePosition = 0.5; // Default center position
    String categoryText = "Average";
    Color categoryColor = Colors.grey;
    
    if (_bmr != null) {
      if (widget.userProfile?.gender == 'Male') {
        // For males
        if (_bmr! < 1400) {
          relativePosition = 0.15;
          categoryText = "Low";
          categoryColor = AppTheme.goldAccent;
        } else if (_bmr! < 1600) {
          relativePosition = 0.3;
          categoryText = "Below Average";
          categoryColor = AppTheme.goldAccent.withAlpha((0.8 * 255).toInt());
        } else if (_bmr! < 1800) {
          relativePosition = 0.45;
          categoryText = "Average";
          categoryColor = AppTheme.primaryBlue;
        } else if (_bmr! < 2000) {
          relativePosition = 0.65;
          categoryText = "Above Average";
          categoryColor = AppTheme.primaryBlue.withAlpha((0.8 * 255).toInt());
        } else {
          relativePosition = 0.85;
          categoryText = "High";
          categoryColor = AppTheme.accentColor;
        }
      } else {
        // For females
        if (_bmr! < 1200) {
          relativePosition = 0.15;
          categoryText = "Low";
          categoryColor = AppTheme.goldAccent;
        } else if (_bmr! < 1350) {
          relativePosition = 0.3;
          categoryText = "Below Average";
          categoryColor = AppTheme.goldAccent.withAlpha((0.8 * 255).toInt());
        } else if (_bmr! < 1500) {
          relativePosition = 0.45;
          categoryText = "Average";
          categoryColor = AppTheme.primaryBlue;
        } else if (_bmr! < 1650) {
          relativePosition = 0.65;
          categoryText = "Above Average";
          categoryColor = AppTheme.primaryBlue.withAlpha((0.8 * 255).toInt());
        } else {
          relativePosition = 0.85;
          categoryText = "High";
          categoryColor = AppTheme.accentColor;
        }
      }
    }
    
    return Column(
      children: [
        // The scale visualization with gradient bar
        Container(
          width: double.infinity,
          height: 12,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            gradient: LinearGradient(
              colors: [
                AppTheme.goldAccent,        // Low
                AppTheme.goldAccent.withAlpha((0.8 * 255).toInt()), // Below Average
                AppTheme.primaryBlue,       // Average
                AppTheme.primaryBlue.withAlpha((0.8 * 255).toInt()), // Above Average
                AppTheme.accentColor,       // High
              ],
              stops: const [0.1, 0.3, 0.5, 0.7, 0.9],
            ),
          ),
        ),
        
        const SizedBox(height: 2),
        
        // Position indicator - FIXED: Prevent negative margins
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            // Calculate the position and ensure it's not causing a negative margin
            double leftPosition = MediaQuery.of(context).size.width * 
                relativePosition * _progressAnimation.value;
            
            // Ensure leftPosition is at least 50 to prevent negative margins
            leftPosition = leftPosition < 50 ? 50 : leftPosition;
            
            return Container(
              margin: EdgeInsets.only(left: leftPosition - 50),
              child: Column(
                children: [
                  Icon(
                    Icons.arrow_drop_up,
                    color: categoryColor,
                    size: 28,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10, 
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: categoryColor.withAlpha((0.8 * 255).toInt()),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Your BMR: ${_bmr!.round()}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, 
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.3 * 255).toInt()),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            categoryText,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        
        const SizedBox(height: 4),
        
        // Scale labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Low',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.goldAccent,
                ),
              ),
              Text(
                'Average',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              Text(
                'High',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentColor,
                ),
              ),
            ],
          ),
        ),
      ],
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