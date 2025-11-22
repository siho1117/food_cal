// lib/widgets/home/quick_edit_food_dialog.dart
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../data/models/food_item.dart';
import '../food/food_card.dart';
import 'quick_edit_food_controller.dart';

class QuickEditFoodDialog extends StatefulWidget {
  final FoodItem foodItem;
  final VoidCallback? onUpdated;

  const QuickEditFoodDialog({
    super.key,
    required this.foodItem,
    this.onUpdated,
  });

  @override
  State<QuickEditFoodDialog> createState() => _QuickEditFoodDialogState();
}

class _QuickEditFoodDialogState extends State<QuickEditFoodDialog> {
  late final QuickEditFoodController _controller;
  final GlobalKey _cardKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _controller = QuickEditFoodController(
      foodItem: widget.foodItem,
      onUpdated: widget.onUpdated,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Food card wrapped in RepaintBoundary for export (excludes buttons)
            RepaintBoundary(
              key: _cardKey,
              child: FoodCardWidget(
                foodItem: widget.foodItem,
                isEditable: true,
                imagePath: _controller.imagePath,
                onImageTap: _showImageSourceDialog,
                onExportTap: _exportFoodCard,
                nameController: _controller.nameController,
                caloriesController: _controller.caloriesController,
                servingSizeController: _controller.servingSizeController,
                proteinController: _controller.proteinController,
                carbsController: _controller.carbsController,
                fatController: _controller.fatController,
                costController: _controller.costController,
              ),
            ),

            // Action Buttons (outside RepaintBoundary - excluded from export)
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Show dialog to choose image source (camera or gallery)
  Future<void> _showImageSourceDialog() async {
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Food Photo'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            if (_controller.imagePath != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo'),
                onTap: () => Navigator.pop(context, null),
              ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    } else if (source == null && _controller.imagePath != null) {
      // Remove photo option selected
      setState(() {
        _controller.removeImage();
      });
    }
  }

  /// Pick image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    try {
      final imagePath = await _controller.pickImage(source);
      if (imagePath != null) {
        setState(() {});
      }
    } catch (e) {
      _showErrorSnackBar('Failed to add photo');
    }
  }

  Widget _buildActionButtons() {
    // Use dynamic card color from FoodCardWidget to ensure consistency
    final cardColor = FoodCardWidget.getCardColor(context);

    // Check if this is a new (empty) food item
    final isNewItem = widget.foodItem.name.isEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 24), // Spacing between food card and buttons
      child: Container(
        // Match food card width (340px)
        width: 340,
        // Card container matching food card style and width
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(24), // Match food card rounded corners
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Delete/Cancel button (original white outline design)
            Expanded(
              child: OutlinedButton(
                onPressed: _controller.isLoading ? null : (isNewItem ? _handleCancel : _handleDelete),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  isNewItem ? 'Cancel' : 'Delete',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Save button (original white filled design)
            Expanded(
              child: FilledButton(
                onPressed: _controller.isLoading ? null : _handleSave,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  _controller.isLoading ? 'Saving...' : 'Save',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSave() async {
    try {
      final success = await _controller.save();

      if (success && mounted) {
        Navigator.of(context).pop();
      } else {
        _showErrorSnackBar('Failed to save changes');
      }
    } catch (e) {
      _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _handleDelete() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        title: const Text(
          'Delete Food Item',
          style: AppDialogTheme.titleStyle,
        ),
        content: Text(
          'Remove "${widget.foodItem.name}" from your food log?',
          style: AppDialogTheme.bodyStyle,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            style: AppDialogTheme.cancelButtonStyle,
            child: const Text('Cancel'),
          ),
          const SizedBox(width: AppDialogTheme.buttonGap),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: AppDialogTheme.destructiveButtonStyle,
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        final success = await _controller.delete();

        if (success && mounted) {
          Navigator.of(context).pop();
        } else {
          _showErrorSnackBar('Failed to delete item');
        }
      } catch (e) {
        _showErrorSnackBar('An error occurred while deleting');
      } finally {
        if (mounted) {
          setState(() {});
        }
      }
    }
  }

  void _handleCancel() {
    // Simply close the dialog without saving for new items
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Export food card as image and share
  Future<void> _exportFoodCard() async {
    try {
      // Find the RenderRepaintBoundary
      final boundary = _cardKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        _showErrorSnackBar('Failed to capture food card');
        return;
      }

      // Capture the widget as an image with high quality
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final imageBytes = byteData?.buffer.asUint8List();

      if (imageBytes == null) {
        _showErrorSnackBar('Failed to capture food card');
        return;
      }

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final fileName = '${widget.foodItem.name.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageBytes);

      // Share the image
      await Share.shareXFiles(
        [XFile(file.path)],
        text: '${widget.foodItem.name} - Nutrition Info',
      );
    } catch (e) {
      _showErrorSnackBar('Failed to export food card');
    }
  }
}
