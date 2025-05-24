// lib/screens/exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise/daily_burn_widget.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({Key? key}) : super(key: key);

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  @override
  Widget build(BuildContext context) {
    // Provide the ExerciseProvider to the widget tree
    return ChangeNotifierProvider(
      create: (_) => ExerciseProvider()..loadData(),
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        body: SafeArea(
          child: Consumer<ExerciseProvider>(
            builder: (context, exerciseProvider, child) {
              // Show loading state
              if (exerciseProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              
              // Show error state if needed
              if (exerciseProvider.errorMessage != null) {
                return _buildErrorState(context, exerciseProvider);
              }
              
              // Show main content with RefreshIndicator for pull-to-refresh
              return RefreshIndicator(
                onRefresh: () => exerciseProvider.refreshData(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      const Text(
                        'EXERCISE TRACKER',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryBlue,
                          letterSpacing: 1.5,
                        ),
                      ),

                      const SizedBox(height: 30),
                      
                      // Daily Burn Recommendations Widget (your existing widget)
                      DailyBurnWidget(
                        userProfile: exerciseProvider.userProfile,
                        currentWeight: exerciseProvider.currentWeight,
                      ),

                      const SizedBox(height: 20),

                      // Date selector for looking at different days
                      _buildDateNavigation(exerciseProvider),

                      const SizedBox(height: 80), // Space for bottom nav
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
  
  Widget _buildErrorState(BuildContext context, ExerciseProvider exerciseProvider) {
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
            exerciseProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => exerciseProvider.refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateNavigation(ExerciseProvider exerciseProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Date navigation header
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppTheme.primaryBlue,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'VIEW DIFFERENT DAY',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Date navigation controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: () => exerciseProvider.previousDay(),
                color: AppTheme.primaryBlue,
              ),
              TextButton(
                onPressed: () => _showDatePicker(context, exerciseProvider),
                child: Text(
                  exerciseProvider.isToday
                      ? 'Today'
                      : '${exerciseProvider.selectedDate.day}/${exerciseProvider.selectedDate.month}/${exerciseProvider.selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios),
                onPressed: exerciseProvider.canGoToNextDay 
                    ? () => exerciseProvider.nextDay()
                    : null,
                color: AppTheme.primaryBlue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper method to show date picker
  Future<void> _showDatePicker(BuildContext context, ExerciseProvider exerciseProvider) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: exerciseProvider.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != exerciseProvider.selectedDate) {
      exerciseProvider.changeDate(picked);
    }
  }
}