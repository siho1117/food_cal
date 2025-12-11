// lib/config/providers/qwen_config.dart

/// Alibaba Cloud Qwen API Configuration
///
/// This file contains all configuration for Alibaba's Qwen (通义千问) API.
/// Provider for China region with multimodal capabilities.
class QwenConfig {
  // Private constructor to prevent instantiation
  QwenConfig._();

  // ═══════════════════════════════════════════════════════════════
  // API ENDPOINT CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Base URL for Qwen API (OpenAI-compatible mode - International)
  static const String baseUrl = 'dashscope-intl.aliyuncs.com';

  /// API endpoint path (OpenAI-compatible endpoint)
  static const String endpoint = '/compatible-mode/v1/chat/completions';

  // ═══════════════════════════════════════════════════════════════
  // MODEL CONFIGURATION
  // ═══════════════════════════════════════════════════════════════

  /// Model for vision tasks (food image recognition)
  /// qwen3-vl-flash: Fast vision-language model optimized for quick responses
  static const String visionModel = 'qwen3-vl-flash';

  /// Model for text tasks (food information lookup)
  /// qwen-turbo: Fast text model for quick responses
  static const String textModel = 'qwen-turbo';

  // ═══════════════════════════════════════════════════════════════
  // ENVIRONMENT VARIABLE KEYS
  // ═══════════════════════════════════════════════════════════════

  /// Environment variable key for API key (stored in .env file)
  static const String apiKeyEnvVar = 'QWEN_API_KEY';

  // ═══════════════════════════════════════════════════════════════
  // NOTES
  // ═══════════════════════════════════════════════════════════════

  /// Provider-specific notes:
  /// - Uses International endpoint: dashscope-intl.aliyuncs.com
  /// - Authorization: Bearer token ("Bearer sk-xxx")
  /// - Request format: OpenAI-compatible (same as ChatGPT API)
  /// - Response format: { choices: [{ message: { content: "..." } }] }
  /// - Supports multimodal input (text + images via URL or base64)
  /// - Available models: qwen-turbo, qwen-plus, qwen-vl-plus, qwen-vl-max
  /// - Best for: International users, China region access
  /// - API Documentation: https://help.aliyun.com/zh/dashscope/
}
