// lib/config/ai_prompts.dart

/// Centralized AI prompts for all API providers
///
/// This file contains all prompts used for food recognition and nutrition analysis.
/// These prompts are provider-agnostic and can be used with OpenAI, Gemini, or other AI services.
class AiPrompts {
  // Private constructor to prevent instantiation
  AiPrompts._();

  // ═══════════════════════════════════════════════════════════════
  // FOOD IMAGE ANALYSIS PROMPTS
  // ═══════════════════════════════════════════════════════════════

  /// System prompt for food image recognition
  /// Sets the AI's behavior and output format requirements
  static const String foodImageSystemPrompt =
      "Food recognition. Return ONLY JSON with exact values (no rounding). "
      "Name: capitalize first letter, max 8 words, no parentheses. "
      "Assume 1.017 servings.";

  /// User prompt for food image recognition
  /// Instructs the AI on what information to extract from the image
  static const String foodImageUserPrompt =
      "Identify food, assume 1.017 servings, return ONLY this JSON: "
      "{\"name\": \"Food name\", \"calories\": 0, \"protein\": 0, \"carbs\": 0, \"fat\": 0}";

  // ═══════════════════════════════════════════════════════════════
  // FOOD INFORMATION LOOKUP PROMPTS
  // ═══════════════════════════════════════════════════════════════

  /// System prompt for food information lookup by name
  /// Sets formatting and precision requirements
  static const String foodInfoSystemPrompt =
      "Nutrition data with exact values (no rounding). "
      "Name: capitalize first letter, max 8 words, no parentheses.";

  /// User prompt for food information lookup by name
  /// Takes the food name as a parameter and returns formatted nutrition request
  static String foodInfoUserPrompt(String foodName) =>
      "Precise nutrition for $foodName:\n"
      "Food Name: $foodName\n"
      "Calories: ? cal\n"
      "Protein: ? g\n"
      "Carbs: ? g\n"
      "Fat: ? g";
}
