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
  final List<String> types;
  final double? height;
  final double? weight;
  final String? description;
  final List<Pokemon>? evolutions;
  bool isFavorite;
  final List<String> abilities;
  final Map<String, int> stats;
  // Categorías derivadas (p.ej. 'legendario', 'mitico', 'mega', etc.)
  final List<String>? categories;
  final bool? isLegendary;
  final bool? isMythical;

  // Forms (mega, alola, regional variants, etc.)
  final List<dynamic>? forms; // usar PokemonForm en repositorio

  Pokemon({
    required this.id,
    required this.name,
    this.spriteUrl,
    this.types = const [],
    this.height,
    this.weight,
    this.description,
    this.evolutions,
    this.isFavorite = false,
    this.abilities = const [],
    this.stats = const {},
    this.categories,
    this.isLegendary,
    this.isMythical,
    this.forms,
  });

  Pokemon copyWith({
    List<dynamic>? forms,
    String? description,
  }) {
    return Pokemon(
      id: id,
      name: name,
      spriteUrl: spriteUrl,
      types: types,
      height: height,
      weight: weight,
      evolutions: evolutions,
      isFavorite: isFavorite,
      abilities: abilities,
      stats: stats,
      categories: categories,
      isLegendary: isLegendary,
      isMythical: isMythical,
      forms: forms ?? this.forms,
      description: description ?? this.description,
    );
  }

  // Fábrica desde JSON genérico
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: json['spriteUrl'] as String?,
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      abilities: (json['abilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stats: (json['stats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
      categories: (json['categories'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      isLegendary: json['isLegendary'] as bool?,
      isMythical: json['isMythical'] as bool?,
      forms: json['forms'] as List<dynamic>?,
      description: json['description'] as String?,
    );
  }
}
