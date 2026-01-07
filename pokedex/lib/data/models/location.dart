/// Modelo para representar una ubicación en el mundo de Pokémon (ej. Route 1, Viridian City).
class Location {
  final int id;
  final String name;
  final String region;
  final List<Encounter> encounters;

  Location({
    required this.id,
    required this.name,
    required this.region,
    required this.encounters,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      name: json['name'] as String,
      region: json['region'] as String,
      encounters: (json['encounters'] as List<dynamic>?)
          ?.map((e) => Encounter.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

/// Modelo para representar un encuentro de Pokémon en una ubicación.
class Encounter {
  final int pokemonId;
  final String pokemonName;
  final String method; // e.g., 'walk', 'surf', 'fish'
  final int minLevel;
  final int maxLevel;
  final double rate; // encounter rate percentage
  final List<String> games; // list of game versions where this encounter is available

  Encounter({
    required this.pokemonId,
    required this.pokemonName,
    required this.method,
    required this.minLevel,
    required this.maxLevel,
    required this.rate,
    required this.games,
  });

  factory Encounter.fromJson(Map<String, dynamic> json) {
    return Encounter(
      pokemonId: json['pokemonId'] as int,
      pokemonName: json['pokemonName'] as String,
      method: json['method'] as String,
      minLevel: json['minLevel'] as int,
      maxLevel: json['maxLevel'] as int,
      rate: (json['rate'] as num).toDouble(),
      games: (json['games'] as List<dynamic>).map((e) => e as String).toList(),
    );
  }
}

/// Modelo para representar una versión de juego (ej. Red, Blue, FireRed).
class GameVersion {
  final int id;
  final String name;
  final int generation;

  GameVersion({
    required this.id,
    required this.name,
    required this.generation,
  });

  factory GameVersion.fromJson(Map<String, dynamic> json) {
    return GameVersion(
      id: json['id'] as int,
      name: json['name'] as String,
      generation: json['generation'] as int,
    );
  }
}
