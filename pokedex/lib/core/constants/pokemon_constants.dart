import 'package:flutter/material.dart';

/// Constantes específicas de Pokémon
class PokemonConstants {
  PokemonConstants._();

  // Ultra Bestias
  static const int ultraBeastRangeStart = 793;
  static const int ultraBeastRangeEnd = 807;

  // Rangos por región (IDs)
  static const Map<String, List<int>> regionRanges = {
    'Kanto': [1, 151],
    'Johto': [152, 251],
    'Hoenn': [252, 386],
    'Sinnoh': [387, 493],
    'Teselia': [494, 649],
    'Kalos': [650, 721],
    'Alola': [722, 809],
    'Galar': [810, 905],
    'Paldea': [906, 1000],
  };

  // Starters por región (IDs) — alineado con la lista proporcionada
  static const Map<String, List<int>> startersByRegion = {
    'Kanto': [1, 4, 7],
    'Johto': [152, 155, 158],
    'Hoenn': [252, 255, 258],
    'Sinnoh': [387, 390, 393],
    'Teselia': [495, 498, 501],
    'Kalos': [650, 653, 656],
    'Alola': [722, 725, 728],
    'Galar': [810, 813, 816],
    'Paldea': [906, 909, 912],
  };

  // Mapeo de regiones a generaciones (mantener para compatibilidad interna)
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

  /// Obtiene el rango de IDs para una región
  static List<int> getRegionRange(String region) {
    return regionRanges[region] ?? [0, 9999];
  }

  /// Verifica si un ID es un starter (ahora por regiones)
  static bool isStarter(int id) {
    return startersByRegion.values.any((s) => s.contains(id));
  }

  /// Verifica si un ID es una Ultra Bestia
  static bool isUltraBeast(int id) {
    return id >= ultraBeastRangeStart && id <= ultraBeastRangeEnd;
  }

  /// Convierte región a número de generación (compatibilidad)
  static String regionToGen(String region) {
    return regionToGeneration[region] ?? '1';
  }

  /// Mantener getGenerationRange para compatibilidad (deprecated)
  static List<int> getGenerationRange(String generation) {
    return regionRanges[generation] ?? [0, 9999];
  }
}
