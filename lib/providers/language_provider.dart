// lib/providers/language_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  
  // Default to English
  Locale _currentLocale = const Locale('en');
  Locale get currentLocale => _currentLocale;
  
  // All 10 supported languages (Top revenue markets)
  final List<Locale> supportedLocales = const [
    Locale('en'),           // English - Global
    Locale('zh', 'CN'),     // Simplified Chinese - Mainland China
    Locale('zh', 'TW'),     // Traditional Chinese - Taiwan/Hong Kong
    Locale('ja'),           // Japanese - Japan
    Locale('ko'),           // Korean - South Korea
    Locale('de'),           // German - Germany/Austria/Switzerland
    Locale('fr'),           // French - France/Canada/Belgium/Switzerland
    Locale('es'),           // Spanish - Spain/Latin America/US
    Locale('pt', 'BR'),     // Portuguese - Brazil/Portugal
    Locale('ar'),           // Arabic - Middle East (RTL)
  ];
  
  // Language display names in native scripts
  final Map<String, String> languageNames = const {
    'en': 'English',
    'zh_CN': '简体中文',      // Simplified Chinese
    'zh_TW': '繁體中文',      // Traditional Chinese
    'ja': '日本語',          // Japanese
    'ko': '한국어',          // Korean
    'de': 'Deutsch',        // German
    'fr': 'Français',       // French
    'es': 'Español',        // Spanish
    'pt_BR': 'Português',   // Portuguese (Brazilian)
    'ar': 'العربية',         // Arabic
  };
  
  // Language flags for display
  final Map<String, String> languageFlags = const {
    'en': '🇺🇸',
    'zh_CN': '🇨🇳',
    'zh_TW': '🇹🇼',
    'ja': '🇯🇵',
    'ko': '🇰🇷',
    'de': '🇩🇪',
    'fr': '🇫🇷',
    'es': '🇪🇸',
    'pt_BR': '🇧🇷',
    'ar': '🇸🇦',
  };
  
  // Market information for each language
  final Map<String, Map<String, String>> languageMarkets = const {
    'en': {
      'primary': 'US, UK, Canada, Australia',
      'secondary': 'Singapore, Hong Kong, India, Global Business'
    },
    'zh_CN': {
      'primary': 'Mainland China',
      'secondary': 'Singapore, Malaysia'
    },
    'zh_TW': {
      'primary': 'Taiwan, Hong Kong, Macau',
      'secondary': 'Traditional Chinese communities'
    },
    'ja': {
      'primary': 'Japan',
      'secondary': 'Global Japanese communities'
    },
    'ko': {
      'primary': 'South Korea',
      'secondary': 'Global Korean communities'
    },
    'de': {
      'primary': 'Germany, Austria, Switzerland',
      'secondary': 'Luxembourg, Liechtenstein'
    },
    'fr': {
      'primary': 'France, Canada (Quebec), Belgium, Switzerland',
      'secondary': 'Luxembourg, Monaco, West Africa'
    },
    'es': {
      'primary': 'Spain, Latin America, parts of US',
      'secondary': 'Philippines, Equatorial Guinea'
    },
    'pt_BR': {
      'primary': 'Brazil, Portugal',
      'secondary': 'Angola, Mozambique, Cape Verde'
    },
    'ar': {
      'primary': 'Saudi Arabia, UAE, Kuwait, Qatar',
      'secondary': 'Egypt, Jordan, Lebanon, North Africa'
    },
  };
  
  /// Initialize language from stored preference
  Future<void> loadLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_languageKey);
      
      if (languageCode != null) {
        final locale = _parseLocaleFromString(languageCode);
        if (locale != null && supportedLocales.contains(locale)) {
          _currentLocale = locale;
          notifyListeners();
          debugPrint('✅ Loaded saved language: $languageCode');
        }
      } else {
        // Auto-detect system language if supported
        await _detectSystemLanguage();
      }
    } catch (e) {
      debugPrint('❌ Error loading language preference: $e');
    }
  }
  
  /// Auto-detect system language and use if supported
  Future<void> _detectSystemLanguage() async {
    try {
      final systemLocales = WidgetsBinding.instance.platformDispatcher.locales;
      
      for (final systemLocale in systemLocales) {
        // Check for exact match first
        if (supportedLocales.contains(systemLocale)) {
          await changeLanguage(_localeToString(systemLocale));
          debugPrint('✅ Auto-detected system language: ${systemLocale.toString()}');
          return;
        }
        
        // Check for language-only match
        final matchingLocale = supportedLocales.firstWhere(
          (locale) => locale.languageCode == systemLocale.languageCode,
          orElse: () => const Locale('en'),
        );
        
        if (matchingLocale.languageCode != 'en') {
          await changeLanguage(_localeToString(matchingLocale));
          debugPrint('✅ Auto-detected language family: ${matchingLocale.toString()}');
          return;
        }
      }
      
      debugPrint('ℹ️ No supported system language found, using English');
    } catch (e) {
      debugPrint('❌ Error detecting system language: $e');
    }
  }
  
  /// Change language and save to preferences
  Future<void> changeLanguage(String languageCode) async {
    try {
      final newLocale = _parseLocaleFromString(languageCode);
      
      if (newLocale != null && supportedLocales.contains(newLocale) && newLocale != _currentLocale) {
        _currentLocale = newLocale;
        
        // Save to preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, languageCode);
        
        notifyListeners();
        debugPrint('✅ Language changed to: $languageCode');
      }
    } catch (e) {
      debugPrint('❌ Error changing language: $e');
    }
  }
  
  /// Parse locale from string (handles both 'en' and 'zh_CN' formats)
  Locale? _parseLocaleFromString(String localeString) {
    final parts = localeString.split('_');
    if (parts.length == 1) {
      return Locale(parts[0]);
    } else if (parts.length == 2) {
      return Locale(parts[0], parts[1]);
    }
    return null;
  }
  
  /// Convert locale to string for storage
  String _localeToString(Locale locale) {
    if (locale.countryCode != null) {
      return '${locale.languageCode}_${locale.countryCode}';
    }
    return locale.languageCode;
  }
  
  /// Get display name for current language
  String get currentLanguageName {
    final key = _localeToString(_currentLocale);
    return languageNames[key] ?? 'English';
  }
  
  /// Get flag for current language
  String get currentLanguageFlag {
    final key = _localeToString(_currentLocale);
    return languageFlags[key] ?? '🇺🇸';
  }
  
  /// Check if a language is currently selected
  bool isLanguageSelected(String languageCode) {
    return _localeToString(_currentLocale) == languageCode;
  }
  
  /// Get display name for any language code
  String getLanguageName(String languageCode) {
    return languageNames[languageCode] ?? languageCode;
  }
  
  /// Get flag for any language code
  String getLanguageFlag(String languageCode) {
    return languageFlags[languageCode] ?? '🌐';
  }
  
  /// Get market info for any language code
  Map<String, String>? getLanguageMarkets(String languageCode) {
    return languageMarkets[languageCode];
  }
  
  /// Check if current language is RTL (Right-to-Left)
  bool get isRTL {
    return _currentLocale.languageCode == 'ar';
  }
  
  /// Get all language codes as strings
  List<String> get allLanguageCodes {
    return supportedLocales.map((locale) => _localeToString(locale)).toList();
  }
}