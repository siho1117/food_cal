// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_data.dart';
import '../widgets/progress/combined_weight_widget.dart';
import '../widgets/progress/combined_bmi_bodyfat_widget.dart'; // NEW: Combined widget
import '../widgets/progress/weight_history_graph_widget.dart';
import '../widgets/progress/energy_metrics_widget.dart';
import '../config/design_system/theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProgressData()..loadUserData(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        body: SafeArea(
          child: Consumer<ProgressData>(
            builder: (context, progressData, child) {
              // Show loading state
              if (progressData.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              // Show error state if needed
              if (progressData.errorMessage != null) {
                return _buildErrorState(context, progressData);
              }
              
              // Show main content with RefreshIndicator for pull-to-refresh
              return RefreshIndicator(
                onRefresh: () => progressData.refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: _buildProgressContent(context, progressData),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, ProgressData progressData) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            progressData.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => progressData.refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildProgressContent(BuildContext context, ProgressData progressData) {
    return Column(
      children: [
        // Combined Weight Widget (with segmented progress)
        CombinedWeightWidget(
          currentWeight: progressData.currentWeight,
          isMetric: progressData.isMetric,
          onWeightEntered: progressData.addWeightEntry,
        ),
        
        const SizedBox(height: 16),
        
        // UPDATED: Combined BMI & Body Fat Widget (replaces separate widgets)
        CombinedBMIBodyFatWidget(
          bmiValue: progressData.bmiValue,
          bmiClassification: progressData.bmiClassification,
          bodyFatPercentage: progressData.bodyFatValue,
          bodyFatClassification: progressData.bodyFatClassification,
          isEstimated: true, // Body fat is estimated from BMI
        ),
        
        const SizedBox(height: 16),
        
        // Energy Metrics Widget
        EnergyMetricsWidget(
          userProfile: progressData.userProfile,
          currentWeight: progressData.currentWeight,
          onSettingsTap: () => Navigator.of(context).pushNamed('/settings'),
        ),
        
        const SizedBox(height: 16),
        
        // Weight History Graph
        WeightHistoryGraphWidget(
          weightHistory: progressData.weightHistory,
          isMetric: progressData.isMetric,
        ),
      ],
    );
  }
}