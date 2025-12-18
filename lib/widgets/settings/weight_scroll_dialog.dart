// lib/widgets/settings/weight_scroll_dialog.dart
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../providers/settings_provider.dart';
import '../../providers/home_provider.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../utils/constants/unit_constants.dart';

/// Reusable weight scroll picker dialog
///
/// Can be configured for either current weight or starting weight updates.
/// Features:
/// - Metric/Imperial unit toggle
/// - Smooth scrolling picker (30-300 kg / 66-660 lbs)
/// - Decimal precision (0.1 increment)
/// - Automatic unit conversion and persistence
class WeightScrollDialog extends StatefulWidget {
  final SettingsProvider settingsProvider;
  final WeightDialogType type;

  const WeightScrollDialog({
    super.key,
    required this.settingsProvider,
    this.type = WeightDialogType.current,
  });

  @override
  State<WeightScrollDialog> createState() => _WeightScrollDialogState();
}

enum WeightDialogType {
  current,
  starting,
}

class _WeightScrollDialogState extends State<WeightScrollDialog> {
  late FixedExtentScrollController _weightWholeController;
  late FixedExtentScrollController _weightDecimalController;
  late bool _isMetric;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.settingsProvider.isMetric;
    final initialWeight = _getInitialWeight();
    _initializeControllers(initialWeight);
  }

  double _getInitialWeight() {
    switch (widget.type) {
      case WeightDialogType.current:
        return widget.settingsProvider.currentWeight ?? 70.0;
      case WeightDialogType.starting:
        return widget.settingsProvider.userProfile?.startingWeight
            ?? widget.settingsProvider.currentWeight
            ?? 70.0;
    }
  }

  void _initializeControllers(double weight) {
    final displayWeight = _isMetric
        ? weight
        : UnitConstants.kgToLbs(weight);

    final wholeWeight = displayWeight.floor();
    final decimalWeight = ((displayWeight - wholeWeight) * 10).round();

    final minDisplayWeight = _isMetric
        ? UnitConstants.minWeightKg
        : UnitConstants.kgToLbs(UnitConstants.minWeightKg.toDouble()).round();
    final maxDisplayWeight = _isMetric
        ? UnitConstants.maxWeightKg
        : UnitConstants.kgToLbs(UnitConstants.maxWeightKg.toDouble()).round();

    _weightWholeController = FixedExtentScrollController(
      initialItem: (wholeWeight - minDisplayWeight).clamp(0, maxDisplayWeight - minDisplayWeight),
    );
    _weightDecimalController = FixedExtentScrollController(
      initialItem: decimalWeight.clamp(0, 9),
    );
  }

  void _toggleUnit() {
    setState(() {
      final currentWeightKg = _currentWeight;
      _isMetric = !_isMetric;
      _weightWholeController.dispose();
      _weightDecimalController.dispose();
      _initializeControllers(currentWeightKg);
    });
  }

  @override
  void dispose() {
    _weightWholeController.dispose();
    _weightDecimalController.dispose();
    super.dispose();
  }

  int get _minDisplayWeight => _isMetric
      ? UnitConstants.minWeightKg
      : UnitConstants.kgToLbs(UnitConstants.minWeightKg.toDouble()).round();

  int get _maxDisplayWeight => _isMetric
      ? UnitConstants.maxWeightKg
      : UnitConstants.kgToLbs(UnitConstants.maxWeightKg.toDouble()).round();

  double get _currentWeight {
    final whole = _minDisplayWeight + _weightWholeController.selectedItem;
    final decimal = _weightDecimalController.selectedItem / 10.0;
    final displayWeight = whole + decimal;

    return _isMetric
        ? displayWeight
        : UnitConstants.lbsToKg(displayWeight);
  }

  Future<void> _handleSave() async {
    try {
      // Update global isMetric if it changed
      if (_isMetric != widget.settingsProvider.isMetric) {
        await widget.settingsProvider.updateUnitPreference(_isMetric);
      }

      // Save weight based on dialog type
      switch (widget.type) {
        case WeightDialogType.current:
          await widget.settingsProvider.updateWeight(_currentWeight, _isMetric);
          break;
        case WeightDialogType.starting:
          await widget.settingsProvider.updateStartingWeight(_currentWeight);
          break;
      }

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        final message = widget.type == WeightDialogType.current
            ? l10n.weightUpdated
            : l10n.startingWeightUpdated;

        Navigator.pop(context);

        // Refresh HomeProvider to pick up updated weight data
        try {
          final homeProvider = Provider.of<HomeProvider>(context, listen: false);
          await homeProvider.refreshUserProfile();
        } catch (_) {
          // HomeProvider might not be available in all contexts
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final unit = _isMetric ? 'kg' : 'lbs';

    final title = widget.type == WeightDialogType.current
        ? l10n.weight
        : l10n.startingWeight;

    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDialogTheme.backdropBlurSigmaX,
        sigmaY: AppDialogTheme.backdropBlurSigmaY,
      ),
      child: AlertDialog(
        backgroundColor: AppDialogTheme.backgroundColor,
        shape: AppDialogTheme.shape,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppDialogTheme.titleStyle,
          ),
          _buildUnitToggle(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.type == WeightDialogType.starting) ...[
            Text(
              l10n.setYourWeightWhenStarted,
              style: const TextStyle(
                fontSize: 13,
                color: AppDialogTheme.colorTextSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          _buildWeightPicker(unit),
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
      ),
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
          _buildUnitButton('kg', _isMetric),
          _buildUnitButton('lbs', !_isMetric),
        ],
      ),
    );
  }

  Widget _buildUnitButton(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        if ((label == 'kg' && !_isMetric) || (label == 'lbs' && _isMetric)) {
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

  Widget _buildWeightPicker(String unit) {
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
          // Whole number picker
          Expanded(
            child: CupertinoPicker(
              scrollController: _weightWholeController,
              itemExtent: 40,
              onSelectedItemChanged: (index) {
                setState(() {});
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
                setState(() {});
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
