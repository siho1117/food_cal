// lib/screens/summary_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../config/design_system/theme_background.dart';
import '../config/design_system/theme_design.dart';
import '../providers/home_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/summary/summary_controls_widget.dart';
import '../widgets/summary/summary_export_widget.dart';
import '../widgets/common/custom_app_bar.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _currentPeriod = SummaryPeriod.daily;
  bool _isExporting = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: ThemeBackground.getGradient(themeProvider.selectedGradient),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: const CustomAppBar(currentPage: 'summary'),
            body: Consumer2<HomeProvider, ExerciseProvider>(
              builder: (context, homeProvider, exerciseProvider, child) {
                if (homeProvider.isLoading || exerciseProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

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
                        Screenshot(
                          controller: _screenshotController,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: ThemeBackground.getGradient(themeProvider.selectedGradient),
                            ),
                            child: SummaryExportWidget(
                              period: _currentPeriod,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

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
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeProvider.errorMessage ?? exerciseProvider.errorMessage ?? 'Unknown error occurred',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              homeProvider.refreshData();
              exerciseProvider.refreshData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textDark,
            ),
            child: const Text('Retry'),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              homeProvider.refreshData();
              exerciseProvider.refreshData();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
            ),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Capture the screenshot as PNG
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0, // High quality for retina displays
      );

      if (imageBytes == null) {
        throw Exception('Failed to capture screenshot');
      }

      // Save to gallery (iOS Photos / Android Gallery)
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'fitness_summary_${DateTime.now().millisecondsSinceEpoch}',
      );

      if (result['isSuccess'] != true) {
        throw Exception('Failed to save to gallery');
      }

      // Also save to temp file for sharing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/fitness_summary.png');
      await tempFile.writeAsBytes(imageBytes);

      // Show native share dialog
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Check out my fitness summary!',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Summary exported successfully! Saved to Photos and ready to share.'),
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