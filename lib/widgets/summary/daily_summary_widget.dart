// lib/widgets/summary/daily_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class DailySummaryWidget extends StatelessWidget {
  const DailySummaryWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeProvider>(
      builder: (context, homeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Text('💰 \$${homeProvider.totalFoodCost.toStringAsFixed(2)} spent today'),
              const SizedBox(height: 8),
              Text('🍽️ ${homeProvider.totalFoodItems} food items logged'),
              const SizedBox(height: 8),
              Text('📊 ${homeProvider.totalCalories} calories consumed'),
            ],
          ),
        );
      },
    );
  }
}