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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    return Dialog(
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
        if (_controller.hasCustomExercises()) _buildCustomExerciseRow(),
        _buildCoreExerciseGrid(),
        if (_controller.shouldShowRunWalkOptions()) _buildRunWalkOptions(),
        _buildCustomExerciseInput(),
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

  Widget _buildCustomExerciseRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('⭐ Your Custom Exercises', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _controller.savedCustomExercises.length,
            itemBuilder: (context, index) {
              final exercise = _controller.savedCustomExercises[index];
              final isSelected = _controller.isCustomExerciseSelected(exercise);
              
              return Container(
                width: 80,
                margin: const EdgeInsets.only(right: 8),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () => _controller.handleExerciseSelect(exercise['name']!),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isSelected ? Colors.purple : Colors.purple.withOpacity(0.3),
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          color: isSelected ? Colors.purple.withOpacity(0.1) : Colors.white,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(exercise['icon']!, style: const TextStyle(fontSize: 20)),
                            const SizedBox(height: 4),
                            Text(
                              exercise['name']!,
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _controller.deleteCustomExercise(exercise),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildCoreExerciseGrid() {
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Always 3 columns for better layout
        childAspectRatio: isMobile ? 0.9 : 1.0, // Slightly taller cards on mobile
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
                  style: TextStyle(fontSize: isMobile ? 20 : 24), // Smaller icons
                ),
                const SizedBox(height: 6),
                Text(
                  exercise['name'] as String,
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11, 
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
                    fontSize: isMobile ? 8 : 9, 
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

  Widget _buildCustomExerciseInput() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.add, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _controller.customExerciseController,
              onChanged: _controller.handleCustomExerciseInput,
              decoration: const InputDecoration(
                hintText: 'Enter custom exercise...',
                border: InputBorder.none,
              ),
            ),
          ),
          if (_controller.shouldShowCustomExerciseSaveButton())
            ElevatedButton(
              onPressed: () async {
                final success = await _controller.saveCustomExercise();
                if (success) _showSnackBar('Exercise saved!', Colors.green);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Save', style: TextStyle(color: Colors.white)),
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
}