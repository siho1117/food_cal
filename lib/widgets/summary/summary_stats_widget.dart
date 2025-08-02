// lib/widgets/summary/summary_stats_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class SummaryStatsWidget extends StatelessWidget {
  const SummaryStatsWidget({super.key});

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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('${homeProvider.mealsCount}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Meals'),
                ],
              ),
              Column(
                children: [
                  Text('${(homeProvider.budgetProgress * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Budget Used'),
                ],
              ),
              Column(
                children: [
                  Text('${(homeProvider.calorieProgress * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Text('Calorie Goal'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}