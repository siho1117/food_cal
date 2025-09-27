// lib/screens/progress_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/progress_data.dart';
import '../widgets/progress/combined_weight_widget.dart';
import '../widgets/progress/combined_bmi_bodyfat_widget.dart';
import '../widgets/progress/weight_history_graph_widget.dart';
import '../widgets/progress/energy_metrics_widget.dart';
import '../config/design_system/theme.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  // FIXED: Create the provider once and manage its lifecycle properly
  late ProgressData _progressData;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    // FIXED: Create provider once in initState
    _progressData = ProgressData();
    _initializeData();
  }

  @override
  void dispose() {
    // FIXED: Properly dispose of the provider
    _progressData.dispose();
    super.dispose();
  }

  // FIXED: Load data only once during initialization
  Future<void> _initializeData() async {
    if (!_isInitialized) {
      await _progressData.loadUserData();
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // FIXED: Use existing provider instead of creating new one
    return ChangeNotifierProvider<ProgressData>.value(
      value: _progressData,
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
        
        // Combined BMI & Body Fat Widget
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