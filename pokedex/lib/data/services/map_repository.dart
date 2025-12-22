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

    // If base contains a stop word like 'route', avoid adding broad wildcards like '%route%'
    final parts = base.split(RegExp(r"\s+"));
    final stopWords = {'route', 'ruta', 'island', 'town', 'city', 'cave', 'mt', 'islands', 'road'};
    final containsStopWord = parts.any((p) => stopWords.contains(p));

    // Always try exact and hyphenated exact first
    variants.add(base);
    final hyphenated = base.replaceAll(RegExp(r"\s+"), '-');
    if (hyphenated.isNotEmpty && hyphenated != base) {
      variants.add(hyphenated);
    }

    // Add no-apostrophe exact
    final noAposNorm = _normalize(noApos);
    if (noAposNorm.isNotEmpty) variants.add(noAposNorm);

    // Add wildcard variants only when not too generic
    if (!containsStopWord) {
      variants.add('%$base%');
      variants.add('%${_normalize(noApos)}%');
      // Also try compacted wildcard
      final noSpace = base.replaceAll(' ', '');
      if (noSpace.isNotEmpty && noSpace != base) {
        variants.add('%$noSpace%');
      }
    } else {
      // If contains stop word (like 'route 1'), add a controlled set of wildcards including hyphenated
      variants.add('%$hyphenated%');
      // also try number-only or last-part wildcards (e.g., '1' or '%1%')
      if (parts.length > 1) {
        final last = parts.last;
        if (last.length <= 3 && RegExp(r"^\d+").hasMatch(last)) {
          variants.add(last);
          variants.add('%$last%');
        }
      }
    }

    // Remove common suffixes like ' island', ' town', ' city', ' route' and add their shorter variants
    final suffixes = [' island', ' town', ' city', ' route', ' cave', ' mt', ' mt.', 'islands'];
    for (final suf in suffixes) {
      if (base.endsWith(suf.trim())) {
        final without = base.substring(0, base.length - suf.trim().length).trim();
        if (without.isNotEmpty) {
          variants.add(without);
          if (!containsStopWord) variants.add('%$without%');
        }
      }
    }

    // Try splitting words, e.g., 'cinnabar island' -> 'cinnabar'
    if (parts.length > 1) {
      for (final p in parts) {
        final part = p.trim();
        if (part.length > 1 && !stopWords.contains(part)) {
          variants.add(part);
          if (!containsStopWord) variants.add('%$part%');
        }
      }
    }

    // Also try compacted (no spaces) as exact variant
    final noSpaceExact = base.replaceAll(' ', '');
    if (noSpaceExact.isNotEmpty && noSpaceExact != base) {
      variants.add(noSpaceExact);
      if (!containsStopWord) variants.add('%$noSpaceExact%');
    }

    return variants.toList();
  }

  /// Resuelve el id de location area (location_area) a partir de su nombre.
  /// Devuelve null si no se encuentra. Si se pasa [regionName], prioriza
  /// coincidencias cuya región (pokemon_v2_location.pokemon_v2_region.name)
  /// contenga ese nombre normalizado.
  Future<int?> getLocationAreaIdByName(String name, {String? regionName}) async {
    // Generar candidatos y probarlos en orden hasta que uno devuelva resultados.
    final candidates = _generateCandidates(name);
    final regionNorm = regionName != null ? _normalize(regionName) : null;

    for (final candidate in candidates) {
      debugPrint('MapRepository: probando candidato: $candidate (region filter: $regionName)');

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

      // Helper local para buscar el primer item que cumpla el test y devolver null si no hay ninguno
      Map<String, dynamic>? firstMatch(List<dynamic> list, bool Function(Map<String, dynamic>) test) {
        for (final item in list.cast<Map<String, dynamic>>()) {
          if (test(item)) return item;
        }
        return null;
      }

      // Si se proporcionó regionName, intentar priorizar items pertenecientes a esa región
      Map<String, dynamic>? chosen;
      if (regionNorm != null) {
        chosen = firstMatch(data, (item) {
          final loc = item['pokemon_v2_location'];
          final region = loc?['pokemon_v2_region']?['name'] as String?;
          final locName = loc?['name'] as String?;
          final regionLower = (region ?? '').toLowerCase();
          final locLower = (locName ?? '').toLowerCase();
          return _normalize(regionLower).contains(regionNorm) || _normalize(locLower).contains(regionNorm);
        });
      }

      // Preferir coincidencia exacta en name o en pokemon_v2_location.name
      final exact = firstMatch(data, (item) {
        final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
        final locName = (item['pokemon_v2_location']?['name'] as String?)?.toLowerCase() ?? '';
        final candNorm = candidate.replaceAll('%', '').toLowerCase();
        return itemName == candNorm || locName == candNorm;
      });

      final finalChoice = chosen ?? exact ?? data.first as Map<String, dynamic>;
      final id = finalChoice['id'] as int?;
      debugPrint('MapRepository: candidato exitoso: $candidate -> id $id (name: ${finalChoice['name']}, location: ${finalChoice['pokemon_v2_location']?['name']}, region: ${finalChoice['pokemon_v2_location']?['pokemon_v2_region']?['name']})');
      return id;
    }

    debugPrint('MapRepository: no se encontró locationArea para: $name (region filter: $regionName)');
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

    // Debug: imprimir cada match con id, name y location.name para facilitar debugging
    try {
      final debugList = data.map((item) => {
        'id': item['id'],
        'name': item['name'],
        'location': item['pokemon_v2_location']?['name']
      }).toList();
      debugPrint('MapRepository: getLocationAreaMatches("$term") -> ${debugList.length} items: $debugList');
    } catch (e) {
      debugPrint('MapRepository: fallo al imprimir matches de "$term": $e');
    }

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
