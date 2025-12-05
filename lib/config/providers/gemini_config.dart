// lib/config/providers/gemini_config.dart

/// Google Gemini API Configuration
///
/// This file contains all configuration for Google's Gemini API.
/// Currently active provider for OptiMate food recognition.
class GeminiConfig {
  // Private constructor to prevent instantiation
  GeminiConfig._();

  // ═══════════════════════════════════════════════════════════════
  // API ENDPOINT CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Base URL for Gemini API
  static const String baseUrl = 'generativelanguage.googleapis.com';

  /// API endpoint path (v1beta for latest features)
  static const String endpoint = '/v1beta/models/';

  // ═══════════════════════════════════════════════════════════════
  // MODEL CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Model for vision tasks (food image recognition)
  /// gemini-2.0-flash-exp: Experimental model with enhanced vision capabilities
  static const String visionModel = 'gemini-2.0-flash-exp';

  /// Model for text tasks (food information lookup)
  /// gemini-2.0-flash-exp: Fast, cost-effective model for text generation
  static const String textModel = 'gemini-2.0-flash-exp';

  // ═══════════════════════════════════════════════════════════════
  // ENVIRONMENT VARIABLE KEYS
  // ═══════════════════════════════════════════════════════════════

  /// Environment variable key for API key (stored in .env file)
  static const String apiKeyEnvVar = 'GEMINI_API_KEY';

  // ═══════════════════════════════════════════════════════════════
  // NOTES
  // ═══════════════════════════════════════════════════════════════

  /// Provider-specific notes:
  /// - Gemini uses query parameter for API key (?key=xxx) instead of Bearer token
  /// - Response format: { candidates: [{ content: { parts: [{ text: "..." }] } }] }
  /// - Token usage in usageMetadata field
  /// - Supports both vision and text in single model
  /// - Markdown code blocks common in responses (```json ... ```)
}
