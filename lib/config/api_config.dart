// lib/config/api_config.dart

import 'providers/gemini_config.dart';

/// Main API Configuration
///
/// This file acts as the central access point for all API configurations.
/// To switch providers, update the constants below.
///
/// Current Provider: Google Gemini (primary) with Qwen as automatic fallback
/// Provider configurations: see providers/gemini_config.dart and providers/qwen_config.dart
/// Note: Qwen is accessed directly via QwenApiAdapter, not through this config file
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // ═══════════════════════════════════════════════════════════════
  // ACTIVE PROVIDER CONFIGURATION - GEMINI (PRIMARY)
  // ═══════════════════════════════════════════════════════════════

  /// Base URL for the active API provider (Gemini)
  static const String geminiBaseUrl = GeminiConfig.baseUrl;

  /// API endpoint path
  static const String geminiEndpoint = GeminiConfig.endpoint;

  /// Model for vision/image recognition tasks
  static const String visionModel = GeminiConfig.visionModel;

  /// Model for text generation tasks
  static const String textModel = GeminiConfig.textModel;

  /// Environment variable key for API key
  static const String apiKeyEnvVar = GeminiConfig.apiKeyEnvVar;

  // ═══════════════════════════════════════════════════════════════
  // QUOTA CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  static const int dailyQuotaLimit = 150;

  // ═══════════════════════════════════════════════════════════════
  // STORAGE KEYS
  // ═══════════════════════════════════════════════════════════════

  static const String errorLogKey = 'api_error_log';
  static const String quotaUsedKey = 'food_api_quota_used';
  static const String quotaDateKey = 'food_api_quota_date';

  // ═══════════════════════════════════════════════════════════════
  // TIMEOUT CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  static const Duration imageAnalysisTimeout = Duration(seconds: 60);
  static const Duration textAnalysisTimeout = Duration(seconds: 15);
  static const Duration standardTimeout = Duration(seconds: 10);

  // ═══════════════════════════════════════════════════════════════
  // HOW TO SWITCH PROVIDERS
  // ═══════════════════════════════════════════════════════════════
  //
  // To switch from Gemini to OpenAI:
  // 1. Comment out: import 'providers/gemini_config.dart';
  // 2. Uncomment: import 'providers/openai_config.dart';
  // 3. Update constants to use OpenAIConfig instead of GeminiConfig:
  //    - geminiBaseUrl = OpenAIConfig.baseUrl
  //    - geminiEndpoint = OpenAIConfig.endpoint
  //    - visionModel = OpenAIConfig.visionModel
  //    - textModel = OpenAIConfig.textModel
  //    - apiKeyEnvVar = OpenAIConfig.apiKeyEnvVar
  // 4. Update .env file with appropriate API key
  // 5. Update api_service.dart method names if needed
  //
}
