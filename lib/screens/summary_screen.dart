// lib/screens/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/home_provider.dart';
import '../providers/exercise_provider.dart';
import '../widgets/summary/summary_controls_widget.dart';
import '../widgets/summary/summary_content_widget.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _currentPeriod = SummaryPeriod.daily;
  bool _isExporting = false;
  final GlobalKey _summaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // ✅ FIXED: No MultiProvider here - use existing app-level providers!
    return Scaffold(
      backgroundColor: AppTheme.secondaryBeige,
      body: SafeArea(
        child: Consumer2<HomeProvider, ExerciseProvider>(
          builder: (context, homeProvider, exerciseProvider, child) {
            // Handle loading states
            if (homeProvider.isLoading || exerciseProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryBlue,
                ),
              );
            }

            // Handle error states
            if (homeProvider.errorMessage != null || exerciseProvider.errorMessage != null) {
              return _buildErrorState(context, homeProvider, exerciseProvider);
            }

            return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    
                    // Period Switcher + Export Controls
                    SummaryControlsWidget(
                      currentPeriod: _currentPeriod,
                      onPeriodChanged: (period) {
                        setState(() {
                          _currentPeriod = period;
                        });
                      },
                      onExport: _handleExport,
                      isExporting: _isExporting,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Main Summary Content (Wrapped for Export)
                    RepaintBoundary(
                      key: _summaryKey,
                      child: Container(
                        color: AppTheme.secondaryBeige,
                        child: SummaryContentWidget(
                          period: _currentPeriod,  // ✅ FIXED: Only pass period parameter
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80), // Extra space for bottom nav
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build error state with retry functionality
  Widget _buildErrorState(BuildContext context, HomeProvider homeProvider, ExerciseProvider exerciseProvider) {
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
          const Text(
            'Error Loading Summary Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeProvider.errorMessage ?? exerciseProvider.errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // ✅ FIXED: Use correct method names that exist on the providers
              homeProvider.refreshData();
              exerciseProvider.refreshData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              // Just refresh data to try to clear the error state
              homeProvider.refreshData();
              exerciseProvider.refreshData();
            },
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  /// Handle export functionality
  Future<void> _handleExport() async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      // Simple export simulation - replace with your actual export logic
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary exported successfully! 📸'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }
}