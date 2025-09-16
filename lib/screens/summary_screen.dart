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

  /// Handle export with clean user feedback
  Future<void> _handleExport() async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      // Show export progress
      _showMessage('Exporting summary...', isLoading: true);
      
      // Small delay for UI feedback
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Export the summary
      final success = await ExportHelper.exportSummary(
        _summaryKey,
        _currentPeriod,
      );

      if (mounted) {
        if (success) {
          _showMessage('Summary saved to Photos! 📸', isSuccess: true);
        } else {
          _showMessage('Export failed. Please try again.', isError: true);
        }
      }

    } catch (e) {
      if (mounted) {
        _showMessage('Export error occurred. Please try again.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  /// Unified message display method
  void _showMessage(String message, {
    bool isLoading = false,
    bool isSuccess = false,
    bool isError = false,
  }) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).clearSnackBars();
    
    Color backgroundColor;
    Widget icon;
    Duration duration;
    SnackBarAction? action;

    if (isLoading) {
      backgroundColor = Colors.blue[600]!;
      icon = const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
      duration = const Duration(seconds: 2);
    } else if (isSuccess) {
      backgroundColor = Colors.green[600]!;
      icon = const Icon(Icons.check_circle, color: Colors.white, size: 20);
      duration = const Duration(seconds: 3);
      action = SnackBarAction(
        label: 'View',
        textColor: Colors.white,
        onPressed: () {
          // iOS will handle opening Photos
        },
      );
    } else if (isError) {
      backgroundColor = Colors.red[600]!;
      icon = const Icon(Icons.error_outline, color: Colors.white, size: 20);
      duration = const Duration(seconds: 4);
      action = SnackBarAction(
        label: 'Retry',
        textColor: Colors.white,
        onPressed: () {
          ScaffoldMessenger.of(context).clearSnackBars();
          _handleExport();
        },
      );
    } else {
      backgroundColor = Colors.grey[600]!;
      icon = const Icon(Icons.info_outline, color: Colors.white, size: 20);
      duration = const Duration(seconds: 2);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: duration,
        action: action,
      ),
    );
  }
}