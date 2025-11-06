/// Modelo que representa un movimiento de Pokémon
class PokemonMove {
  final int moveId;
  final String name;
  final String nameSpanish;
  final int? power;
  final int? accuracy;
  final int? pp;
  final String typeName;
  final String? damageClass;

  PokemonMove({
    required this.moveId,
    required this.name,
    required this.nameSpanish,
    this.power,
    this.accuracy,
    this.pp,
    required this.typeName,
    this.damageClass,
  });

  factory PokemonMove.fromGraphQL(Map<String, dynamic> json) {
    final move = json['pokemon_v2_move'] as Map<String, dynamic>?;
    if (move == null) {
      throw Exception('Invalid move data');
    }

    // Obtener el nombre en español
    String spanishName = move['name'] as String;
    try {
      final moveNames = move['pokemon_v2_movenames'] as List<dynamic>?;
      if (moveNames != null && moveNames.isNotEmpty) {
        final spanishNameData = moveNames[0]['name'] as String?;
        if (spanishNameData != null && spanishNameData.isNotEmpty) {
          spanishName = spanishNameData;
        }
      }
    } catch (e) {
      // Si hay error obteniendo nombre español, usar nombre en inglés
    }

    return PokemonMove(
      moveId: json['move_id'] as int,
      name: move['name'] as String,
      nameSpanish: spanishName,
      power: move['power'] as int?,
      accuracy: move['accuracy'] as int?,
      pp: move['pp'] as int?,
      typeName: move['pokemon_v2_type']?['name'] as String? ?? 'normal',
      damageClass: move['pokemon_v2_movedamageclass']?['name'] as String?,
    );
  }

  /// Formatea el nombre del movimiento para mostrar (usa el nombre en español)
  String get displayName {
    return nameSpanish;
  }

  /// Obtiene el nombre del tipo en español
  String get typeNameSpanish {
    const typeMap = {
      'normal': 'Normal',
      'fighting': 'Lucha',
      'flying': 'Volador',
      'poison': 'Veneno',
      'ground': 'Tierra',
      'rock': 'Roca',
      'bug': 'Bicho',
      'ghost': 'Fantasma',
      'steel': 'Acero',
      'fire': 'Fuego',
      'water': 'Agua',
      'grass': 'Planta',
      'electric': 'Eléctrico',
      'psychic': 'Psíquico',
      'ice': 'Hielo',
      'dragon': 'Dragón',
      'dark': 'Siniestro',
      'fairy': 'Hada',
    };
    return typeMap[typeName.toLowerCase()] ?? typeName;
  }
}
