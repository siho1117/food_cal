// lib/screens/exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/exercise_provider.dart';
import '../widgets/exercise/daily_burn_widget.dart';
import '../widgets/exercise/exercise_log_widget.dart';

class ExerciseScreen extends StatefulWidget {
  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const ExerciseScreen({super.key});

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
                      
                      // Daily Burn Recommendations Widget
                      DailyBurnWidget(
                        userProfile: exerciseProvider.userProfile,
                        currentWeight: exerciseProvider.currentWeight,
                      ),

                      const SizedBox(height: 20),

                      // Exercise Log Widget
                      const ExerciseLogWidget(
                        showHeader: false, // Header is already shown above
                      ),
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

  /// Build error state with retry button
  Widget _buildErrorState(BuildContext context, ExerciseProvider exerciseProvider) {
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
                // ✅ FIXED: Use withValues instead of deprecated withOpacity
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
              exerciseProvider.errorMessage ?? 'Unknown error occurred',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => exerciseProvider.refreshData(),
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