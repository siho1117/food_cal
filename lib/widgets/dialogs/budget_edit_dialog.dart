// lib/widgets/dialogs/budget_edit_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/home_provider.dart';

class BudgetEditDialog extends StatefulWidget {
  final double currentBudget;
  final HomeProvider? homeProvider; // Optional for direct provider updates
  final Function(double)? onBudgetSaved; // Optional callback for manual handling
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
      text: widget.currentBudget.toStringAsFixed(2),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: _buildTitle(),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        const Text('💰', style: TextStyle(fontSize: 20)),
        const SizedBox(width: 8),
        Text(
          widget.title ?? 'Set Daily Budget',
          style: AppTextStyles.getSubHeadingStyle().copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
            fontSize: 18,
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
          'How much do you want to spend on food per day?',
          style: AppTextStyles.getBodyStyle().copyWith(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        
        // Budget input field
        TextField(
          controller: _budgetController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          inputFormatters: [
            // FIXED: Complete the regex pattern for decimal numbers
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: 'Daily Budget',
            prefixText: '\$',
            hintText: '20.00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.green[600]!, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
          ),
          onSubmitted: (_) => _handleSave(),
        ),
        
        const SizedBox(height: 12),
        
        // Quick preset buttons
        _buildPresetButtons(),
        
        const SizedBox(height: 12),
        
        // Helpful tip
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green[200]!, width: 1),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Colors.green[600], size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Consider your food goals and spending habits',
                  style: AppTextStyles.getBodyStyle().copyWith(
                    fontSize: 11,
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
          const SizedBox(height: 16),
          _buildAdvancedOptions(),
        ],
      ],
    );
  }

  Widget _buildPresetButtons() {
    final presets = [
      {'label': 'Frugal', 'amount': 15.0, 'color': Colors.blue[600]!},
      {'label': 'Moderate', 'amount': 25.0, 'color': Colors.green[600]!},
      {'label': 'Generous', 'amount': 40.0, 'color': Colors.orange[600]!},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick presets:',
          style: AppTextStyles.getBodyStyle().copyWith(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: presets.map((preset) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: OutlinedButton(
                  onPressed: () {
                    _budgetController.text = (preset['amount'] as double).toStringAsFixed(2);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: preset['color'] as Color,
                    side: BorderSide(color: preset['color'] as Color),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        preset['label'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '\$${(preset['amount'] as double).toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 11),
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

  Widget _buildAdvancedOptions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Budget Overview',
            style: AppTextStyles.getBodyStyle().copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
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
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: AppTextStyles.getNumericStyle().copyWith(
            fontSize: 11,
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
          'Cancel',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
      ElevatedButton(
        onPressed: _isLoading ? null : _handleSave,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
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

    // Validation
    if (budget == null || budget <= 0) {
      _showErrorSnackBar('Please enter a valid budget amount');
      return;
    }

    if (budget > 1000) {
      _showErrorSnackBar('Budget seems high. Please check the amount.');
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Daily budget set to \$${budget.toStringAsFixed(2)}'),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorSnackBar('Failed to save budget. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[400],
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}