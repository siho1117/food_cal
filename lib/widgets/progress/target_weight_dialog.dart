// lib/widgets/progress/target_weight_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../config/theme.dart';
import '../../config/text_styles.dart';
import '../../utils/formula.dart';

class TargetWeightDialog extends StatefulWidget {
  final double? initialTargetWeight;
  final bool isMetric;
  final Function(double, bool) onWeightSaved;

  const TargetWeightDialog({
    Key? key,
    this.initialTargetWeight,
    required this.isMetric,
    required this.onWeightSaved,
  }) : super(key: key);

  @override
  State<TargetWeightDialog> createState() => _TargetWeightDialogState();
}

class _TargetWeightDialogState extends State<TargetWeightDialog> {
  late bool _isMetric;
  late double _selectedWeight;

  // For wheel picker
  late int _selectedWholeNumber;
  late int _selectedDecimal;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.isMetric;

    // Set initial target weight
    if (widget.initialTargetWeight != null) {
      _selectedWeight = widget.initialTargetWeight!;
      if (!_isMetric) {
        // Convert kg to lbs for display
        _selectedWeight = _selectedWeight * 2.20462;
      }
    } else {
      _selectedWeight = _isMetric ? 65.0 : 143.0; // Default values
    }

    // Extract whole and decimal parts
    _selectedWholeNumber = _selectedWeight.floor();
    _selectedDecimal = ((_selectedWeight - _selectedWholeNumber) * 10).round();
  }

  void _toggleUnit() {
    setState(() {
      if (_isMetric) {
        // Convert kg to lbs
        _selectedWeight = _selectedWeight * 2.20462;
      } else {
        // Convert lbs to kg
        _selectedWeight = _selectedWeight / 2.20462;
      }
      _isMetric = !_isMetric;

      // Update components
      _selectedWholeNumber = _selectedWeight.floor();
      _selectedDecimal =
          ((_selectedWeight - _selectedWholeNumber) * 10).round();
    });
  }

  void _saveWeight() {
    // Combine the whole and decimal parts
    final weight = _selectedWholeNumber + (_selectedDecimal / 10);

    // If in imperial, convert back to metric for storage
    final metricWeight = _isMetric ? weight : weight / 2.20462;

    // Pass back the selected weight and unit preference
    widget.onWeightSaved(metricWeight, _isMetric);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 15),
              decoration: BoxDecoration(
                color: AppTheme.primaryBlue.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Set Weight Goal',
                    style: AppTextStyles.getSubHeadingStyle().copyWith(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Adjust your target weight to track progress',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Unit toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Imperial',
                  style: TextStyle(
                    color: !_isMetric ? Colors.black : Colors.grey,
                    fontWeight:
                        !_isMetric ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                Switch(
                  value: _isMetric,
                  onChanged: (value) => _toggleUnit(),
                  activeColor: AppTheme.primaryBlue,
                ),
                Text(
                  'Metric',
                  style: TextStyle(
                    color: _isMetric ? Colors.black : Colors.grey,
                    fontWeight:
                        _isMetric ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Target weight display
            Text(
              'Target Weight',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 10),

            // Weight value display
            Text(
              '${_selectedWholeNumber}.$_selectedDecimal ${_isMetric ? 'kg' : 'lbs'}',
              style: AppTextStyles.getNumericStyle().copyWith(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.accentColor,
              ),
            ),

            const SizedBox(height: 20),

            // Weight picker
            Container(
              height: 160,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Whole number picker
                  SizedBox(
                    width: 80,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      looping: false,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedWholeNumber = _isMetric
                              ? index + 30 // 30-250 kg
                              : index + 66; // 66-550 lbs
                        });
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: _isMetric
                            ? _selectedWholeNumber - 30
                            : _selectedWholeNumber - 66,
                      ),
                      children: List.generate(
                        _isMetric ? 221 : 485, // Range depends on unit
                        (index) => Center(
                          child: Text(
                            _isMetric ? '${index + 30}' : '${index + 66}',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Decimal point
                  const Text(
                    '.',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Decimal picker
                  SizedBox(
                    width: 60,
                    child: CupertinoPicker(
                      itemExtent: 40,
                      looping: true,
                      onSelectedItemChanged: (index) {
                        setState(() {
                          _selectedDecimal = index;
                        });
                      },
                      scrollController: FixedExtentScrollController(
                        initialItem: _selectedDecimal,
                      ),
                      children: List.generate(
                        10,
                        (index) => Center(
                          child: Text(
                            '$index',
                            style: const TextStyle(fontSize: 22),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Unit
                  SizedBox(
                    width: 60,
                    child: Center(
                      child: Text(
                        _isMetric ? 'kg' : 'lbs',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 10),
            
            // Healthy weight tip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: AppTheme.primaryBlue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Set a goal that is realistic and achievable. A healthy weight loss/gain is 0.5-1kg (1-2lbs) per week.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[700],
                    ),
                    child: const Text('CANCEL'),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Save button
                  ElevatedButton(
                    onPressed: _saveWeight,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text('SAVE GOAL'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}