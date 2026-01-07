import '../models/type_effectiveness.dart';
import '../../core/constants/pokemon_constants.dart';

/// Servicio para calcular la efectividad de tipos según las reglas oficiales de Pokémon
class TypeEffectivenessService {
  TypeEffectivenessService._();

  /// Tabla completa de efectividad de tipos (atacante -> defensor -> multiplicador)
  static const Map<String, Map<String, double>> _typeChart = {
    'Normal': {
      'Roca': 0.5,
      'Fantasma': 0.0,
      'Acero': 0.5,
    },
    'Fuego': {
      'Fuego': 0.5,
      'Agua': 0.5,
      'Planta': 2.0,
      'Hielo': 2.0,
      'Bicho': 2.0,
      'Roca': 0.5,
      'Dragón': 0.5,
      'Acero': 2.0,
    },
    'Agua': {
      'Fuego': 2.0,
      'Agua': 0.5,
      'Planta': 0.5,
      'Tierra': 2.0,
      'Roca': 2.0,
      'Dragón': 0.5,
    },
    'Eléctrico': {
      'Agua': 2.0,
      'Eléctrico': 0.5,
      'Planta': 0.5,
      'Tierra': 0.0,
      'Volador': 2.0,
      'Dragón': 0.5,
    },
    'Planta': {
      'Fuego': 0.5,
      'Agua': 2.0,
      'Planta': 0.5,
      'Veneno': 0.5,
      'Volador': 0.5,
      'Bicho': 0.5,
      'Tierra': 2.0,
      'Roca': 2.0,
      'Dragón': 0.5,
      'Acero': 0.5,
    },
    'Hielo': {
      'Fuego': 0.5,
      'Agua': 0.5,
      'Planta': 2.0,
      'Hielo': 0.5,
      'Tierra': 2.0,
      'Volador': 2.0,
      'Dragón': 2.0,
      'Acero': 0.5,
    },
    'Lucha': {
      'Normal': 2.0,
      'Hielo': 2.0,
      'Veneno': 0.5,
      'Volador': 0.5,
      'Psíquico': 0.5,
      'Bicho': 0.5,
      'Roca': 2.0,
      'Fantasma': 0.0,
      'Siniestro': 2.0,
      'Acero': 2.0,
      'Hada': 0.5,
    },
    'Veneno': {
      'Planta': 2.0,
      'Veneno': 0.5,
      'Tierra': 0.5,
      'Roca': 0.5,
      'Fantasma': 0.5,
      'Acero': 0.0,
      'Hada': 2.0,
    },
    'Tierra': {
      'Fuego': 2.0,
      'Eléctrico': 2.0,
      'Planta': 0.5,
      'Veneno': 2.0,
      'Volador': 0.0,
      'Bicho': 0.5,
      'Roca': 2.0,
      'Acero': 2.0,
    },
    'Volador': {
      'Eléctrico': 0.5,
      'Planta': 2.0,
      'Lucha': 2.0,
      'Bicho': 2.0,
      'Roca': 0.5,
      'Acero': 0.5,
    },
    'Psíquico': {
      'Lucha': 2.0,
      'Veneno': 2.0,
      'Psíquico': 0.5,
      'Siniestro': 0.0,
      'Acero': 0.5,
    },
    'Bicho': {
      'Fuego': 0.5,
      'Planta': 2.0,
      'Lucha': 0.5,
      'Veneno': 0.5,
      'Volador': 0.5,
      'Psíquico': 2.0,
      'Fantasma': 0.5,
      'Siniestro': 2.0,
      'Acero': 0.5,
      'Hada': 0.5,
    },
    'Roca': {
      'Fuego': 2.0,
      'Hielo': 2.0,
      'Lucha': 0.5,
      'Tierra': 0.5,
      'Volador': 2.0,
      'Bicho': 2.0,
      'Acero': 0.5,
    },
    'Fantasma': {
      'Normal': 0.0,
      'Psíquico': 2.0,
      'Fantasma': 2.0,
      'Siniestro': 0.5,
    },
    'Dragón': {
      'Dragón': 2.0,
      'Acero': 0.5,
      'Hada': 0.0,
    },
    'Siniestro': {
      'Lucha': 0.5,
      'Psíquico': 2.0,
      'Fantasma': 2.0,
      'Siniestro': 0.5,
      'Hada': 0.5,
    },
    'Acero': {
      'Fuego': 0.5,
      'Agua': 0.5,
      'Eléctrico': 0.5,
      'Hielo': 2.0,
      'Roca': 2.0,
      'Acero': 0.5,
      'Hada': 2.0,
    },
    'Hada': {
      'Fuego': 0.5,
      'Lucha': 2.0,
      'Veneno': 0.5,
      'Dragón': 2.0,
      'Siniestro': 2.0,
      'Acero': 0.5,
    },
  };

  /// Calcula la efectividad combinada para un Pokémon con uno o dos tipos
  static PokemonTypeEffectiveness calculateEffectiveness(List<String> pokemonTypes) {
    final Map<String, double> finalMultipliers = {};

    // Obtener todos los tipos atacantes posibles
    final allTypes = PokemonConstants.typeColors.keys.toList();

    for (final attackingType in allTypes) {
      double combinedMultiplier = 1.0;

      // Para cada tipo del Pokémon defensor, multiplicar la efectividad
      for (final defendingType in pokemonTypes) {
        final typeChart = _typeChart[attackingType] ?? {};
        final multiplier = typeChart[defendingType] ?? 1.0;
        combinedMultiplier *= multiplier;
      }

      finalMultipliers[attackingType] = combinedMultiplier;
    }

    return PokemonTypeEffectiveness(finalMultipliers);
  }

  /// Obtiene la efectividad de un tipo atacante contra un tipo defensor
  static double getSingleTypeEffectiveness(String attackingType, String defendingType) {
    return _typeChart[attackingType]?[defendingType] ?? 1.0;
  }
}
