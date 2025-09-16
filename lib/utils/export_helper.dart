// lib/utils/export_helper.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import '../widgets/summary/summary_controls_widget.dart';

class ExportHelper {
  ExportHelper._(); // Private constructor

  /// Export summary to Photos library
  static Future<bool> exportSummary(
    GlobalKey widgetKey,
    SummaryPeriod period, {
    String? customFileName,
  }) async {
    try {
      // Step 1: Capture widget as image
      final imageBytes = await _captureWidget(widgetKey);
      if (imageBytes == null) return false;

      // Step 2: Save directly to Photos (iOS handles permissions)
      final fileName = customFileName ?? _generateFileName(period);
      return await _saveToPhotos(imageBytes, fileName);

    } catch (e) {
      debugPrint('Export error: $e');
      return false;
    }
  }

  /// Capture widget as PNG bytes
  static Future<Uint8List?> _captureWidget(GlobalKey widgetKey) async {
    try {
      final boundary = widgetKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      // Wait for render completion
      await Future.delayed(const Duration(milliseconds: 200));

      // Capture with good quality
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Widget capture error: $e');
      return null;
    }
  }

  /// Save image to Photos library
  static Future<bool> _saveToPhotos(Uint8List imageBytes, String fileName) async {
    try {
      final result = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: fileName,
      );

      return result != null && result['isSuccess'] == true;
    } catch (e) {
      debugPrint('Save to Photos error: $e');
      return false;
    }
  }

  /// Generate timestamped filename
  static String _generateFileName(SummaryPeriod period) {
    final now = DateTime.now();
    final date = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final time = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}';
    return 'food_summary_${period.name}_${date}_$time';
  }

  // Compatibility methods for existing code
  static Future<bool> exportSummaryWithPreview(
    BuildContext context,
    GlobalKey widgetKey,
    SummaryPeriod period, {
    String? customFileName,
  }) async {
    return await exportSummary(widgetKey, period, customFileName: customFileName);
  }
}