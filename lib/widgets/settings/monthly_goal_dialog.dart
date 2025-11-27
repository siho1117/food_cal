// lib/widgets/settings/monthly_goal_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/accent_colors.dart';
import '../../providers/settings_provider.dart';

/// Monthly Weight Goal Picker Dialog
///
/// A clean iOS-style dialog for selecting monthly weight loss goals.
/// Features:
/// - CupertinoPicker wheel with 0.1 kg increments (0.1-9.9 kg)
/// - kg/lbs unit toggle
/// - Color-coded zone indicators (Safe/Moderate/Aggressive/Custom)
/// - Tappable zones to quickly jump to recommended values
/// - Unit label overlay on picker
class MonthlyGoalDialog extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const MonthlyGoalDialog({
    super.key,
    required this.settingsProvider,
  });

  @override
  State<MonthlyGoalDialog> createState() => _MonthlyGoalDialogState();
}

class _MonthlyGoalDialogState extends State<MonthlyGoalDialog> {
  late FixedExtentScrollController _scrollController;
  late bool _isMetric;

  // Constants
  static const double _kgToLbsRatio = 2.20462;
  static const double _minGoalKg = 0.1;
  static const double _maxGoalKg = 9.9;
  static const double _increment = 0.1;
  static const double _safeZoneMax = 0.5;
  static const double _moderateZoneMax = 1.0;
  static const double _aggressiveZoneMax = 2.0;
  static const double _defaultGoalKg = 0.8;

  // Zone target values (in kg) for quick selection
  static const double _safeTarget = 0.3;
  static const double _moderateTarget = 0.8;
  static const double _aggressiveTarget = 1.5;
  static const double _customTarget = 3.0;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.settingsProvider.isMetric;

    // Get current goal (stored as negative in DB for weight loss)
    final currentGoalFromDb = widget.settingsProvider.userProfile?.monthlyWeightGoal;
    final initialGoalKg = currentGoalFromDb?.abs() ?? _defaultGoalKg;

    _initializeController(initialGoalKg);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // ============ Initialization & State Management ============

  void _initializeController(double goalInKg) {
    final displayValue = _toDisplayUnit(goalInKg);
    final minDisplay = _toDisplayUnit(_minGoalKg);
    final selectedIndex = ((displayValue - minDisplay) / _increment)
        .round()
        .clamp(0, _getTotalItems() - 1);

    _scrollController = FixedExtentScrollController(initialItem: selectedIndex);
  }

  void _toggleUnit() {
    setState(() {
      final currentGoalKg = _currentGoalInKg;
      _isMetric = !_isMetric;
      _scrollController.dispose();
      _initializeController(currentGoalKg);
    });
  }

  // ============ Getters ============

  /// Current selected goal in kg (always stored in kg)
  double get _currentGoalInKg {
    if (!_scrollController.hasClients) return _defaultGoalKg;

    final minDisplay = _toDisplayUnit(_minGoalKg);
    final displayGoal = minDisplay + (_scrollController.selectedItem * _increment);
    return _toKg(displayGoal);
  }

  /// Current zone based on goal value
  String get _currentZone {
    final goal = _currentGoalInKg;
    if (goal <= _safeZoneMax) return 'Safe';
    if (goal <= _moderateZoneMax) return 'Moderate';
    if (goal <= _aggressiveZoneMax) return 'Aggressive';
    return 'Custom';
  }

  String get _unit => _isMetric ? 'kg' : 'lbs';

  int _getTotalItems() {
    final minDisplay = _toDisplayUnit(_minGoalKg);
    final maxDisplay = _toDisplayUnit(_maxGoalKg);
    return ((maxDisplay - minDisplay) / _increment).round() + 1;
  }

  // ============ Unit Conversion Helpers ============

  /// Convert kg to display unit (kg or lbs)
  double _toDisplayUnit(double kg) => _isMetric ? kg : kg * _kgToLbsRatio;

  /// Convert display unit to kg
  double _toKg(double displayValue) => _isMetric ? displayValue : displayValue / _kgToLbsRatio;

  /// Format range for display
  String _formatRange(double minKg, double maxKg) {
    final minDisplay = _toDisplayUnit(minKg);
    final maxDisplay = _toDisplayUnit(maxKg);
    return '${minDisplay.toStringAsFixed(1)}-${maxDisplay.toStringAsFixed(1)} $_unit';
  }

  // ============ Zone Configuration ============

  void _jumpToZone(double targetKg) {
    final targetDisplay = _toDisplayUnit(targetKg);
    final minDisplay = _toDisplayUnit(_minGoalKg);
    final targetIndex = ((targetDisplay - minDisplay) / _increment)
        .round()
        .clamp(0, _getTotalItems() - 1);

    _scrollController.animateToItem(
      targetIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ============ Save Handler ============

  Future<void> _handleSave() async {
    try {
      // Store as negative value (weight loss convention)
      final goalToSave = -_currentGoalInKg;
      await widget.settingsProvider.updateMonthlyWeightGoal(goalToSave);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Monthly weight goal updated'),
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

  // ============ Build Methods ============

  @override
  Widget build(BuildContext context) {
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
        title: const Text(
          'Monthly Weight Goal',
          style: AppDialogTheme.titleStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: _buildUnitToggle(),
            ),
            const SizedBox(height: 16),
            _buildWeightPicker(),
            const SizedBox(height: 20),
            _buildZoneIndicators(),
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

  Widget _buildWeightPicker() {
    final minDisplay = _toDisplayUnit(_minGoalKg);
    final totalItems = _getTotalItems();

    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          // Picker wheel
          CupertinoPicker(
            scrollController: _scrollController,
            itemExtent: 40,
            onSelectedItemChanged: (_) => setState(() {}),
            children: List.generate(totalItems, (index) {
              final value = minDisplay + (index * _increment);
              return Center(
                child: Text(
                  value.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 20,
                    color: AppDialogTheme.colorPrimaryDark,
                  ),
                ),
              );
            }),
          ),
          // Unit overlay at center
          IgnorePointer(
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 70),
                  Text(
                    _unit,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: AppDialogTheme.colorTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZoneIndicators() {
    final currentZone = _currentZone;

    return Column(
      children: [
        _buildZoneRow(
          'Safe',
          AccentColors.brightGreen,
          _formatRange(_minGoalKg, _safeZoneMax),
          currentZone == 'Safe',
          _safeTarget,
        ),
        const SizedBox(height: 8),
        _buildZoneRow(
          'Moderate',
          AccentColors.goldenYellow,
          _formatRange(_safeZoneMax + 0.1, _moderateZoneMax),
          currentZone == 'Moderate',
          _moderateTarget,
        ),
        const SizedBox(height: 8),
        _buildZoneRow(
          'Aggressive',
          AccentColors.brightOrange,
          _formatRange(_moderateZoneMax + 0.1, _aggressiveZoneMax),
          currentZone == 'Aggressive',
          _aggressiveTarget,
        ),
        const SizedBox(height: 8),
        _buildZoneRow(
          'Custom',
          AccentColors.vibrantRed,
          _formatRange(_aggressiveZoneMax + 0.1, _maxGoalKg),
          currentZone == 'Custom',
          _customTarget,
        ),
      ],
    );
  }

  Widget _buildZoneRow(
    String label,
    Color color,
    String range,
    bool isActive,
    double targetKg,
  ) {
    return GestureDetector(
      onTap: () => _jumpToZone(targetKg),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: isActive ? null : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            if (isActive)
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(right: 8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                color: isActive ? Colors.white : AppDialogTheme.colorPrimaryDark,
              ),
            ),
            const Spacer(),
            Text(
              range,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isActive ? Colors.white : AppDialogTheme.colorTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
