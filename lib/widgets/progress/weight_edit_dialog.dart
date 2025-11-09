// lib/widgets/progress/weight_edit_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../data/models/weight_data.dart';

/// Shows a dialog to edit a weight entry with scrolling wheel pickers
///
/// Can be used in two modes:
/// 1. Edit mode: Pass [entry] to edit an existing weight entry
/// 2. Add mode: Pass [initialWeight] to add a new weight entry
Future<void> showWeightEditDialog({
  required BuildContext context,
  WeightData? entry,
  double? initialWeight,
  required bool isMetric,
  required double? targetWeight,
  Function(String entryId, double weight, DateTime timestamp, String? note)? onSave,
  Function(double weight, bool isMetric)? onAddWeight,
  required Function(double targetWeight) onSaveTarget,
}) async {
  // Validate: must have either entry (edit mode) or initialWeight (add mode)
  assert(
    (entry != null) || (initialWeight != null),
    'Must provide either entry (edit mode) or initialWeight (add mode)',
  );

  await showDialog(
    context: context,
    builder: (context) => _WeightEditDialog(
      entry: entry,
      initialWeight: initialWeight,
      isMetric: isMetric,
      targetWeight: targetWeight,
      onSave: onSave,
      onAddWeight: onAddWeight,
      onSaveTarget: onSaveTarget,
    ),
  );
}

class _WeightEditDialog extends StatefulWidget {
  final WeightData? entry; // Nullable for add mode
  final double? initialWeight; // For add mode
  final bool isMetric;
  final double? targetWeight;
  final Function(String entryId, double weight, DateTime timestamp, String? note)? onSave;
  final Function(double weight, bool isMetric)? onAddWeight;
  final Function(double targetWeight) onSaveTarget;

  const _WeightEditDialog({
    this.entry,
    this.initialWeight,
    required this.isMetric,
    required this.targetWeight,
    this.onSave,
    this.onAddWeight,
    required this.onSaveTarget,
  });

  @override
  State<_WeightEditDialog> createState() => _WeightEditDialogState();
}

class _WeightEditDialogState extends State<_WeightEditDialog> {
  late FixedExtentScrollController _weightWholeController;
  late FixedExtentScrollController _weightDecimalController;

  // Tab state: true = Weight mode, false = Target mode
  bool _isWeightMode = true;

  // Weight range configuration
  static const int minWeight = 30; // kg or converted to lbs
  static const int maxWeight = 300; // kg or converted to lbs

  @override
  void initState() {
    super.initState();

    // Initialize controllers with appropriate weight
    final initialWeightValue = widget.entry?.weight ?? widget.initialWeight ?? 70.0;
    _initializeControllers(initialWeightValue);
  }

  void _initializeControllers(double weight) {
    // Convert weight to display unit
    final displayWeight = widget.isMetric
        ? weight
        : weight * 2.20462;

    // Initialize weight controllers
    final wholeWeight = displayWeight.floor();
    final decimalWeight = ((displayWeight - wholeWeight) * 10).round();

    final minDisplayWeight = widget.isMetric ? minWeight : (minWeight * 2.20462).round();
    final maxDisplayWeight = widget.isMetric ? maxWeight : (maxWeight * 2.20462).round();

    _weightWholeController = FixedExtentScrollController(
      initialItem: (wholeWeight - minDisplayWeight).clamp(0, maxDisplayWeight - minDisplayWeight),
    );
    _weightDecimalController = FixedExtentScrollController(
      initialItem: decimalWeight.clamp(0, 9),
    );
  }

  void _switchMode() {
    setState(() {
      _isWeightMode = !_isWeightMode;

      // Dispose old controllers
      _weightWholeController.dispose();
      _weightDecimalController.dispose();

      // Reinitialize with appropriate weight
      if (_isWeightMode) {
        // Switch to Weight mode - use entry weight or initial weight
        final initialWeightValue = widget.entry?.weight ?? widget.initialWeight ?? 70.0;
        _initializeControllers(initialWeightValue);
      } else {
        // Switch to Target mode - use target weight or fall back to current weight
        final fallbackWeight = widget.entry?.weight ?? widget.initialWeight ?? 70.0;
        _initializeControllers(widget.targetWeight ?? fallbackWeight);
      }
    });
  }

  @override
  void dispose() {
    _weightWholeController.dispose();
    _weightDecimalController.dispose();
    super.dispose();
  }

  int get _minDisplayWeight => widget.isMetric ? minWeight : (minWeight * 2.20462).round();
  int get _maxDisplayWeight => widget.isMetric ? maxWeight : (maxWeight * 2.20462).round();

  double get _currentWeight {
    final whole = _minDisplayWeight + _weightWholeController.selectedItem;
    final decimal = _weightDecimalController.selectedItem / 10.0;
    final displayWeight = whole + decimal;

    // Convert back to kg if using imperial
    return widget.isMetric ? displayWeight : displayWeight / 2.20462;
  }

  void _handleSave() {
    if (_isWeightMode) {
      // Editing an existing entry
      if (widget.entry != null && widget.onSave != null) {
        widget.onSave!(
          widget.entry!.id,
          _currentWeight,
          widget.entry!.timestamp,
          widget.entry!.note,
        );
      }
      // Adding a new weight entry
      else if (widget.onAddWeight != null) {
        widget.onAddWeight!(_currentWeight, widget.isMetric);
      }
    } else {
      // Save target weight
      widget.onSaveTarget(_currentWeight);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.isMetric ? 'kg' : 'lbs';

    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Title text with more breathing room
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Edit Weight',
                      style: AppDialogTheme.titleStyle,
                    ),
                    // Add date subtitle if entry exists
                    if (widget.entry != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yy').format(widget.entry!.timestamp),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppDialogTheme.colorTextSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 16), // Add horizontal spacing before tab switcher
              // Tab switcher
              _buildTabSwitcher(),
            ],
          ),
          const SizedBox(height: 16), // Add spacing below title row
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Weight Picker Section
          _buildSectionLabel(_isWeightMode ? 'Current Weight' : 'Target Weight'),
          const SizedBox(height: 16), // Increased from 12 to 16
          _buildWeightPicker(unit),
          const SizedBox(height: 8), // Add bottom spacing
        ],
      ),
      actions: [
        // Cancel and Save buttons on the same row
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Cancel button
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppDialogTheme.cancelButtonStyle,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: AppDialogTheme.buttonGap),

            // Save button
            FilledButton(
              onPressed: _handleSave,
              style: AppDialogTheme.primaryButtonStyle,
              child: const Text('Save'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        color: Color(0xFF374151),
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
            label: 'Current',
            isSelected: _isWeightMode,
            onTap: () {
              if (!_isWeightMode) _switchMode();
            },
          ),
          _buildTabButton(
            label: 'Target',
            isSelected: !_isWeightMode,
            onTap: () {
              if (_isWeightMode) _switchMode();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppDialogTheme.colorPrimaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppDialogTheme.colorTextSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildWeightPicker(String unit) {
    return Container(
      height: 180, // Increased from 150 to 180 for better usability
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Whole number picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _weightWholeController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {}); // Update to show current value
              },
              children: List.generate(
                _maxDisplayWeight - _minDisplayWeight + 1,
                (index) => Center(
                  child: Text(
                    '${_minDisplayWeight + index}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Decimal point
          const Text(
            '.',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),

          // Decimal picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _weightDecimalController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {}); // Update to show current value
              },
              children: List.generate(
                10,
                (index) => Center(
                  child: Text(
                    '$index',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Unit label
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Text(
              unit,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
