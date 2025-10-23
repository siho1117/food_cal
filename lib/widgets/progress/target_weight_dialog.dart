// lib/widgets/progress/target_weight_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/typography.dart';

class TargetWeightDialog extends StatefulWidget {
  final double? currentWeight;
  final double? currentTarget;
  final bool isMetric;
  final Function(double) onTargetSet;

  const TargetWeightDialog({
    super.key,
    required this.currentWeight,
    this.currentTarget,
    required this.isMetric,
    required this.onTargetSet,
  });

  @override
  State<TargetWeightDialog> createState() => _TargetWeightDialogState();
}

class _TargetWeightDialogState extends State<TargetWeightDialog> {
  late TextEditingController _weightController;
  late bool _localIsMetric;
  late double _minWeightKg;
  late double _maxWeightKg;

  @override
  void initState() {
    super.initState();
    _localIsMetric = widget.isMetric;
    _weightController = TextEditingController();
    
    // Calculate 20% limits
    final currentWeight = widget.currentWeight ?? 70.0;
    final maxLossKg = currentWeight * 0.20;
    final maxGainKg = currentWeight * 0.20;
    _minWeightKg = currentWeight - maxLossKg;
    _maxWeightKg = currentWeight + maxGainKg;
    
    // Set initial value
    final initialWeight = widget.currentTarget ?? currentWeight;
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
              color: Colors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.flag,
              color: Colors.green[600],
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Set Target Weight',
            style: AppTypography.displaySmall.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning about limits
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!, width: 1),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.amber[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Recommended range: ${_formatWeight(_minWeightKg)} - ${_formatWeight(_maxWeightKg)}\n(±20% of current weight)',
                    style: AppTypography.bodyMedium.copyWith(
                      fontSize: 11,
                      color: Colors.amber[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
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
                          color: !_localIsMetric ? Colors.green[600] : Colors.grey[600],
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
                          color: _localIsMetric ? Colors.green[600] : Colors.grey[600],
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
            style: AppTypography.dataLarge.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green[600],
            ),
            decoration: InputDecoration(
              hintText: _localIsMetric ? '70.0' : '154.0',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 24,
              ),
              suffixText: _localIsMetric ? 'kg' : 'lbs',
              suffixStyle: AppTypography.bodyMedium.copyWith(
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
                borderSide: BorderSide(color: Colors.green[600]!, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Current weight display
          Text(
            'Current: ${_formatWeight(widget.currentWeight)}',
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.grey[600],
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[600],
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Set Target',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSave() {
    final inputText = _weightController.text.trim();
    if (inputText.isEmpty) return;
    
    final inputWeight = double.tryParse(inputText);
    if (inputWeight == null || inputWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid weight'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Convert to kg if needed
    final weightInKg = _localIsMetric ? inputWeight : inputWeight / 2.20462;
    
    // Check if within 20% limits
    if (weightInKg < _minWeightKg || weightInKg > _maxWeightKg) {
      _showWarningDialog(weightInKg);
    } else {
      _saveTarget(weightInKg);
    }
  }

  void _showWarningDialog(double weightInKg) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Target Weight Warning'),
        content: Text(
          'This target exceeds the recommended ±20% range (${_formatWeight(_minWeightKg)} - ${_formatWeight(_maxWeightKg)}).\n\nFor significant weight changes, please consult with a healthcare professional.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Edit Target'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close warning
              _saveTarget(weightInKg);
            },
            child: const Text('Set Anyway'),
          ),
        ],
      ),
    );
  }

  void _saveTarget(double weightInKg) {
    widget.onTargetSet(weightInKg);
    Navigator.of(context).pop();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Target weight set to ${_formatWeight(weightInKg)}'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }
}