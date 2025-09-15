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
                      
                      const SizedBox(height: 16),
                      
                      // Main Summary Content (Wrapped for Export)
                      // The RepaintBoundary is crucial for capturing the widget
                      RepaintBoundary(
                        key: _summaryKey,
                        child: Container(
                          color: AppTheme.secondaryBeige, // Ensure background color
                          child: SummaryContentWidget(
                            period: _currentPeriod,
                          ),
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

  /// Enhanced export handler with better error handling and user feedback
  Future<void> _handleExport() async {
    if (_isExporting) return; // Prevent multiple simultaneous exports
    
    setState(() {
      _isExporting = true;
    });

    try {
      // Show immediate feedback to user
      _showInfoMessage('Preparing export...');
      
      // Small delay to ensure UI updates
      await Future.delayed(const Duration(milliseconds: 200));
      
      // Ensure the widget is fully rendered
      final context = _summaryKey.currentContext;
      if (context == null) {
        debugPrint('❌ Export failed: Widget context not found');
        if (mounted) {
          _showErrorMessage('Widget not ready for export. Please try again.');
        }
        return;
      }
      
      // Check if widget is visible and rendered
      final renderObject = context.findRenderObject();
      if (renderObject == null || !renderObject.attached) {
        debugPrint('❌ Export failed: Widget not rendered');
        if (mounted) {
          _showErrorMessage('Widget not visible. Please ensure the summary is fully loaded.');
        }
        return;
      }

      debugPrint('🔄 Starting export with key: ${_summaryKey.toString()}');
      debugPrint('📊 Current period: ${_currentPeriod.name}');
      
      // Direct export to device storage
      final success = await ExportHelper.exportSummary(
        _summaryKey,
        _currentPeriod,
      );

      if (mounted) {
        if (success) {
          _showSuccessMessage('Summary exported successfully!');
        } else {
          _showErrorMessage('Failed to export summary. Please check permissions and try again.');
        }
      }
    } catch (e) {
      debugPrint('❌ Export exception: $e');
      if (mounted) {
        _showErrorMessage('Export error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Show info message during export process
  void _showInfoMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show success message with optional "View Saved" action
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
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
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Show error message with helpful information
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(message)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Tip: Ensure app has storage permissions',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 4),
      ),
    );
  }
}