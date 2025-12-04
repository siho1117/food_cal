// lib/data/models/summary_card_config.dart
import 'package:flutter/material.dart';

/// Enum representing all available summary cards
enum SummaryCardType {
  bodyMetrics('body_metrics', 'Body Metrics & Metabolism', false),
  nutrition('nutrition', 'Nutrition Summary', false),
  budget('budget', 'Food Budget', false),
  exercise('exercise', 'Exercise & Activity', false),
  progress('progress', 'Progress & Achievements', false),
  mealLog('meal_log', 'Meal Log', false);

  final String id;
  final String displayName;
  final bool isRequired; // Required cards can't be hidden

  const SummaryCardType(this.id, this.displayName, this.isRequired);

  /// Get the icon for this card type
  IconData get icon {
    switch (this) {
      case SummaryCardType.bodyMetrics:
        return Icons.straighten;
      case SummaryCardType.nutrition:
        return Icons.restaurant;
      case SummaryCardType.budget:
        return Icons.attach_money;
      case SummaryCardType.exercise:
        return Icons.fitness_center;
      case SummaryCardType.progress:
        return Icons.emoji_events;
      case SummaryCardType.mealLog:
        return Icons.restaurant_menu;
    }
  }

  static SummaryCardType fromId(String id) {
    return SummaryCardType.values.firstWhere(
      (type) => type.id == id,
      orElse: () => SummaryCardType.bodyMetrics,
    );
  }
}

/// Configuration for a single summary card
class SummaryCardConfig {
  final SummaryCardType type;
  final bool isVisible;
  final int order;

  const SummaryCardConfig({
    required this.type,
    required this.isVisible,
    required this.order,
  });

  SummaryCardConfig copyWith({
    SummaryCardType? type,
    bool? isVisible,
    int? order,
  }) {
    return SummaryCardConfig(
      type: type ?? this.type,
      isVisible: isVisible ?? this.isVisible,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.id,
      'isVisible': isVisible,
      'order': order,
    };
  }

  factory SummaryCardConfig.fromJson(Map<String, dynamic> json) {
    return SummaryCardConfig(
      type: SummaryCardType.fromId(json['type'] as String),
      isVisible: json['isVisible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
    );
  }

  /// Default configuration for all cards
  static List<SummaryCardConfig> getDefaultConfig() {
    return [
      const SummaryCardConfig(
        type: SummaryCardType.progress,
        isVisible: true,
        order: 0,
      ),
      const SummaryCardConfig(
        type: SummaryCardType.bodyMetrics,
        isVisible: true,
        order: 1,
      ),
      const SummaryCardConfig(
        type: SummaryCardType.mealLog,
        isVisible: true,
        order: 2,
      ),
      const SummaryCardConfig(
        type: SummaryCardType.nutrition,
        isVisible: true,
        order: 3,
      ),
      const SummaryCardConfig(
        type: SummaryCardType.exercise,
        isVisible: true,
        order: 4,
      ),
      const SummaryCardConfig(
        type: SummaryCardType.budget,
        isVisible: true,
        order: 5,
      ),
    ];
  }
}
