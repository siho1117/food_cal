// lib/widgets/home/quick_edit_food_dialog.dart
// UPDATED VERSION - Now uses AppConstants

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/constants/app_constants.dart';  // NEW IMPORT
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
  
  // PROPER FIX: Initialize controllers directly
  late final TextEditingController _nameController;
  late final TextEditingController _servingSizeController;
  late final TextEditingController _caloriesController;
  late final TextEditingController _proteinController;
  late final TextEditingController _carbsController;
  late final TextEditingController _fatController;
  late final TextEditingController _costController;
  
  late String _selectedUnit;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    // PROPER INITIALIZATION: Initialize all controllers in initState
    _nameController = TextEditingController(text: widget.foodItem.name);
    _servingSizeController = TextEditingController(text: widget.foodItem.servingSize.toString());
    _caloriesController = TextEditingController(text: widget.foodItem.calories.round().toString());
    _proteinController = TextEditingController(text: widget.foodItem.proteins.round().toString());
    _carbsController = TextEditingController(text: widget.foodItem.carbs.round().toString());
    _fatController = TextEditingController(text: widget.foodItem.fats.round().toString());
    _selectedUnit = widget.foodItem.servingUnit;
    
    // PROPER COST INITIALIZATION: Handle null cost properly
    _costController = TextEditingController(
      text: widget.foodItem.cost?.toStringAsFixed(AppConstants.maxDecimalPlaces) ?? ''
    );
  }

  @override
  void dispose() {
    // CRITICAL: Dispose all controllers to prevent memory leaks
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
      title: _buildTitle(),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBasicInfo(),
            const SizedBox(height: AppConstants.spacingLarge),
            _buildNutritionInfo(),
            if (widget.foodItem.cost != null) ...[
              const SizedBox(height: AppConstants.spacingLarge),
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
        const Text('🍽️', style: TextStyle(fontSize: AppConstants.emojiSize)),
        const SizedBox(width: AppConstants.spacingSmall),
        Text(
          'Edit Food Item',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
            fontSize: AppConstants.fontSizeXLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                topRight: Radius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit, color: AppTheme.primaryBlue, size: AppConstants.iconSizeMedium),
                const SizedBox(width: AppConstants.spacingSmall),
                Text(
                  'Basic Information',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                    fontSize: AppConstants.fontSizeMedium + 1, // 15
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                // Food Name
                _buildTextField(_nameController, 'Food Name', 'e.g., Grilled Chicken'),
                
                const SizedBox(height: AppConstants.spacingMedium),
                
                // Serving Size and Unit
                Row(
                  children: [
                    // Serving Size
                    Expanded(
                      flex: 2,
                      child: _buildTextField(_servingSizeController, 'Serving Size', AppConstants.defaultServingSize.toString()),
                    ),
                    const SizedBox(width: AppConstants.spacingMedium),
                    
                    // Unit Dropdown
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Unit:',
                            style: AppTextStyles.getBodyStyle().copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: AppConstants.fontSizeMedium,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spacingSmall),
                          DropdownButtonFormField<String>(
                            value: _selectedUnit,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                                borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppConstants.paddingMedium,
                                vertical: AppConstants.paddingSmall,
                              ),
                              isDense: true,
                            ),
                            items: AppConstants.servingUnits.map((unit) => DropdownMenuItem(
                              value: unit,
                              child: Text(unit),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedUnit = value;
                                });
                              }
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
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                topRight: Radius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.restaurant, color: AppTheme.primaryBlue, size: AppConstants.iconSizeMedium),
                const SizedBox(width: AppConstants.spacingSmall),
                Text(
                  'Nutrition Information',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                    fontSize: AppConstants.fontSizeMedium + 1, // 15
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: Column(
              children: [
                // Row 1: Calories and Protein
                Row(
                  children: [
                    Expanded(child: _buildNutritionField(_caloriesController, 'Calories', 'cal')),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Expanded(child: _buildNutritionField(_proteinController, 'Protein', 'g')),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingMedium),
                
                // Row 2: Carbs and Fat
                Row(
                  children: [
                    Expanded(child: _buildNutritionField(_carbsController, 'Carbs', 'g')),
                    const SizedBox(width: AppConstants.spacingMedium),
                    Expanded(child: _buildNutritionField(_fatController, 'Fat', 'g')),
                  ],
                ),
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
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          Container(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppConstants.borderRadiusMedium),
                topRight: Radius.circular(AppConstants.borderRadiusMedium),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.attach_money, color: Colors.green[700], size: AppConstants.iconSizeMedium),
                const SizedBox(width: AppConstants.spacingSmall),
                Text(
                  'Cost Information',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.green[700],
                    fontSize: AppConstants.fontSizeMedium + 1, // 15
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: _buildTextField(_costController, 'Cost per serving', '0.00', prefix: '\$'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, String hint, {String? prefix}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: AppTextStyles.getBodyStyle().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            hintText: hint,
            prefixText: prefix,
            isDense: true,
          ),
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: AppConstants.fontSizeMedium,
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
          style: AppTextStyles.getBodyStyle().copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingSmall,
            ),
            suffixText: unit,
            suffixStyle: AppTextStyles.getBodyStyle().copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
              fontSize: AppConstants.fontSizeMedium,
            ),
            isDense: true,
          ),
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: AppConstants.fontSizeMedium,
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
          style: AppTextStyles.getBodyStyle().copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall)),
        ),
        child: Text(
          _isLoading ? AppConstants.savingMessage : AppConstants.saveLabel,
          style: AppTextStyles.getBodyStyle().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  Future<void> _handleSave() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _updateFoodItem();
      
      if (mounted) {
        HapticFeedback.lightImpact();
        Navigator.of(context).pop();
        widget.onUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _updateFoodItem() async {
    // Validation using constants
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      throw Exception(AppConstants.nameRequired);
    }
    if (name.length > AppConstants.maxFoodNameLength) {
      throw Exception(AppConstants.nameTooLong);
    }

    final servingSize = double.tryParse(_servingSizeController.text.trim());
    if (servingSize == null || servingSize <= 0) {
      throw Exception(AppConstants.invalidServingSize);
    }

    final calories = double.tryParse(_caloriesController.text.trim());
    if (calories == null || calories < 0) {
      throw Exception(AppConstants.invalidCalories);
    }

    final protein = double.tryParse(_proteinController.text.trim());
    if (protein == null || protein < 0) {
      throw Exception(AppConstants.invalidProtein);
    }

    final carbs = double.tryParse(_carbsController.text.trim());
    if (carbs == null || carbs < 0) {
      throw Exception(AppConstants.invalidCarbs);
    }

    final fat = double.tryParse(_fatController.text.trim());
    if (fat == null || fat < 0) {
      throw Exception(AppConstants.invalidFat);
    }

    // Cost validation (optional field)
    double? cost;
    final costText = _costController.text.trim();
    if (costText.isNotEmpty) {
      cost = double.tryParse(costText);
      if (cost == null || cost < 0) {
        throw Exception(AppConstants.invalidCost);
      }
    }

    // Create updated food item
    final updatedFoodItem = widget.foodItem.copyWith(
      name: name,
      servingSize: servingSize,
      servingUnit: _selectedUnit,
      calories: calories,
      proteins: protein,
      carbs: carbs,
      fats: fat,
      cost: cost,
    );

    // Save to repository
    final success = await _foodRepository.updateFoodEntry(updatedFoodItem);
    if (!success) {
      throw Exception('Failed to update food item. Please try again.');
    }
  }
}