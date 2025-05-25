// lib/widgets/exercise/exercise_entry_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/design_system/theme.dart';
import '../../config/design_system/text_styles.dart';
import '../../providers/exercise_provider.dart';
import '../../data/models/exercise_entry.dart';

class ExerciseEntryDialog extends StatefulWidget {
  final ExerciseProvider exerciseProvider;
  final ExerciseEntry? existingExercise;
  final String? preselectedExercise;
  final VoidCallback? onExerciseSaved;

  const ExerciseEntryDialog({
    Key? key,
    required this.exerciseProvider,
    this.existingExercise,
    this.preselectedExercise,
    this.onExerciseSaved,
  }) : super(key: key);

  @override
  State<ExerciseEntryDialog> createState() => _ExerciseEntryDialogState();
}

class _ExerciseEntryDialogState extends State<ExerciseEntryDialog> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedExercise;
  String _selectedType = 'Cardio';
  String _selectedIntensity = 'Moderate';
  int _estimatedCalories = 0;
  bool _isLoading = false;

  // Common exercises list
  final List<Map<String, String>> _commonExercises = [
    {'name': 'Walking', 'type': 'Cardio'},
    {'name': 'Brisk Walking', 'type': 'Cardio'},
    {'name': 'Running', 'type': 'Cardio'},
    {'name': 'Cycling', 'type': 'Cardio'},
    {'name': 'Swimming', 'type': 'Water'},
    {'name': 'Weight Training', 'type': 'Strength'},
    {'name': 'Yoga', 'type': 'Flexibility'},
    {'name': 'HIIT', 'type': 'Cardio'},
    {'name': 'Dancing', 'type': 'Cardio'},
    {'name': 'Stretching', 'type': 'Flexibility'},
  ];

  final List<String> _exerciseTypes = ['Cardio', 'Strength', 'Flexibility', 'Sports', 'Water', 'Other'];
  final List<String> _intensityLevels = ['Light', 'Moderate', 'Intense'];

  @override
  void initState() {
    super.initState();

    // Initialize with existing exercise or preselected exercise
    if (widget.existingExercise != null) {
      final exercise = widget.existingExercise!;
      _selectedExercise = exercise.name;
      _selectedType = exercise.type;
      _selectedIntensity = exercise.intensity;
      _durationController.text = exercise.duration.toString();
      _notesController.text = exercise.notes ?? '';
      _estimatedCalories = exercise.caloriesBurned;
    } else if (widget.preselectedExercise != null) {
      _selectedExercise = widget.preselectedExercise;
      final exerciseData = _commonExercises.firstWhere(
        (e) => e['name'] == widget.preselectedExercise,
        orElse: () => {'name': widget.preselectedExercise!, 'type': 'Cardio'},
      );
      _selectedType = exerciseData['type']!;
      _durationController.text = '30'; // Default duration
    }

    // Calculate initial calories if we have duration
    if (_durationController.text.isNotEmpty) {
      _calculateCalories();
    }
  }

  @override
  void dispose() {
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _calculateCalories() {
    final duration = int.tryParse(_durationController.text) ?? 0;
    if (duration > 0 && _selectedExercise != null) {
      // Get user's current weight (default to 70kg if not available)
      final userWeight = widget.exerciseProvider.currentWeight ?? 70.0;
      
      try {
        // Create a temporary exercise to get calorie calculation
        final tempExercise = ExerciseEntry.fromTemplate(
          exerciseName: _selectedExercise!,
          duration: duration,
          userWeight: userWeight,
        );
        
        setState(() {
          _estimatedCalories = tempExercise.caloriesBurned;
        });
      } catch (e) {
        // Fallback calculation if exercise template not found
        double caloriesPerMinute = _getCaloriesPerMinute(_selectedIntensity, userWeight);
        setState(() {
          _estimatedCalories = (duration * caloriesPerMinute).round();
        });
      }
    } else {
      setState(() {
        _estimatedCalories = 0;
      });
    }
  }

  double _getCaloriesPerMinute(String intensity, double weight) {
    // Base calories per minute for 70kg person, adjusted for actual weight
    double baseCalories;
    switch (intensity.toLowerCase()) {
      case 'light':
        baseCalories = 3.5;
        break;
      case 'moderate':
        baseCalories = 7.0;
        break;
      case 'intense':
        baseCalories = 12.0;
        break;
      default:
        baseCalories = 7.0;
    }
    
    // Adjust for user's weight
    return baseCalories * (weight / 70.0);
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final duration = int.parse(_durationController.text);
      final notes = _notesController.text.trim();

      if (widget.existingExercise != null) {
        // Update existing exercise
        final updatedExercise = widget.existingExercise!.copyWith(
          name: _selectedExercise!,
          type: _selectedType,
          duration: duration,
          caloriesBurned: _estimatedCalories,
          intensity: _selectedIntensity,
          notes: notes.isEmpty ? null : notes,
        );
        
        await widget.exerciseProvider.updateExercise(updatedExercise);
      } else {
        // Create new exercise
        final newExercise = ExerciseEntry.create(
          name: _selectedExercise!,
          type: _selectedType,
          duration: duration,
          caloriesBurned: _estimatedCalories,
          intensity: _selectedIntensity,
          notes: notes.isEmpty ? null : notes,
        );
        
        await widget.exerciseProvider.logExercise(newExercise);
      }

      if (mounted) {
        Navigator.of(context).pop();
        if (widget.onExerciseSaved != null) {
          widget.onExerciseSaved!();
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.existingExercise != null 
                  ? 'Exercise updated successfully'
                  : 'Exercise logged successfully',
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving exercise: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.existingExercise != null ? 'Edit Exercise' : 'Log Exercise',
        style: AppTextStyles.getSubHeadingStyle().copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppTheme.primaryBlue,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Exercise selection
              _buildExerciseSelector(),
              
              const SizedBox(height: 20),
              
              // Exercise type
              _buildTypeSelector(),
              
              const SizedBox(height: 20),
              
              // Duration input
              _buildDurationInput(),
              
              const SizedBox(height: 20),
              
              // Intensity selection
              _buildIntensitySelector(),
              
              const SizedBox(height: 20),
              
              // Calorie estimate
              _buildCalorieEstimate(),
              
              const SizedBox(height: 20),
              
              // Notes input
              _buildNotesInput(),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('CANCEL'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveExercise,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryBlue,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Text(widget.existingExercise != null ? 'UPDATE' : 'SAVE'),
        ),
      ],
    );
  }

  Widget _buildExerciseSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Exercise',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedExercise,
          decoration: InputDecoration(
            hintText: 'Select an exercise',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: [
            // Common exercises
            ..._commonExercises.map((exercise) => DropdownMenuItem(
              value: exercise['name'],
              child: Text(exercise['name']!),
            )),
            // Custom option
            const DropdownMenuItem(
              value: 'Custom',
              child: Text('Custom Exercise'),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedExercise = value;
              if (value != null && value != 'Custom') {
                final exerciseData = _commonExercises.firstWhere(
                  (e) => e['name'] == value,
                  orElse: () => {'name': value, 'type': 'Cardio'},
                );
                _selectedType = exerciseData['type']!;
              }
              _calculateCalories();
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select an exercise';
            }
            return null;
          },
        ),
        
        // Custom exercise name input
        if (_selectedExercise == 'Custom') ...[
          const SizedBox(height: 12),
          TextFormField(
            decoration: InputDecoration(
              labelText: 'Custom Exercise Name',
              hintText: 'Enter exercise name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: AppTheme.primaryBlue),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _selectedExercise = value.trim().isEmpty ? 'Custom' : value.trim();
                _calculateCalories();
              });
            },
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter exercise name';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: _exerciseTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: (value) {
            setState(() {
              _selectedType = value!;
              _calculateCalories();
            });
          },
        ),
      ],
    );
  }

  Widget _buildDurationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duration (minutes)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            hintText: 'e.g., 30',
            suffixText: 'min',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (value) {
            _calculateCalories();
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter duration';
            }
            final duration = int.tryParse(value);
            if (duration == null || duration <= 0) {
              return 'Please enter a valid duration';
            }
            if (duration > 480) {
              return 'Duration cannot exceed 8 hours';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildIntensitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Intensity',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: _intensityLevels.map((intensity) {
            final isSelected = _selectedIntensity == intensity;
            final color = _getIntensityColor(intensity);
            
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIntensity = intensity;
                      _calculateCalories();
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? color.withOpacity(0.2) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _getIntensityIcon(intensity),
                          color: isSelected ? color : Colors.grey[600],
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          intensity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            color: isSelected ? color : Colors.grey[600],
                          ),
                        ),
                      ],
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

  Widget _buildCalorieEstimate() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryBlue.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryBlue.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_fire_department,
            color: AppTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Estimated calories burned:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const Spacer(),
          Text(
            '$_estimatedCalories cal',
            style: AppTextStyles.getNumericStyle().copyWith(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes about your workout...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppTheme.primaryBlue),
            ),
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Color _getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'light':
        return AppTheme.mintAccent;
      case 'moderate':
        return AppTheme.goldAccent;
      case 'intense':
        return AppTheme.coralAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _getIntensityIcon(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'light':
        return Icons.directions_walk;
      case 'moderate':
        return Icons.directions_bike;
      case 'intense':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }
}