// lib/config/api_config.dart

/// Configuration constants for API services
/// Centralizes all hardcoded values related to API configuration
class ApiConfig {
  // OpenAI Configuration
  static const String openAIBaseUrl = 'api.openai.com';
  static const String openAIImagesEndpoint = '/v1/chat/completions';
  static const String visionModel = 'gpt-4.1-mini';
  static const String textModel = 'gpt-4.1-mini';

  // VM Proxy Configuration (Fallback Provider)
  static const String vmProxyUrl = '35.201.20.109';
  static const int vmProxyPort = 3000;
  static const String vmProxyEndpoint = '/api/openai-proxy';

  // Quota Configuration
  static const int dailyQuotaLimit = 150;

  // Storage Keys
  static const String errorLogKey = 'api_error_log';
  static const String quotaUsedKey = 'food_api_quota_used';
  static const String quotaDateKey = 'food_api_quota_date';

  // Timeout Configuration
  static const Duration imageAnalysisTimeout = Duration(seconds: 60);
  static const Duration textAnalysisTimeout = Duration(seconds: 15);
  static const Duration standardTimeout = Duration(seconds: 10);

  // Private constructor to prevent instantiation
  ApiConfig._();
}
