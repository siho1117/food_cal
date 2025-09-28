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
  const SummaryScreen({super.key});  // ✅ FIXED: Using super parameter instead of Key? key

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
                            period: _currentPeriod,  // ✅ FIXED: Only pass period parameter
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
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

  Future<void> _handleExport() async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });

    try {
      // ✅ FIXED: Use correct method name from ExportHelper
      final success = await ExportHelper.exportSummary(
        _summaryKey,
        _currentPeriod,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Summary exported successfully! 📸'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Export failed. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Export error: ${e.toString()}'),
            backgroundColor: Colors.red,
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