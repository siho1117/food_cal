// lib/screens/summary_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/design_system/theme.dart';
import '../providers/home_provider.dart';
import '../providers/exercise_provider.dart';
import '../widgets/summary/summary_controls_widget.dart';
import '../widgets/summary/summary_content_widget.dart';
import '../utils/export_helper.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({Key? key}) : super(key: key);

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _currentPeriod = SummaryPeriod.daily;
  bool _isExporting = false;
  final GlobalKey _summaryKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeProvider()..loadData()),
        ChangeNotifierProvider(create: (_) => ExerciseProvider()..loadData()),
      ],
      child: Scaffold(
        backgroundColor: AppTheme.secondaryBeige,
        body: SafeArea(
          child: Consumer2<HomeProvider, ExerciseProvider>(
            builder: (context, homeProvider, exerciseProvider, child) {
              if (homeProvider.isLoading || exerciseProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryBlue,
                  ),
                );
              }

              return NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return true;
                },
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 10), // Small top padding
                      
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
                      
                      const SizedBox(height: 16), // Reduced spacing
                      
                      // Main Summary Content (Wrapped for Export)
                      RepaintBoundary(
                        key: _summaryKey,
                        child: SummaryContentWidget(
                          period: _currentPeriod,
                        ),
                      ),
                      
                      const SizedBox(height: 100), // Bottom padding for navigation
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

  /// Simplified export handler - direct save with feedback
  Future<void> _handleExport() async {
    setState(() {
      _isExporting = true;
    });

    try {
      // Direct export to device storage
      final success = await ExportHelper.exportSummary(
        _summaryKey,
        _currentPeriod,
      );

      if (mounted) {
        if (success) {
          _showSuccessMessage('Summary saved to device storage!');
        } else {
          _showErrorMessage('Failed to export summary. Please try again.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorMessage('Export error: Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Show success message with optional "View Saved" action
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'View Saved',
          textColor: Colors.white,
          onPressed: () {
            ExportHelper.showSavedFiles(context);
          },
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// Show error message
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}