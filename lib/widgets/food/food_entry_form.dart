// lib/widgets/food/food_entry_form.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/constants/app_constants.dart';  // ADDED: Import for constants
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';

class FoodEntryForm extends StatefulWidget {
  final String mealType;
  final FoodItem? initialFoodItem; // For editing existing items
  final Function() onSaved;

  // ✅ FIXED: Use super parameter instead of explicit key parameter
  const FoodEntryForm({
    super.key,
    required this.mealType,
    this.initialFoodItem,
    required this.onSaved,
  });

  @override
  State<FoodEntryForm> createState() => _FoodEntryFormState();
}

class _FoodEntryFormState extends State<FoodEntryForm> {
  final _formKey = GlobalKey<FormState>();
  final FoodRepository _repository = FoodRepository();
  bool _isLoading = false;

  // Form fields
  late TextEditingController _nameController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinsController;
  late TextEditingController _carbsController;
  late TextEditingController _fatsController;
  late TextEditingController _servingSizeController;
  late String _servingUnit;
  late String _selectedMealType;

  // FIXED: Use AppConstants instead of hardcoded arrays
  final List<String> _servingUnits = AppConstants.servingUnits;
  final List<String> _mealTypes = AppConstants.mealTypes;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with data if editing
    if (widget.initialFoodItem != null) {
      _nameController =
          TextEditingController(text: widget.initialFoodItem!.name);
      _caloriesController = TextEditingController(
          text: widget.initialFoodItem!.calories.round().toString());
      _proteinsController = TextEditingController(
          text: widget.initialFoodItem!.proteins.round().toString());
      _carbsController = TextEditingController(
          text: widget.initialFoodItem!.carbs.round().toString());
      _fatsController = TextEditingController(
          text: widget.initialFoodItem!.fats.round().toString());
      _servingSizeController = TextEditingController(
          text: widget.initialFoodItem!.servingSize.toString());
      _servingUnit = widget.initialFoodItem!.servingUnit;
      _selectedMealType = widget.initialFoodItem!.mealType;
    } else {
      // Default values for new entry
      _nameController = TextEditingController();
      _caloriesController = TextEditingController();
      _proteinsController = TextEditingController();
      _carbsController = TextEditingController();
      _fatsController = TextEditingController();
      _servingSizeController = TextEditingController(text: AppConstants.defaultServingSize.toString());
      _servingUnit = AppConstants.servingUnits[0]; // FIXED: Use AppConstants
      _selectedMealType = widget.mealType;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinsController.dispose();
    _carbsController.dispose();
    _fatsController.dispose();
    _servingSizeController.dispose();
    super.dispose();
  }

  Future<void> _saveFood() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final foodItem = FoodItem(
          id: widget.initialFoodItem?.id ?? 'food_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          calories: double.parse(_caloriesController.text),
          proteins: double.parse(_proteinsController.text),
          carbs: double.parse(_carbsController.text),
          fats: double.parse(_fatsController.text),
          servingSize: double.parse(_servingSizeController.text),
          servingUnit: _servingUnit,
          mealType: _selectedMealType,
          timestamp: widget.initialFoodItem?.timestamp ?? DateTime.now(),
          imagePath: widget.initialFoodItem?.imagePath,
        );

        final success = await _repository.saveFoodEntry(foodItem);

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.initialFoodItem != null ? 'Food updated successfully!' : 'Food saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onSaved();
          Navigator.of(context).pop();
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save food. Please try again.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.initialFoodItem != null ? 'Edit Food' : 'Add Food',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
        backgroundColor: AppTheme.secondaryBeige,
        elevation: 0,
      ),
      backgroundColor: AppTheme.secondaryBeige,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Food Name
              _buildTextField(
                controller: _nameController,
                label: 'Food Name',
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return AppConstants.nameRequired;
                  }
                  if (value!.length > AppConstants.maxFoodNameLength) {
                    return AppConstants.nameTooLong;
                  }
                  return null;
                },
                inputFormatters: [
                  LengthLimitingTextInputFormatter(AppConstants.maxFoodNameLength),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Meal Type Dropdown
              _buildDropdown(
                label: 'Meal Type',
                value: _selectedMealType,
                items: _mealTypes,
                onChanged: (value) => setState(() => _selectedMealType = value!),
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Serving Information
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildTextField(
                      controller: _servingSizeController,
                      label: 'Serving Size',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed <= 0) {
                          return AppConstants.invalidServingSize;
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    flex: 1,
                    child: _buildDropdown(
                      label: 'Unit',
                      value: _servingUnit,
                      items: _servingUnits,
                      onChanged: (value) => setState(() => _servingUnit = value!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingLarge),

              // Nutrition Information
              Text(
                'Nutrition Information',
                style: AppTextStyles.getSubHeadingStyle().copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryBlue,
                ),
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Calories
              _buildTextField(
                controller: _caloriesController,
                label: 'Calories',
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value ?? '');
                  if (parsed == null || parsed < 0) {
                    return AppConstants.invalidCalories;
                  }
                  return null;
                },
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                ],
              ),

              const SizedBox(height: AppConstants.spacingMedium),

              // Macronutrients Row
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _proteinsController,
                      label: 'Protein (g)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return AppConstants.invalidProtein;
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: _buildTextField(
                      controller: _carbsController,
                      label: 'Carbs (g)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return AppConstants.invalidCarbs;
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingMedium),
                  Expanded(
                    child: _buildTextField(
                      controller: _fatsController,
                      label: 'Fat (g)',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final parsed = double.tryParse(value ?? '');
                        if (parsed == null || parsed < 0) {
                          return AppConstants.invalidFat;
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppConstants.spacingXLarge),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveFood,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingMedium),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.initialFoodItem != null ? 'Update Food' : 'Save Food',
                          style: AppTextStyles.getBodyStyle().copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppConstants.paddingMedium,
          vertical: AppConstants.paddingSmall,
        ),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(
            item.capitalized,
            style: AppTextStyles.getBodyStyle(),
          ),
        );
      }).toList(),
    );
  }
}