// lib/utils/export_helper.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import '../widgets/summary/summary_controls_widget.dart';

class ExportHelper {
  // Private constructor to prevent instantiation
  ExportHelper._();

  /// Export summary widget as image and return the file path
  static Future<String?> exportAsImage(
    GlobalKey widgetKey,
    SummaryPeriod period, {
    String? customFileName,
  }) async {
    try {
      // Find the RenderRepaintBoundary
      final RenderRepaintBoundary? boundary = widgetKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        debugPrint('Could not find widget to export');
        return null;
      }

      // Capture the widget as an image
      final ui.Image image = await boundary.toImage(pixelRatio: 2.0);

      // Convert to PNG bytes
      final ByteData? byteData = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (byteData == null) {
        debugPrint('Failed to convert image to bytes');
        return null;
      }

      final Uint8List pngBytes = byteData.buffer.asUint8List();

      // Generate filename
      final fileName = customFileName ?? _generateFileName(period);

      // Save to app documents directory (permanent storage)
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/food_cal_exports');
      
      // Create exports directory if it doesn't exist
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      final file = File('${exportsDir.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      debugPrint('Error exporting as image: $e');
      return null;
    }
  }

  /// Get list of all exported files
  static Future<List<File>> getExportedFiles() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/food_cal_exports');
      
      if (!await exportsDir.exists()) {
        return [];
      }

      final files = await exportsDir
          .list()
          .where((entity) => entity is File && entity.path.endsWith('.png'))
          .cast<File>()
          .toList();

      // Sort by modification date (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

      return files;
    } catch (e) {
      debugPrint('Error getting exported files: $e');
      return [];
    }
  }

  /// Delete an exported file
  static Future<bool> deleteExportedFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }

  /// Clear all exported files
  static Future<bool> clearAllExports() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/food_cal_exports');

      if (await exportsDir.exists()) {
        await exportsDir.delete(recursive: true);
        return true;
      }
      return true;
    } catch (e) {
      debugPrint('Error clearing exports: $e');
      return false;
    }
  }

  /// Show export dialog with save option only
  static Future<void> showExportDialog(
    BuildContext context,
    GlobalKey widgetKey,
    SummaryPeriod period,
  ) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Export ${_getPeriodName(period)} Summary',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.download,
                size: 48,
                color: Colors.blue[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Save your ${period.name} summary as an image to your device storage.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              
              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _handleExport(context, widgetKey, period);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Summary'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 8),
              
              // View saved button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showSavedFiles(context);
                  },
                  icon: const Icon(Icons.folder),
                  label: const Text('View Saved Summaries'),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        );
      },
    );
  }

  // Private helper methods

  static String _generateFileName(SummaryPeriod period) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'food_summary_${period.name}_${dateStr}_$timeStr.png';
  }

  static String _getPeriodName(SummaryPeriod period) {
    switch (period) {
      case SummaryPeriod.daily:
        return 'Daily';
      case SummaryPeriod.weekly:
        return 'Weekly';
      case SummaryPeriod.monthly:
        return 'Monthly';
    }
  }

  static Future<void> _handleExport(
    BuildContext context,
    GlobalKey widgetKey,
    SummaryPeriod period,
  ) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Saving summary...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      final savedPath = await exportAsImage(widgetKey, period);
      
      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Show result
      if (savedPath != null && context.mounted) {
        _showSuccessDialog(context, savedPath, period);
      } else if (context.mounted) {
        _showErrorMessage(context, 'Failed to save summary');
      }
    } catch (e) {
      // Hide loading
      if (context.mounted) {
        Navigator.of(context).pop();
        _showErrorMessage(context, 'Error: $e');
      }
    }
  }

  static void _showSuccessDialog(BuildContext context, String filePath, SummaryPeriod period) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Summary Saved!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your ${period.name} summary has been saved successfully.'),
            const SizedBox(height: 12),
            Text(
              'Location: Food Cal Exports folder',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _showSavedFiles(context);
            },
            child: const Text('View All Saved'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static Future<void> _showSavedFiles(BuildContext context) async {
    final files = await getExportedFiles();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Saved Summaries'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: files.isEmpty
              ? const Center(
                  child: Text('No saved summaries yet.'),
                )
              : ListView.builder(
                  itemCount: files.length,
                  itemBuilder: (context, index) {
                    final file = files[index];
                    final fileName = file.path.split('/').last;
                    final fileSize = file.lengthSync();
                    final fileSizeKB = (fileSize / 1024).round();
                    
                    return ListTile(
                      leading: const Icon(Icons.image),
                      title: Text(
                        fileName,
                        style: const TextStyle(fontSize: 14),
                      ),
                      subtitle: Text('${fileSizeKB}KB'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final deleted = await deleteExportedFile(file.path);
                          if (deleted && context.mounted) {
                            Navigator.of(context).pop();
                            _showSavedFiles(context); // Refresh list
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          if (files.isNotEmpty)
            TextButton(
              onPressed: () async {
                final cleared = await clearAllExports();
                if (cleared && context.mounted) {
                  Navigator.of(context).pop();
                  _showSuccessMessage(context, 'All summaries cleared!');
                }
              },
              child: const Text('Clear All'),
            ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  static void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 8),
            Text(message),
          ],
        ),
        backgroundColor: Colors.red[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}