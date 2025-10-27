import 'package:flutter/material.dart';

class PokemonTypeColors {
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

  static Color getTypeColor(String type) {
    return typeColors[type] ?? const Color(0xFFA0A29F); // Default Normal color
  }

  static String? getTypeIcon(String type) {
    return typeIcons[type];
  }
}

