// lib/widgets/home/quick_edit_food_dialog.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/nutrition_colors.dart';
import '../../config/design_system/theme_background.dart';
import '../../config/design_system/color_utils.dart';
import '../../config/constants/app_constants.dart';
import '../../data/models/food_item.dart';
import '../../providers/theme_provider.dart';
import '../../services/food_image_service.dart';
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
    // Dynamic card color based on theme (restored)
    final cardColor = ColorUtils.getComplementaryColor(
      ThemeBackground.getColors(
        context.watch<ThemeProvider>().selectedGradient,
      )![1], // Tone 2
    );

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Stack(
          children: [
            // 1. White background (bottom layer) - 310×330px, centered horizontally
            Positioned(
              left: 15,
              top: 50,
              right: 15,
              height: 330,
              child: Container(
                color: Colors.white,
              ),
            ),

            // 2. Food image (middle layer) - fills entire white background
            Positioned(
              left: 15,
              top: 50,
              right: 15,
              height: 330,
              child: _buildFoodImage(), // No Center - let BoxFit.cover fill completely
            ),

            // 3. Colored card with arch cutout (top layer - masks the image)
            Positioned.fill(
              child: CustomPaint(
                painter: ArchCardPainter(cardColor: cardColor),
                child: Container(), // Empty container for painting
              ),
            ),

            // Image picker button
            Positioned(
              top: 66,
              right: 41,
              child: _buildImagePickerButton(),
            ),

            // All content on colored card (NO SCROLLVIEW - everything fits)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Spacer for arch window (50 + 320 = 370px)
                const SizedBox(height: 370),

                // Content on colored card (tighter spacing)
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 12, 28, 20), // Reduced top padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Food Name Input
                      _buildFoodNameInput(),

                      const SizedBox(height: 20), // Reduced from 24

                      // Calories and Serving Size Row
                      _buildCaloriesServingRow(),

                      const SizedBox(height: 18), // Reduced from 20

                      // Macronutrients Section (without title)
                      _buildMacronutrientsSection(),
                    ],
                  ),
                ),

                // Action Buttons
                _buildActionButtons(),
              ],
            ),
          ],
        ),
      ),
    );
  }


  /// Build food image display (uses actual image or placeholder)
  Widget _buildFoodImage() {
    // If we have an image path, show the actual food image
    if (_controller.imagePath != null && _controller.imagePath!.isNotEmpty) {
      // Use FutureBuilder to asynchronously load the image file
      return FutureBuilder<File?>(
        future: FoodImageService.getImageFile(_controller.imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show placeholder while loading
            return _buildImagePlaceholder();
          }

          if (snapshot.hasData && snapshot.data != null) {
            // Image file found - display it filling entire container
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,  // Fill width
              height: double.infinity, // Fill height
              errorBuilder: (context, error, stackTrace) {
                // If file can't be loaded, show placeholder
                return _buildImagePlaceholder();
              },
            );
          }

          // Image not found - show placeholder
          return _buildImagePlaceholder();
        },
      );
    }

    // No image - show placeholder
    return _buildImagePlaceholder();
  }

  /// Build placeholder when no image is available
  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey[300]!,
            Colors.grey[200]!,
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_rounded,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'Tap + to add photo',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build image picker button (floating action button style)
  Widget _buildImagePickerButton() {
    return Material(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(20),
      elevation: 4,
      child: InkWell(
        onTap: _showImageSourceDialog,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(
            _controller.imagePath != null ? Icons.edit : Icons.add_a_photo,
            size: 24,
            color: Colors.grey[800],
          ),
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

  Widget _buildFoodNameInput() {
    return TextField(
      controller: _controller.nameController,
      style: AppTypography.displaySmall.copyWith(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      decoration: InputDecoration(
        hintText: 'Food name',
        hintStyle: AppTypography.displaySmall.copyWith(
          color: Colors.white.withValues(alpha: 0.5),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 16
      ),
      inputFormatters: [
        LengthLimitingTextInputFormatter(AppConstants.maxFoodNameLength),
      ],
    );
  }

  Widget _buildCaloriesServingRow() {
    return Row(
      children: [
        // Calories (Left - 50%)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALORIES',
                style: AppTypography.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10, // Reduced from 11
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6), // Reduced from 8
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 18, // Reduced from 20
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  const SizedBox(width: 7), // Reduced from 8
                  Flexible(
                    child: TextField(
                      controller: _controller.caloriesController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                        fontSize: 26, // Reduced from 28
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 28), // Reduced from 32

        // Serving Size (Right - 50%)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVING',
                style: AppTypography.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10, // Reduced from 11
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6), // Reduced from 8
              Row(
                children: [
                  Text(
                    '×',
                    style: TextStyle(
                      fontSize: 18, // Reduced from 20
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                  const SizedBox(width: 7), // Reduced from 8
                  Flexible(
                    child: TextField(
                      controller: _controller.servingSizeController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                        fontSize: 26, // Reduced from 28
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrientsSection() {
    // No title - just the macro pills
    return Row(
      children: [
        // Protein
        Expanded(
          child: _buildMacroPill(
            label: 'Protein',
            controller: _controller.proteinController,
            color: NutritionColors.proteinColor,
            icon: Icons.fitness_center_rounded,
          ),
        ),
        const SizedBox(width: 10),
        // Carbs
        Expanded(
          child: _buildMacroPill(
            label: 'Carbs',
            controller: _controller.carbsController,
            color: NutritionColors.carbsColor,
            icon: Icons.grain_rounded,
          ),
        ),
        const SizedBox(width: 10),
        // Fat
        Expanded(
          child: _buildMacroPill(
            label: 'Fat',
            controller: _controller.fatController,
            color: NutritionColors.fatColor,
            icon: Icons.water_drop_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroPill({
    required String label,
    required TextEditingController controller,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with unit (e.g., "PROTEIN / g")
        Text(
          '${label.toUpperCase()} / g',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.5),
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(width: 5),
            Flexible(
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 24), // Reduced top and bottom padding
      child: Row(
        children: [
          // Delete button
          Expanded(
            child: OutlinedButton(
              onPressed: _controller.isLoading ? null : _handleDelete,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 14
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                'Delete',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12), // Reduced from 14

          // Save button
          Expanded(
            child: FilledButton(
              onPressed: _controller.isLoading ? null : _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(vertical: 12), // Reduced from 14
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _controller.isLoading ? 'Saving...' : 'Save',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
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
}

// Custom painter to create orange card with arch window cutout
class ArchCardPainter extends CustomPainter {
  final Color cardColor;

  ArchCardPainter({required this.cardColor});

  @override
  void paint(Canvas canvas, Size size) {
    // REFINED ARCH: Larger window with 145px radius
    // Fixed dimensions for consistent design
    const double marginLeft = 25.0;
    const double marginRight = 25.0;
    const double marginTop = 50.0;
    const double windowHeight = 320.0;  // Increased window height
    const double archRadius = 145.0;    // Back to original 145px radius

    // Create the arch window cutout using rounded rectangle
    final archWindowRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
        marginLeft,        // 25 - left edge
        marginTop,         // 50 - top edge
        340 - marginRight, // 315 - right edge
        marginTop + windowHeight, // 370 - bottom edge
      ),
      topLeft: const Radius.circular(archRadius),  // Classic arch curve
      topRight: const Radius.circular(archRadius), // Classic arch curve
      bottomLeft: Radius.zero,                     // Sharp bottom corners
      bottomRight: Radius.zero,                    // Sharp bottom corners
    );

    // Create the colored card with arch cutout
    final cardPaint = Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill;

    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, 340, size.height));

    final archWindowPath = Path()
      ..addRRect(archWindowRect);

    // Subtract arch window from card to create cutout
    final cardWithCutout = Path.combine(
      PathOperation.difference,
      outerPath,
      archWindowPath,
    );

    // Draw the card with the arch window cutout
    // (This masks anything drawn below it in the arch window area)
    canvas.drawPath(cardWithCutout, cardPaint);
  }

  @override
  bool shouldRepaint(covariant ArchCardPainter oldDelegate) {
    return oldDelegate.cardColor != cardColor;
  }
}
