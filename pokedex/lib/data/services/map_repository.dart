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

  /// Intenta resolver un `pokemon_v2_location` por nombre usando la nueva query.
  /// Devuelve el id de la location si se encuentra, o null si no.
  Future<int?> getLocationIdByName(String name) async {
    final candidates = _generateCandidates(name);
    debugPrint('MapRepository: getLocationIdByName buscando: $name -> candidates: $candidates');

    for (final candidate in candidates) {
      debugPrint('MapRepository: probando candidate: $candidate');

      final options = QueryOptions(
        document: gql(GraphQLQueryService.locationByName),
        variables: {'name': candidate},
      );

      final result = await client.query(options);
      if (result.hasException) {
        debugPrint('MapRepository: error getLocationIdByName for $candidate -> ${result.exception}');
        continue;
      }

      final raw = result.data;
      if (raw == null) continue;
      final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
      final data = clean['pokemon_v2_location'] as List<dynamic>? ?? [];

      if (data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        debugPrint('MapRepository: getLocationIdByName match for $candidate -> ${first['name']} id=${first['id']}');
        return first['id'] as int?;
      }
    }

    debugPrint('MapRepository: no match for $name');
    return null;
  }

  /// Intenta resolver un `pokemon_v2_location` por identificador exacto (ej. "kanto-route-1").
  /// Devuelve el id de la location si se encuentra, o null si no.
    Future<int?> getLocationIdByIdentifier(String identifier) async {
    debugPrint('MapRepository: getLocationIdByIdentifier buscando: $identifier');

    // Helper local que prueba un candidate exacto (location y locationarea)
    Future<int?> tryExactCandidate(String cand) async {
      // Intentar location exacto
      try {
        final optionsLoc = QueryOptions(
          document: gql(GraphQLQueryService.locationByName),
          variables: {'name': cand},
        );
        final resLoc = await client.query(optionsLoc);
        if (!resLoc.hasException && resLoc.data != null) {
          final cleanLoc = jsonDecode(jsonEncode(resLoc.data)) as Map<String, dynamic>;
          final dataLoc = cleanLoc['pokemon_v2_location'] as List<dynamic>? ?? [];
          if (dataLoc.isNotEmpty) {
            final lowerCand = cand.toLowerCase();
            for (final item in dataLoc.cast<Map<String, dynamic>>()) {
              final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
              if (itemName == lowerCand) {
                debugPrint('MapRepository: getLocationIdByIdentifier exact match (location) -> ${item['name']} id=${item['id']}');
                return item['id'] as int?;
              }
            }
            final first = dataLoc.first as Map<String, dynamic>;
            debugPrint('MapRepository: getLocationIdByIdentifier fallback first (location) -> ${first['name']} id=${first['id']}');
            return first['id'] as int?;
          }
        } else if (resLoc.hasException) {
          debugPrint('MapRepository: error getLocationIdByIdentifier (location) -> ${resLoc.exception}');
        }
      } catch (e) {
        debugPrint('MapRepository: exception querying locationByName -> $e');
      }

      // Intentar location area exacto
      try {
        final optionsArea = QueryOptions(
          document: gql(GraphQLQueryService.locationAreaByName),
          variables: {'name': cand},
        );
        final resArea = await client.query(optionsArea);
        if (!resArea.hasException && resArea.data != null) {
          final cleanArea = jsonDecode(jsonEncode(resArea.data)) as Map<String, dynamic>;
          final dataArea = cleanArea['pokemon_v2_locationarea'] as List<dynamic>? ?? [];
          if (dataArea.isNotEmpty) {
            final lowerCand = cand.toLowerCase();
            for (final item in dataArea.cast<Map<String, dynamic>>()) {
              final itemName = (item['name'] as String?)?.toLowerCase() ?? '';
              final locName = (item['pokemon_v2_location']?['name'] as String?)?.toLowerCase() ?? '';
              if (itemName == lowerCand || locName == lowerCand) {
                debugPrint('MapRepository: getLocationIdByIdentifier exact match (area) -> ${item['name']} id=${item['id']} (location: $locName)');
                return item['id'] as int?;
              }
            }
            final firstArea = dataArea.first as Map<String, dynamic>;
            debugPrint('MapRepository: getLocationIdByIdentifier fallback first (area) -> ${firstArea['name']} id=${firstArea['id']}');
            return firstArea['id'] as int?;
          }
        } else if (resArea.hasException) {
          debugPrint('MapRepository: error getLocationIdByIdentifier (area) -> ${resArea.exception}');
        }
      } catch (e) {
        debugPrint('MapRepository: exception querying locationAreaByName -> $e');
      }

      return null;
    }

    // Preparar candidatos: original + variante con 'sea' si aplica
    final candidates = <String>[identifier];
    try {
      final routeMatch = RegExp(r"^([a-z0-9\-]+)-route-(\d+)", caseSensitive: false);
      final seaMatch = RegExp(r"^([a-z0-9\-]+)-sea-route-(\d+)", caseSensitive: false);
      if (routeMatch.hasMatch(identifier)) {
        final m = routeMatch.firstMatch(identifier)!;
        final region = m.group(1);
        final num = m.group(2);
        if (region != null && num != null) {
          final alt = '$region-sea-route-$num';
          if (!candidates.contains(alt)) candidates.add(alt);
        }
      } else if (seaMatch.hasMatch(identifier)) {
        final m = seaMatch.firstMatch(identifier)!;
        final region = m.group(1);
        final num = m.group(2);
        if (region != null && num != null) {
          final alt = '$region-route-$num';
          if (!candidates.contains(alt)) candidates.add(alt);
        }
      }
    } catch (e) {
      debugPrint('MapRepository: error generating sea-variant -> $e');
    }

    // Probar candidatos exactos en orden
    for (final cand in candidates) {
      final res = await tryExactCandidate(cand);
      if (res != null) return res;
    }

    // 3) Si no encontramos exacto, intentar quitar posible prefijo de región
    // Ej: 'kanto-route-20' -> region='kanto', rest='route-20'
    try {
      final parts = identifier.split('-');
      if (parts.length > 1) {
        final maybeRegion = parts.first;
        final rest = parts.sublist(1).join('-');
        // Probar buscar por nombre sin prefijo (rest) como location y como area (priorizando area con filtro de región)
        debugPrint('MapRepository: intentado sin prefijo de región -> rest: $rest, region: $maybeRegion');

        final tryLoc = await getLocationIdByName(rest);
        if (tryLoc != null) {
          debugPrint('MapRepository: encontrado por getLocationIdByName para $rest -> $tryLoc');
          return tryLoc;
        }

        final tryAreaWithRegion = await getLocationAreaIdByName(rest, regionName: maybeRegion);
        if (tryAreaWithRegion != null) {
          debugPrint('MapRepository: encontrado area con region para $rest + $maybeRegion -> $tryAreaWithRegion');
          return tryAreaWithRegion;
        }

        final tryAreaNoRegion = await getLocationAreaIdByName(rest, regionName: null);
        if (tryAreaNoRegion != null) {
          debugPrint('MapRepository: encontrado area sin region para $rest -> $tryAreaNoRegion');
          return tryAreaNoRegion;
        }
      }
    } catch (e) {
      debugPrint('MapRepository: exception trying variants without region -> $e');
    }

    // 4) Último intento: usar las funciones que generan candidatos desde el mismo identifier
    try {
      final byName = await getLocationIdByName(identifier);
      if (byName != null) return byName;
      final byArea = await getLocationAreaIdByName(identifier, regionName: null);
      if (byArea != null) return byArea;
    } catch (e) {
      debugPrint('MapRepository: exception last-resort lookups -> $e');
    }

    // 5) Búsqueda por patrón usando ILIKE (parcial, case-insensitive) como último recurso.
    // Esto permite encontrar entradas que no coinciden exactamente con el identifier
    // pero contienen tokens relevantes, p. ej. 'Route 20', 'route-20', '20'.
    try {
      final ilikePatterns = <String>[];
      // forma original con y sin %
      ilikePatterns.add('%$identifier%');

      // si contiene guiones, probar reemplazando por espacios
      final spaced = identifier.replaceAll('-', ' ');
      if (spaced != identifier) ilikePatterns.add('%$spaced%');

      // tokens separados
      final tokens = identifier.split(RegExp(r"[-\s]+")).where((s) => s.isNotEmpty).toList();
      if (tokens.isNotEmpty) {
        ilikePatterns.add('%${tokens.join(' ')}%');
        ilikePatterns.add('%${tokens.join('-')}%');
        for (final t in tokens) {
          if (t.length > 0) ilikePatterns.add('%$t%');
        }
      }

      // Eliminar duplicados manteniendo el orden
      final seen = <String>{};
      final patterns = ilikePatterns.where((p) => seen.add(p)).toList();

      for (final p in patterns) {
        // Intentar la tabla de locations primero
        try {
          final optionsLikeLoc = QueryOptions(document: gql(GraphQLQueryService.locationByNameLike), variables: {'name': p});
          final resLikeLoc = await client.query(optionsLikeLoc);
          if (!resLikeLoc.hasException && resLikeLoc.data != null) {
            final clean = jsonDecode(jsonEncode(resLikeLoc.data)) as Map<String, dynamic>;
            final data = clean['pokemon_v2_location'] as List<dynamic>? ?? [];
            if (data.isNotEmpty) {
              if (identifier.contains('-')) {
                final maybeRegion = identifier.split('-').first.toLowerCase();
                for (final item in data.cast<Map<String, dynamic>>()) {
                  final region = (item['pokemon_v2_region']?['name'] as String?)?.toLowerCase() ?? '';
                  if (region.contains(maybeRegion)) {
                    debugPrint('MapRepository: ilike match (location) pattern $p -> ${item['name']} id=${item['id']} (region matched $region)');
                    return item['id'] as int?;
                  }
                }
              }
              final first = data.first as Map<String, dynamic>;
              debugPrint('MapRepository: ilike fallback (location) pattern $p -> ${first['name']} id=${first['id']}');
              return first['id'] as int?;
            }
          }
        } catch (e) {
          debugPrint('MapRepository: error ilike location query for $p -> $e');
        }

        // Intentar location area con LIKE
        try {
          final optionsLikeArea = QueryOptions(document: gql(GraphQLQueryService.locationAreaByNameLike), variables: {'name': p});
          final resLikeArea = await client.query(optionsLikeArea);
          if (!resLikeArea.hasException && resLikeArea.data != null) {
            final clean = jsonDecode(jsonEncode(resLikeArea.data)) as Map<String, dynamic>;
            final data = clean['pokemon_v2_locationarea'] as List<dynamic>? ?? [];
            if (data.isNotEmpty) {
              if (identifier.contains('-')) {
                final maybeRegion = identifier.split('-').first.toLowerCase();
                for (final item in data.cast<Map<String, dynamic>>()) {
                  final region = (item['pokemon_v2_location']?['pokemon_v2_region']?['name'] as String?)?.toLowerCase() ?? '';
                  if (region.contains(maybeRegion)) {
                    debugPrint('MapRepository: ilike match (area) pattern $p -> ${item['name']} id=${item['id']} (region matched $region)');
                    return item['id'] as int?;
                  }
                }
              }
              final first = data.first as Map<String, dynamic>;
              debugPrint('MapRepository: ilike fallback (area) pattern $p -> ${first['name']} id=${first['id']}');
              return first['id'] as int?;
            }
          }
        } catch (e) {
          debugPrint('MapRepository: error ilike area query for $p -> $e');
        }
      }
    } catch (e) {
      debugPrint('MapRepository: exception during ilike attempts -> $e');
    }

    debugPrint('MapRepository: getLocationIdByIdentifier no encontró nada para: $identifier');
    return null;
  }

  // Genera variantes de búsqueda a partir del nombre original.
  List<String> _generateCandidates(String name, {String? regionName}) {
    final cleaned = name.trim();
    final noApos = cleaned.replaceAll("'", '');

    final lower = cleaned.toLowerCase();
    final base = _normalize(lower);

    final variants = <String>{};

    // Primero probar exacto y su variante con guiones
    variants.add(base);
    final hyphenated = base.replaceAll(RegExp(r"\s+"), '-');
    if (hyphenated.isNotEmpty && hyphenated != base) {
      variants.add(hyphenated);
    }

    // Añadir variante sin apóstrofe
    final noAposNorm = _normalize(noApos);
    if (noAposNorm.isNotEmpty) variants.add(noAposNorm);

    // Si esto parece una ruta (contiene 'route' o un número final), también añadir variantes con prefijo/sufijo 'sea'
    bool looksLikeRoute = base.contains('route') || RegExp(r"\b\d+\b").hasMatch(base);
    if (looksLikeRoute) {
      // sea + base
      variants.add('sea $base');
      // sea-hyphenated
      if (hyphenated.isNotEmpty) variants.add('sea-$hyphenated');
      // base + sea
      variants.add('$base sea');
      if (hyphenated.isNotEmpty) variants.add('$hyphenated-sea');
      // compacted
      final compact = base.replaceAll(' ', '');
      if (compact.isNotEmpty) {
        variants.add('sea$compact');
        variants.add('${compact}sea');
      }
    }

    // Eliminar sufijos comunes como ' island', ' town', ' city', ' route' y añadir sus variantes cortas
    final suffixes = [' island', ' town', ' city', ' route', ' cave', ' mt', ' mt.', 'islands'];
    for (final suf in suffixes) {
      if (base.endsWith(suf.trim())) {
        final without = base.substring(0, base.length - suf.trim().length).trim();
        if (without.isNotEmpty) {
          variants.add(without);
        }
      }
    }

    // Intentar dividir palabras, p. ej., 'cinnabar island' -> 'cinnabar'
    final parts = base.split(RegExp(r"\s+"));
    final stopWords = {'route', 'ruta', 'island', 'town', 'city', 'cave', 'mt', 'islands', 'road'};
    if (parts.length > 1) {
      for (final p in parts) {
        final part = p.trim();
        if (part.length > 1 && !stopWords.contains(part)) {
          variants.add(part);
        }
      }
    }

    // También probar la variante compacta (sin espacios) como variante exacta
    final noSpaceExact = base.replaceAll(' ', '');
    if (noSpaceExact.isNotEmpty && noSpaceExact != base) {
      variants.add(noSpaceExact);
    }

    // Si se proporciona regionName, agregar variante con el nombre de la región
    if (regionName != null) {
      final regionNorm = _normalize(regionName).replaceAll(' ', '-');
      // prefijo con guion: e.g. 'kanto-route-1'
      variants.add('$regionNorm-$base');
      if (hyphenated.isNotEmpty) variants.add('$regionNorm-$hyphenated');
      if (noAposNorm.isNotEmpty) variants.add('$regionNorm-$noAposNorm');
      // Si ya parece ruta, probar variantes con 'sea' y región: 'kanto-sea-route-20' y 'kanto-route-20-sea'
      if (looksLikeRoute) {
        variants.add('$regionNorm-sea-$base');
        if (hyphenated.isNotEmpty) variants.add('$regionNorm-sea-$hyphenated');
        variants.add('$regionNorm-$base-sea');
        if (hyphenated.isNotEmpty) variants.add('$regionNorm-$hyphenated-sea');
      }
    }

    return variants.toList();
  }

  /// Resuelve el id de location area (location_area) a partir de su nombre.
  /// Devuelve null si no se encuentra. Si se pasa [regionName], prioriza
  /// coincidencias cuya región (pokemon_v2_location.pokemon_v2_region.name)
  /// contenga ese nombre normalizado.
  Future<int?> getLocationAreaIdByName(String name, {String? regionName}) async {
    // Generar candidatos y probarlos en orden hasta que uno devuelva resultados.
    final candidates = _generateCandidates(name, regionName: regionName);
    debugPrint('MapRepository: candidatos generados para "$name" (region: $regionName) -> $candidates');
    final regionNorm = regionName != null ? _normalize(regionName) : null;

    for (final candidate in candidates) {
      debugPrint('MapRepository: probando candidato: $candidate (region filter: $regionName)');

      final options = QueryOptions(
        document: gql(GraphQLQueryService.locationAreaByName),
        variables: {'name': candidate}, // exact match
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
        final candNorm = candidate.toLowerCase();
        return itemName == candNorm || locName == candNorm;
      });

      final finalChoice = chosen ?? exact ?? (data.first is Map<String, dynamic> ? data.first as Map<String, dynamic> : null);

      if (finalChoice == null) {
        debugPrint('MapRepository: finalChoice es null para candidato $candidate, continuar');
        continue;
      }
      // Debug: imprimir elección final para saber por qué se eligió
      try {
        debugPrint('MapRepository: finalChoice para candidato $candidate -> ${jsonEncode(finalChoice)}');
      } catch (e) {
        debugPrint('MapRepository: fallo al imprimir finalChoice -> $e');
      }
      final id = finalChoice['id'] as int?;
      debugPrint('MapRepository: candidato exitoso: $candidate -> id $id (name: ${finalChoice['name']}, location: ${finalChoice['pokemon_v2_location']?['name']}, region: ${finalChoice['pokemon_v2_location']?['pokemon_v2_region']?['name']})');
      return id;
    }

    debugPrint('MapRepository: no se encontró locationArea para: $name (region filter: $regionName)');
    return null;
  }

  /// Wrapper que intenta resolver una ubicación primero como `location` y si
  /// no se encuentra, como `locationarea`. Devuelve un Map con keys:
  /// { 'type': 'location'|'location-area'|'none', 'id': int?, 'name': String? }
  Future<Map<String, dynamic>> resolveLocationOrArea(String name, {String? regionName}) async {
    // Intentar location primero
    final locId = await getLocationIdByName(name);
    if (locId != null) {
      return {'type': 'location', 'id': locId, 'name': name};
    }

    // Intentar locationarea
    final areaId = await getLocationAreaIdByName(name, regionName: regionName);
    if (areaId != null) {
      return {'type': 'location-area', 'id': areaId, 'name': name};
    }

    return {'type': 'none', 'id': null, 'name': name};
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

  /// Obtiene encuentros de Pokémon para una ubicación o área específica.
  Future<List<Encounter>> getEncountersByLocationOrArea(int id, String type) async {
    final query = type == 'location-area' ? GraphQLQueryService.encountersByLocationArea : GraphQLQueryService.encountersByLocation;
    final variables = type == 'location-area' ? {'locationAreaId': id} : {'locationId': id};

    final options = QueryOptions(
      document: gql(query),
      variables: variables,
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
    return [];
  }

  /// Devuelve una lista de coincidencias de location areas para un término.
  /// Cada item es un mapa con keys: 'id', 'name', 'locationName'.
  Future<List<Map<String, dynamic>>> getLocationAreaMatches(String term) async {
    final candidates = _generateCandidates(term);
    final allMatches = <Map<String, dynamic>>{};

    for (final candidate in candidates) {
      final options = QueryOptions(
        document: gql(GraphQLQueryService.locationAreaByName),
        variables: {'name': candidate},
      );

      final result = await client.query(options);
      if (result.hasException) {
        debugPrint('MapRepository: error matches for $candidate -> ${result.exception}');
        continue;
      }

      final raw = result.data;
      if (raw == null) continue;
      final clean = jsonDecode(jsonEncode(raw)) as Map<String, dynamic>;
      final data = clean['pokemon_v2_locationarea'] as List<dynamic>? ?? [];

      for (final item in data) {
        final id = item['id'] as int?;
        if (id != null && !allMatches.any((m) => m['id'] == id)) {
          allMatches.add({
            'id': id,
            'name': item['name'] as String?,
            'locationName': item['pokemon_v2_location']?['name'] as String?,
          });
        }
      }
    }

    debugPrint('MapRepository: getLocationAreaMatches("$term") -> ${allMatches.length} items');
    return allMatches.toList();
  }

  /// Obtiene información básica de varios pokémon por sus IDs.
  Future<List<Pokemon>> getPokemonsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    debugPrint('MapRepository: getPokemonsByIds solicitados -> $ids');

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
      final mapped = PokemonMapperService.mapList(data);
      debugPrint('MapRepository: getPokemonsByIds resultados -> ${mapped.map((p) => p.id).toList()}');
      return mapped;
    } catch (e) {
      debugPrint('MapRepository: fallo al mapear pokemons -> $e');
      // Fallback mínimo
      final fallback = data.map((p) {
        final typesList = (p['pokemon_v2_pokemontypes'] as List<dynamic>?)?.map((t) {
          return (t['pokemon_v2_type']?['name'] as String?) ?? '';
        }).where((s) => s.isNotEmpty).toList() ?? [];

        return Pokemon(
          id: p['id'] as int,
          name: p['name'] as String,
          spriteUrl: null,
          types: typesList,
        );
      }).toList();
      debugPrint('MapRepository: getPokemonsByIds fallback resultados -> ${fallback.map((p) => p.id).toList()}');
      return fallback;
    }
  }
}
