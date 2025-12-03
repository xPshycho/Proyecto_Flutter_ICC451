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
  final int? level;
  final String? learnMethod;
  final String? versionGroup;

  PokemonMove({
    required this.moveId,
    required this.name,
    required this.nameSpanish,
    this.power,
    this.accuracy,
    this.pp,
    required this.typeName,
    this.damageClass,
    this.level,
    this.learnMethod,
    this.versionGroup,
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

    // Obtener datos de aprendizaje
    final level = json['level'] as int?;
    final learnMethodData = json['pokemon_v2_movelearnmethod'] as Map<String, dynamic>?;
    final versionGroupData = json['pokemon_v2_versiongroup'] as Map<String, dynamic>?;

    return PokemonMove(
      moveId: json['move_id'] as int,
      name: move['name'] as String,
      nameSpanish: spanishName,
      power: move['power'] as int?,
      accuracy: move['accuracy'] as int?,
      pp: move['pp'] as int?,
      typeName: move['pokemon_v2_type']?['name'] as String? ?? 'normal',
      damageClass: move['pokemon_v2_movedamageclass']?['name'] as String?,
      level: level,
      learnMethod: learnMethodData?['name'] as String?,
      versionGroup: versionGroupData?['name'] as String?,
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

  /// Obtiene el método de aprendizaje en español
  String get learnMethodSpanish {
    if (learnMethod == null) return 'Desconocido';

    const methodMap = {
      'level-up': 'Por nivel',
      'machine': 'MT/MO',
      'tutor': 'Tutor',
      'egg': 'Por herencia',
      'light-ball-egg': 'Herencia especial',
      'colosseum-purification': 'Purificación',
      'xd-shadow': 'Pokémon Sombra',
      'xd-purification': 'Purificación XD',
      'form-change': 'Cambio de forma',
    };
    return methodMap[learnMethod!.toLowerCase()] ?? learnMethod!;
  }

  /// Obtiene el grupo de versión en español
  String get versionGroupSpanish {
    if (versionGroup == null) return 'Todas las versiones';

    const versionMap = {
      'red-blue': 'Rojo/Azul',
      'yellow': 'Amarillo',
      'gold-silver': 'Oro/Plata',
      'crystal': 'Cristal',
      'ruby-sapphire': 'Rubí/Zafiro',
      'emerald': 'Esmeralda',
      'firered-leafgreen': 'Rojo Fuego/Verde Hoja',
      'diamond-pearl': 'Diamante/Perla',
      'platinum': 'Platino',
      'heartgold-soulsilver': 'Oro HeartGold/Plata SoulSilver',
      'black-white': 'Negro/Blanco',
      'black-2-white-2': 'Negro 2/Blanco 2',
      'x-y': 'X/Y',
      'omega-ruby-alpha-sapphire': 'Rubí Omega/Zafiro Alfa',
      'sun-moon': 'Sol/Luna',
      'ultra-sun-ultra-moon': 'Ultra Sol/Ultra Luna',
      'sword-shield': 'Espada/Escudo',
      'scarlet-violet': 'Escarlata/Púrpura',
    };
    return versionMap[versionGroup!.toLowerCase()] ?? versionGroup!;
  }
}
