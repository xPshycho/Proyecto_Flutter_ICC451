/// Constantes específicas de Pokémon
class PokemonConstants {
  PokemonConstants._();

  // Rangos de generaciones
  static const Map<String, List<int>> generationRanges = {
    '1': [1, 151],
    '2': [152, 251],
    '3': [252, 386],
    '4': [387, 493],
    '5': [494, 649],
    '6': [650, 721],
    '7': [722, 809],
    '8': [810, 905],
    '9': [906, 1000],
  };

  // Starters por generación
  static const Map<int, List<int>> startersByGeneration = {
    1: [1, 4, 7],
    2: [152, 155, 158],
    3: [252, 255, 258],
    4: [387, 390, 393],
    5: [494, 497, 500],
    6: [650, 653, 656],
    7: [722, 725, 728],
    8: [810, 813, 816],
    9: [906, 909, 912],
  };

  // Ultra Bestias
  static const int ultraBeastRangeStart = 793;
  static const int ultraBeastRangeEnd = 807;

  // Mapeo de regiones a generaciones
  static const Map<String, String> regionToGeneration = {
    'Kanto': '1',
    'Johto': '2',
    'Hoenn': '3',
    'Sinnoh': '4',
    'Teselia': '5',
    'Kalos': '6',
    'Alola': '7',
    'Galar': '8',
    'Paldea': '9',
  };

  /// Obtiene el rango de IDs para una generación
  static List<int> getGenerationRange(String generation) {
    return generationRanges[generation] ?? [0, 9999];
  }

  /// Verifica si un ID es un starter
  static bool isStarter(int id) {
    return startersByGeneration.values.any((starters) => starters.contains(id));
  }

  /// Verifica si un ID es una Ultra Bestia
  static bool isUltraBeast(int id) {
    return id >= ultraBeastRangeStart && id <= ultraBeastRangeEnd;
  }

  /// Convierte región a número de generación
  static String regionToGen(String region) {
    return regionToGeneration[region] ?? '1';
  }
}

