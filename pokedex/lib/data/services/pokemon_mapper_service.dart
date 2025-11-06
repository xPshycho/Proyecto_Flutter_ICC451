import '../models/pokemon.dart';

class PokemonMapperService {
  const PokemonMapperService._();

  /// Mapea una lista de datos GraphQL a lista de Pokemon
  static List<Pokemon> mapList(List<dynamic> data) {
    return data.map((item) => mapBasic(item)).toList();
  }

  /// Mapea un Pokémon básico (id, name, sprite, types)
  static Pokemon mapBasic(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final name = item['name'] as String;
    final spriteUrl = _extractSpriteUrl(item['pokemon_v2_pokemonsprites']);
    final types = _extractTypes(item['pokemon_v2_pokemontypes']);
    final speciesData = _extractSpeciesData(item['pokemon_v2_pokemonspecy']);

    return Pokemon(
      id: id,
      name: name,
      spriteUrl: spriteUrl,
      types: types,
      categories: speciesData['categories'],
      isLegendary: speciesData['isLegendary'],
      isMythical: speciesData['isMythical'],
      generationId: speciesData['generationId'],
    );
  }

  /// Mapea una lista de datos detallados de GraphQL
  static List<Pokemon> mapDetailedList(List<dynamic> data) {
    return data.map((item) => mapDetailed(item)).toList();
  }

  /// Mapea un Pokémon con detalles completos
  static Pokemon mapDetailed(Map<String, dynamic> item) {
    final id = item['id'] as int;
    final name = item['name'] as String;
    final spriteUrl = _extractSpriteUrl(item['pokemon_v2_pokemonsprites']);
    final types = _extractTypes(item['pokemon_v2_pokemontypes']);
    final height = (item['height'] as num?)?.toDouble();
    final weight = (item['weight'] as num?)?.toDouble();

    // Extraer habilidades
    final abilities = _extractAbilities(item['pokemon_v2_pokemonabilities']);

    // Extraer estadísticas
    final stats = _extractStats(item['pokemon_v2_pokemonstats']);

    // Extraer categorías y flags de especies
    final speciesData = _extractSpeciesData(item['pokemon_v2_pokemonspecy']);

    return Pokemon(
      id: id,
      name: name,
      spriteUrl: spriteUrl,
      types: types,
      height: height,
      weight: weight,
      abilities: abilities,
      stats: stats,
      categories: speciesData['categories'],
      isLegendary: speciesData['isLegendary'],
      isMythical: speciesData['isMythical'],
      generationId: speciesData['generationId'],
    );
  }

  /// Extrae la URL del sprite desde los datos GraphQL
  static String? _extractSpriteUrl(dynamic spritesData) {
    if (spritesData == null) return null;

    final spritesList = spritesData is List ? spritesData : [spritesData];

    for (var sprite in spritesList) {
      final url = sprite['sprites']['front_default'];
      if (url != null && url is String) return url;
    }

    return null;
  }

  /// Extrae los tipos desde los datos GraphQL
  static List<String> _extractTypes(dynamic typesData) {
    if (typesData == null) return [];

    final typesList = typesData is List ? typesData : [typesData];

    return typesList
        .map<String>((t) => t['pokemon_v2_type']['name'] as String)
        .toList();
  }

  /// Extrae las habilidades desde los datos GraphQL
  static List<String> _extractAbilities(dynamic abilitiesData) {
    if (abilitiesData == null || abilitiesData is! List) return [];

    return abilitiesData
        .map((a) {
      final ability = a['pokemon_v2_ability'];
      if (ability == null) return null;

      // Intentar obtener nombre en español
      final abilityNames = ability['pokemon_v2_abilitynames'];
      if (abilityNames is List && abilityNames.isNotEmpty) {
        final spanishName = abilityNames[0]['name'];
        if (spanishName != null) return spanishName as String;
      }

      // Fallback al nombre en inglés
      return ability['name'] as String?;
    })
        .where((name) => name != null)
        .cast<String>()
        .toList();
  }

  /// Extrae las estadísticas desde los datos GraphQL
  static Map<String, int> _extractStats(dynamic statsData) {
    if (statsData == null || statsData is! List) return {};

    final statsMap = <String, int>{};

    for (final stat in statsData) {
      final statName = stat['pokemon_v2_stat']?['name'];
      final baseStat = stat['base_stat'];

      if (statName != null && baseStat != null) {
        statsMap[statName as String] = baseStat as int;
      }
    }

    return statsMap;
  }

  /// Extrae datos de la especie (legendary, mythical, categories, generationId)
  static Map<String, dynamic> _extractSpeciesData(dynamic speciesData) {
    if (speciesData == null) {
      return {
        'categories': null,
        'isLegendary': null,
        'isMythical': null,
        'generationId': null,
      };
    }

    final isLegendary = speciesData['is_legendary'] as bool?;
    final isMythical = speciesData['is_mythical'] as bool?;
    final generationId = speciesData['generation_id'] as int?;

    final categories = <String>[];
    if (isLegendary == true) categories.add('legendario');
    if (isMythical == true) categories.add('mitico');

    return {
      'categories': categories.isEmpty ? null : categories,
      'isLegendary': isLegendary,
      'isMythical': isMythical,
      'generationId': generationId,
    };
  }

  /// Extrae la descripción desde flavor texts
  static String? extractDescription(Map<String, dynamic> data) {
    try {
      final specy = data['pokemon_v2_pokemonspecy'];
      if (specy != null && specy['pokemon_v2_pokemonspeciesflavortexts'] is List) {
        final texts = specy['pokemon_v2_pokemonspeciesflavortexts'] as List<dynamic>;
        if (texts.isNotEmpty) {
          final ft = texts[0]['flavor_text'] as String?;
          if (ft != null && ft.trim().isNotEmpty) {
            return ft.replaceAll('\n', ' ').replaceAll('\f', ' ').trim();
          }
        }
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  /// Crea un objeto PokemonForm desde datos GraphQL
  static Map<String, dynamic> createForm(Map<String, dynamic> formData) {
    return {
      'id': formData['id'] as int,
      'pokemon_id': formData['pokemon_id'] as int,
      'name': formData['name'] as String?,
      'form_name': formData['form_name'] as String?,
      'is_default': (formData['is_default'] as bool?) ?? false,
      'is_battle_only': (formData['is_battle_only'] as bool?) ?? false,
      'is_mega': formData['is_mega'] as bool?,
      'sprite_url': null,
      'types': <String>[],
    };
  }

  /// Extrae tipos desde un objeto pokemon en datos de forma
  static List<String> extractTypesFromPokemon(dynamic pokemonData) {
    if (pokemonData == null) return [];

    try {
      final types = pokemonData['pokemon_v2_pokemontypes'] as List<dynamic>?;
      if (types != null) {
        return types
            .map((t) => t['pokemon_v2_type']['name'] as String)
            .toList();
      }
    } catch (_) {
      return [];
    }

    return [];
  }
}

