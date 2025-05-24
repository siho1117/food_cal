// lib/data/models/exercise_entry.dart

/// Model class representing an exercise entry logged by the user
class ExerciseEntry {
  final String id;
  final String name; // Exercise name (e.g., "Running", "Cycling", "Push-ups")
  final String type; // Exercise type (e.g., "Cardio", "Strength", "Flexibility")
  final int duration; // Duration in minutes
  final int caloriesBurned; // Estimated calories burned
  final String intensity; // "Light", "Moderate", "Intense"
  final DateTime timestamp; // When the exercise was performed
  final String? notes; // Optional user notes about the exercise

  ExerciseEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.duration,
    required this.caloriesBurned,
    required this.intensity,
    required this.timestamp,
    this.notes,
  });

  /// Create a new exercise entry with a unique ID
  factory ExerciseEntry.create({
    required String name,
    required String type,
    required int duration,
    required int caloriesBurned,
    required String intensity,
    DateTime? timestamp,
    String? notes,
  }) {
    final now = timestamp ?? DateTime.now();
    final id = '${now.millisecondsSinceEpoch}_${name.replaceAll(' ', '_').toLowerCase()}';

    return ExerciseEntry(
      id: id,
      name: name,
      type: type,
      duration: duration,
      caloriesBurned: caloriesBurned,
      intensity: intensity,
      timestamp: now,
      notes: notes,
    );
  }

  /// Create a copy of this exercise entry with modified properties
  ExerciseEntry copyWith({
    String? id,
    String? name,
    String? type,
    int? duration,
    int? caloriesBurned,
    String? intensity,
    DateTime? timestamp,
    String? notes,
  }) {
    return ExerciseEntry(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      intensity: intensity ?? this.intensity,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  /// Convert to Map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'duration': duration,
      'caloriesBurned': caloriesBurned,
      'intensity': intensity,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'notes': notes,
    };
  }

  /// Create from Map for retrieval from storage
  factory ExerciseEntry.fromMap(Map<String, dynamic> map) {
    return ExerciseEntry(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Exercise',
      type: map['type'] ?? 'Other',
      duration: map['duration']?.toInt() ?? 0,
      caloriesBurned: map['caloriesBurned']?.toInt() ?? 0,
      intensity: map['intensity'] ?? 'Moderate',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
      notes: map['notes'],
    );
  }

  /// Get formatted duration string
  String getFormattedDuration() {
    if (duration < 60) {
      return '${duration}m';
    } else {
      final hours = duration ~/ 60;
      final minutes = duration % 60;
      return minutes > 0 ? '${hours}h ${minutes}m' : '${hours}h';
    }
  }

  /// Get formatted calories string
  String getFormattedCalories() {
    return '$caloriesBurned cal';
  }

  /// Get intensity color for UI display
  static String getIntensityColor(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'light':
        return '#E4F7D7'; // Mint green
      case 'moderate':
        return '#CF9340'; // Gold
      case 'intense':
        return '#E27069'; // Coral
      default:
        return '#F5EFE0'; // Beige
    }
  }

  /// Get exercise type icon name for UI display
  static String getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'cardio':
        return 'directions_run';
      case 'strength':
        return 'fitness_center';
      case 'flexibility':
        return 'self_improvement';
      case 'sports':
        return 'sports_tennis';
      case 'water':
        return 'pool';
      default:
        return 'directions_walk';
    }
  }

  /// Calculate calories per minute for this exercise
  double get caloriesPerMinute => duration > 0 ? caloriesBurned / duration : 0.0;

  /// Check if this is a high-intensity exercise (>= 10 cal/min)
  bool get isHighIntensity => caloriesPerMinute >= 10.0;

  /// Get descriptive summary of the exercise
  String getSummary() {
    return '$name • ${getFormattedDuration()} • ${getFormattedCalories()}';
  }

  /// Generate a descriptive string for the exercise entry
  @override
  String toString() {
    return 'ExerciseEntry: $name (${getFormattedDuration()}, ${getFormattedCalories()})';
  }

  /// Common exercise templates for quick logging
  static List<Map<String, dynamic>> getCommonExercises() {
    return [
      {
        'name': 'Walking',
        'type': 'Cardio',
        'intensity': 'Light',
        'caloriesPerMinute': 3.5, // Approximate for 70kg person
      },
      {
        'name': 'Brisk Walking',
        'type': 'Cardio',
        'intensity': 'Moderate',
        'caloriesPerMinute': 5.0,
      },
      {
        'name': 'Running',
        'type': 'Cardio',
        'intensity': 'Intense',
        'caloriesPerMinute': 12.0,
      },
      {
        'name': 'Cycling',
        'type': 'Cardio',
        'intensity': 'Moderate',
        'caloriesPerMinute': 8.0,
      },
      {
        'name': 'Swimming',
        'type': 'Water',
        'intensity': 'Moderate',
        'caloriesPerMinute': 10.0,
      },
      {
        'name': 'Weight Training',
        'type': 'Strength',
        'intensity': 'Moderate',
        'caloriesPerMinute': 6.0,
      },
      {
        'name': 'Yoga',
        'type': 'Flexibility',
        'intensity': 'Light',
        'caloriesPerMinute': 3.0,
      },
      {
        'name': 'HIIT',
        'type': 'Cardio',
        'intensity': 'Intense',
        'caloriesPerMinute': 15.0,
      },
      {
        'name': 'Dancing',
        'type': 'Cardio',
        'intensity': 'Moderate',
        'caloriesPerMinute': 7.0,
      },
      {
        'name': 'Stretching',
        'type': 'Flexibility',
        'intensity': 'Light',
        'caloriesPerMinute': 2.5,
      },
    ];
  }

  /// Create an exercise entry from a common exercise template
  static ExerciseEntry fromTemplate({
    required String exerciseName,
    required int duration,
    required double userWeight, // in kg
    DateTime? timestamp,
    String? notes,
  }) {
    // Find the exercise template
    final templates = getCommonExercises();
    final template = templates.firstWhere(
      (t) => t['name'] == exerciseName,
      orElse: () => {
        'name': exerciseName,
        'type': 'Other',
        'intensity': 'Moderate',
        'caloriesPerMinute': 5.0,
      },
    );

    // Calculate calories based on user weight (adjust for weight differences from 70kg base)
    final baseCaloriesPerMinute = template['caloriesPerMinute'] as double;
    final adjustedCaloriesPerMinute = baseCaloriesPerMinute * (userWeight / 70.0);
    final totalCalories = (adjustedCaloriesPerMinute * duration).round();

    return ExerciseEntry.create(
      name: template['name'] as String,
      type: template['type'] as String,
      duration: duration,
      caloriesBurned: totalCalories,
      intensity: template['intensity'] as String,
      timestamp: timestamp,
      notes: notes,
    );
  }

  /// Validate exercise entry data
  bool isValid() {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        type.isNotEmpty &&
        duration > 0 &&
        caloriesBurned >= 0 &&
        intensity.isNotEmpty;
  }

  /// Check if two exercise entries are equal
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}