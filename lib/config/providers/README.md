# API Provider Configurations

This directory contains configuration files for different AI API providers.

## Current Provider: Google Gemini

**Active Config:** `gemini_config.dart`
- Model: `gemini-2.5-flash-lite`
- Strengths: Fast, supports vision + text, cost-effective
- Response format: JSON in markdown code blocks

## Backup Provider: OpenAI

**Backup Config:** `openai_config.dart`
- Model: `gpt-4o-mini`
- Strengths: Reliable, clean JSON responses, well-documented
- Response format: Clean JSON

## How to Switch Providers

### Switch from Gemini → OpenAI:

1. **Update api_config.dart imports:**
   ```dart
   // Comment out Gemini
   // import 'providers/gemini_config.dart';

   // Uncomment OpenAI
   import 'providers/openai_config.dart';
   ```

2. **Update ApiConfig constants:**
   ```dart
   static const String geminiBaseUrl = OpenAIConfig.baseUrl;
   static const String geminiEndpoint = OpenAIConfig.endpoint;
   static const String visionModel = OpenAIConfig.visionModel;
   static const String textModel = OpenAIConfig.textModel;
   static const String apiKeyEnvVar = OpenAIConfig.apiKeyEnvVar;
   ```

3. **Update .env file:**
   ```env
   OPENAI_API_KEY=your-openai-api-key-here
   ```

4. **Update api_service.dart method names (optional):**
   - Rename `_analyzeWithGemini` → `_analyzeWithOpenAI`
   - Rename `_getFoodInfoFromGemini` → `_getFoodInfoFromOpenAI`
   - Update request body format to OpenAI structure

5. **Restart the app**

### Switch from OpenAI → Gemini:

Just reverse the process above!

## Adding New Providers

To add a new provider (e.g., Anthropic Claude):

1. Create `claude_config.dart` in this directory
2. Define all provider-specific constants
3. Add notes about API quirks and response formats
4. Update api_config.dart to import and use it

## File Structure

```
lib/config/
├── api_config.dart           # Main config (imports active provider)
├── ai_prompts.dart           # Provider-agnostic prompts
└── providers/
    ├── README.md             # This file
    ├── gemini_config.dart    # Google Gemini config (ACTIVE)
    └── openai_config.dart    # OpenAI config (BACKUP)
```

## Benefits of This Architecture

✅ **Clean separation** - Each provider's config is isolated
✅ **Easy switching** - Change one import to switch providers
✅ **Version control** - All configs preserved in git history
✅ **Documentation** - Provider-specific quirks documented in each file
✅ **Future-proof** - Easy to add more providers (Claude, Cohere, etc.)
