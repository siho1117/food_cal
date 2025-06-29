// lib/widgets/home/macronutrient_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class MacronutrientWidget extends StatefulWidget {
  const MacronutrientWidget({super.key});

  @override
  State<MacronutrientWidget> createState() => _MacronutrientWidgetState();
}

class _MacronutrientWidgetState extends State<MacronutrientWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller for progress animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    
    // Initialize the animation properly
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        // Get data from provider
        final consumedMacros = homeProvider.consumedMacros;
        final targetMacros = homeProvider.targetMacros;
        final progressPercentages = homeProvider.macroProgressPercentages;

        return Container(
          padding: const EdgeInsets.all(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Macronutrients',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Macronutrient rows
              _buildMacroRow(
                'Protein',
                consumedMacros['protein']!,
                targetMacros['protein']!.toDouble(),
                progressPercentages['protein']!,
                Colors.red[400]!,
              ),
              
              const SizedBox(height: 16),
              
              _buildMacroRow(
                'Carbs',
                consumedMacros['carbs']!,
                targetMacros['carbs']!.toDouble(),
                progressPercentages['carbs']!,
                Colors.blue[400]!,
              ),
              
              const SizedBox(height: 16),
              
              _buildMacroRow(
                'Fat',
                consumedMacros['fat']!,
                targetMacros['fat']!.toDouble(),
                progressPercentages['fat']!,
                Colors.orange[400]!,
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildMacroRow(
    String name,
    double consumed,
    double target,
    double progressPercentage,
    Color color,
  ) {
    return Column(
      children: [
        // Macro name and values
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: AppTextStyles.getBodyStyle().copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${consumed.toInt()}g / ${target.toInt()}g',
              style: AppTextStyles.getBodyStyle().copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Progress bar
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Stack(
              children: [
                // Background bar
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Progress bar
                FractionallySizedBox(
                  widthFactor: (progressPercentage / 100 * _progressAnimation.value).clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}