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

class _MacronutrientWidgetState extends State<MacronutrientWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  // Track previous values for refresh detection
  String? _previousDataHash;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller first
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Then create animation
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    
    // Start animation after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _checkForRefresh(Map<String, double> consumed, Map<String, int> target) {
    final currentHash = '${consumed.values.join(',')}_${target.values.join(',')}';
    if (_previousDataHash != null && _previousDataHash != currentHash && mounted) {
      _controller.reset();
      _controller.forward();
    }
    _previousDataHash = currentHash;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        final consumed = homeProvider.consumedMacros;
        final target = homeProvider.targetMacros;
        final progress = homeProvider.macroProgressPercentages;

        _checkForRefresh(consumed, target);

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Opacity(
                  opacity: _animation.value,
                  child: Row(
                    children: [
                      const Text('💪', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Text(
                        'Macronutrients',
                        style: AppTextStyles.getSubHeadingStyle().copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Macro rows
                ..._buildMacroRows(consumed, target, progress),

                const SizedBox(height: 20),

                // Balance summary
                _buildBalanceSummary(consumed),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildMacroRows(Map<String, double> consumed, Map<String, int> target, Map<String, double> progress) {
    final macros = [
      {'key': 'protein', 'symbol': '🥩', 'name': 'Protein', 'color': Colors.red[500]!},
      {'key': 'carbs', 'symbol': '🍞', 'name': 'Carbs', 'color': Colors.blue[500]!},
      {'key': 'fat', 'symbol': '🥑', 'name': 'Fat', 'color': Colors.orange[500]!},
    ];

    return macros.asMap().entries.map((entry) {
      final index = entry.key;
      final macro = entry.value;
      final key = macro['key'] as String;
      final delay = index * 0.2; // Stagger animation

      return Padding(
        padding: EdgeInsets.only(bottom: index < 2 ? 20 : 0),
        child: Opacity(
          opacity: (_animation.value - delay).clamp(0.0, 1.0),
          child: _buildMacroRow(
            symbol: macro['symbol'] as String,
            name: macro['name'] as String,
            consumed: consumed[key]! * _animation.value,
            target: target[key]!.toDouble() * _animation.value,
            progress: progress[key]! * _animation.value,
            color: macro['color'] as Color,
          ),
        ),
      );
    }).toList();
  }

  Widget _buildMacroRow({
    required String symbol,
    required String name,
    required double consumed,
    required double target,
    required double progress,
    required Color color,
  }) {
    return Column(
      children: [
        // Main row
        Row(
          children: [
            Text(symbol, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: AppTextStyles.getBodyStyle().copyWith(fontWeight: FontWeight.w600, fontSize: 16))),
            Text('${consumed.round()}g / ${target.round()}g', style: AppTextStyles.getNumericStyle().copyWith(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(width: 12),
            Text('${progress.round()}%', style: AppTextStyles.getNumericStyle().copyWith(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Dot progress
        Row(
          children: [
            const SizedBox(width: 30),
            Expanded(child: _buildDotProgress(progress / 100, color)),
            const SizedBox(width: 50),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // Message
        Row(
          children: [
            const SizedBox(width: 30),
            Expanded(
              child: Text(
                _getMessage(progress),
                style: AppTextStyles.getBodyStyle().copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: color, fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDotProgress(double progress, Color color) {
    const dots = 8;
    final filled = (progress * dots).round().clamp(0, dots);
    
    return Row(
      children: List.generate(dots, (i) => Padding(
        padding: const EdgeInsets.only(right: 4),
        child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: i < filled ? color : Colors.grey[300],
            shape: BoxShape.circle,
          ),
        ),
      )),
    );
  }

  Widget _buildBalanceSummary(Map<String, double> consumed) {
    final totalCals = consumed['protein']! * 4 + consumed['carbs']! * 4 + consumed['fat']! * 9;
    if (totalCals == 0) return const SizedBox.shrink();

    final percentages = {
      'protein': ((consumed['protein']! * 4) / totalCals * 100).round(),
      'carbs': ((consumed['carbs']! * 4) / totalCals * 100).round(),
      'fat': ((consumed['fat']! * 9) / totalCals * 100).round(),
    };

    return Opacity(
      opacity: _animation.value,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('📊', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text('Macro Balance', style: AppTextStyles.getSubHeadingStyle().copyWith(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              children: [
                _buildBalanceItem('🥩 Protein', '${percentages['protein']}%', Colors.red[500]!),
                _buildBalanceItem('🍞 Carbs', '${percentages['carbs']}%', Colors.blue[500]!),
                _buildBalanceItem('🥑 Fat', '${percentages['fat']}%', Colors.orange[500]!),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, String percentage, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.getBodyStyle().copyWith(fontSize: 12, fontWeight: FontWeight.w500, color: color)),
        const SizedBox(width: 4),
        Text(percentage, style: AppTextStyles.getNumericStyle().copyWith(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  String _getMessage(double percentage) {
    if (percentage >= 100) return '🎯 Mission complete!';
    if (percentage >= 80) return '⭐ Almost there!';
    if (percentage >= 60) return '💪 Keep it up!';
    if (percentage >= 40) return '🚀 Good progress!';
    if (percentage >= 20) return '📈 Getting started!';
    return '🍽️ Time to fuel up!';
  }
}