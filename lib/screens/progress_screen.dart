import 'package:flutter/material.dart';
import '../config/design_system/theme.dart';
import '../widgets/progress/bmi_widget.dart';
import '../widgets/progress/body_fat_percentage_widget.dart';
import '../widgets/progress/weight_entry_widget.dart';
import '../widgets/progress/weight_history_graph_widget.dart';
import '../data/models/weight_data.dart';
import '../data/models/user_profile.dart';
import 'progress_widgets.dart'; // Import for the ProgressDataProvider

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // This will be handled by the refreshData function from ProgressDataProvider
            await Future.delayed(const Duration(milliseconds: 300));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: ProgressDataProvider(
              builder: ({
                required UserProfile? userProfile,
                required double? currentWeight,
                required bool isMetric,
                required List<WeightData> weightHistory,
                required double? bmiValue,
                required String bmiClassification,
                required double? bodyFatValue,
                required String bodyFatClassification,
                required bool isLoading,
                required String? errorMessage,
                required Function(double, bool) onWeightEntered,
                required Function() refreshData,
              }) {
                // Handle loading state
                if (isLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                
                // Handle error state
                if (errorMessage != null) {
                  return _buildErrorState(errorMessage, refreshData);
                }
                
                // Define the actual layout here
                return _buildProgressLayout(
                  context: context,
                  userProfile: userProfile,
                  currentWeight: currentWeight,
                  isMetric: isMetric,
                  weightHistory: weightHistory,
                  bmiValue: bmiValue,
                  bmiClassification: bmiClassification,
                  bodyFatValue: bodyFatValue,
                  bodyFatClassification: bodyFatClassification,
                  onWeightEntered: onWeightEntered,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  // Error state widget
  Widget _buildErrorState(String errorMessage, Function() refreshData) {
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
            errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
  
  // Main layout builder
  Widget _buildProgressLayout({
    required BuildContext context,
    required UserProfile? userProfile,
    required double? currentWeight,
    required bool isMetric,
    required List<WeightData> weightHistory,
    required double? bmiValue,
    required String bmiClassification,
    required double? bodyFatValue,
    required String bodyFatClassification,
    required Function(double, bool) onWeightEntered,
  }) {
    // Here you can change the layout and order of widgets
    // Any changes to positions or arrangement would be made here
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
        
        // Example of a different layout - Putting BMI and Body Fat side by side
        // Note: You can experiment with different layouts as needed
        Row(
          children: [
            // BMI Widget - Half width
            Expanded(
              child: BMIWidget(
                bmiValue: bmiValue,
                classification: bmiClassification,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Body Fat Percentage Widget - Half width
            Expanded(
              child: BodyFatPercentageWidget(
                bodyFatPercentage: bodyFatValue,
                classification: bodyFatClassification,
                isEstimated: true,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Weight Entry Widget - Full width
        WeightEntryWidget(
          currentWeight: currentWeight,
          isMetric: isMetric,
          onWeightEntered: onWeightEntered,
        ),
        
        const SizedBox(height: 30),
        
        // History section header
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
          weightHistory: weightHistory,
          isMetric: isMetric,
        ),
        
        // Additional space at the bottom for bottom nav bar
        const SizedBox(height: 80),
      ],
    );
  }
}