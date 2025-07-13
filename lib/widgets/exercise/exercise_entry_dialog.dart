// lib/widgets/exercise/exercise_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme.dart';
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

  @override
  void initState() {
    super.initState();
    _controller = ExerciseDialogController(
      exerciseProvider: widget.exerciseProvider,
      existingExercise: widget.existingExercise,
      preselectedExercise: widget.preselectedExercise,
    );
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _handleSave() async {
    final result = await _controller.saveExercise();
    if (result == 'success') {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onExerciseSaved?.call();
        _showSnackBar('Exercise logged successfully!', Colors.green);
      }
    } else {
      _showSnackBar(result, Colors.red);
    }
  }

  void _showCustomExerciseOptions(int slotIndex, Map<String, String> exercise) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              exercise['name']!,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.openCustomExerciseModal(slotIndex);
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Edit', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _controller.deleteCustomExerciseSlot(slotIndex);
                    },
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Stack(
      children: [
        Dialog(
          insetPadding: EdgeInsets.all(isMobile ? 8 : 16),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: isMobile ? screenWidth * 0.95 : 800,
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_controller.showCustomExerciseModal) _buildCustomExerciseModal(),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.existingExercise != null ? 'Edit Exercise' : 'Log Exercise',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  'Complete your workout entry',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildExerciseSection(),
          if (_controller.selectedExercise != null) ...[
            const SizedBox(height: 24),
            _buildDurationSection(),
          ],
          if (_controller.durationController.text.isNotEmpty) ...[
            const SizedBox(height: 24),
            _buildIntensitySection(),
          ],
          if (_controller.estimatedCalories > 0) ...[
            const SizedBox(height: 24),
            _buildCalorieEstimate(),
          ],
          const SizedBox(height: 24),
          _buildNotesSection(),
          const SizedBox(height: 24),
          _buildSummaryCard(),
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseSection(),
                if (_controller.selectedExercise != null) ...[
                  const SizedBox(height: 24),
                  _buildDurationSection(),
                ],
                if (_controller.durationController.text.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildIntensitySection(),
                ],
                if (_controller.estimatedCalories > 0) ...[
                  const SizedBox(height: 24),
                  _buildCalorieEstimate(),
                ],
                const SizedBox(height: 24),
                _buildNotesSection(),
              ],
            ),
          ),
        ),
        Container(
          width: 280,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            border: Border(left: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Column(
            children: [
              _buildSummaryCard(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('1', 'Choose Exercise *'),
        const SizedBox(height: 16),
        _buildCustomExerciseSlots(),
        _buildCoreExerciseGrid(),
        if (_controller.shouldShowRunWalkOptions()) _buildRunWalkOptions(),
      ],
    );
  }

  Widget _buildStepHeader(String step, String title) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(color: AppTheme.primaryBlue, shape: BoxShape.circle),
          child: Center(
            child: Text(step, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildCustomExerciseSlots() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text('⭐', style: TextStyle(color: Colors.purple)),
            SizedBox(width: 8),
            Text('Your Custom Exercises', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: 3, // Always 3 slots
          itemBuilder: (context, index) {
            final customExercise = _controller.getCustomExerciseAtSlot(index);
            final isEmpty = customExercise == null;
            final isSelected = !isEmpty && _controller.isCustomExerciseSelected(index);
            
            return GestureDetector(
              onTap: () {
                if (isEmpty) {
                  _controller.openCustomExerciseModal(index);
                } else {
                  _controller.handleExerciseSelect(customExercise['name']!);
                }
              },
              onLongPress: isEmpty ? null : () {
                _showCustomExerciseOptions(index, customExercise!);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isEmpty 
                        ? Colors.grey.shade300
                        : isSelected 
                            ? Colors.purple 
                            : Colors.purple.withOpacity(0.3),
                    width: 2,
                    style: isEmpty ? BorderStyle.dashed : BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  color: isEmpty 
                      ? Colors.grey.shade50
                      : isSelected 
                          ? Colors.purple.withOpacity(0.1) 
                          : Colors.white,
                ),
                child: isEmpty 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: Colors.grey.shade400, size: 24),
                          const SizedBox(height: 4),
                          Text(
                            'Add Custom',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Exercise',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey.shade500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(customExercise['icon']!, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            customExercise['name']!,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            customExercise['benefit']!,
                            style: const TextStyle(
                              fontSize: 8,
                              color: Colors.purple,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCoreExerciseGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Always 3 columns for better layout
        childAspectRatio: 0.9, // Slightly taller cards on mobile
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _controller.getCoreExercises().length,
      itemBuilder: (context, index) {
        final exercise = _controller.getCoreExercises()[index];
        final isSelected = _controller.isExerciseSelected(exercise['name'] as String);
        
        return GestureDetector(
          onTap: () => _controller.handleExerciseSelect(exercise['name'] as String),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                width: 2,
              ),
              borderRadius: BorderRadius.circular(12),
              color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  exercise['icon'] as String, 
                  style: const TextStyle(fontSize: 20), // Smaller icons
                ),
                const SizedBox(height: 6),
                Text(
                  exercise['name'] as String,
                  style: const TextStyle(
                    fontSize: 10, 
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  exercise['benefit'] as String,
                  style: TextStyle(
                    fontSize: 8, 
                    color: AppTheme.primaryBlue,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (exercise['hasSubOptions'] == true)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'Tap to choose', 
                      style: TextStyle(
                        fontSize: 7, 
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRunWalkOptions() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          const Text('Choose your pace:', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            children: _controller.getRunWalkOptions().map((option) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => _controller.handleRunWalkSelect(option),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        Text(option['icon']!, style: const TextStyle(fontSize: 20)),
                        Text(option['name']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('2', 'Duration *'),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _controller.durationController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: _controller.validateDuration,
                onChanged: _controller.handleDurationChange,
                decoration: const InputDecoration(
                  hintText: '30',
                  suffixText: 'min',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _controller.getDurationPresets().map((preset) {
            final isSelected = _controller.isDurationPresetSelected(preset);
            return GestureDetector(
              onTap: () => _controller.handleDurationPreset(preset),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '${preset}m',
                  style: TextStyle(color: isSelected ? Colors.white : Colors.black),
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
        _buildStepHeader('3', 'Intensity'),
        const SizedBox(height: 12),
        Column(
          children: _controller.getIntensityLevels().map((level) {
            final isSelected = _controller.isIntensitySelected(level['name'] as String);
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _controller.handleIntensitySelect(level['name'] as String),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected ? AppTheme.primaryBlue : Colors.grey.shade300,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Text(level['icon'] as String, style: const TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(level['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                            Text(level['description'] as String, style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                      if (isSelected) Icon(Icons.check, color: AppTheme.primaryBlue),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCalorieEstimate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.local_fire_department, color: Colors.orange.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Estimated Calories', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${_controller.selectedIntensity} intensity', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(
            '${_controller.estimatedCalories}',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStepHeader('4', 'Notes (Optional)'),
        const SizedBox(height: 12),
        TextField(
          controller: _controller.notesController,
          maxLines: 3,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'How did it feel?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        border: Border.all(color: Colors.blue.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.fitness_center, color: AppTheme.primaryBlue),
              const SizedBox(width: 8),
              const Text('Summary', style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Exercise:', _controller.getDisplayExerciseName()),
          _buildSummaryRow('Duration:', _controller.durationController.text.isNotEmpty 
              ? '${_controller.durationController.text} min' : 'Not set'),
          _buildSummaryRow('Intensity:', _controller.selectedIntensity),
          if (_controller.estimatedCalories > 0)
            _buildSummaryRow('Calories:', '${_controller.estimatedCalories}'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _controller.canSave && !_controller.isLoading ? _handleSave : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryBlue,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _controller.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    widget.existingExercise != null ? 'Update' : 'Log Exercise',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomExerciseModal() {
    final isEditing = _controller.editingSlotIndex != null && 
        _controller.getCustomExerciseAtSlot(_controller.editingSlotIndex!) != null;
    final existingExercise = isEditing 
        ? _controller.getCustomExerciseAtSlot(_controller.editingSlotIndex!)! 
        : null;

    String selectedName = existingExercise?['name'] ?? '';
    String selectedIcon = existingExercise?['icon'] ?? _controller.getAvailableIcons().first;
    String selectedBenefit = existingExercise?['benefit'] ?? _controller.getAvailableBenefits().first;

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isEditing ? 'Edit Custom Exercise' : 'Create Custom Exercise',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  
                  // Exercise Name
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Exercise Name',
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(text: selectedName),
                    onChanged: (value) => selectedName = value,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Icon Selection
                  const Text('Choose Icon:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 120,
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        childAspectRatio: 1,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemCount: _controller.getAvailableIcons().length,
                      itemBuilder: (context, index) {
                        final icon = _controller.getAvailableIcons()[index];
                        final isSelected = selectedIcon == icon;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedIcon = icon),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected ? Colors.purple : Colors.grey.shade300,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.white,
                            ),
                            child: Center(
                              child: Text(icon, style: const TextStyle(fontSize: 20)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Benefit Category
                  DropdownButtonFormField<String>(
                    value: selectedBenefit,
                    decoration: const InputDecoration(
                      labelText: 'Benefit Category',
                      border: OutlineInputBorder(),
                    ),
                    items: _controller.getAvailableBenefits().map((benefit) {
                      return DropdownMenuItem(value: benefit, child: Text(benefit));
                    }).toList(),
                    onChanged: (value) => setModalState(() => selectedBenefit = value!),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: _controller.closeCustomExerciseModal,
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedName.trim().isNotEmpty) {
                              final success = await _controller.saveCustomExerciseToSlot(
                                name: selectedName,
                                icon: selectedIcon,
                                benefit: selectedBenefit,
                              );
                              if (success) {
                                _controller.closeCustomExerciseModal();
                                _showSnackBar(
                                  isEditing ? 'Exercise updated!' : 'Exercise created!',
                                  Colors.green,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                          child: Text(
                            isEditing ? 'Update' : 'Create',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}