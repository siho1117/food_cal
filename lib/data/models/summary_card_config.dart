// lib/data/models/summary_card_config.dart
import 'package:flutter/material.dart';
import 'package:animated_emoji/animated_emoji.dart';
import '../../l10n/generated/app_localizations.dart';

/// Enum representing all available summary cards
enum SummaryCardType {
  bodyMetrics('body_metrics', false),
  nutrition('nutrition', false),
  budget('budget', false),
  exercise('exercise', false),
  progress('progress', false),
  mealLog('meal_log', false);

  final String id;
  final bool isRequired; // Required cards can't be hidden

  const SummaryCardType(this.id, this.isRequired);

  /// Get the localized display name for this card type
  String getDisplayName(AppLocalizations l10n) {
    switch (this) {
      case SummaryCardType.bodyMetrics:
        return l10n.bodyMetricsMetabolism;
      case SummaryCardType.nutrition:
        return l10n.nutritionSummary;
      case SummaryCardType.budget:
        return l10n.foodBudget;
      case SummaryCardType.exercise:
        return l10n.exerciseActivityLog;
      case SummaryCardType.progress:
        return l10n.progressAchievements;
      case SummaryCardType.mealLog:
        return l10n.mealLog;
    }
  }

  /// Get the animated emoji icon for this card type
  AnimatedEmojiData get icon {
    switch (this) {
      case SummaryCardType.bodyMetrics:
        return AnimatedEmojis.fire;
      case SummaryCardType.nutrition:
        return AnimatedEmojis.balanceScale;
      case SummaryCardType.budget:
        return AnimatedEmojis.moneyWithWings;
      case SummaryCardType.exercise:
        return AnimatedEmojis.muscle;
      case SummaryCardType.progress:
        return AnimatedEmojis.trophy;
      case SummaryCardType.mealLog:
        return AnimatedEmojis.spaghetti;
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
