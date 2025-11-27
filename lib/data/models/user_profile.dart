// lib/data/models/user_profile.dart
import 'package:flutter/foundation.dart'; // Added for debugPrint

class UserProfile {
  final String id;
  final String? name;
  final int? age;
  final double? height; // Stored in cm
  final bool isMetric; // User's preferred unit system
  final String? gender;
  final double? goalWeight; // Stored in kg
  final DateTime? birthDate; // New field for date of birth
  final double? monthlyWeightGoal; // New field for monthly weight change goal in kg
  final double? startingWeight; // Starting weight for progress tracking in kg

  UserProfile({
    required this.id,
    this.name,
    this.age,
    this.height,
    this.isMetric = true,
    this.gender,
    this.goalWeight,
    this.birthDate,
    this.monthlyWeightGoal,
    this.startingWeight,
  });

  // Copy constructor for updating user profile
  UserProfile copyWith({
    String? id,
    String? name,
    int? age,
    double? height,
    bool? isMetric,
    String? gender,
    double? goalWeight,
    DateTime? birthDate,
    double? monthlyWeightGoal,
    double? startingWeight,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      height: height ?? this.height,
      isMetric: isMetric ?? this.isMetric,
      gender: gender ?? this.gender,
      goalWeight: goalWeight ?? this.goalWeight,
      birthDate: birthDate ?? this.birthDate,
      monthlyWeightGoal: monthlyWeightGoal ?? this.monthlyWeightGoal,
      startingWeight: startingWeight ?? this.startingWeight,
    );
  }

  // Format height based on user's preferred unit system
  String formattedHeight() {
    if (height == null) return 'Not set';

    if (isMetric) {
      return '$height cm';
    } else {
      // Convert cm to feet and inches
      final totalInches = height! / 2.54;
      final feet = (totalInches / 12).floor();
      final inches = (totalInches % 12).round();
      return '$feet\' $inches"';
    }
  }

  // Convert to map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'height': height,
      'isMetric': isMetric,
      'gender': gender,
      'goalWeight': goalWeight,
      'birthDate': birthDate?.millisecondsSinceEpoch,
      'monthlyWeightGoal': monthlyWeightGoal,
      'startingWeight': startingWeight,
    };
  }

  // Create from map for retrieval
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    // Ensure proper type conversion for age
    int? ageValue;
    if (map['age'] != null) {
      if (map['age'] is int) {
        ageValue = map['age'] as int;
      } else if (map['age'] is double) {
        ageValue = (map['age'] as double).toInt();
      } else if (map['age'] is String) {
        ageValue = int.tryParse(map['age'] as String);
      }
    }

    final profile = UserProfile(
      id: map['id'],
      name: map['name'],
      age: ageValue,
      height: map['height'],
      isMetric: map['isMetric'] ?? true,
      gender: map['gender'],
      goalWeight: map['goalWeight'],
      birthDate: map['birthDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['birthDate'])
          : null,
      monthlyWeightGoal: map['monthlyWeightGoal'],
      startingWeight: map['startingWeight'],
    );
    // Silent migration: ignore legacy activityLevel field if present

    return profile;
  }

  // Debug method to print all user profile details - USE MANUALLY ONLY
  void debugUserProfile() {
    // ✅ FIXED: Replace all print statements with debugPrint
    debugPrint("\n===== USER PROFILE DEBUG INFO =====");
    debugPrint("ID: $id");
    debugPrint("Name: $name");
    debugPrint("Age: $age");
    debugPrint("Height: ${height != null ? '$height cm' : 'Not set'}");
    debugPrint("Gender: ${gender ?? 'Not set'}");
    debugPrint("Is Metric: $isMetric");
    debugPrint("Goal Weight: ${goalWeight != null ? '$goalWeight kg' : 'Not set'}");
    debugPrint("Starting Weight: ${startingWeight != null ? '$startingWeight kg' : 'Not set'}");
    debugPrint("Monthly Weight Goal: ${monthlyWeightGoal != null ? '$monthlyWeightGoal kg' : 'Not set'}");
    debugPrint("Birth Date: ${birthDate != null ? birthDate.toString() : 'Not set'}");
    debugPrint("Complete Map: ${toMap()}");
    debugPrint("===================================\n");
  }

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, age: $age, height: $height, isMetric: $isMetric)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}