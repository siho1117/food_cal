// lib/widgets/home/quick_edit_food_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import '../../config/constants/app_constants.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';

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
    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      
      title: const Text(
        'Edit Food Item',
        style: AppDialogTheme.titleStyle,
      ),
      
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cost (Optional) - AT TOP
            _buildSectionLabel('Cost (Optional)'),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _costController,
              label: 'Price per serving',
              placeholder: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Basic Information
            _buildSectionLabel('Basic Information'),
            const SizedBox(height: 12),
            _buildInputField(
              controller: _nameController,
              label: 'Food Name',
              placeholder: 'e.g., Grilled Chicken',
              inputFormatters: [
                LengthLimitingTextInputFormatter(AppConstants.maxFoodNameLength),
              ],
            ),
            const SizedBox(height: 16),
            _buildInputField(
              controller: _servingSizeController,
              label: 'Serving Size',
              placeholder: '1.0',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Nutrition Information
            _buildSectionLabel('Nutrition (per serving)'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _caloriesController,
                    label: 'Calories',
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    controller: _proteinController,
                    label: 'Protein (g)',
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInputField(
                    controller: _carbsController,
                    label: 'Carbs (g)',
                    placeholder: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildInputField(
                    controller: _fatController,
                    label: 'Fat (g)',
                    placeholder: '0',
                    keyboardType: TextInputType.number,
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
      
      // ✅ ALL ACTIONS ON ONE LINE
      actions: [
        Row(
          children: [
            // Delete button (left-aligned)
            FilledButton(
              onPressed: _isLoading ? null : _handleDelete,
              style: AppDialogTheme.destructiveButtonStyle,
              child: const Text('Delete'),
            ),
            
            const Spacer(),
            
            // Cancel button
            TextButton(
              onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
              style: AppDialogTheme.cancelButtonStyle,
              child: const Text('Cancel'),
            ),
            
            const SizedBox(width: AppDialogTheme.buttonGap),
            
            // Save button
            FilledButton(
              onPressed: _isLoading ? null : _handleSave,
              style: AppDialogTheme.primaryButtonStyle,
              child: Text(_isLoading ? 'Saving...' : 'Save'),
            ),
          ],
        ),
      ],
    );
  }

  // ✅ BOLD SECTION HEADERS
  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTypography.labelMedium.copyWith(
        color: const Color(0xFF374151),
        fontWeight: FontWeight.bold, // ✅ BOLD
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6b7280),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppDialogTheme.inputTextStyle,
          decoration: AppDialogTheme.inputDecoration(hintText: placeholder),
        ),
      ],
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
      final success = await _foodRepository.updateFoodEntry(updatedItem);

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
        final success = await _foodRepository.deleteFoodEntry(
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