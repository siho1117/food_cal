// lib/widgets/home/quick_edit_food_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/food_repository.dart';
import '../../providers/home_provider.dart';

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
  
  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  
  late String _selectedUnit;
  bool _isLoading = false;
  
  final List<String> _units = [
    'serving', 'cup', 'gram', 'oz', 'piece', 'slice', 'tbsp', 'tsp'
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.foodItem.name);
    _servingSizeController = TextEditingController(text: widget.foodItem.servingSize.toString());
    _caloriesController = TextEditingController(text: widget.foodItem.calories.round().toString());
    _proteinController = TextEditingController(text: widget.foodItem.proteins.round().toString());
    _carbsController = TextEditingController(text: widget.foodItem.carbs.round().toString());
    _fatController = TextEditingController(text: widget.foodItem.fats.round().toString());
    _selectedUnit = widget.foodItem.servingUnit;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(0),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      title: _buildDialogTitle(),
      content: _isLoading ? _buildLoadingContent() : _buildEditContent(),
      actions: _buildDialogActions(),
    );
  }

  Widget _buildDialogTitle() {
    return Row(
      children: [
        Text('✏️', style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          'Edit Food',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryBlue,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingContent() {
    return const SizedBox(
      height: 300,
      child: Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildEditContent() {
    return Container(
      width: double.maxFinite,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBasicInfoSection(),
            const SizedBox(height: 16),
            _buildNutritionSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.keyboard_arrow_down, size: 20, color: AppTheme.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  'Basic Information',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryBlue,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          
          // Section Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Food Name Section - Label above input
                Text(
                  'Food Name:',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    counterText: '',
                    isDense: true,
                  ),
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textCapitalization: TextCapitalization.words,
                  inputFormatters: [LengthLimitingTextInputFormatter(100)],
                ),
                
                const SizedBox(height: 16),
                
                // Serving Size Section - Better spacing
                Text(
                  'Serving Size:',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                // Amount Controls Row
                Row(
                  children: [
                    _buildServingAdjustButton(Icons.remove, () => _adjustServing(-0.1)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _servingSizeController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          isDense: true,
                        ),
                        style: AppTextStyles.getNumericStyle().copyWith(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _buildServingAdjustButton(Icons.add, () => _adjustServing(0.1)),
                  ],
                ),
                const SizedBox(height: 12), // 12 spacing before unit dropdown
                // Unit Dropdown - Full Width
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    isDense: true,
                    labelText: 'Unit',
                    labelStyle: AppTextStyles.getBodyStyle().copyWith(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  items: _units.map((unit) => DropdownMenuItem(
                    value: unit,
                    child: Text(unit, style: AppTextStyles.getBodyStyle().copyWith(fontSize: 14)),
                  )).toList(),
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
    );
  }

  Widget _buildNutritionSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.green[700]),
                const SizedBox(width: 8),
                Text(
                  'Nutrition (per serving)',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontWeight: FontWeight.w700,
                    color: Colors.green[700],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildNutritionRow('🔥', 'Calories', _caloriesController, 'cal'),
                const SizedBox(height: 12),
                _buildNutritionRow('🥩', 'Protein', _proteinController, 'g'),
                const SizedBox(height: 12),
                _buildNutritionRow('🍞', 'Carbs', _carbsController, 'g'),
                const SizedBox(height: 12),
                _buildNutritionRow('🥑', 'Fat', _fatController, 'g'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String emoji, String label, TextEditingController controller, String unit) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(
            '$label:',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              suffixText: unit,
              suffixStyle: AppTextStyles.getBodyStyle().copyWith(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
              isDense: true,
            ),
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              LengthLimitingTextInputFormatter(8),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServingAdjustButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, size: 18, color: AppTheme.primaryBlue),
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  List<Widget> _buildDialogActions() {
    return [
      TextButton(
        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
        child: Text(
          'Cancel',
          style: AppTextStyles.getBodyStyle().copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      const SizedBox(width: 8),
      ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        ),
        child: Text(
          _isLoading ? 'Saving...' : 'Save',
          style: AppTextStyles.getBodyStyle().copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ];
  }

  void _adjustServing(double adjustment) {
    final current = double.tryParse(_servingSizeController.text) ?? 1.0;
    final newValue = (current + adjustment).clamp(0.1, 99.9);
    _servingSizeController.text = newValue.toStringAsFixed(1);
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
    final name = _nameController.text.trim();
    final servingSizeText = _servingSizeController.text.trim();
    final caloriesText = _caloriesController.text.trim();
    final proteinText = _proteinController.text.trim();
    final carbsText = _carbsController.text.trim();
    final fatText = _fatController.text.trim();

    // Validation
    if (name.isEmpty) {
      throw Exception('Food name cannot be empty.');
    }
    if (name.length > 100) {
      throw Exception('Food name must be 100 characters or less.');
    }
    
    final servingSize = double.tryParse(servingSizeText);
    final calories = double.tryParse(caloriesText);
    final protein = double.tryParse(proteinText);
    final carbs = double.tryParse(carbsText);
    final fat = double.tryParse(fatText);

    if (servingSize == null || servingSize <= 0) {
      throw Exception('Serving size must be a positive number.');
    }
    if (calories == null || calories < 0) {
      throw Exception('Calories must be a non-negative number.');
    }
    if (protein == null || protein < 0) {
      throw Exception('Protein must be a non-negative number.');
    }
    if (carbs == null || carbs < 0) {
      throw Exception('Carbs must be a non-negative number.');
    }
    if (fat == null || fat < 0) {
      throw Exception('Fat must be a non-negative number.');
    }

    // Upper bounds validation
    if (servingSize > 100) throw Exception('Serving size seems too large (max 100).');
    if (calories > 10000) throw Exception('Calories seem too high (max 10,000).');
    if (protein > 1000) throw Exception('Protein amount seems too high (max 1,000g).');
    if (carbs > 1000) throw Exception('Carbs amount seems too high (max 1,000g).');
    if (fat > 1000) throw Exception('Fat amount seems too high (max 1,000g).');

    final updatedItem = widget.foodItem.copyWith(
      name: name,
      servingSize: servingSize,
      servingUnit: _selectedUnit,
      calories: calories,
      proteins: protein,
      carbs: carbs,
      fats: fat,
    );

    final success = await _foodRepository.updateFoodEntry(updatedItem);
    
    if (!success) {
      throw Exception('Database update failed. Please try again.');
    }
  }
}