// lib/screens/summary_screen.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../l10n/generated/app_localizations.dart';
import '../config/design_system/theme_background.dart';
import '../config/design_system/theme_design.dart';
import '../providers/home_provider.dart';
import '../providers/exercise_provider.dart';
import '../providers/theme_provider.dart';
import '../services/food_image_service.dart';
import '../services/summary_card_settings_service.dart';
import '../data/models/summary_card_config.dart';
import '../utils/summary/summary_constants.dart';
import '../widgets/summary/summary_controls_widget.dart';
import '../widgets/summary/summary_export_widget.dart';
import '../widgets/summary/card_settings_bottom_sheet.dart';
import '../widgets/common/custom_app_bar.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends State<SummaryScreen> {
  SummaryPeriod _currentPeriod = SummaryPeriod.daily;
  bool _isExporting = false;
  List<SummaryCardConfig> _cardConfigs = [];
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _loadCardConfiguration();
  }

  Future<void> _loadCardConfiguration() async {
    final configs = await SummaryCardSettingsService.loadCardConfig();
    if (mounted) {
      setState(() {
        _cardConfigs = configs;
      });
    }
  }

  void _showSettingsBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CardSettingsBottomSheet(
        cardConfigs: _cardConfigs,
        onVisibilityChanged: _updateCardVisibility,
        onReorder: _reorderCards,
      ),
    );
  }

  Future<void> _updateCardVisibility(SummaryCardType cardType, bool isVisible) async {
    await SummaryCardSettingsService.updateCardVisibility(cardType, isVisible);
    await _loadCardConfiguration();
  }

  Future<void> _reorderCards(int oldIndex, int newIndex) async {
    await SummaryCardSettingsService.reorderCards(oldIndex, newIndex);
    await _loadCardConfiguration();
  }

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

                return RefreshIndicator(
                  onRefresh: () => _handleRefresh(homeProvider, exerciseProvider),
                  color: Colors.white,
                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                  child: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (notification) {
                      notification.disallowIndicator();
                      return true;
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
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
                            onSettingsTap: _showSettingsBottomSheet,
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
                                key: ValueKey('${homeProvider.userProfile?.isMetric}_${_currentPeriod}_${_cardConfigs.length}'),
                                period: _currentPeriod,
                                cardConfigs: _cardConfigs,
                              ),
                            ),
                          ),

                          const SizedBox(height: 80),
                        ],
                      ),
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
    final l10n = AppLocalizations.of(context)!;

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
            l10n.errorLoadingSummaryData,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            homeProvider.errorMessage ?? exerciseProvider.errorMessage ?? l10n.unknownErrorOccurred,
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
            child: Text(l10n.retry),
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
            child: Text(l10n.dismiss),
          ),
        ],
      ),
    );
  }

  Future<void> _handleRefresh(HomeProvider homeProvider, ExerciseProvider exerciseProvider) async {
    // Refresh both providers to get latest data
    await Future.wait([
      homeProvider.refreshData(),
      exerciseProvider.refreshData(),
    ]);
  }

  /// Preload all food images to ensure they're ready for screenshot
  Future<void> _preloadFoodImages(HomeProvider homeProvider) async {
    final foodEntries = homeProvider.foodEntries;

    // Get all image files
    final List<File?> imageFiles = await Future.wait(
      foodEntries
          .where((food) => food.imagePath != null && food.imagePath!.isNotEmpty)
          .map((food) => FoodImageService.getImageFile(food.imagePath))
          .toList(),
    );

    // Precache images in Flutter's image cache
    if (mounted) {
      final validFiles = imageFiles.whereType<File>().toList();
      if (validFiles.isNotEmpty) {
        await Future.wait(
          validFiles.map((file) => precacheImage(FileImage(file), context)).toList(),
        );
      }
    }
  }

  Future<void> _handleExport() async {
    if (_isExporting) return;

    setState(() {
      _isExporting = true;
    });

    try {
      // Preload all food images to ensure they're available for screenshot
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      await _preloadFoodImages(homeProvider);

      // Wait a bit more for FutureBuilder widgets to complete rendering
      await Future.delayed(SummaryConstants.imagePreloadDelay);

      // Capture the screenshot as PNG
      final Uint8List? imageBytes = await _screenshotController.capture(
        pixelRatio: SummaryConstants.screenshotPixelRatio,
      );

      if (imageBytes == null) {
        throw Exception(AppLocalizations.of(context)!.failedToCaptureScreenshot);
      }

      // Save to temp file for sharing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/fitness_summary_${DateTime.now().millisecondsSinceEpoch}.png');
      await tempFile.writeAsBytes(imageBytes);

      // Show native share dialog (user can save from here)
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: AppLocalizations.of(context)!.checkOutMyFitnessSummary,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.summaryExportedSuccessfully),
            backgroundColor: Colors.green,
            duration: SummaryConstants.exportSnackbarDuration,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${AppLocalizations.of(context)!.exportError}${e.toString()}'),
            backgroundColor: Colors.red,
            duration: SummaryConstants.errorSnackbarDuration,
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