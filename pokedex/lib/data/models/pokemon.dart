import '../../domain/models/type_effectiveness.dart';
import '../../domain/services/type_effectiveness_service.dart';
import '../../core/constants/pokemon_constants.dart';
import 'evolution_detail.dart';
import 'pokemon_ability.dart';

/// Modelo principal de Pokémon. Representa la entidad "base" del pokémon con sus
/// atributos principales (id, nombre, tipos, stats, etc.).
///
/// Notas sobre `forms` (varianzas):
/// - No modelamos cada forma como un `Pokemon` independiente para evitar duplicar
///   datos (stats, id lógico, etc.). En su lugar `forms` almacena variantes (Mega,
///   Alola, Galar, Hisui, Gigantamax, primal, etc.) como `PokemonForm`.
/// - `PokemonForm` contiene sprite(s) y flags específicos de la forma. Se cargan
///   por separado (batch) cuando la UI los necesita (detalle o cadena de evolución).
class Pokemon {
  final int id;
  final String name;
  final String? spriteUrl;
  final String? shinySpriteUrl;
  final String? cryUrl;
  final List<String> types;
  final double? height;
  final double? weight;
  final String? description;
  final List<Pokemon>? evolutions;
  final Map<int, EvolutionDetail>? evolutionDetails;
  bool isFavorite;
  final List<PokemonAbility> abilities;
  final Map<String, int> stats;
  final List<String>? categories;
  final bool? isLegendary;
  final bool? isMythical;
  final int? generationId;
  final List<dynamic>? forms;
  /// NUEVO: formas agregadas de toda la cadena evolutiva (megas/variantes de las evoluciones)
  final List<dynamic>? formsChain;
  /// Grupos de huevo del Pokémon
  final List<String>? eggGroups;

  Pokemon({
    required this.id,
    required this.name,
    this.spriteUrl,
    this.shinySpriteUrl,
    this.cryUrl,
    this.types = const [],
    this.height,
    this.weight,
    this.description,
    this.evolutions,
    this.evolutionDetails,
    this.isFavorite = false,
    this.abilities = const [],
    this.stats = const {},
    this.categories,
    this.isLegendary,
    this.isMythical,
    this.generationId,
    this.forms,
    this.formsChain,
    this.eggGroups,
  });

  /// Calcula la efectividad de tipos para este Pokémon
  PokemonTypeEffectiveness get typeEffectiveness {
    final spanishTypes = types.map(PokemonConstants.toSpanishType).toList();
    return TypeEffectivenessService.calculateEffectiveness(spanishTypes);
  }

  Pokemon copyWith({
    List<dynamic>? forms,
    List<dynamic>? formsChain,
    String? description,
    List<Pokemon>? evolutions,
    Map<int, EvolutionDetail>? evolutionDetails,
    int? generationId,
    List<String>? eggGroups,
  }) {
    return Pokemon(
      id: id,
      name: name,
      spriteUrl: spriteUrl,
      shinySpriteUrl: shinySpriteUrl,
      cryUrl: cryUrl,
      types: types,
      height: height,
      weight: weight,
      evolutions: evolutions ?? this.evolutions,
      evolutionDetails: evolutionDetails ?? this.evolutionDetails,
      isFavorite: isFavorite,
      abilities: abilities,
      stats: stats,
      categories: categories,
      isLegendary: isLegendary,
      isMythical: isMythical,
      generationId: generationId ?? this.generationId,
      forms: forms ?? this.forms,
      formsChain: formsChain ?? this.formsChain,
      description: description ?? this.description,
      eggGroups: eggGroups ?? this.eggGroups,
    );
  }

  // Fábrica desde JSON genérico
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    // Parsear abilities - puede venir como lista de strings o de objetos
    List<PokemonAbility> parsedAbilities = [];
    final abilitiesData = json['abilities'];
    if (abilitiesData is List) {
      for (final item in abilitiesData) {
        if (item is String) {
          parsedAbilities.add(PokemonAbility(name: item));
        } else if (item is Map<String, dynamic>) {
          parsedAbilities.add(PokemonAbility(
            name: item['name'] as String? ?? '',
            isHidden: item['isHidden'] as bool? ?? false,
            effect: item['effect'] as String?,
          ));
        }
      }
    }

    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: json['spriteUrl'] as String?,
      shinySpriteUrl: json['shinySpriteUrl'] as String?,
      cryUrl: json['cryUrl'] as String?,
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      abilities: parsedAbilities,
      stats: (json['stats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isLegendary: json['isLegendary'] as bool?,
      isMythical: json['isMythical'] as bool?,
      generationId: json['generationId'] as int?,
      forms: json['forms'] as List<dynamic>?,
      formsChain: json['formsChain'] as List<dynamic>?,
      description: json['description'] as String?,
      eggGroups: (json['eggGroups'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}
