// lib/widgets/food/food_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/nutrition_colors.dart';
import '../../config/design_system/theme_background.dart';
import '../../config/design_system/color_utils.dart';
import '../../data/models/food_item.dart';
import '../../providers/theme_provider.dart';
import '../../services/food_image_service.dart';

/// Reusable food card widget that displays food information
/// Can be used for:
/// - Edit dialog (with text inputs)
/// - Loading screen (display only)
/// - Export image (display only)
class FoodCardWidget extends StatelessWidget {
  final FoodItem foodItem;
  final bool isEditable;
  final String? imagePath;
  final VoidCallback? onImageTap;
  final VoidCallback? onExportTap;
  final TextEditingController? nameController;
  final TextEditingController? caloriesController;
  final TextEditingController? servingSizeController;
  final TextEditingController? proteinController;
  final TextEditingController? carbsController;
  final TextEditingController? fatController;

  const FoodCardWidget({
    super.key,
    required this.foodItem,
    this.isEditable = false,
    this.imagePath,
    this.onImageTap,
    this.onExportTap,
    this.nameController,
    this.caloriesController,
    this.servingSizeController,
    this.proteinController,
    this.carbsController,
    this.fatController,
  });

  @override
  Widget build(BuildContext context) {
    final cardColor = ColorUtils.getComplementaryColor(
      ThemeBackground.getColors(
        context.watch<ThemeProvider>().selectedGradient,
      )![1], // Tone 2
    );

    return Container(
      width: 340,
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
          // 1. White background (bottom layer) - 330×330px square, centered horizontally
          Positioned(
            left: 5,
            top: 90,
            right: 5,
            height: 330,
            child: Container(
              color: Colors.white,
            ),
          ),

          // 2. Food image (middle layer) - fills entire white background
          Positioned(
            left: 5,
            top: 90,
            right: 5,
            height: 330,
            child: _buildFoodImage(),
          ),

          // 3. Colored card with arch cutout (top layer - masks the image)
          Positioned.fill(
            child: CustomPaint(
              painter: ArchCardPainter(cardColor: cardColor),
              child: Container(), // Empty container for painting
            ),
          ),

          // Tappable arch window area for image picker (only if editable)
          if (isEditable && onImageTap != null)
            Positioned(
              left: 5,
              top: 90,
              right: 5,
              height: 330,
              child: GestureDetector(
                onTap: onImageTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

          // App name - top left (Row 1)
          const Positioned(
            left: 28,
            top: 16,
            child: Text(
              'Food LLM',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),

          // Cost indicator - left side (Row 2)
          Positioned(
            left: 28,
            top: 56,
            child: Text(
              '\$\$\$',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.9),
                letterSpacing: -0.5,
              ),
            ),
          ),

          // Export icon - right side (Row 2, aligned with $$$)
          if (onExportTap != null)
            Positioned(
              right: 28,
              top: 56,
              child: GestureDetector(
                onTap: onExportTap,
                child: Icon(
                  Icons.ios_share,
                  size: 28,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ),

          // All content on colored card
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Spacer for arch window (90 + 320 = 410px)
              const SizedBox(height: 410),

              // Content on colored card (tighter spacing)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 12, 28, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Food Name Input/Display
                    _buildFoodNameField(),

                    const SizedBox(height: 20),

                    // Calories and Serving Size Row
                    _buildCaloriesServingRow(),

                    const SizedBox(height: 18),

                    // Macronutrients Section
                    _buildMacronutrientsSection(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build food image display
  Widget _buildFoodImage() {
    if (imagePath != null && imagePath!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: FoodImageService.getImageFile(imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildImagePlaceholder();
          }

          if (snapshot.hasData && snapshot.data != null) {
            return Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            );
          }

          return _buildImagePlaceholder();
        },
      );
    }
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

  /// Build food name field (editable or display)
  Widget _buildFoodNameField() {
    if (isEditable && nameController != null) {
      return TextField(
        controller: nameController,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        decoration: InputDecoration(
          hintText: 'Food name',
          hintStyle: TextStyle(
            fontSize: 20,
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
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      );
    }

    return Text(
      foodItem.name,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
    );
  }

  /// Build calories and serving size row
  Widget _buildCaloriesServingRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Calories
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CALORIES',
                style: AppTypography.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 20,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 6),
                  if (isEditable && caloriesController != null)
                    Expanded(
                      child: TextField(
                        controller: caloriesController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${foodItem.calories.toInt()}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Serving Size
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVING',
                style: AppTypography.overline.copyWith(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Text(
                    '×',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isEditable && servingSizeController != null)
                    Expanded(
                      child: TextField(
                        controller: servingSizeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${foodItem.servingSize}',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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

  /// Build macronutrients section
  Widget _buildMacronutrientsSection() {
    return Row(
      children: [
        // Protein
        Expanded(
          child: _buildMacroPill(
            label: 'Protein',
            value: foodItem.proteins,
            controller: proteinController,
            color: NutritionColors.proteinColor,
            icon: Icons.set_meal,
          ),
        ),
        const SizedBox(width: 10),
        // Carbs
        Expanded(
          child: _buildMacroPill(
            label: 'Carbs',
            value: foodItem.carbs,
            controller: carbsController,
            color: NutritionColors.carbsColor,
            icon: Icons.local_pizza,
          ),
        ),
        const SizedBox(width: 10),
        // Fat
        Expanded(
          child: _buildMacroPill(
            label: 'Fat',
            value: foodItem.fats,
            controller: fatController,
            color: NutritionColors.fatColor,
            icon: Icons.grain_rounded,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroPill({
    required String label,
    required double value,
    TextEditingController? controller,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label with unit
        Text(
          '${label.toUpperCase()} / g',
          style: TextStyle(
            fontSize: 11,
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
              size: 18,
              color: Colors.white.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 6),
            if (isEditable && controller != null)
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              )
            else
              Text(
                '${value.toInt()}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// Custom painter for arch card cutout
class ArchCardPainter extends CustomPainter {
  final Color cardColor;

  ArchCardPainter({required this.cardColor});

  @override
  void paint(Canvas canvas, Size size) {
    const double marginLeft = 25.0;
    const double marginRight = 25.0;
    const double marginTop = 90.0;
    const double windowHeight = 320.0;
    const double archRadius = 145.0;

    final archWindowRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
        marginLeft,
        marginTop,
        size.width - marginRight,
        marginTop + windowHeight,
      ),
      topLeft: Radius.circular(archRadius),
      topRight: Radius.circular(archRadius),
      bottomLeft: const Radius.circular(20),
      bottomRight: const Radius.circular(20),
    );

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(28),
    );

    final cardPath = Path()..addRRect(cardRect);
    final windowPath = Path()..addRRect(archWindowRect);

    final cardWithCutout = Path.combine(
      PathOperation.difference,
      cardPath,
      windowPath,
    );

    final cardPaint = Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(cardWithCutout, cardPaint);
  }

  @override
  bool shouldRepaint(covariant ArchCardPainter oldDelegate) {
    return oldDelegate.cardColor != cardColor;
  }
}
