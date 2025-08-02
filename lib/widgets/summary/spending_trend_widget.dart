// lib/widgets/summary/spending_trend_widget.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class SpendingTrendWidget extends StatelessWidget {
  const SpendingTrendWidget({super.key});

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
              const Text('📊 Weekly Spending Trend', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayBar('M', 15.50),
                  _buildDayBar('T', 22.30),
                  _buildDayBar('W', 18.75),
                  _buildDayBar('T', 25.00),
                  _buildDayBar('F', 30.20),
                  _buildDayBar('S', 12.40),
                  _buildDayBar('S', 16.80),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDayBar(String day, double amount) {
    return Column(
      children: [
        Container(
          width: 20,
          height: (amount * 2).clamp(10, 60),
          decoration: BoxDecoration(
            color: Colors.blue[300],
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(day, style: const TextStyle(fontSize: 12)),
        Text('\$${amount.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}