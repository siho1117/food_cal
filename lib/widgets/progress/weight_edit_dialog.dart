// lib/widgets/progress/weight_edit_dialog.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../data/models/weight_data.dart';
import '../../l10n/generated/app_localizations.dart';

enum WeightMode { start, current, target }

/// Shows a dialog to edit a weight entry with scrolling wheel pickers
///
/// Can be used in multiple modes:
/// 1. Edit mode: Pass [entry] to edit an existing weight entry
/// 2. Add mode: Pass [initialWeight] to add a new weight entry
/// 3. Start/Current/Target tabs for managing all weight values
Future<void> showWeightEditDialog({
  required BuildContext context,
  WeightData? entry,
  double? initialWeight,
  required bool isMetric,
  required double? targetWeight,
  double? startingWeight,
  Function(String entryId, double weight, DateTime timestamp, String? note)? onSave,
  Function(double weight, bool isMetric)? onAddWeight,
  required Function(double targetWeight) onSaveTarget,
  Function(double startingWeight)? onSaveStartingWeight,
  WeightMode initialMode = WeightMode.current,
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
      startingWeight: startingWeight,
      onSave: onSave,
      onAddWeight: onAddWeight,
      onSaveTarget: onSaveTarget,
      onSaveStartingWeight: onSaveStartingWeight,
      initialMode: initialMode,
    ),
  );
}

class _WeightEditDialog extends StatefulWidget {
  final WeightData? entry; // Nullable for add mode
  final double? initialWeight; // For add mode
  final bool isMetric;
  final double? targetWeight;
  final double? startingWeight;
  final Function(String entryId, double weight, DateTime timestamp, String? note)? onSave;
  final Function(double weight, bool isMetric)? onAddWeight;
  final Function(double targetWeight) onSaveTarget;
  final Function(double startingWeight)? onSaveStartingWeight;
  final WeightMode initialMode;

  const _WeightEditDialog({
    this.entry,
    this.initialWeight,
    required this.isMetric,
    required this.targetWeight,
    this.startingWeight,
    this.onSave,
    this.onAddWeight,
    required this.onSaveTarget,
    this.onSaveStartingWeight,
    this.initialMode = WeightMode.current,
  });

  @override
  State<_WeightEditDialog> createState() => _WeightEditDialogState();
}

/// Represents the state of a single weight mode (start/current/target)
class _WeightModeState {
  final double initialValue; // Original value from database
  double currentValue; // Current picker value
  bool isDirty; // Has user actually scrolled the picker?

  _WeightModeState({
    required this.initialValue,
  })  : currentValue = initialValue,
        isDirty = false;

  /// Mark this mode as modified by user interaction
  void markDirty() {
    isDirty = true;
  }

  /// Update the current picker value
  void updateValue(double value) {
    currentValue = value;
  }
}

class _WeightEditDialogState extends State<_WeightEditDialog> {
  late FixedExtentScrollController _weightWholeController;
  late FixedExtentScrollController _weightDecimalController;

  // Current active tab
  late WeightMode _currentMode;

  // Clean state management: one state object per mode
  late _WeightModeState _startState;
  late _WeightModeState _currentState;
  late _WeightModeState _targetState;

  // Weight range configuration (in kg)
  static const int minWeight = 30;
  static const int maxWeight = 300;

  // Unit conversion constants
  static const double kgToLbs = 2.20462;
  static const double lbsToKg = 0.453592;

  @override
  void initState() {
    super.initState();

    // Set initial mode from widget parameter
    _currentMode = widget.initialMode;

    // Initialize each mode state with its database value
    final fallbackWeight = widget.entry?.weight ?? widget.initialWeight ?? 70.0;

    _startState = _WeightModeState(
      initialValue: widget.startingWeight ?? fallbackWeight,
    );

    _currentState = _WeightModeState(
      initialValue: widget.entry?.weight ?? widget.initialWeight ?? 70.0,
    );

    _targetState = _WeightModeState(
      initialValue: widget.targetWeight ?? fallbackWeight,
    );

    // Initialize controllers with current mode's initial value
    _initializeControllers(_getCurrentModeState().currentValue);
  }

  /// Get the state object for the current mode
  _WeightModeState _getCurrentModeState() {
    switch (_currentMode) {
      case WeightMode.start:
        return _startState;
      case WeightMode.current:
        return _currentState;
      case WeightMode.target:
        return _targetState;
    }
  }

  /// Convert weight from kg to display unit (kg or lbs based on isMetric)
  double _toDisplayWeight(double weightInKg) {
    return widget.isMetric ? weightInKg : weightInKg * kgToLbs;
  }

  /// Convert weight from display unit to kg
  double _toKg(double displayWeight) {
    return widget.isMetric ? displayWeight : displayWeight * lbsToKg;
  }

  /// Get minimum weight in current display unit
  int get _minDisplayWeight => widget.isMetric ? minWeight : (minWeight * kgToLbs).round();

  /// Get maximum weight in current display unit
  int get _maxDisplayWeight => widget.isMetric ? maxWeight : (maxWeight * kgToLbs).round();

  void _initializeControllers(double weightInKg) {
    final displayWeight = _toDisplayWeight(weightInKg);

    // Split into whole and decimal parts
    final wholeWeight = displayWeight.floor();
    final decimalWeight = ((displayWeight - wholeWeight) * 10).round();

    _weightWholeController = FixedExtentScrollController(
      initialItem: (wholeWeight - _minDisplayWeight).clamp(0, _maxDisplayWeight - _minDisplayWeight),
    );
    _weightDecimalController = FixedExtentScrollController(
      initialItem: decimalWeight.clamp(0, 9),
    );
  }

  void _switchMode(WeightMode newMode) {
    if (_currentMode == newMode) return;

    // Save current picker value to current mode's state
    final currentModeState = _getCurrentModeState();
    currentModeState.updateValue(_getPickerWeight());

    // Switch to new mode
    setState(() {
      _currentMode = newMode;
    });

    // Get the new mode's state
    final newModeState = _getCurrentModeState();

    // Animate picker to new mode's current value
    _animatePickerToWeight(newModeState.currentValue);
  }

  /// Get the current weight from the picker controllers (returns weight in kg)
  double _getPickerWeight() {
    final whole = _minDisplayWeight + _weightWholeController.selectedItem;
    final decimal = _weightDecimalController.selectedItem / 10.0;
    final displayWeight = whole + decimal;

    // Convert display weight back to kg
    return _toKg(displayWeight);
  }

  /// Animate picker to a specific weight value (expects weight in kg)
  void _animatePickerToWeight(double weightInKg) {
    final displayWeight = _toDisplayWeight(weightInKg);

    // Calculate new indices
    final wholeWeight = displayWeight.floor();
    final decimalWeight = ((displayWeight - wholeWeight) * 10).round();

    final newWholeIndex = (wholeWeight - _minDisplayWeight).clamp(0, _maxDisplayWeight - _minDisplayWeight);
    final newDecimalIndex = decimalWeight.clamp(0, 9);

    // Animate to new positions
    _weightWholeController.animateToItem(
      newWholeIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    _weightDecimalController.animateToItem(
      newDecimalIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  /// Called when user scrolls the picker - marks current mode as modified
  void _onPickerChanged() {
    final currentModeState = _getCurrentModeState();
    currentModeState.markDirty();
    currentModeState.updateValue(_getPickerWeight());
    setState(() {}); // Update UI
  }

  @override
  void dispose() {
    _weightWholeController.dispose();
    _weightDecimalController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    try {
      // Update current mode's state one final time
      final currentModeState = _getCurrentModeState();
      currentModeState.updateValue(_getPickerWeight());

      // Save only modes that were actually modified (isDirty = true)
      if (_startState.isDirty && widget.onSaveStartingWeight != null) {
        await widget.onSaveStartingWeight!(_startState.currentValue);
      }

      if (_currentState.isDirty) {
        // Editing an existing entry
        if (widget.entry != null && widget.onSave != null) {
          await widget.onSave!(
            widget.entry!.id,
            _currentState.currentValue,
            widget.entry!.timestamp,
            widget.entry!.note,
          );
        }
        // Adding a new weight entry
        else if (widget.onAddWeight != null) {
          await widget.onAddWeight!(_currentState.currentValue, widget.isMetric);
        }
      }

      if (_targetState.isDirty) {
        await widget.onSaveTarget(_targetState.currentValue);
      }

      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      // If save fails, show error to user and keep dialog open
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = widget.isMetric ? l10n.kg : l10n.lbs;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
      child: AlertDialog(
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
                      Text(
                        l10n.editWeight,
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
            _buildSectionLabel(_getLabelForMode()),
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
                child: Text(l10n.cancel),
              ),
              const SizedBox(width: AppDialogTheme.buttonGap),

              // Save button
              FilledButton(
                onPressed: _handleSave,
                style: AppDialogTheme.primaryButtonStyle,
                child: Text(l10n.save),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getLabelForMode() {
    final l10n = AppLocalizations.of(context)!;
    switch (_currentMode) {
      case WeightMode.start:
        return l10n.startingWeight;
      case WeightMode.current:
        return l10n.currentWeight;
      case WeightMode.target:
        return l10n.targetWeight;
    }
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
    final l10n = AppLocalizations.of(context)!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTabButton(
            label: l10n.start,
            isSelected: _currentMode == WeightMode.start,
            onTap: () => _switchMode(WeightMode.start),
          ),
          _buildTabButton(
            label: l10n.current,
            isSelected: _currentMode == WeightMode.current,
            onTap: () => _switchMode(WeightMode.current),
          ),
          _buildTabButton(
            label: l10n.target,
            isSelected: _currentMode == WeightMode.target,
            onTap: () => _switchMode(WeightMode.target),
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
                _onPickerChanged();
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
                _onPickerChanged();
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
