// lib/widgets/settings/height_scroll_dialog.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/settings_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/constants/unit_constants.dart';

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
        initialItem: (cm - UnitConstants.minHeightCm).clamp(0, UnitConstants.maxHeightCm - UnitConstants.minHeightCm),
      );
      _secondaryController = FixedExtentScrollController(initialItem: 0);
    } else {
      // Imperial: feet and inches
      final heightData = UnitConstants.cmToFeetAndInches(heightInCm);

      _primaryController = FixedExtentScrollController(
        initialItem: (heightData.feet - UnitConstants.minHeightFeet).clamp(0, UnitConstants.maxHeightFeet - UnitConstants.minHeightFeet),
      );
      _secondaryController = FixedExtentScrollController(
        initialItem: heightData.inches.clamp(0, 11),
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
      return (UnitConstants.minHeightCm + _primaryController.selectedItem).toDouble();
    } else {
      // Convert feet + inches to cm
      final feet = UnitConstants.minHeightFeet + _primaryController.selectedItem;
      final inches = _secondaryController.selectedItem;
      return UnitConstants.feetAndInchesToCm(feet, inches);
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
        final l10n = AppLocalizations.of(context)!;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.heightUpdated),
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
    final l10n = AppLocalizations.of(context)!;
    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.height,
            style: AppDialogTheme.titleStyle,
          ),
          _buildUnitToggle(l10n),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _isMetric
              ? _buildMetricPicker(l10n)
              : _buildImperialPicker(l10n),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: AppDialogTheme.cancelButtonStyle,
              child: Text(l10n.cancel),
            ),
            const SizedBox(width: AppDialogTheme.buttonGap),
            FilledButton(
              onPressed: _handleSave,
              style: AppDialogTheme.primaryButtonStyle,
              child: Text(l10n.save),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUnitToggle(AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildUnitButton(l10n.cm, _isMetric, true),
          _buildUnitButton(l10n.ft, !_isMetric, false),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, bool isSelected, bool isMetricButton) {
    return GestureDetector(
      onTap: () {
        if ((isMetricButton && !_isMetric) || (!isMetricButton && _isMetric)) {
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

  Widget _buildMetricPicker(AppLocalizations l10n) {
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
                UnitConstants.maxHeightCm - UnitConstants.minHeightCm + 1,
                (index) => Center(
                  child: Text(
                    '${UnitConstants.minHeightCm + index}',
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
              l10n.cm,
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

  Widget _buildImperialPicker(AppLocalizations l10n) {
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
                UnitConstants.maxHeightFeet - UnitConstants.minHeightFeet + 1,
                (index) => Center(
                  child: Text(
                    '${UnitConstants.minHeightFeet + index}',
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              l10n.ft,
              style: const TextStyle(
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
          Padding(
            padding: const EdgeInsets.only(left: 8, right: 16),
            child: Text(
              l10n.inchesUnit,
              style: const TextStyle(
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
