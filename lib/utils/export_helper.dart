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

  /// Single-action export: capture widget and save to device
  static Future<bool> exportSummary(
    GlobalKey widgetKey,
    SummaryPeriod period, {
    String? customFileName,
  }) async {
    try {
      // Step 1: Capture widget as image
      final filePath = await _captureWidgetAsImage(widgetKey, period, customFileName: customFileName);
      if (filePath == null) {
        return false;
      }

      // Step 2: Save to permanent device storage
      final savedPath = await _saveToDevice(filePath, period, customFileName: customFileName);
      return savedPath != null;
    } catch (e) {
      debugPrint('Error in exportSummary: $e');
      return false;
    }
  }

  /// Get list of all exported files for "View Saved" functionality
  static Future<List<File>> getSavedExports() async {
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
      debugPrint('Error getting saved exports: $e');
      return [];
    }
  }

  /// Delete a saved export file
  static Future<bool> deleteExport(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting export: $e');
      return false;
    }
  }

  /// Show saved files dialog (optional, for "View Saved" button)
  static Future<void> showSavedFiles(BuildContext context) async {
    final files = await getSavedExports();
    
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
                          final deleted = await deleteExport(file.path);
                          if (deleted && context.mounted) {
                            Navigator.of(context).pop();
                            showSavedFiles(context); // Refresh list
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // Private helper methods

  /// Capture widget as PNG image
  static Future<String?> _captureWidgetAsImage(
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

      // Save to temporary directory first
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(pngBytes);

      return file.path;
    } catch (e) {
      debugPrint('Error capturing widget as image: $e');
      return null;
    }
  }

  /// Save file to permanent device storage
  static Future<String?> _saveToDevice(
    String tempFilePath,
    SummaryPeriod period, {
    String? customFileName,
  }) async {
    try {
      final sourceFile = File(tempFilePath);
      if (!await sourceFile.exists()) {
        debugPrint('Source file does not exist');
        return null;
      }

      // Get app documents directory
      final directory = await getApplicationDocumentsDirectory();
      final exportsDir = Directory('${directory.path}/food_cal_exports');

      // Create exports directory if it doesn't exist
      if (!await exportsDir.exists()) {
        await exportsDir.create(recursive: true);
      }

      // Generate filename
      final fileName = customFileName ?? _generateFileName(period);
      final savedFile = File('${exportsDir.path}/$fileName');

      // Copy file to permanent location
      await sourceFile.copy(savedFile.path);

      return savedFile.path;
    } catch (e) {
      debugPrint('Error saving to device: $e');
      return null;
    }
  }

  /// Generate filename with timestamp
  static String _generateFileName(SummaryPeriod period) {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'food_summary_${period.name}_${dateStr}_$timeStr.png';
  }
}