// lib/widgets/progress/exercise_entry_dialog.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/dialog_theme.dart';
import '../../config/design_system/typography.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';
import 'exercise_dialog_controller.dart';

class ExerciseEntryDialog extends StatefulWidget {
  final ExerciseProvider exerciseProvider;
  final ExerciseEntry? existingExercise;
  final String? preselectedExercise;
  final VoidCallback? onExerciseSaved;

  const ExerciseEntryDialog({
    super.key,
    required this.exerciseProvider,
    this.existingExercise,
    this.preselectedExercise,
    this.onExerciseSaved,
  });

  @override
  State<ExerciseEntryDialog> createState() => _ExerciseEntryDialogState();
}

class _ExerciseEntryDialogState extends State<ExerciseEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  late ExerciseDialogController _controller;
  bool _isCustomTab = false;
  bool _isManualCalories = false;
  final TextEditingController _manualCaloriesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ExerciseDialogController(
      exerciseProvider: widget.exerciseProvider,
      existingExercise: widget.existingExercise,
      preselectedExercise: widget.preselectedExercise,
    );
    _controller.addListener(() => setState(() {}));
    
    if (widget.existingExercise != null) {
      _manualCaloriesController.text = widget.existingExercise!.caloriesBurned.toString();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualCaloriesController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState?.validate() ?? false) {
      // Handle manual calories for preset tab
      if (!_isCustomTab && _isManualCalories && _manualCaloriesController.text.isNotEmpty) {
        final manualCal = int.tryParse(_manualCaloriesController.text);
        if (manualCal != null && manualCal > 0) {
          _controller.estimatedCalories = manualCal;
        }
      }
      
      // Handle calories for custom tab (always from _manualCaloriesController)
      if (_isCustomTab && _manualCaloriesController.text.isNotEmpty) {
        final customCal = int.tryParse(_manualCaloriesController.text);
        if (customCal != null && customCal > 0) {
          _controller.estimatedCalories = customCal;
        }
      }

      // For custom tab, set default intensity since user doesn't select it
      if (_isCustomTab) {
        _controller.selectedIntensity = 'Moderate';
      }

      final result = await _controller.saveExercise();
      if (result == 'success') {
        if (mounted) {
          Navigator.of(context).pop();
          widget.onExerciseSaved?.call();
          // ✅ REMOVED: Success snackbar - dialog closes silently
        }
      } else {
        // Only show snackbar for errors
        _showSnackBar(result, Colors.red);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: AppDialogTheme.backdropBlurSigmaX,
        sigmaY: AppDialogTheme.backdropBlurSigmaY,
      ),
      child: Dialog(
        shape: AppDialogTheme.shape,
        backgroundColor: AppDialogTheme.backgroundColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 700,
            maxHeight: 700,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    child: _isCustomTab ? _buildCustomTab() : _buildPresetTab(),
                  ),
                ),
              ),
              _buildActions(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Expanded(
            child: Text(
              widget.existingExercise != null ? 'Edit Exercise' : 'Log Exercise',
              style: AppDialogTheme.titleStyle,
            ),
          ),
          // Tab Switcher
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabButton('Preset', !_isCustomTab, () {
                  setState(() => _isCustomTab = false);
                }),
                const SizedBox(width: 6),
                _buildTabButton('Custom', _isCustomTab, () {
                  setState(() => _isCustomTab = true);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1A1A1A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isActive
              ? [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))]
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : const Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }

  Widget _buildPresetTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseSelection(),
          const SizedBox(height: 24),
          _buildDurationSection(),
          const SizedBox(height: 24),
          _buildIntensitySection(),
          const SizedBox(height: 24),
          _buildCalorieSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCustomTab() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomExerciseName(),
          const SizedBox(height: 24),
          _buildDurationSection(),
          const SizedBox(height: 24),
          _buildCustomCaloriesInput(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text, {bool required = false}) {
    return Text(
      required ? '$text *' : text,
      style: AppTypography.labelMedium.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF374151),
      ),
    );
  }

  Widget _buildExerciseSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Choose Exercise', required: true),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisExtent: 105,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: _controller.getExercises().length,
          itemBuilder: (context, index) {
            final exerciseName = _controller.getExercises()[index];
            final isSelected = _controller.isExerciseSelected(exerciseName);

            return GestureDetector(
              onTap: () => _controller.selectExercise(exerciseName),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFD1D5DB),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isSelected ? const Color(0xFFF9FAFB) : Colors.white,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getExerciseIcon(exerciseName),
                      size: 29,
                      color: const Color(0xFF4B5563),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Text(
                        exerciseName,
                        style: AppTypography.bodySmall.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1A1A),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  IconData _getExerciseIcon(String exerciseName) {
    final iconMap = {
      'Running': Icons.directions_run,
      'Walking': Icons.directions_walk,
      'Cycling': Icons.directions_bike,
      'Swimming': Icons.pool,
      'Weight Training': Icons.fitness_center,
      'Yoga': Icons.self_improvement,
    };
    return iconMap[exerciseName] ?? Icons.sports_gymnastics;
  }

  Widget _buildCustomExerciseName() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Exercise Name', required: true),
        const SizedBox(height: 12),
        TextFormField(
          initialValue: _controller.selectedExercise,
          onChanged: (value) => _controller.selectedExercise = value,
          style: AppDialogTheme.inputTextStyle,
          decoration: AppDialogTheme.inputDecoration(
            hintText: 'e.g., Jump Rope, Pilates',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Exercise name is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Duration', required: true),
        const SizedBox(height: 12),
        TextFormField(
          controller: _controller.durationController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppDialogTheme.inputTextStyle,
          decoration: AppDialogTheme.inputDecoration(
            hintText: 'Minutes',
          ),
          validator: _controller.validateDuration,
          onChanged: _controller.onDurationChanged,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: _controller.getDurationPresets().map((preset) {
            final isSelected = _controller.isDurationPresetSelected(preset);
            return GestureDetector(
              onTap: () => _controller.selectDurationPreset(preset),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFD1D5DB),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: isSelected ? const Color(0xFFF9FAFB) : Colors.white,
                ),
                child: Text(
                  '${preset}m',
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFF6B7280),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildIntensitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Intensity'),
        const SizedBox(height: 12),
        Row(
          children: _controller.getIntensityLevels().map((intensity) {
            final isSelected = _controller.isIntensitySelected(intensity);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: GestureDetector(
                  onTap: () => _controller.selectIntensity(intensity),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? const Color(0xFF1A1A1A) : const Color(0xFFD1D5DB),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: isSelected ? const Color(0xFFF9FAFB) : Colors.white,
                    ),
                    child: Text(
                      intensity,
                      style: AppTypography.labelMedium.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1A1A1A),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalorieSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Calories Burned'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _isManualCalories ? 'MANUAL OVERRIDE' : 'ESTIMATED CALORIES',
                      style: AppTypography.overline.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _isManualCalories
                        ? SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _manualCaloriesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              style: AppTypography.dataSmall.copyWith(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1A1A),
                              ),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFFD1D5DB)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Color(0xFF1A1A1A), width: 2),
                                ),
                              ),
                              validator: (value) {
                                if (_isManualCalories && (value == null || value.isEmpty)) {
                                  return 'Required';
                                }
                                return null;
                              },
                            ),
                          )
                        : Text(
                            '${_controller.estimatedCalories} cal',
                            style: AppTypography.dataSmall.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isManualCalories = !_isManualCalories;
                    if (!_isManualCalories) {
                      _manualCaloriesController.clear();
                    } else {
                      _manualCaloriesController.text = _controller.estimatedCalories.toString();
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFD1D5DB)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isManualCalories ? 'Auto' : 'Edit',
                    style: AppTypography.labelMedium.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomCaloriesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionLabel('Calories Burned', required: true),
        const SizedBox(height: 12),
        TextFormField(
          controller: _manualCaloriesController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: AppDialogTheme.inputTextStyle,
          decoration: AppDialogTheme.inputDecoration(
            hintText: 'Enter calories burned',
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Calories are required for custom exercises';
            }
            final cal = int.tryParse(value);
            if (cal == null || cal <= 0) {
              return 'Please enter a valid number';
            }
            return null;
          },
          onChanged: (value) {
            final cal = int.tryParse(value);
            if (cal != null) {
              _controller.estimatedCalories = cal;
            }
          },
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: AppDialogTheme.actionsPadding,
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: AppDialogTheme.cancelButtonStyle,
              child: const Text('Cancel'),
            ),
          ),
          const SizedBox(width: AppDialogTheme.buttonGap),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: _controller.canSave && !_controller.isLoading ? _handleSave : null,
              style: AppDialogTheme.primaryButtonStyle,
              child: _controller.isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save'),
            ),
          ),
        ],
      ),
    );
  }
}