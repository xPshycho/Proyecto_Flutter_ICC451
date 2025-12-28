import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para gestionar el idioma de la aplicación
/// Soporta español (es) e inglés (en)
class LanguageService extends ChangeNotifier {
  static const String _languageKey = 'quiz_language';

  // Idiomas soportados
  static const String spanish = 'es';
  static const String english = 'en';

  // IDs de idioma para la PokéAPI (GraphQL)
  // Según: https://pokeapi.co/docs/v2#languages
  static const int spanishLanguageId = 7;
  static const int englishLanguageId = 9;

  String _currentLanguage = spanish;
  bool _isInitialized = false;

  /// Obtiene el idioma actual
  String get currentLanguage => _currentLanguage;

  /// Obtiene el ID del idioma para las queries de PokéAPI
  int get languageId => _currentLanguage == spanish
      ? spanishLanguageId
      : englishLanguageId;

  /// Verifica si el idioma actual es español
  bool get isSpanish => _currentLanguage == spanish;

  /// Verifica si el idioma actual es inglés
  bool get isEnglish => _currentLanguage == english;

  /// Verifica si el servicio está inicializado
  bool get isInitialized => _isInitialized;

  /// Inicializa el servicio cargando el idioma guardado
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      _currentLanguage = prefs.getString(_languageKey) ?? spanish;
      _isInitialized = true;
      debugPrint('LanguageService: Initialized with language: $_currentLanguage');
    } catch (e) {
      debugPrint('LanguageService: Error initializing: $e');
      _currentLanguage = spanish;
      _isInitialized = true;
    }
  }

  /// Cambia el idioma actual
  Future<void> setLanguage(String language) async {
    if (language != spanish && language != english) {
      debugPrint('LanguageService: Invalid language: $language');
      return;
    }

    if (_currentLanguage == language) return;

    _currentLanguage = language;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, language);
      debugPrint('LanguageService: Language changed to: $language');
    } catch (e) {
      debugPrint('LanguageService: Error saving language: $e');
    }

    notifyListeners();
  }

  /// Alterna entre español e inglés
  Future<void> toggleLanguage() async {
    final newLanguage = _currentLanguage == spanish ? english : spanish;
    await setLanguage(newLanguage);
  }

  /// Obtiene el nombre del idioma para mostrar en la UI
  String get languageDisplayName {
    return _currentLanguage == spanish ? 'Español' : 'English';
  }

  /// Obtiene el código de bandera/emoji para el idioma
  String get languageFlag {
    return _currentLanguage == spanish ? '🇪🇸' : '🇺🇸';
  }
}

