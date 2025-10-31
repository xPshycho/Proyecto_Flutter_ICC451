/// Constantes globales de la aplicación
class AppConstants {
  AppConstants._(); // Constructor privado para prevenir instanciación

  // Paginación
  static const int defaultPageSize = 24;
  static const int scrollThreshold = 200;

  // Animaciones
  static const int defaultAnimationDuration = 300;
  static const int pokeballAnimationDuration = 1000;

  // Tamaños
  static const double pokeballSize = 250.0;
  static const double pokeballOpacity = 0.8;
  static const double pokedexButtonIconSize = 32.0;
  static const double pokedexButtonFontSize = 20.0;
  static const double searchBoxHeight = 36.0;
  static const double iconButtonSize = 28.0;

  // Rotación Pokeball
  static const double pokeballRotationStart = -0.025;
  static const double pokeballRotationEnd = 0.025;

  // Timeouts
  static const int graphqlTimeoutSeconds = 8;
  static const int restTimeoutSeconds = 6;

  // Cache
  static const int cacheChunkSize = 250;
}

