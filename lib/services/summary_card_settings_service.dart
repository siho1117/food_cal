// lib/services/summary_card_settings_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/models/summary_card_config.dart';

/// Service for managing summary card layout preferences
class SummaryCardSettingsService {
  static const String _keyCardConfig = 'summary_card_config';

  /// Load card configuration from storage
  static Future<List<SummaryCardConfig>> loadCardConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_keyCardConfig);

      if (jsonString == null) {
        // No saved config, return default
        return SummaryCardConfig.getDefaultConfig();
      }

      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final configs = jsonList
          .map((json) => SummaryCardConfig.fromJson(json as Map<String, dynamic>))
          .toList();

      // Sort by order
      configs.sort((a, b) => a.order.compareTo(b.order));

      return configs;
    } catch (e) {
      // On error, return default config
      return SummaryCardConfig.getDefaultConfig();
    }
  }

  /// Save card configuration to storage
  static Future<bool> saveCardConfig(List<SummaryCardConfig> configs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = configs.map((config) => config.toJson()).toList();
      final jsonString = jsonEncode(jsonList);

      return await prefs.setString(_keyCardConfig, jsonString);
    } catch (e) {
      return false;
    }
  }

  /// Reset card configuration to default
  static Future<bool> resetToDefault() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_keyCardConfig);
    } catch (e) {
      return false;
    }
  }

  /// Update visibility for a specific card
  static Future<bool> updateCardVisibility(
    SummaryCardType cardType,
    bool isVisible,
  ) async {
    final configs = await loadCardConfig();
    final index = configs.indexWhere((c) => c.type == cardType);

    if (index != -1) {
      configs[index] = configs[index].copyWith(isVisible: isVisible);
      return await saveCardConfig(configs);
    }

    return false;
  }

  /// Reorder cards
  static Future<bool> reorderCards(
    int oldIndex,
    int newIndex,
  ) async {
    final configs = await loadCardConfig();

    if (oldIndex < 0 || oldIndex >= configs.length || newIndex < 0 || newIndex >= configs.length) {
      return false;
    }

    final item = configs.removeAt(oldIndex);
    configs.insert(newIndex, item);

    // Update order values
    for (int i = 0; i < configs.length; i++) {
      configs[i] = configs[i].copyWith(order: i);
    }

    return await saveCardConfig(configs);
  }
}
