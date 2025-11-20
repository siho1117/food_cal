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
import '../loading/animations/pulse_widget.dart';
import '../loading/animations/animated_text_widget.dart';
import '../loading/animations/animated_ellipsis_widget.dart';
import '../loading/animations/animated_cost_indicator.dart';
import 'painters/arch_card_painter.dart';
import 'dialogs/edit_food_name_dialog.dart';
import 'helpers/food_card_pickers.dart';
import '../common/text_input_overlay.dart';

/// Reusable food card widget that displays food information
/// Can be used for:
/// - Edit dialog (with text inputs)
/// - Loading screen (display only)
/// - Export image (display only)
/// - Preview mode (with animated cost indicator)
class FoodCardWidget extends StatefulWidget {
  final FoodItem foodItem;
  final bool isEditable;
  final bool isLoading;
  final bool isPreviewMode;
  final bool costEntryCompleted; // NEW: Track if user has finished adding cost
  final String? imagePath;
  final VoidCallback? onImageTap;
  final VoidCallback? onExportTap;
  final VoidCallback? onCostPickerOpened;
  final Function(double)? onCostUpdated;
  final Function(String)? onNameUpdated;
  final Function(int)? onCaloriesUpdated;
  final Function(double)? onServingSizeUpdated;
  final Function(int)? onProteinUpdated;
  final Function(int)? onCarbsUpdated;
  final Function(int)? onFatUpdated;
  final TextEditingController? nameController;
  final TextEditingController? caloriesController;
  final TextEditingController? servingSizeController;
  final TextEditingController? proteinController;
  final TextEditingController? carbsController;
  final TextEditingController? fatController;
  final TextEditingController? costController;

  const FoodCardWidget({
    super.key,
    required this.foodItem,
    this.isEditable = false,
    this.isLoading = false,
    this.isPreviewMode = false,
    this.costEntryCompleted = false, // NEW: Default to false
    this.imagePath,
    this.onImageTap,
    this.onExportTap,
    this.onCostPickerOpened,
    this.onCostUpdated,
    this.onNameUpdated,
    this.onCaloriesUpdated,
    this.onServingSizeUpdated,
    this.onProteinUpdated,
    this.onCarbsUpdated,
    this.onFatUpdated,
    this.nameController,
    this.caloriesController,
    this.servingSizeController,
    this.proteinController,
    this.carbsController,
    this.fatController,
    this.costController,
  });

  @override
  State<FoodCardWidget> createState() => _FoodCardWidgetState();
}

class _FoodCardWidgetState extends State<FoodCardWidget> {
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
          if (widget.isEditable && widget.onImageTap != null)
            Positioned(
              left: 5,
              top: 90,
              right: 5,
              height: 330,
              child: GestureDetector(
                onTap: widget.onImageTap,
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
            child: _buildCostIndicator(),
          ),

          // Export icon - right side (Row 2, aligned with $$$)
          if (widget.onExportTap != null)
            Positioned(
              right: 28,
              top: 56,
              child: GestureDetector(
                onTap: widget.onExportTap,
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
    if (widget.imagePath != null && widget.imagePath!.isNotEmpty) {
      return FutureBuilder<File?>(
        future: FoodImageService.getImageFile(widget.imagePath),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildImagePlaceholder();
          }

          if (snapshot.hasData && snapshot.data != null) {
            final imageWidget = Image.file(
              snapshot.data!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            );

            // If loading mode, show image with black overlay and spinner
            if (widget.isLoading) {
              return Stack(
                children: [
                  // Background image
                  imageWidget,
                  // Black overlay
                  Container(
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                  // Centered spinner
                  const Center(
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 4,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            }

            return imageWidget;
          }

          return _buildImagePlaceholder();
        },
      );
    }
    return _buildImagePlaceholder();
  }

  /// Build placeholder when no image is available
  Widget _buildImagePlaceholder() {
    // Show pulse animation when in loading mode (no image available)
    if (widget.isLoading) {
      return const PulseWidget(
        width: double.infinity,
        height: double.infinity,
        borderRadius: BorderRadius.zero,
        baseColor: Color(0xFFE0E0E0),
      );
    }

    // Show normal placeholder with icon and text
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
    // Show "Analyzing your food..." text with animation when loading
    if (widget.isLoading) {
      return const AnimatedTextWidget(
        text: 'Analyzing your food...',
        textStyle: TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      );
    }

    if (widget.isEditable && widget.nameController != null) {
      return GestureDetector(
        onTap: () => _showEditFoodNameDialog(context),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
          ),
          child: Text(
            widget.nameController!.text.isEmpty
                ? 'Food name'
                : widget.nameController!.text,
            style: TextStyle(
              fontSize: 20,
              color: widget.nameController!.text.isEmpty
                  ? Colors.white.withValues(alpha: 0.5)
                  : Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    // Preview mode - tappable to edit
    if (widget.isPreviewMode && widget.onNameUpdated != null) {
      return GestureDetector(
        onTap: () => _showNamePickerInPreview(context),
        child: Text(
          widget.foodItem.name,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      );
    }

    return Text(
      widget.foodItem.name,
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
                  if (widget.isEditable && widget.caloriesController != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showCaloriesPicker(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: widget.caloriesController,
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
                        ),
                      ),
                    )
                  else if (widget.isLoading)
                    const AnimatedEllipsisWidget(
                      textStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  else if (widget.isPreviewMode && widget.onCaloriesUpdated != null)
                    GestureDetector(
                      onTap: () => _showCaloriesPickerInPreview(context),
                      child: Text(
                        '${widget.foodItem.calories.toInt()}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${widget.foodItem.calories.toInt()}',
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
                  if (widget.isEditable && widget.servingSizeController != null)
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _showServingSizePicker(context),
                        child: AbsorbPointer(
                          child: TextField(
                            controller: widget.servingSizeController,
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
                        ),
                      ),
                    )
                  else if (widget.isLoading)
                    const AnimatedEllipsisWidget(
                      textStyle: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  else if (widget.isPreviewMode && widget.onServingSizeUpdated != null)
                    GestureDetector(
                      onTap: () => _showServingSizePickerInPreview(context),
                      child: Text(
                        '${widget.foodItem.servingSize}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Text(
                      '${widget.foodItem.servingSize}',
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
            value: widget.foodItem.proteins,
            controller: widget.proteinController,
            color: NutritionColors.proteinColor,
            icon: Icons.set_meal,
            onPreviewTap: widget.isPreviewMode && widget.onProteinUpdated != null
                ? () => _showProteinPickerInPreview(context)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        // Carbs
        Expanded(
          child: _buildMacroPill(
            label: 'Carbs',
            value: widget.foodItem.carbs,
            controller: widget.carbsController,
            color: NutritionColors.carbsColor,
            icon: Icons.local_pizza,
            onPreviewTap: widget.isPreviewMode && widget.onCarbsUpdated != null
                ? () => _showCarbsPickerInPreview(context)
                : null,
          ),
        ),
        const SizedBox(width: 10),
        // Fat
        Expanded(
          child: _buildMacroPill(
            label: 'Fat',
            value: widget.foodItem.fats,
            controller: widget.fatController,
            color: NutritionColors.fatColor,
            icon: Icons.grain_rounded,
            onPreviewTap: widget.isPreviewMode && widget.onFatUpdated != null
                ? () => _showFatPickerInPreview(context)
                : null,
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
    VoidCallback? onPreviewTap,
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
            if (widget.isEditable && controller != null)
              Expanded(
                child: GestureDetector(
                  onTap: () => _showMacroPicker(context, label, controller),
                  child: AbsorbPointer(
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
                  ),
                ),
              )
            else if (widget.isLoading)
              const AnimatedEllipsisWidget(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              )
            else if (onPreviewTap != null)
              GestureDetector(
                onTap: onPreviewTap,
                child: Text(
                  '${value.toInt()}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

  /// Show calories picker dialog
  Future<void> _showCaloriesPicker(BuildContext context) async {
    final currentValue = int.tryParse(widget.caloriesController?.text ?? '0') ?? 0;
    final result = await FoodCardPickers.showCaloriesPicker(
      context: context,
      currentValue: currentValue,
    );
    if (result != null && widget.caloriesController != null) {
      widget.caloriesController!.text = result.toString();
    }
  }

  /// Show serving size picker dialog
  Future<void> _showServingSizePicker(BuildContext context) async {
    final currentValue = double.tryParse(widget.servingSizeController?.text ?? '1.0') ?? 1.0;
    final result = await FoodCardPickers.showServingSizePicker(
      context: context,
      currentValue: currentValue,
    );
    if (result != null && widget.servingSizeController != null) {
      widget.servingSizeController!.text = result.toString();
    }
  }

  /// Show macro nutrient picker dialog
  Future<void> _showMacroPicker(
    BuildContext context,
    String label,
    TextEditingController? controller,
  ) async {
    if (controller == null) return;

    final currentValue = int.tryParse(controller.text) ?? 0;
    final result = await FoodCardPickers.showMacroPicker(
      context: context,
      label: label,
      currentValue: currentValue,
    );
    if (result != null) {
      controller.text = result.toString();
    }
  }

  /// Show cost picker overlay (for editable mode)
  Future<void> _showCostPicker(BuildContext context) async {
    final currentValue = double.tryParse(widget.costController?.text ?? '0.0') ?? 0.0;

    final result = await FoodCardPickers.showCostPicker(
      currentValue: currentValue,
    );

    if (result != null && widget.costController != null) {
      setState(() {
        widget.costController!.text = result.toStringAsFixed(2);
      });
    }
  }

  /// Show cost picker dialog in preview mode
  /// Notifies parent to cancel the 8-second timer
  Future<void> _showCostPickerInPreview(BuildContext context) async {
    final currentValue = widget.foodItem.cost ?? 0.0;

    final result = await FoodCardPickers.showCostPickerInPreview(
      currentValue: currentValue,
      onCostPickerOpened: widget.onCostPickerOpened,
    );

    // Update the food item cost through callback
    if (result != null) {
      widget.onCostUpdated?.call(result);
    }
  }

  /// Show name picker in preview mode (cancels 8-second timer)
  Future<void> _showNamePickerInPreview(BuildContext context) async {
    widget.onCostPickerOpened?.call(); // Cancel timer

    final result = await showTextInputOverlay(
      title: 'Edit Food Name',
      initialValue: widget.foodItem.name,
      hintText: 'Food name',
    );

    if (result != null && result.isNotEmpty) {
      widget.onNameUpdated?.call(result);
    }
  }

  /// Show calories picker in preview mode (cancels 8-second timer)
  Future<void> _showCaloriesPickerInPreview(BuildContext context) async {
    final currentValue = widget.foodItem.calories.round();

    final result = await FoodCardPickers.showCaloriesPickerInPreview(
      context: context,
      currentValue: currentValue,
      onPickerOpened: widget.onCostPickerOpened,
    );

    if (result != null) {
      widget.onCaloriesUpdated?.call(result);
    }
  }

  /// Show serving size picker in preview mode (cancels 8-second timer)
  Future<void> _showServingSizePickerInPreview(BuildContext context) async {
    final currentValue = widget.foodItem.servingSize;

    final result = await FoodCardPickers.showServingSizePickerInPreview(
      context: context,
      currentValue: currentValue,
      onPickerOpened: widget.onCostPickerOpened,
    );

    if (result != null) {
      widget.onServingSizeUpdated?.call(result);
    }
  }

  /// Show protein picker in preview mode (cancels 8-second timer)
  Future<void> _showProteinPickerInPreview(BuildContext context) async {
    final currentValue = widget.foodItem.proteins.round();

    final result = await FoodCardPickers.showMacroPickerInPreview(
      context: context,
      label: 'Protein',
      currentValue: currentValue,
      onPickerOpened: widget.onCostPickerOpened,
    );

    if (result != null) {
      widget.onProteinUpdated?.call(result);
    }
  }

  /// Show carbs picker in preview mode (cancels 8-second timer)
  Future<void> _showCarbsPickerInPreview(BuildContext context) async {
    final currentValue = widget.foodItem.carbs.round();

    final result = await FoodCardPickers.showMacroPickerInPreview(
      context: context,
      label: 'Carbs',
      currentValue: currentValue,
      onPickerOpened: widget.onCostPickerOpened,
    );

    if (result != null) {
      widget.onCarbsUpdated?.call(result);
    }
  }

  /// Show fat picker in preview mode (cancels 8-second timer)
  Future<void> _showFatPickerInPreview(BuildContext context) async {
    final currentValue = widget.foodItem.fats.round();

    final result = await FoodCardPickers.showMacroPickerInPreview(
      context: context,
      label: 'Fat',
      currentValue: currentValue,
      onPickerOpened: widget.onCostPickerOpened,
    );

    if (result != null) {
      widget.onFatUpdated?.call(result);
    }
  }

  /// Build cost indicator (editable or display)
  Widget _buildCostIndicator() {
    // Helper function to format cost as dollar amount
    String getCostDisplay(double? cost) {
      if (cost == null || cost == 0) return '\$\$\$';
      return '\$${cost.toStringAsFixed(2)}';
    }

    final textStyle = TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      color: Colors.white.withValues(alpha: 0.9),
      letterSpacing: -0.5,
    );

    // Loading mode - hide cost indicator completely
    if (widget.isLoading) {
      return const SizedBox.shrink();
    }

    // Editable mode (edit dialog)
    if (widget.isEditable && widget.costController != null) {
      final currentCost = double.tryParse(widget.costController?.text ?? '0.0') ?? 0.0;

      return GestureDetector(
        onTap: () => _showCostPicker(context),
        child: Text(
          getCostDisplay(currentCost),
          style: textStyle,
        ),
      );
    }

    // Preview mode - check if cost entry is completed
    if (widget.isPreviewMode) {
      // If cost entry completed, show static cost (no animation)
      if (widget.costEntryCompleted) {
        return Text(
          getCostDisplay(widget.foodItem.cost),
          style: textStyle,
        );
      }

      // Otherwise, show animated cost indicator (tappable)
      return AnimatedCostIndicator(
        text: getCostDisplay(widget.foodItem.cost),
        textStyle: textStyle,
        onTap: () => _showCostPickerInPreview(context),
      );
    }

    // Display mode - static
    return Text(
      getCostDisplay(widget.foodItem.cost),
      style: textStyle,
    );
  }

  /// Show edit food name dialog
  Future<void> _showEditFoodNameDialog(BuildContext context) async {
    if (widget.nameController == null) return;

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => EditFoodNameDialog(
        initialValue: widget.nameController!.text,
      ),
    );

    if (result != null && mounted) {
      setState(() {
        widget.nameController!.text = result;
      });
    }
  }
}
