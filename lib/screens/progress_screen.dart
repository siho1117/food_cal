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
  const ProgressScreen({super.key});  // ✅ FIXED: Use super parameter

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: Use existing provider from app level instead of manual management
    return Scaffold(
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
            
            // Show error state
            if (progressData.errorMessage != null) {
              return _buildErrorState(context, progressData);
            }
            
            return RefreshIndicator(
              onRefresh: () => progressData.refreshData(),  // ✅ FIXED: Use correct method name
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    const Text(
                      'PROGRESS TRACKER',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlue,
                        letterSpacing: 1.5,
                      ),
                    ),
                    
                    const SizedBox(height: 30),
                    
                    // Weight Input Widget
                    CombinedWeightWidget(
                      currentWeight: progressData.currentWeight,
                      isMetric: progressData.isMetric,
                      onWeightEntered: progressData.addWeightEntry,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // BMI and Body Fat Widget
                    CombinedBMIBodyFatWidget(
                      bmiValue: progressData.bmiValue,
                      bmiClassification: progressData.bmiClassification,
                      bodyFatPercentage: progressData.bodyFatValue,
                      bodyFatClassification: progressData.bodyFatClassification,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Weight History Graph
                    WeightHistoryGraphWidget(
                      weightHistory: progressData.weightHistory,
                      isMetric: progressData.isMetric,
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Energy Metrics
                    EnergyMetricsWidget(
                      userProfile: progressData.userProfile,
                      currentWeight: progressData.currentWeight,
                    ),
                    
                    // Add some bottom padding
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build error state with retry button
  Widget _buildErrorState(BuildContext context, ProgressData progressData) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Oops! Something went wrong',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              progressData.errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => progressData.refreshData(),  // ✅ FIXED: Use correct method name
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}