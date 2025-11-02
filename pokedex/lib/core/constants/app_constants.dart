// Constantes globales de la aplicación (en español)
class AppConstants {
  // Timeout por defecto para consultas GraphQL (segundos)
  static const int graphqlTimeoutSeconds = 8;

  // Tamaño de bloque al cachear todos los pokémons
  static const int cacheChunkSize = 250;

  // Tamaño de página por defecto en listados
  static const int pageSizeDefault = 20;
  // Alias usado en UI
  static const int defaultPageSize = pageSizeDefault;

  // TTL en segundos para caches en memoria (0 = sin expiración)
  static const int memoryCacheTtlSeconds = 0;

  // Animaciones / UI
  static const int pokeballAnimationDuration = 800; // ms
  static const double pokeballRotationStart = -0.125;
  static const double pokeballRotationEnd = 0.4;
  static const double scrollThreshold = 200.0;

  // Tamaño / opacidad del pokeball de fondo
  static const double pokeballSize = 240.0;
  static const double pokeballOpacity = 1;

  // Botón Pokedex
  static const double pokedexButtonIconSize = 20.0;
  static const double pokedexButtonFontSize = 16.0;

  // Search / layout
  static const double searchBoxHeight = 44.0;
  static const double iconButtonSize = 20.0;
}
