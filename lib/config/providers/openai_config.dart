// lib/config/providers/openai_config.dart

/// OpenAI API Configuration (BACKUP)
///
/// This file contains all configuration for OpenAI's API.
/// Preserved as backup - can be activated by updating api_config.dart.
class OpenAIConfig {
  // Private constructor to prevent instantiation
  OpenAIConfig._();

  // ═══════════════════════════════════════════════════════════════
  // API ENDPOINT CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Base URL for OpenAI API
  static const String baseUrl = 'api.openai.com';

  /// API endpoint path for chat completions (used for both vision and text)
  static const String endpoint = '/v1/chat/completions';

  // ═══════════════════════════════════════════════════════════════
  // MODEL CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Model for vision tasks (food image recognition)
  /// gpt-4o-mini: Cost-effective model with vision capabilities
  /// Note: Original config had 'gpt-5-mini' which was likely a typo
  static const String visionModel = 'gpt-4o-mini';

  /// Model for text tasks (food information lookup)
  /// gpt-4o-mini: Fast, cost-effective model for text generation
  static const String textModel = 'gpt-4o-mini';

  // ═══════════════════════════════════════════════════════════════
  // ENVIRONMENT VARIABLE KEYS
  // ═══════════════════════════════════════════════════════════════

  /// Environment variable key for API key (stored in .env file)
  static const String apiKeyEnvVar = 'OPENAI_API_KEY';

  // ═══════════════════════════════════════════════════════════════
  // NOTES
  // ═══════════════════════════════════════════════════════════════

  /// Provider-specific notes:
  /// - OpenAI uses Bearer token authentication (Authorization: Bearer xxx)
  /// - Request format: { model: "...", messages: [{ role: "...", content: "..." }] }
  /// - Response format: { choices: [{ message: { content: "..." } }] }
  /// - Token usage in usage field
  /// - Supports vision via image_url in message content
  /// - Generally returns clean JSON without markdown wrappers
  ///
  /// Cost (gpt-4o-mini):
  /// - Input: $0.000150 per 1K tokens
  /// - Output: $0.000600 per 1K tokens
  ///
  /// To reactivate OpenAI:
  /// 1. Update .env: OPENAI_API_KEY=your-key-here
  /// 2. Update api_config.dart to import openai_config.dart
  /// 3. Update api_service.dart method names (_analyzeWithOpenAI, etc.)
}
