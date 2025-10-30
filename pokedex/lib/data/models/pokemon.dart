class Pokemon {
  final int id;
  final String name;
  final String? spriteUrl;
  final List<String> types;
  final int? height;
  final int? weight;
  final List<Pokemon>? evolutions;
  bool isFavorite;
  final List<String> abilities;
  final Map<String, int> stats;

  Pokemon({
    required this.id,
    required this.name,
    this.spriteUrl,
    this.types = const [],
    this.height,
    this.weight,
    this.evolutions,
    this.isFavorite = false,
    this.abilities = const [],
    this.stats = const {},
  });

  // Fábrica desde JSON genérico
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'] as int,
      name: json['name'] as String,
      spriteUrl: json['spriteUrl'] as String?,
      types: (json['types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      height: json['height'] as int?,
      weight: json['weight'] as int?,
      abilities: (json['abilities'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stats: (json['stats'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v as int)) ?? {},
    );
  }
}
