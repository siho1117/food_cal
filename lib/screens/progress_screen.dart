// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/progress/progress_data.dart';
import '../widgets/progress/bmi_widget.dart';
import '../widgets/progress/body_fat_percentage_widget.dart';
import '../widgets/progress/weight_entry_widget.dart';
import '../widgets/progress/weight_history_graph_widget.dart';
import '../widgets/progress/energy_metrics_widget.dart';
import '../widgets/progress/target_weight_widget.dart'; // New import
import '../config/design_system/theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    // Provide the ProgressData to the widget tree
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current stats section
        Text(
          'CURRENT STATS',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Weight Entry Widget
        WeightEntryWidget(
          currentWeight: progressData.currentWeight,
          isMetric: progressData.isMetric,
          onWeightEntered: progressData.addWeightEntry,
        ),
        
        const SizedBox(height: 16),
        
        // Target Weight Widget (new)
        const TargetWeightWidget(),
        
        const SizedBox(height: 16),
        
        // BMI Widget
        BMIWidget(
          bmiValue: progressData.bmiValue,
          classification: progressData.bmiClassification,
        ),
        
        const SizedBox(height: 16),
        
        // Energy Metrics Widget
        EnergyMetricsWidget(
          userProfile: progressData.userProfile,
          currentWeight: progressData.currentWeight,
          onSettingsTap: () => Navigator.of(context).pushNamed('/settings'),
        ),
        
        const SizedBox(height: 16),
        
        // Body Fat Percentage Widget
        BodyFatPercentageWidget(
          bodyFatPercentage: progressData.bodyFatValue,
          classification: progressData.bodyFatClassification,
          isEstimated: true, // Since it's calculated from BMI
        ),
        
        const SizedBox(height: 30),
        
        // History section
        Text(
          'HISTORY',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[700],
          ),
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