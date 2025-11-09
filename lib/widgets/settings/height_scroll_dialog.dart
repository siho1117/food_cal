// lib/widgets/settings/height_scroll_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/settings_provider.dart';

/// Height scroll picker dialog with different design from weight
/// - Metric: Single cm picker (100-250 cm)
/// - Imperial: Feet + inches pickers (3-8 ft, 0-11 in)
class HeightScrollDialog extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const HeightScrollDialog({
    super.key,
    required this.settingsProvider,
  });

  @override
  State<HeightScrollDialog> createState() => _HeightScrollDialogState();
}

class _HeightScrollDialogState extends State<HeightScrollDialog> {
  late FixedExtentScrollController _primaryController;
  late FixedExtentScrollController _secondaryController;
  late bool _isMetric;

  // Metric: 100-250 cm
  static const int minHeightCm = 100;
  static const int maxHeightCm = 250;

  // Imperial: 3-8 feet, 0-11 inches
  static const int minFeet = 3;
  static const int maxFeet = 8;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.settingsProvider.isMetric;
    final currentHeight = widget.settingsProvider.userProfile?.height ?? 170.0;
    _initializeControllers(currentHeight);
  }

  void _initializeControllers(double heightInCm) {
    if (_isMetric) {
      // Metric: single cm picker
      final cm = heightInCm.round();
      _primaryController = FixedExtentScrollController(
        initialItem: (cm - minHeightCm).clamp(0, maxHeightCm - minHeightCm),
      );
      _secondaryController = FixedExtentScrollController(initialItem: 0);
    } else {
      // Imperial: feet and inches
      final totalInches = heightInCm / 2.54;
      final feet = totalInches ~/ 12;
      final inches = (totalInches % 12).round();

      _primaryController = FixedExtentScrollController(
        initialItem: (feet - minFeet).clamp(0, maxFeet - minFeet),
      );
      _secondaryController = FixedExtentScrollController(
        initialItem: inches.clamp(0, 11),
      );
    }
  }

  void _toggleUnit() {
    setState(() {
      // Get current height in cm
      final currentHeightCm = _currentHeight;

      // Toggle the unit
      _isMetric = !_isMetric;

      // Dispose old controllers
      _primaryController.dispose();
      _secondaryController.dispose();

      // Reinitialize with the same height value
      _initializeControllers(currentHeightCm);
    });
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  double get _currentHeight {
    if (_isMetric) {
      // Return cm directly
      return (minHeightCm + _primaryController.selectedItem).toDouble();
    } else {
      // Convert feet + inches to cm
      final feet = minFeet + _primaryController.selectedItem;
      final inches = _secondaryController.selectedItem;
      final totalInches = (feet * 12) + inches;
      return totalInches * 2.54;
    }
  }

  void _handleSave() async {
    try {
      // Update global isMetric if it changed
      if (_isMetric != widget.settingsProvider.isMetric) {
        await widget.settingsProvider.updateUnitPreference(_isMetric);
      }

      await widget.settingsProvider.updateHeight(_currentHeight);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Height updated'),
            behavior: SnackBarBehavior.floating,
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Height',
            style: AppDialogTheme.titleStyle,
          ),
          _buildUnitToggle(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isMetric
              ? _buildMetricPicker()
              : _buildImperialPicker(),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: AppDialogTheme.cancelButtonStyle,
              child: const Text('Cancel'),
            ),
            const SizedBox(width: AppDialogTheme.buttonGap),
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

  Widget _buildUnitToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitButton('cm', _isMetric),
          _buildUnitButton('ft', !_isMetric),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if ((label == 'cm' && !_isMetric) || (label == 'ft' && _isMetric)) {
          _toggleUnit();
        }
      },
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

  Widget _buildMetricPicker() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // CM picker
          Expanded(
            flex: 2,
            child: CupertinoPicker(
              scrollController: _primaryController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {});
              },
              children: List.generate(
                maxHeightCm - minHeightCm + 1,
                (index) => Center(
                  child: Text(
                    '${minHeightCm + index}',
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
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16),
            child: Text(
              'cm',
              style: TextStyle(
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

  Widget _buildImperialPicker() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Feet picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _primaryController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {});
              },
              children: List.generate(
                maxFeet - minFeet + 1,
                (index) => Center(
                  child: Text(
                    '${minFeet + index}',
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              'ft',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          // Inches picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _secondaryController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {});
              },
              children: List.generate(
                12,
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
          const Padding(
            padding: EdgeInsets.only(left: 8, right: 16),
            child: Text(
              'in',
              style: TextStyle(
                fontSize: 16,
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
