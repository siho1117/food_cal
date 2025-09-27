// lib/widgets/dialogs/budget_edit_dialog.dart
// UPDATED VERSION - Now uses AppConstants

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/text_styles.dart';
import '../../config/constants/app_constants.dart';  // NEW IMPORT
import '../../providers/home_provider.dart';

class BudgetEditDialog extends StatefulWidget {
  final double currentBudget;
  final HomeProvider? homeProvider;
  final Function(double)? onBudgetSaved;
  final String? title;
  final bool showAdvancedOptions;

  const BudgetEditDialog({
    super.key,
    required this.currentBudget,
    this.homeProvider,
    this.onBudgetSaved,
    this.title,
    this.showAdvancedOptions = false,
  });

  @override
  State<BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<BudgetEditDialog> {
  late TextEditingController _budgetController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _budgetController = TextEditingController(
      text: widget.currentBudget.toStringAsFixed(AppConstants.maxDecimalPlaces),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.borderRadiusLarge)),
      title: _buildTitle(),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Text('💰', style: TextStyle(fontSize: AppConstants.emojiSize)),
        const SizedBox(width: AppConstants.spacingSmall),
        Text(
          widget.title ?? 'Set Daily Budget',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
            fontSize: AppConstants.fontSizeXLarge,
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppConstants.budgetQuestion,
          style: AppTextStyles.getBodyStyle().copyWith(
            color: Colors.grey[600],
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),
        const SizedBox(height: AppConstants.spacingMedium),
        
        // Budget input field
        TextField(
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(AppConstants.decimalNumberPattern)),
          ],
          decoration: InputDecoration(
            labelText: 'Daily Budget',
            prefixText: '\$',
            hintText: '20.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: BorderSide(color: Colors.green[600]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onSubmitted: (_) => _handleSave(),
        ),
        
        const SizedBox(height: AppConstants.spacingMedium),
        
        // Quick preset buttons
        _buildPresetButtons(),
        
        const SizedBox(height: AppConstants.spacingMedium),
        
        // Helpful tip
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
            border: Border.all(color: Colors.green[200]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green[600], size: AppConstants.iconSizeSmall),
              const SizedBox(width: AppConstants.spacingSmall),
              Expanded(
                child: Text(
                  AppConstants.budgetAdvice,
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: AppConstants.fontSizeSmall,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Advanced options (for settings page)
        if (widget.showAdvancedOptions) ...[
          const SizedBox(height: AppConstants.spacingMedium),
          _buildAdvancedOptions(),
        ],
      ],
    );
  }

  Widget _buildPresetButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick presets:',
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: AppConstants.fontSizeMedium,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppConstants.spacingSmall),
        Row(
          children: AppConstants.budgetPresets.map((preset) {
            final color = _getPresetColor(preset['label'] as String);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: OutlinedButton(
                  onPressed: () {
                    _budgetController.text = (preset['amount'] as double).toStringAsFixed(AppConstants.maxDecimalPlaces);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.spacingSmall)),
                    padding: const EdgeInsets.symmetric(vertical: AppConstants.spacingSmall),
                  ),
                  child: Column(
                    children: [
                      Text(
                        preset['label'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${(preset['amount'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: AppConstants.fontSizeSmall),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getPresetColor(String label) {
    switch (label) {
      case 'Frugal':
        return Colors.blue[600]!;
      case 'Moderate':
        return Colors.green[600]!;
      case 'Generous':
        return Colors.orange[600]!;
      default:
        return Colors.grey[600]!;
    }
  }

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Overview',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: AppConstants.spacingSmall),
          _buildBudgetCalculation(),
        ],
      ),
    );
  }

  Widget _buildBudgetCalculation() {
    final budget = double.tryParse(_budgetController.text) ?? widget.currentBudget;
    
    return Column(
      children: [
        _buildBudgetRow('Weekly', budget * 7),
        const SizedBox(height: 4),
        _buildBudgetRow('Monthly', budget * 30),
        const SizedBox(height: 4),
        _buildBudgetRow('Yearly', budget * 365),
      ],
    );
  }

  Widget _buildBudgetRow(String period, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          period,
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: AppConstants.fontSizeSmall,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: AppConstants.fontSizeSmall,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
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
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
      ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: AppConstants.iconSizeSmall,
                height: AppConstants.iconSizeSmall,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Save Budget'),
      ),
    ];
  }

  Future<void> _handleSave() async {
    final budgetText = _budgetController.text.trim();
    final budget = double.tryParse(budgetText);

    // Validation using constants
    if (budget == null || budget <= 0) {
      _showErrorSnackBar(AppConstants.invalidBudget);
      return;
    }

    if (budget > AppConstants.maxBudgetAmount) {
      _showErrorSnackBar(AppConstants.budgetTooHigh);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Option 1: Use provider directly (for cost summary widget)
      if (widget.homeProvider != null) {
        await widget.homeProvider!.setDailyFoodBudget(budget);
      }

      // Option 2: Use callback (for settings page or custom handling)
      if (widget.onBudgetSaved != null) {
        widget.onBudgetSaved!(budget);
      }

      if (mounted) {
        Navigator.of(context).pop();
        _showSuccessSnackBar(AppConstants.budgetUpdateSuccess);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Failed to save budget: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}