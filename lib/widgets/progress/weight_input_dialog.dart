// lib/widgets/progress/weight_input_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';

class WeightInputDialog extends StatefulWidget {
  final double? currentWeight;
  final bool isMetric;
  final Function(double, bool) onWeightEntered;

  const WeightInputDialog({
    super.key,
    required this.currentWeight,
    required this.isMetric,
    required this.onWeightEntered,
  });

  @override
  State<WeightInputDialog> createState() => _WeightInputDialogState();
}

class _WeightInputDialogState extends State<WeightInputDialog> {
  late TextEditingController _weightController;
  late bool _localIsMetric;

  @override
  void initState() {
    super.initState();
    _localIsMetric = widget.isMetric;
    _weightController = TextEditingController();
    
    // Set initial value
    final initialWeight = widget.currentWeight ?? (_localIsMetric ? 70.0 : 154.0);
    final displayWeight = _localIsMetric ? initialWeight : initialWeight * 2.20462;
    _weightController.text = displayWeight.toStringAsFixed(1);
  }

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  String _formatWeight(double? weight) {
    if (weight == null) return _localIsMetric ? '-- kg' : '-- lbs';
    final displayWeight = _localIsMetric ? weight : weight * 2.20462;
    final unit = _localIsMetric ? 'kg' : 'lbs';
    return '${displayWeight.toStringAsFixed(1)} $unit';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.monitor_weight_rounded,
              color: AppTheme.primaryBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Update Weight',
            style: AppTextStyles.getSubHeadingStyle().copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Unit Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (_localIsMetric) {
                        final currentInput = double.tryParse(_weightController.text) ?? 70.0;
                        _weightController.text = (currentInput * 2.20462).toStringAsFixed(1);
                        setState(() => _localIsMetric = false);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: !_localIsMetric ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: !_localIsMetric ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Text(
                        'lbs',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: !_localIsMetric ? AppTheme.primaryBlue : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      if (!_localIsMetric) {
                        final currentInput = double.tryParse(_weightController.text) ?? 154.0;
                        _weightController.text = (currentInput / 2.20462).toStringAsFixed(1);
                        setState(() => _localIsMetric = true);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: _localIsMetric ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: _localIsMetric ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ] : null,
                      ),
                      child: Text(
                        'kg',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _localIsMetric ? AppTheme.primaryBlue : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Weight Input Field
          TextField(
            controller: _weightController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
            ],
            textAlign: TextAlign.center,
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
            decoration: InputDecoration(
              hintText: _localIsMetric ? '70.0' : '154.0',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 24,
              ),
              suffixText: _localIsMetric ? 'kg' : 'lbs',
              suffixStyle: AppTextStyles.getBodyStyle().copyWith(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppTheme.primaryBlue, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final input = _weightController.text.trim();
                    if (input.isNotEmpty) {
                      final inputWeight = double.tryParse(input);
                      if (inputWeight != null && inputWeight > 0) {
                        final weightInKg = _localIsMetric ? inputWeight : inputWeight / 2.20462;
                        widget.onWeightEntered(weightInKg, _localIsMetric);
                        Navigator.of(context).pop();
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Weight updated to ${_formatWeight(weightInKg)}'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Save',
                    style: AppTextStyles.getBodyStyle().copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}