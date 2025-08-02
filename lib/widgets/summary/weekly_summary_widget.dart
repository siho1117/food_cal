
// lib/widgets/summary/weekly_summary_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class WeeklySummaryWidget extends StatelessWidget {
  const WeeklySummaryWidget({super.key});

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
              Text('💹 \$${homeProvider.weeklyFoodCost.toStringAsFixed(2)} spent this week'),
              const SizedBox(height: 8),
              Text('🎯 ${homeProvider.budgetProgress > 1 ? "Over" : "Under"} budget this week'),
              const SizedBox(height: 8),
              Text('📈 Weekly average: \$${(homeProvider.weeklyFoodCost / 7).toStringAsFixed(2)}/day'),
            ],
          ),
        );
      },
    );
  }
}
