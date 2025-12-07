// lib/widgets/settings/personal_details_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/theme_provider.dart';
import '../../config/design_system/widget_theme.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import 'height_scroll_dialog.dart';

class PersonalDetailsWidget extends StatelessWidget {
  const PersonalDetailsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<SettingsProvider, ThemeProvider>(
      builder: (context, settingsProvider, themeProvider, child) {
        final borderColor = AppWidgetTheme.getBorderColor(
          themeProvider.selectedGradient,
          GlassCardStyle.borderOpacity,
        );
        final textColor = AppWidgetTheme.getTextColor(
          themeProvider.selectedGradient,
        );

        return ClipRRect(
          borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: GlassCardStyle.blurSigma,
              sigmaY: GlassCardStyle.blurSigma,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: GlassCardStyle.backgroundTintOpacity),
                borderRadius: BorderRadius.circular(AppWidgetTheme.cardBorderRadius),
                border: Border.all(
                  color: borderColor,
                  width: GlassCardStyle.borderWidth,
                ),
              ),
              child: Column(
            children: [
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.cake,
                title: 'Date of Birth',
                value: settingsProvider.calculatedAge,
                onTap: () => _showDatePicker(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.height,
                title: 'Height',
                value: settingsProvider.formattedHeight,
                onTap: () => _showHeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.monitor_weight,
                title: 'Current Weight',
                value: settingsProvider.formattedWeight,
                onTap: () => _showWeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.flag,
                title: 'Starting Weight',
                value: settingsProvider.formattedStartingWeight,
                onTap: () => _showStartingWeightDialog(context, settingsProvider),
              ),
              Divider(
                height: 1,
                thickness: 1,
                color: borderColor.withValues(alpha: AppWidgetTheme.opacityMediumLight),
              ),
              _buildDetailItem(
                context,
                settingsProvider,
                textColor,
                icon: Icons.person,
                title: 'Gender',
                value: settingsProvider.userProfile?.gender ?? 'Not set',
                onTap: () => _showGenderDialog(context, settingsProvider),
              ),
            ],
          ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailItem(
    BuildContext context,
    SettingsProvider settingsProvider,
    Color textColor, {
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppWidgetTheme.spaceLG,
        vertical: AppWidgetTheme.spaceSM,
      ),
      leading: Container(
        width: AppWidgetTheme.iconContainerMedium,
        height: AppWidgetTheme.iconContainerMedium,
        decoration: BoxDecoration(
          color: textColor.withValues(alpha: AppWidgetTheme.opacityLight),
          borderRadius: BorderRadius.circular(AppWidgetTheme.borderRadiusMD),
        ),
        child: Icon(
          icon,
          color: textColor,
          size: AppWidgetTheme.iconSizeMedium,
        ),
      ),
      title: Text(
        title,
        style: AppTypography.labelMedium.copyWith(
          color: textColor,
        ),
      ),
      subtitle: Text(
        value,
        style: AppTypography.bodyMedium.copyWith(
          color: textColor.withValues(
            alpha: AppWidgetTheme.opacityVeryHigh,
          ),
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: textColor.withValues(
          alpha: AppWidgetTheme.opacityHigh,
        ),
      ),
      onTap: onTap,
    );
  }


  void _showDatePicker(BuildContext context, SettingsProvider settingsProvider) {
    final currentDate = settingsProvider.userProfile?.birthDate ?? DateTime.now().subtract(const Duration(days: 365 * 25));
    
    showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    ).then((date) async {
      if (date != null) {
        try {
          // Calculate age from selected date
          final now = DateTime.now();
          int age = now.year - date.year;
          if (now.month < date.month || (now.month == date.month && now.day < date.day)) {
            age--;
          }
          
          await settingsProvider.updateDateOfBirth(date, age);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Date of birth updated'), behavior: SnackBarBehavior.floating),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
            );
          }
        }
      }
    });
  }

  void _showHeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => HeightScrollDialog(
        settingsProvider: settingsProvider,
      ),
    );
  }

  void _showWeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => _WeightScrollDialog(
        settingsProvider: settingsProvider,
      ),
    );
  }

  void _showStartingWeightDialog(BuildContext context, SettingsProvider settingsProvider) {
    showDialog(
      context: context,
      builder: (context) => _StartingWeightScrollDialog(
        settingsProvider: settingsProvider,
      ),
    );
  }

  void _showGenderDialog(BuildContext context, SettingsProvider settingsProvider) {
    final genders = ['Male', 'Female', 'Other', 'Prefer not to say'];
    final currentGender = settingsProvider.userProfile?.gender;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: AppDialogTheme.shape,
        backgroundColor: AppDialogTheme.backgroundColor,
        contentPadding: AppDialogTheme.contentPadding,
        actionsPadding: AppDialogTheme.actionsPadding,
        title: Text(
          'Gender',
          style: AppDialogTheme.titleStyle,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: genders.map((gender) {
            final isSelected = gender == currentGender;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                gender,
                style: AppDialogTheme.bodyStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isSelected
                      ? AppDialogTheme.colorPrimaryDark
                      : AppDialogTheme.colorTextSecondary,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: AppDialogTheme.colorPrimaryDark)
                  : null,
              onTap: () async {
                try {
                  await settingsProvider.updateGender(gender);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gender updated'), behavior: SnackBarBehavior.floating),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            style: AppDialogTheme.cancelButtonStyle,
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

}

// ═══════════════════════════════════════════════════════════════
// Weight Scroll Picker Dialog (matches weight_edit_dialog design)
// ═══════════════════════════════════════════════════════════════

class _WeightScrollDialog extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const _WeightScrollDialog({
    required this.settingsProvider,
  });

  @override
  State<_WeightScrollDialog> createState() => _WeightScrollDialogState();
}

class _WeightScrollDialogState extends State<_WeightScrollDialog> {
  late FixedExtentScrollController _weightWholeController;
  late FixedExtentScrollController _weightDecimalController;
  late bool _isMetric;

  static const int minWeight = 30;
  static const int maxWeight = 300;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.settingsProvider.isMetric;
    final initialWeight = widget.settingsProvider.currentWeight ?? 70.0;
    _initializeControllers(initialWeight);
  }

  void _initializeControllers(double weight) {
    final displayWeight = _isMetric
        ? weight
        : weight * 2.20462;

    final wholeWeight = displayWeight.floor();
    final decimalWeight = ((displayWeight - wholeWeight) * 10).round();

    final minDisplayWeight = _isMetric
        ? minWeight
        : (minWeight * 2.20462).round();
    final maxDisplayWeight = _isMetric
        ? maxWeight
        : (maxWeight * 2.20462).round();

    _weightWholeController = FixedExtentScrollController(
      initialItem: (wholeWeight - minDisplayWeight).clamp(0, maxDisplayWeight - minDisplayWeight),
    );
    _weightDecimalController = FixedExtentScrollController(
      initialItem: decimalWeight.clamp(0, 9),
    );
  }

  void _toggleUnit() {
    setState(() {
      // Get current weight in kg
      final currentWeightKg = _currentWeight;

      // Toggle the unit
      _isMetric = !_isMetric;

      // Dispose old controllers
      _weightWholeController.dispose();
      _weightDecimalController.dispose();

      // Reinitialize with the same weight value
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
      ? minWeight
      : (minWeight * 2.20462).round();
  int get _maxDisplayWeight => _isMetric
      ? maxWeight
      : (maxWeight * 2.20462).round();

  double get _currentWeight {
    final whole = _minDisplayWeight + _weightWholeController.selectedItem;
    final decimal = _weightDecimalController.selectedItem / 10.0;
    final displayWeight = whole + decimal;

    return _isMetric
        ? displayWeight
        : displayWeight / 2.20462;
  }

  void _handleSave() async {
    try {
      // Update global isMetric if it changed
      if (_isMetric != widget.settingsProvider.isMetric) {
        await widget.settingsProvider.updateUnitPreference(_isMetric);
      }

      await widget.settingsProvider.updateWeight(
        _currentWeight,
        _isMetric,
      );
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Weight updated'),
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
    final unit = _isMetric ? 'kg' : 'lbs';

    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Weight',
            style: AppDialogTheme.titleStyle,
          ),
          _buildUnitToggle(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

// ═══════════════════════════════════════════════════════════════
// Starting Weight Scroll Picker Dialog
// ═══════════════════════════════════════════════════════════════

class _StartingWeightScrollDialog extends StatefulWidget {
  final SettingsProvider settingsProvider;

  const _StartingWeightScrollDialog({
    required this.settingsProvider,
  });

  @override
  State<_StartingWeightScrollDialog> createState() => _StartingWeightScrollDialogState();
}

class _StartingWeightScrollDialogState extends State<_StartingWeightScrollDialog> {
  late FixedExtentScrollController _weightWholeController;
  late FixedExtentScrollController _weightDecimalController;
  late bool _isMetric;

  static const int minWeight = 30;
  static const int maxWeight = 300;

  @override
  void initState() {
    super.initState();
    _isMetric = widget.settingsProvider.isMetric;
    // Use existing starting weight, or fall back to current weight, or default
    final initialWeight = widget.settingsProvider.userProfile?.startingWeight
        ?? widget.settingsProvider.currentWeight
        ?? 70.0;
    _initializeControllers(initialWeight);
  }

  void _initializeControllers(double weight) {
    final displayWeight = _isMetric
        ? weight
        : weight * 2.20462;

    final wholeWeight = displayWeight.floor();
    final decimalWeight = ((displayWeight - wholeWeight) * 10).round();

    final minDisplayWeight = _isMetric
        ? minWeight
        : (minWeight * 2.20462).round();
    final maxDisplayWeight = _isMetric
        ? maxWeight
        : (maxWeight * 2.20462).round();

    _weightWholeController = FixedExtentScrollController(
      initialItem: (wholeWeight - minDisplayWeight).clamp(0, maxDisplayWeight - minDisplayWeight),
    );
    _weightDecimalController = FixedExtentScrollController(
      initialItem: decimalWeight.clamp(0, 9),
    );
  }

  void _toggleUnit() {
    setState(() {
      // Get current weight in kg
      final currentWeightKg = _currentWeight;

      // Toggle the unit
      _isMetric = !_isMetric;

      // Dispose old controllers
      _weightWholeController.dispose();
      _weightDecimalController.dispose();

      // Reinitialize with the same weight value
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
      ? minWeight
      : (minWeight * 2.20462).round();
  int get _maxDisplayWeight => _isMetric
      ? maxWeight
      : (maxWeight * 2.20462).round();

  double get _currentWeight {
    final whole = _minDisplayWeight + _weightWholeController.selectedItem;
    final decimal = _weightDecimalController.selectedItem / 10.0;
    final displayWeight = whole + decimal;

    return _isMetric
        ? displayWeight
        : displayWeight / 2.20462;
  }

  void _handleSave() async {
    try {
      await widget.settingsProvider.updateStartingWeight(_currentWeight);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Starting weight updated'),
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
    final unit = _isMetric ? 'kg' : 'lbs';

    return AlertDialog(
      backgroundColor: AppDialogTheme.backgroundColor,
      shape: AppDialogTheme.shape,
      contentPadding: AppDialogTheme.contentPadding,
      actionsPadding: AppDialogTheme.actionsPadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Starting Weight',
            style: AppDialogTheme.titleStyle,
          ),
          _buildUnitToggle(),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Set your weight when you started your journey',
            style: TextStyle(
              fontSize: 13,
              color: AppDialogTheme.colorTextSecondary,
            ),
          ),
          const SizedBox(height: 16),
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