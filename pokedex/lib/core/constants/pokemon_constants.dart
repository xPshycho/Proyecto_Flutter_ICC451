import 'package:flutter/material.dart';

/// Constantes específicas de Pokémon
class PokemonConstants {
  PokemonConstants._();

  // Ultra Bestias
  static const int ultraBeastRangeStart = 793;
  static const int ultraBeastRangeEnd = 807;

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

  /// Colores de tipos
  static const Map<String, Color> typeColors = {
    'Bicho': Color(0xFF92BC2C),
    'Siniestro': Color(0xFF595761),
    'Dragón': Color(0xFF0C69C8),
    'Eléctrico': Color(0xFFF2D94E),
    'Fuego': Color(0xFFFBA54C),
    'Hada': Color(0xFFEE90E6),
    'Lucha': Color(0xFFD3425F),
    'Volador': Color(0xFFA1BBEC),
    'Fantasma': Color(0xFF5F6DBC),
    'Planta': Color(0xFF5FBD58),
    'Tierra': Color(0xFFDA7C4D),
    'Hielo': Color(0xFF75D0C1),
    'Normal': Color(0xFFA0A29F),
    'Veneno': Color(0xFFB763CF),
    'Psíquico': Color(0xFFFA8581),
    'Roca': Color(0xFFC9BB8A),
    'Acero': Color(0xFF5695A3),
    'Agua': Color(0xFF539DDF),
  };

  /// Íconos de tipos
  static const Map<String, String> typeIcons = {
    'Bicho': 'assets/icons/types/icons/bug.svg',
    'Siniestro': 'assets/icons/types/icons/dark.svg',
    'Dragón': 'assets/icons/types/icons/dragon.svg',
    'Eléctrico': 'assets/icons/types/icons/electric.svg',
    'Fuego': 'assets/icons/types/icons/fire.svg',
    'Hada': 'assets/icons/types/icons/fairy.svg',
    'Lucha': 'assets/icons/types/icons/fighting.svg',
    'Volador': 'assets/icons/types/icons/flying.svg',
    'Fantasma': 'assets/icons/types/icons/ghost.svg',
    'Planta': 'assets/icons/types/icons/grass.svg',
    'Tierra': 'assets/icons/types/icons/ground.svg',
    'Hielo': 'assets/icons/types/icons/ice.svg',
    'Normal': 'assets/icons/types/icons/normal.svg',
    'Veneno': 'assets/icons/types/icons/poison.svg',
    'Psíquico': 'assets/icons/types/icons/psychic.svg',
    'Roca': 'assets/icons/types/icons/rock.svg',
    'Acero': 'assets/icons/types/icons/steel.svg',
    'Agua': 'assets/icons/types/icons/water.svg',
  };

  // Mapeo de nombres en español (UI) a nombres de tipo usados por la API (inglés, lowercase)
  static const Map<String, String> _spanishToApi = {
    'Bicho': 'bug',
    'Siniestro': 'dark',
    'Dragón': 'dragon',
    'Eléctrico': 'electric',
    'Fuego': 'fire',
    'Hada': 'fairy',
    'Lucha': 'fighting',
    'Volador': 'flying',
    'Fantasma': 'ghost',
    'Planta': 'grass',
    'Tierra': 'ground',
    'Hielo': 'ice',
    'Normal': 'normal',
    'Veneno': 'poison',
    'Psíquico': 'psychic',
    'Roca': 'rock',
    'Acero': 'steel',
    'Agua': 'water',
  };

  // Mapeo inverso de nombres de tipo de la API (inglés) a español (UI)
  static const Map<String, String> _apiToSpanish = {
    'bug': 'Bicho',
    'dark': 'Siniestro',
    'dragon': 'Dragón',
    'electric': 'Eléctrico',
    'fire': 'Fuego',
    'fairy': 'Hada',
    'fighting': 'Lucha',
    'flying': 'Volador',
    'ghost': 'Fantasma',
    'grass': 'Planta',
    'ground': 'Tierra',
    'ice': 'Hielo',
    'normal': 'Normal',
    'poison': 'Veneno',
    'psychic': 'Psíquico',
    'rock': 'Roca',
    'steel': 'Acero',
    'water': 'Agua',
  };

  /// Obtiene el color asociado a un tipo
  static Color getTypeColor(String type) {
    return typeColors[type] ?? const Color(0xFFA0A29F); // Default Normal color
  }

  /// Obtiene el ícono asociado a un tipo
  static String? getTypeIcon(String type) {
    return typeIcons[type];
  }

  // Traduce una lista de nombres en español a la forma que usa la API
  static List<String> toApiTypes(List<String> spanishTypes) {
    return spanishTypes.map((s) => _spanishToApi[s] ?? s.toLowerCase()).toList();
  }

  // Traduce un nombre de tipo de la API (inglés) a español
  static String toSpanishType(String apiType) {
    return _apiToSpanish[apiType.toLowerCase()] ?? apiType;
  }

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
