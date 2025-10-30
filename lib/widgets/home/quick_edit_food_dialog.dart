// lib/widgets/home/quick_edit_food_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme_design.dart';
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
  
  late String _selectedUnit;
  bool _isLoading = false;

  // Local UI constants (since they were removed from AppConstants)
  static const double _borderRadiusLarge = 16.0;
  static const double _borderRadiusMedium = 12.0;
  static const double _borderRadiusSmall = 8.0;
  static const double _spacingSmall = 8.0;
  static const double _spacingMedium = 16.0;
  static const double _spacingLarge = 20.0;
  static const double _paddingMedium = 16.0;
  static const double _paddingSmall = 8.0;
  static const double _emojiSize = 20.0;
  static const double _fontSizeXLarge = 18.0;
  static const double _fontSizeMedium = 14.0;
  static const double _iconSizeMedium = 20.0;

  @override
  void initState() {
    super.initState();
    
    _nameController = TextEditingController(text: widget.foodItem.name);
    _servingSizeController = TextEditingController(text: widget.foodItem.servingSize.toString());
    _caloriesController = TextEditingController(text: widget.foodItem.calories.round().toString());
    _proteinController = TextEditingController(text: widget.foodItem.proteins.round().toString());
    _carbsController = TextEditingController(text: widget.foodItem.carbs.round().toString());
    _fatController = TextEditingController(text: widget.foodItem.fats.round().toString());
    _selectedUnit = widget.foodItem.servingUnit;
    
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadiusLarge)),
      title: _buildTitle(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: _spacingLarge),
            _buildNutritionInfo(),
            if (widget.foodItem.cost != null) ...[
              const SizedBox(height: _spacingLarge),
              _buildCostInfo(),
            ],
          ],
        ),
      ),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Text('🍽️', style: TextStyle(fontSize: _emojiSize)),
        const SizedBox(width: _spacingSmall),
        Text(
          'Edit Food Item',
          style: AppTypography.displaySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppLegacyColors.primaryBlue,
            fontSize: _fontSizeXLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(_paddingMedium),
            decoration: BoxDecoration(
              color: AppLegacyColors.primaryBlue.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_borderRadiusMedium),
                topRight: Radius.circular(_borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.edit, color: AppLegacyColors.primaryBlue, size: _iconSizeMedium),
                const SizedBox(width: _spacingSmall),
                Text(
                  'Basic Information',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppLegacyColors.primaryBlue,
                    fontSize: _fontSizeMedium + 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_paddingMedium),
            child: Column(
              children: [
                _buildTextField(_nameController, 'Food Name', 'e.g., Grilled Chicken'),
                const SizedBox(height: _spacingMedium),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildTextField(_servingSizeController, 'Serving Size', AppConstants.defaultServingSize.toString()),
                    ),
                    const SizedBox(width: _spacingMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit:',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: _fontSizeMedium,
                            ),
                          ),
                          const SizedBox(height: _spacingSmall),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(_borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: _paddingMedium,
                                vertical: _paddingSmall,
                              ),
                              isDense: true,
                            ),
                            items: AppConstants.servingUnits.map((unit) {
                              return DropdownMenuItem(value: unit, child: Text(unit));
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedUnit = value!;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(_paddingMedium),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_borderRadiusMedium),
                topRight: Radius.circular(_borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.green[700], size: _iconSizeMedium),
                const SizedBox(width: _spacingSmall),
                Text(
                  'Nutrition Facts',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.green[700],
                    fontSize: _fontSizeMedium + 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_paddingMedium),
            child: Column(
              children: [
                _buildNutritionField(_caloriesController, 'Calories', 'kcal'),
                const SizedBox(height: _spacingMedium),
                _buildNutritionField(_proteinController, 'Protein', 'g'),
                const SizedBox(height: _spacingMedium),
                _buildNutritionField(_carbsController, 'Carbs', 'g'),
                const SizedBox(height: _spacingMedium),
                _buildNutritionField(_fatController, 'Fat', 'g'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(_borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(_paddingMedium),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(_borderRadiusMedium),
                topRight: Radius.circular(_borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, color: Colors.orange[700], size: _iconSizeMedium),
                const SizedBox(width: _spacingSmall),
                Text(
                  'Cost Information',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.orange[700],
                    fontSize: _fontSizeMedium + 1,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(_paddingMedium),
            child: _buildNutritionField(_costController, 'Cost', '\$'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: _fontSizeMedium,
          ),
        ),
        const SizedBox(height: _spacingSmall),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadiusSmall),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadiusSmall),
              borderSide: const BorderSide(color: AppLegacyColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _paddingMedium,
              vertical: _paddingSmall,
            ),
            isDense: true,
          ),
          style: AppTypography.bodyMedium.copyWith(
            fontSize: _fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
          inputFormatters: controller == _nameController
            ? [LengthLimitingTextInputFormatter(AppConstants.maxFoodNameLength)]
            : [FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern))],
        ),
      ],
    );
  }

  Widget _buildNutritionField(TextEditingController controller, String label, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: _fontSizeMedium,
          ),
        ),
        const SizedBox(height: _spacingSmall),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadiusSmall),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadiusSmall),
              borderSide: const BorderSide(color: AppLegacyColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: _paddingMedium,
              vertical: _paddingSmall,
            ),
            suffixText: unit,
            suffixStyle: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: _fontSizeMedium,
            ),
            isDense: true,
          ),
          style: AppTypography.labelLarge.copyWith(
            fontSize: _fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        child: Text(
          AppConstants.cancelLabel,
          style: AppTypography.bodyMedium.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppLegacyColors.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_borderRadiusSmall)),
        ),
        child: Text(_isLoading ? 'Saving...' : 'Save Changes'),
      ),
    ];
  }

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    final servingSize = double.tryParse(_servingSizeController.text);
    final calories = double.tryParse(_caloriesController.text);
    final protein = double.tryParse(_proteinController.text);
    final carbs = double.tryParse(_carbsController.text);
    final fat = double.tryParse(_fatController.text);
    final cost = _costController.text.isNotEmpty ? double.tryParse(_costController.text) : null;

    if (name.isEmpty || servingSize == null || calories == null || protein == null || carbs == null || fat == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final updatedItem = widget.foodItem.copyWith(
        name: name,
        servingSize: servingSize,
        servingUnit: _selectedUnit,
        calories: calories,
        proteins: protein,
        carbs: carbs,
        fats: fat,
        cost: cost,
      );

      await _foodRepository.updateFoodEntry(updatedItem);

      if (mounted) {
        Navigator.of(context).pop();
        widget.onUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Food item updated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating food item: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}