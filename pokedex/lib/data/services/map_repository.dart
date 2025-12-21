import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/location.dart';
import '../models/pokemon.dart';
import 'graphql_query_service.dart';
import 'pokemon_mapper_service.dart';

/// Repositorio para manejar datos de mapas y encuentros de Pokémon.
class MapRepository {
  final GraphQLClient client;

  MapRepository(this.client);

  // Helper: normaliza acentos básicos y pasa a minúsculas
  String _normalize(String s) {
    var out = s.toLowerCase();
    const accents = {
      'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
      'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
      'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
      'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
      'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
      'ñ': 'n',
    };
    accents.forEach((k, v) {
      out = out.replaceAll(k, v);
    });
    return out;
  }

  // Genera variantes de búsqueda a partir del nombre original.
  List<String> _generateCandidates(String name) {
    final cleaned = name.trim();
    final noApos = cleaned.replaceAll("'", '');

    final lower = cleaned.toLowerCase();
    final base = _normalize(lower);

    final variants = <String>{};

    variants.add(base);
    variants.add('%$base%');

    variants.add(_normalize(noApos));
    variants.add('%${_normalize(noApos)}%');

    // Remove common suffixes like ' island', ' town', ' city', ' route'
    final suffixes = [' island', ' town', ' city', ' route', ' cave', ' mt', ' mt.', 'islands'];
    for (final suf in suffixes) {
      if (base.endsWith(suf.trim())) {
        final without = base.substring(0, base.length - suf.trim().length).trim();
        if (without.isNotEmpty) {
          variants.add(without);
          variants.add('%$without%');
        }
      }
    }

    // Try splitting words, e.g., 'cinnabar island' -> 'cinnabar'
    final parts = base.split(RegExp(r"\s+"));
    if (parts.length > 1) {
      for (final p in parts) {
        if (p.length > 1) {
          variants.add(p);
          variants.add('%$p%');
        }
      }
    }

    // Also try compacted (no spaces)
    final noSpace = base.replaceAll(' ', '');
    if (noSpace.isNotEmpty && noSpace != base) {
      variants.add(noSpace);
      variants.add('%$noSpace%');
    }

    return variants.toList();
  }

  /// Resuelve el id de location area (location_area) a partir de su nombre.
  /// Devuelve null si no se encuentra.
  Future<int?> getLocationAreaIdByName(String name) async {
    // Generar candidatos y probarlos en orden hasta que uno devuelva resultados.
    final candidates = _generateCandidates(name);

    for (final candidate in candidates) {
      debugPrint('MapRepository: probando candidato: $candidate');

      final options = QueryOptions(
        document: gql(GraphQLQueryService.locationAreaByName),
        variables: {'name': candidate}, // ilike pattern
      );

      final result = await client.query(options);

      if (result.hasException) {
        // Si hubo un error, saltar al siguiente candidato
        debugPrint('MapRepository: query error con candidato $candidate -> ${result.exception}');
        continue;
      }

      final raw = result.data;
      if (raw == null) continue;
      final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
      final data = clean['pokemon_v2_locationarea'] as List<dynamic>? ?? [];
      if (data.isEmpty) continue;

      // Preferir coincidencia exacta en name o en pokemon_v2_location.name
      final exact = data.firstWhere(
        (item) {
          final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
          final locName = (item['pokemon_v2_location']?['name'] as String?)?.toLowerCase() ?? '';
          final candNorm = candidate.replaceAll('%', '').toLowerCase();
          return itemName == candNorm || locName == candNorm;
        },
        orElse: () => null,
      );

      final chosen = exact ?? data.first;
      final id = chosen['id'] as int?;
      debugPrint('MapRepository: candidato exitoso: $candidate -> id $id (name: ${chosen['name']}, location: ${chosen['pokemon_v2_location']?['name']})');
      return id;
    }

    debugPrint('MapRepository: no se encontró locationArea para: $name');
    return null;
  }

  /// Obtiene encuentros de Pokémon para una ubicación específica.
  Future<List<Encounter>> getEncountersByLocation(int locationId) async {
    final options = QueryOptions(
      document: gql(GraphQLQueryService.encountersByLocation),
      variables: {'locationId': locationId},
    );

    final result = await client.query(options);

    if (result.hasException) {
      throw Exception('Error fetching encounters: ${result.exception}');
    }

    final raw = result.data;
    if (raw == null) return [];
    final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    final data = clean['pokemon_v2_encounter'] as List<dynamic>? ?? [];

    return data.map((json) {
      final pokemon = json['pokemon_v2_pokemon'];
      final slot = json['pokemon_v2_encounterslot'];
      final method = slot?['pokemon_v2_encountermethod']?['name'] ?? 'walk';
      final rarity = slot?['rarity'] ?? 0;
      final rate = rarity / 100.0; // assuming rarity is percentage

      return Encounter(
        pokemonId: pokemon['id'] as int,
        pokemonName: pokemon['name'] as String,
        method: method,
        minLevel: json['min_level'] as int,
        maxLevel: json['max_level'] as int,
        rate: rate,
        games: [json['pokemon_v2_version']['name'] as String],
      );
    }).toList();
  }

  /// Obtiene encuentros de un Pokémon específico.
  Future<List<Encounter>> getEncountersByPokemon(int pokemonId) async {
    final options = QueryOptions(
      document: gql(GraphQLQueryService.encountersByPokemon),
      variables: {'pokemonId': pokemonId},
    );

    final result = await client.query(options);

    if (result.hasException) {
      throw Exception('Error fetching encounters: ${result.exception}');
    }

    final raw = result.data;
    if (raw == null) return [];
    final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    final data = clean['pokemon_v2_encounter'] as List<dynamic>? ?? [];

    return data.map((json) {
      final locationArea = json['pokemon_v2_locationarea'];
      final location = locationArea?['pokemon_v2_location'];
      final region = location?['pokemon_v2_region'];
      final slot = json['pokemon_v2_encounterslot'];
      final method = slot?['pokemon_v2_encountermethod']?['name'] ?? 'walk';
      final rarity = slot?['rarity'] ?? 0;
      final rate = rarity / 100.0;
      final pokemon = json['pokemon_v2_pokemon'];

      return Encounter(
        pokemonId: pokemonId,
        pokemonName: pokemon?['name'] as String? ?? 'Unknown',
        method: method,
        minLevel: json['min_level'] as int,
        maxLevel: json['max_level'] as int,
        rate: rate,
        games: [json['pokemon_v2_version']['name'] as String],
      );
    }).toList();
  }

  /// Obtiene ubicaciones con encuentros de un Pokémon específico.
  Future<List<Location>> getLocationsWithEncountersByPokemon(int pokemonId) async {
    final options = QueryOptions(
      document: gql(GraphQLQueryService.encountersByPokemon),
      variables: {'pokemonId': pokemonId},
    );

    final result = await client.query(options);

    if (result.hasException) {
      throw Exception('Error fetching encounters: ${result.exception}');
    }

    final raw = result.data;
    if (raw == null) return [];
    final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    final data = clean['pokemon_v2_encounter'] as List<dynamic>? ?? [];

    // Group by location area
    final locationMap = <int, Map<String, dynamic>>{};
    for (final json in data) {
      final locationArea = json['pokemon_v2_locationarea'];
      final location = locationArea?['pokemon_v2_location'];
      final region = location?['pokemon_v2_region'];
      final locationAreaId = locationArea?['id'] as int?;
      final locationAreaName = locationArea?['name'] as String? ?? 'Unknown';
      final locationName = location?['name'] as String? ?? 'Unknown';
      final regionName = region?['name'] as String? ?? 'Unknown';

      if (locationAreaId != null) {
        if (!locationMap.containsKey(locationAreaId)) {
          locationMap[locationAreaId] = {
            'id': locationAreaId,
            'name': locationAreaName,
            'location': locationName,
            'region': regionName,
            'encounters': <Encounter>[],
          };
        }

        final slot = json['pokemon_v2_encounterslot'];
        final method = slot?['pokemon_v2_encountermethod']?['name'] ?? 'walk';
        final rarity = slot?['rarity'] ?? 0;
        final rate = rarity / 100.0;

        final encounter = Encounter(
          pokemonId: pokemonId,
          pokemonName: json['pokemon_v2_pokemon']?['name'] as String? ?? 'Unknown',
          method: method,
          minLevel: json['min_level'] as int,
          maxLevel: json['max_level'] as int,
          rate: rate,
          games: [json['pokemon_v2_version']['name'] as String],
        );

        locationMap[locationAreaId]!['encounters'].add(encounter);
      }
    }

    return locationMap.values.map((map) {
      return Location(
        id: map['id'] as int,
        name: map['name'] as String,
        region: map['region'] as String,
        encounters: map['encounters'] as List<Encounter>,
      );
    }).toList();
  }

  /// Obtiene ubicaciones por región (placeholder, implementar si necesario).
  Future<List<Location>> getLocationsByRegion(String region) async {
    // Placeholder: en una implementación real, consultar ubicaciones por región.
    // Por ahora, devolver lista vacía o mock.
    return [];
  }

  /// Devuelve una lista de coincidencias de location areas para un término.
  /// Cada item es un mapa con keys: 'id', 'name', 'locationName'.
  Future<List<Map<String, dynamic>>> getLocationAreaMatches(String term) async {
    final pattern = '%${_normalize(term)}%';
    final options = QueryOptions(
      document: gql(GraphQLQueryService.locationAreaByName),
      variables: {'name': pattern},
    );

    final result = await client.query(options);
    if (result.hasException) {
      debugPrint('MapRepository: error buscando matches para $term -> ${result.exception}');
      return [];
    }

    final raw = result.data;
    if (raw == null) return [];
    final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    final data = clean['pokemon_v2_locationarea'] as List<dynamic>? ?? [];
    return data.map((item) {
      return {
        'id': item['id'] as int?,
        'name': item['name'] as String?,
        'locationName': item['pokemon_v2_location']?['name'] as String?,
      };
    }).toList();
  }

  /// Obtiene información básica de varios pokémon por sus IDs.
  Future<List<Pokemon>> getPokemonsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    final options = QueryOptions(
      document: gql(GraphQLQueryService.byIds),
      variables: {'ids': ids},
    );

    final result = await client.query(options);
    if (result.hasException) {
      debugPrint('MapRepository: error getPokemonsByIds -> ${result.exception}');
      return [];
    }

    final raw = result.data;
    if (raw == null) return [];
    final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
    final data = clean['pokemon_v2_pokemon'] as List<dynamic>? ?? [];

    // Usar el mapper central para evitar problemas de tipos (y parseo de sprites JSON)
    try {
      return PokemonMapperService.mapList(data);
    } catch (e) {
      debugPrint('MapRepository: fallo al mapear pokemons -> $e');
      // Fallback mínimo
      return data.map((p) {
        final typesList = (p['pokemon_v2_pokemontypes'] as List<dynamic>?)?.map((t) {
          return (t['pokemon_v2_type']?['name'] as String?) ?? '';
        }).where((s) => s.isNotEmpty).toList() ?? [];

        final sprite = (p['pokemon_v2_pokemonsprites'] is List && p['pokemon_v2_pokemonsprites'].isNotEmpty)
            ? (p['pokemon_v2_pokemonsprites'][0]['sprites'] is String
                ? null
                : null)
            : null;

        return Pokemon(
          id: p['id'] as int,
          name: p['name'] as String,
          spriteUrl: null,
          types: typesList,
        );
      }).toList();
    }
  }
}
