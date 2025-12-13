// lib/config/api_config.dart

/// Main API Configuration
///
/// Central configuration for API settings.
/// Using Cloud Function proxy for Vertex AI (gemini-2.0-flash)
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

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
