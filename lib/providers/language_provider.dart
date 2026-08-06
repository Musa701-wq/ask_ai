// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class LanguageProvider with ChangeNotifier {
//   Locale _currentLocale = const Locale('en');
//   static const String _localeKey = 'app_language';
//
//   Locale get currentLocale => _currentLocale;
//
//   LanguageProvider() {
//     _loadSavedLocale();
//   }
//
//   Future<void> _loadSavedLocale() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final languageCode = prefs.getString(_localeKey);
//
//       if (languageCode != null) {
//         _currentLocale = Locale(languageCode);
//         notifyListeners();
//       }
//     } catch (e) {
//       print('Error loading saved locale: $e');
//     }
//   }
//
//   Future<void> setLocale(Locale locale) async {
//     try {
//       _currentLocale = locale;
//       notifyListeners();
//
//       // Save to shared preferences
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString(_localeKey, locale.languageCode);
//     } catch (e) {
//       print('Error saving locale: $e');
//     }
//   }
//
//   Future<void> toggleLanguage() async {
//     if (_currentLocale.languageCode == 'en') {
//       await setLocale(const Locale('es'));
//     } else {
//       await setLocale(const Locale('en'));
//     }
//   }
//
//   String getCurrentLanguageName() {
//     switch (_currentLocale.languageCode) {
//       case 'en':
//         return 'English';
//       case 'es':
//         return 'Español';
//       case 'fr':
//         return 'Français';
//       case 'de':
//         return 'Deutsch';
//       case 'nl':
//         return 'Nederlands';
//       case 'ar':
//         return 'العربية';
//       case 'zh':
//         return '中文';
//       default:
//         return 'English';
//     }
//   }
//
//   String getCurrentLanguageFlag() {
//     switch (_currentLocale.languageCode) {
//       case 'en':
//         return '🇺🇸';
//       case 'es':
//         return '🇪🇸';
//       case 'fr':
//         return '🇫🇷';
//       case 'de':
//         return '🇩🇪';
//       case 'nl':
//         return '🇳🇱';
//       case 'ar':
//         return '🇸🇦';
//       case 'zh':
//         return '🇨🇳';
//       default:
//         return '🌐';
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider with ChangeNotifier {
  Locale _currentLocale = const Locale('en');
  static const String _localeKey = 'app_language';
  bool _isLoading = false;

  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;

  LanguageProvider() {
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey);

      if (languageCode != null && languageCode.isNotEmpty) {
        _currentLocale = Locale(languageCode);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading saved locale: $e');
      // Don't rethrow - just use default locale
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_currentLocale.languageCode == locale.languageCode) {
      // Already at this locale, no need to change
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Update the locale
      _currentLocale = locale;

      // Save to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, locale.languageCode);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error saving locale: $e');
      rethrow; // Rethrow so UI can handle the error
    }
  }

  Future<void> toggleLanguage() async {
    if (_currentLocale.languageCode == 'en') {
      await setLocale(const Locale('es'));
    } else {
      await setLocale(const Locale('en'));
    }
  }

  String getCurrentLanguageName() {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'nl':
        return 'Nederlands';
      case 'ar':
        return 'العربية';
      case 'zh':
        return '中文';
      default:
        return 'English';
    }
  }

  String getCurrentLanguageFlag() {
    switch (_currentLocale.languageCode) {
      case 'en':
        return '🇺🇸';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'nl':
        return '🇳🇱';
      case 'ar':
        return '🇸🇦';
      case 'zh':
        return '🇨🇳';
      default:
        return '🌐';
    }
  }

  // Helper method to check if a locale is supported
  bool isLocaleSupported(String languageCode) {
    const supportedLocales = ['en', 'es', 'fr', 'de', 'nl', 'ar', 'zh'];
    return supportedLocales.contains(languageCode);
  }
}