// lib/widgets/home/quick_edit_food_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import '../../config/design_system/nutrition_colors.dart';
import '../../config/design_system/theme_background.dart';
import '../../config/design_system/color_utils.dart';
import '../../config/constants/app_constants.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';
import '../../providers/theme_provider.dart';

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
  final FoodRepository _foodRepository = FoodRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _servingSizeController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _costController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.foodItem.name);
    _servingSizeController = TextEditingController(text: widget.foodItem.servingSize.toString());
    _caloriesController = TextEditingController(text: widget.foodItem.calories.round().toString());
    _proteinController = TextEditingController(text: widget.foodItem.proteins.round().toString());
    _carbsController = TextEditingController(text: widget.foodItem.carbs.round().toString());
    _fatController = TextEditingController(text: widget.foodItem.fats.round().toString());
    _costController = TextEditingController(
      text: widget.foodItem.cost?.toStringAsFixed(AppConstants.maxDecimalPlaces) ?? ''
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _costController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 340,
        constraints: const BoxConstraints(maxHeight: 680),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Arch Window Header
            _buildArchWindowHeader(),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Food Name Input
                    _buildFoodNameInput(),

                    const SizedBox(height: 28),

                    // Calories and Serving Size Row
                    _buildCaloriesServingRow(),

                    const SizedBox(height: 24),

                    // Macronutrients Section
                    _buildMacronutrientsSection(),
                  ],
                ),
              ),
            ),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildArchWindowHeader() {
    const double cardHeight = 550.0; // Fixed card height

    return SizedBox(
      height: cardHeight,
      child: Stack(
        children: [
          // Food image background (behind the card)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1567620905732-2d1ec7ab7445?w=800',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.restaurant_rounded,
                        size: 120,
                        color: Colors.grey[500],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Colored card with arch cutout using CustomPaint
          // Card color is complementary to background theme (Tone 2)
          Positioned.fill(
            child: CustomPaint(
              painter: ArchCardPainter(
                cardColor: ColorUtils.getComplementaryColor(
                  ThemeBackground.getColors(
                    context.watch<ThemeProvider>().selectedGradient,
                  )![1], // Tone 2 (index 1: second color from top)
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodNameInput() {
    return TextField(
      controller: _nameController,
      style: AppTypography.displaySmall.copyWith(
        color: const Color(0xFF1A1A1A),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
      ),
      decoration: InputDecoration(
        hintText: 'Food name',
        hintStyle: AppTypography.displaySmall.copyWith(
          color: const Color(0xFFD0D0D0),
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFE8E8E8), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: NutritionColors.primary, width: 2.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                  color: const Color(0xFF999999),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: NutritionColors.caloriesColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: NutritionColors.caloriesColor.withValues(alpha: 0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 20,
                      color: NutritionColors.caloriesColor,
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        controller: _caloriesController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: NutritionColors.caloriesColor,
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
              ),
            ],
          ),
        ),

        const SizedBox(width: 14),

        // Serving Size (Right - 50%)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SERVING SIZE',
                style: AppTypography.overline.copyWith(
                  color: const Color(0xFF999999),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      '×',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF999999),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: TextField(
                        controller: _servingSizeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMacronutrientsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MACRONUTRIENTS',
          style: AppTypography.overline.copyWith(
            color: const Color(0xFF999999),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            // Protein
            Expanded(
              child: _buildMacroPill(
                label: 'Protein',
                controller: _proteinController,
                color: NutritionColors.proteinColor,
                icon: Icons.fitness_center_rounded,
              ),
            ),
            const SizedBox(width: 10),
            // Carbs
            Expanded(
              child: _buildMacroPill(
                label: 'Carbs',
                controller: _carbsController,
                color: NutritionColors.carbsColor,
                icon: Icons.grain_rounded,
              ),
            ),
            const SizedBox(width: 10),
            // Fat
            Expanded(
              child: _buildMacroPill(
                label: 'Fat',
                controller: _fatController,
                color: NutritionColors.fatColor,
                icon: Icons.water_drop_rounded,
              ),
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: color,
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
              Text(
                'g',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
      child: Row(
        children: [
          // Delete button
          Expanded(
            child: FilledButton(
              onPressed: _isLoading ? null : _handleDelete,
              style: FilledButton.styleFrom(
                backgroundColor: NutritionColors.error.withValues(alpha: 0.1),
                foregroundColor: NutritionColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                'Delete',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Save button
          Expanded(
            child: FilledButton(
              onPressed: _isLoading ? null : _handleSave,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1A1A1A),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                _isLoading ? 'Saving...' : 'Save',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCostEditDialog() {
    final controller = TextEditingController(text: _costController.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Cost'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Cost per serving',
            prefixText: '\$',
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                _costController.text = controller.text;
              });
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _handleExport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export functionality coming soon!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSave() async {
    // Validate inputs
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      _showErrorSnackBar('Please enter a food name');
      return;
    }

    final servingSize = double.tryParse(_servingSizeController.text);
    if (servingSize == null || servingSize <= 0) {
      _showErrorSnackBar('Please enter a valid serving size');
      return;
    }

    final calories = double.tryParse(_caloriesController.text) ?? 0;
    final protein = double.tryParse(_proteinController.text) ?? 0;
    final carbs = double.tryParse(_carbsController.text) ?? 0;
    final fat = double.tryParse(_fatController.text) ?? 0;

    final costText = _costController.text.trim();
    final cost = costText.isNotEmpty ? double.tryParse(costText) : null;

    setState(() => _isLoading = true);

    try {
      // Create updated food item
      final updatedItem = widget.foodItem.copyWith(
        name: name,
        servingSize: servingSize,
        calories: calories,
        proteins: protein,
        carbs: carbs,
        fats: fat,
        cost: cost,
      );

      // Save to repository
      final success = await _foodRepository.storageService.updateFoodEntry(updatedItem);

      if (success) {
        if (mounted) {
          widget.onUpdated?.call();
          Navigator.of(context).pop();
        }
      } else {
        _showErrorSnackBar('Failed to save changes');
      }
    } catch (e) {
      debugPrint('Error saving food item: $e');
      _showErrorSnackBar('An error occurred while saving');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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
      setState(() => _isLoading = true);

      try {
        final success = await _foodRepository.storageService.deleteFoodEntry(
          widget.foodItem.id,
          widget.foodItem.timestamp,
        );

        if (success && mounted) {
          widget.onUpdated?.call();
          Navigator.of(context).pop();
        } else {
          _showErrorSnackBar('Failed to delete item');
        }
      } catch (e) {
        debugPrint('Error deleting food item: $e');
        _showErrorSnackBar('An error occurred while deleting');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
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
    final paint = Paint()
      ..color = cardColor
      ..style = PaintingStyle.fill;

    // SIMPLE APPROACH: Use RRect with rounded top corners for arch effect
    // Fixed dimensions for consistent design
    const double marginLeft = 25.0;
    const double marginRight = 25.0;
    const double marginTop = 60.0;
    const double archRadius = 145.0; // Large radius creates arch effect
    const double windowHeight = 345.0; // 145 (arch) + 200 (square portion)

    // Create the arch window using rounded rectangle
    // Large top corner radii create the arch effect
    final windowRect = RRect.fromRectAndCorners(
      Rect.fromLTRB(
        marginLeft,        // 25 - left edge
        marginTop,         // 60 - top edge
        340 - marginRight, // 315 - right edge
        marginTop + windowHeight, // 405 - bottom edge
      ),
      topLeft: const Radius.circular(145),     // Large radius = arch curve
      topRight: const Radius.circular(145),    // Large radius = arch curve
      bottomLeft: Radius.zero,                 // Sharp bottom corners
      bottomRight: Radius.zero,                // Sharp bottom corners
    );

    // Create paths for subtraction
    final outerPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, 340, size.height));

    final windowPath = Path()
      ..addRRect(windowRect);

    // Subtract window from card to create cutout
    final cardWithCutout = Path.combine(
      PathOperation.difference,
      outerPath,
      windowPath,
    );

    // Draw the card with the arch window cutout
    canvas.drawPath(cardWithCutout, paint);
  }

  @override
  bool shouldRepaint(covariant ArchCardPainter oldDelegate) {
    return oldDelegate.cardColor != cardColor;
  }
}
