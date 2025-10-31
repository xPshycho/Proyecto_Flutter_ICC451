import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/pokemon.dart';
import '../../core/constants/pokemon_constants.dart';
import '../../core/constants/app_constants.dart';

class PokemonRepository {
  final GraphQLClient client;
  PokemonRepository(this.client);

  // Consultas GraphQL (reemplazan endpoints REST)
  static const String _byIdsQuery = r'''
    query getByIds($ids: [Int!]) {
      pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { id is_legendary is_mythical evolution_chain_id }
      }
    }
  ''';

  static const String _evolutionChainQuery = r'''
    query getEvolutionChain($id: Int!) {
      pokemon_v2_evolutionchain_by_pk(id: $id) {
        id
        baby_trigger_item_id
        pokemonspecies(order_by: {id: asc}) {
          id
          name
          evolves_from_species_id
          evolution_chain_id
          pokemon_v2_pokemons(order_by: {id: asc}) {
            id
            name
            pokemon_v2_pokemonsprites { sprites }
            pokemon_v2_pokemontypes { pokemon_v2_type { name } }
          }
        }
      }
    }
  ''';

  static const String _speciesByIdQuery = r'''
    query getSpecies($id: Int!) {
      pokemon_v2_pokemonspecies_by_pk(id: $id) {
        id
        name
        is_legendary
        is_mythical
        evolution_chain_id
      }
    }
  ''';

  // Query para obtener detalles completos (abilities, stats, sprites, types) por lista de ids
  static const String _detailsByIdsQuery = r'''
    query getDetailsByIds($ids: [Int!]) {
      pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
        id
        name
        height
        weight
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonabilities { pokemon_v2_ability { name } }
        pokemon_v2_pokemonstats { base_stat pokemon_v2_stat { name } }
        pokemon_v2_pokemonspecy { evolution_chain_id }
      }
    }
  ''';

  // Caché de páginas pequeña para evitar refetching de las mismas páginas
  final Map<int, List<Pokemon>> _pageCache = {};

  // Caché global usado para operaciones costosas (filtrado por categorías)
  static List<Pokemon>? _allCache;

  // Caché de detalles por ID para evitar llamadas repetidas (abilities, stats, species)
  final Map<int, Pokemon> _detailsCache = {};

  // Mapa para guardar evolution_chain_id por pokemon id cuando está disponible
  final Map<int, int?> _evolutionChainIdMap = {};

  // Caché de cadenas evolutivas por chainId
  final Map<int, List<Pokemon>> _evolutionChainCache = {};

  // Query para lista de pokémon con tipos y sprites
  static const String _listQuery = r'''
    query getPokemons($limit: Int!, $offset: Int!, $orderBy: [pokemon_v2_pokemon_order_by!]!, $where: pokemon_v2_pokemon_bool_exp) {
      pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: $orderBy, where: $where) {
        id
        name
        pokemon_v2_pokemonsprites {
          sprites
        }
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
      }
    }
  ''';

  // Query para detalles por id
  static const String _detailQuery = r'''
    query getPokemon($id: Int!) {
      pokemon_v2_pokemon_by_pk(id: $id) {
        id
        name
        height
        weight
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonabilities { pokemon_v2_ability { name } }
        pokemon_v2_pokemonstats { base_stat pokemon_v2_stat { name } }
        pokemon_v2_pokemonspecy { evolution_chain_id }
      }
    }
  ''';

  // Helper: asegura que '_allCache' esté poblada (obtener en bloques para evitar una sola petición enorme)
  Future<void> _ensureAllCached() async {
    if (_allCache != null) return;
    final chunk = AppConstants.cacheChunkSize; // tamaño de bloque razonable
    int offset = 0;
    final List<Pokemon> accumulated = [];
    try {
      while (true) {
        final options = QueryOptions(
          document: gql(_listQuery),
          variables: {'limit': chunk, 'offset': offset, 'orderBy': [{'id': 'asc'}]},
          fetchPolicy: FetchPolicy.networkOnly,
        );
        QueryResult result;
        try {
          result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
        } on TimeoutException catch (te) {
          debugPrint('PokemonRepository: timeout GraphQL al cargar bloque en offset $offset: $te');
          break;
        }
        if (result.hasException || result.data == null) {
          debugPrint('PokemonRepository: Error al obtener bloque en offset $offset: ${result.exception}');
          break;
        }
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data == null || data.isEmpty) break;
        final page = _mapFromGraphQL(data);
        accumulated.addAll(page);
        if (page.length < chunk) break; // last page
        offset += chunk;
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error en _ensureAllCached: $e');
      debugPrint('$st');
    }
    _allCache = accumulated;
    debugPrint('PokemonRepository: total cacheado ${_allCache?.length ?? 0} pokémons');
  }

  Future<List<Pokemon>> fetchPokemons({int limit = 20, int offset = 0, List<String>? types, List<String>? regions, List<String>? categories, String? sortBy, bool? ascending}) async {
    // Normalizar categories (trim + eliminar vacíos)
    final normalizedCategories = (categories ?? []).map((c) => c.toString().trim()).where((s) => s.isNotEmpty).toList();
    final bool hasCategories = normalizedCategories.isNotEmpty;

    // Fast-path para categoría exclusiva 'Starter' (case-insensitive)
    if (hasCategories && normalizedCategories.length == 1 && normalizedCategories[0].toLowerCase() == 'starter') {
      // Construir lista de IDs de starters filtrada por regiones si aplica
      final List<int> starterIds = [];
      if (regions != null && regions.isNotEmpty) {
        for (final r in regions) {
          final ids = PokemonConstants.startersByRegion[r];
          if (ids != null) starterIds.addAll(ids);
        }
      } else {
        // todas las regiones
        for (final ids in PokemonConstants.startersByRegion.values) {
          starterIds.addAll(ids);
        }
      }

      final uniqueIds = starterIds.toSet().toList()..sort();
      if (uniqueIds.isEmpty) return [];

      try {
        final options = QueryOptions(document: gql(_byIdsQuery), variables: {'ids': uniqueIds}, fetchPolicy: FetchPolicy.networkOnly);
        final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
        if (!result.hasException && result.data != null) {
          final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
          if (data != null) {
            var list = _mapFromGraphQL(data);
            // aplicar filtro de tipos si corresponde
            if (types != null && types.isNotEmpty) {
              final lower = types.map((t) => t.toLowerCase()).toList();
              list = list.where((p) => p.types.any((t) => lower.contains(t.toLowerCase()))).toList();
            }
            // ordenar
            if (sortBy != null) {
              if (sortBy == 'name') list.sort((a, b) => a.name.compareTo(b.name) * (ascending == true ? 1 : -1));
              else if (sortBy == 'id') list.sort((a, b) => (a.id - b.id) * (ascending == true ? 1 : -1));
            } else {
              list.sort((a, b) => a.id - b.id);
            }

            // paginar
            final start = offset;
            final end = (offset + limit) < list.length ? (offset + limit) : list.length;
            if (start >= list.length) return [];
            return list.sublist(start, end);
          }
        } else {
          debugPrint('PokemonRepository: GraphQL byIds error: ${result.exception}');
        }
      } catch (e, st) {
        debugPrint('PokemonRepository: error fetching starters by ids (graphql): $e');
        debugPrint('$st');
      }
      // Si la query GraphQL por IDs falla, intentar obtener por REST los detalles por id
      try {
        final restList = await _fetchByIdsGraphQL(uniqueIds);
        var list = restList;
        if (types != null && types.isNotEmpty) {
          final lower = types.map((t) => t.toLowerCase()).toList();
          list = list.where((p) => p.types.any((t) => lower.contains(t.toLowerCase()))).toList();
        }
        if (sortBy != null) {
          if (sortBy == 'name') list.sort((a, b) => a.name.compareTo(b.name) * (ascending == true ? 1 : -1));
          else if (sortBy == 'id') list.sort((a, b) => (a.id - b.id) * (ascending == true ? 1 : -1));
        } else {
          list.sort((a, b) => a.id - b.id);
        }
        final start = offset;
        final end = (offset + limit) < list.length ? (offset + limit) : list.length;
        if (start >= list.length) return [];
        return list.sublist(start, end);
      } catch (e, st) {
        debugPrint('PokemonRepository: error fetching starters by ids (alt graphql): $e');
        debugPrint('$st');
      }
      // En caso de fallo total, caemos al flujo normal más abajo
    }

    // If categories requested and not handled by fast-path, determine if we need the full cache.
    if (hasCategories) {
      // Categorías que requieren datos completos (species/detail)
      final Set<String> heavyCats = {'legendario', 'mítico', 'mitico', 'mega', 'gigantamax'};
      final bool needFullCache = normalizedCategories.any((c) => heavyCats.contains(c.toLowerCase()));
      if (needFullCache) {
        await _ensureAllCached();
        var list = List<Pokemon>.from(_allCache ?? []);

        // Apply types filter if present
        if (types != null && types.isNotEmpty) {
          final lower = types.map((t) => t.toLowerCase()).toList();
          list = list.where((p) => p.types.any((t) => lower.contains(t.toLowerCase()))).toList();
        }

        // Apply regions filter if present
        if (regions != null && regions.isNotEmpty) {
          final ranges = regions.map((region) => PokemonConstants.getRegionRange(region)).toList();
          list = list.where((p) => ranges.any((r) => p.id >= r[0] && p.id <= r[1])).toList();
        }

        // Apply category filtering using existing helper
        list = await _filterByCategories(list, normalizedCategories);

        // Sort if requested
        if (sortBy != null) {
          if (sortBy == 'name') {
            list.sort((a, b) => a.name.compareTo(b.name) * (ascending == true ? 1 : -1));
          } else if (sortBy == 'id') {
            list.sort((a, b) => (a.id - b.id) * (ascending == true ? 1 : -1));
          }
        }

        // Paginate after filtering
        final start = offset;
        final end = (offset + limit) < list.length ? (offset + limit) : list.length;
        if (start >= list.length) return [];
        return list.sublist(start, end);
      }
      // Si no requiere full cache, caerá al flujo paginado y aplicará filtros sobre la página
    }

    // No categories: try to serve from page cache
    final cacheKey = offset;
    if (_pageCache.containsKey(cacheKey)) {
      return _pageCache[cacheKey]!;
    }

    // Normal behaviour: query GraphQL for the requested page
    try {
      final orderBy = sortBy != null ? [{sortBy: ascending == true ? 'asc' : 'desc'}] : [{'id': 'asc'}];
      final options = QueryOptions(
        document: gql(_listQuery),
        variables: {'limit': limit, 'offset': offset, 'orderBy': orderBy},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      QueryResult result;
      try {
        result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      } on TimeoutException catch (te) {
        debugPrint('PokemonRepository: timeout GraphQL al cargar página en offset $offset: $te');
        // reintentar con consulta GraphQL alternativa
        final altList = await _fetchPageGraphQL(limit: limit, offset: offset, types: types);
        _pageCache[cacheKey] = altList;
        return altList;
      }

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          var list = _mapFromGraphQL(data);

          // Types filter
          if (types != null && types.isNotEmpty) {
            final lower = types.map((t) => t.toLowerCase()).toList();
            list = list.where((p) => p.types.any((t) => lower.contains(t.toLowerCase()))).toList();
          }

          // Regions filter
          if (regions != null && regions.isNotEmpty) {
            final ranges = regions.map((region) => PokemonConstants.getRegionRange(region)).toList();

            list = list.where((p) => ranges.any((r) => p.id >= r[0] && p.id <= r[1])).toList();
          }

          // Cache this page
          _pageCache[cacheKey] = list;

          debugPrint('PokemonRepository: GraphQL returned ${list.length} items');
          return list;
        }
      } else {
        debugPrint('GraphQL fetch error: ${result.exception}');
      }
    } catch (e, st) {
      debugPrint('GraphQL error: $e');
      debugPrint('$st');
    }

    // Fallback: reintentar con alternativa GraphQL (no se usa REST)
    try {
      final altList = await _fetchPageGraphQL(limit: limit, offset: offset, types: types);
      debugPrint('PokemonRepository: GraphQL (alt) returned ${altList.length} items');
      return altList;
    } catch (e, st) {
      debugPrint('PokemonRepository: error en fallback GraphQL: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<Pokemon> fetchPokemonDetail(int id) async {
    try {
      final options = QueryOptions(document: gql(_detailQuery), variables: {'id': id});
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          final pokemon = _mapSingleFromGraphQL(data);
          // Intentar obtener especies/evolución si existe campo
          try {
            final species = data['pokemon_v2_pokemonspecy'];
            if (species != null && species['evolution_chain_id'] != null) {
              final chainId = species['evolution_chain_id'] as int;
              // obtener cadena evolutiva por GraphQL
              final evols = await _fetchEvolutionChain(chainId);
              return Pokemon(id: pokemon.id, name: pokemon.name, spriteUrl: pokemon.spriteUrl, types: pokemon.types, height: pokemon.height, weight: pokemon.weight, evolutions: evols);
            }
          } catch (_) {}
          return pokemon;
        }
      } else {
        debugPrint('GraphQL detail error: ${result.exception}');
      }
    } catch (e, st) {
      debugPrint('GraphQL detail exception: $e');
      debugPrint('$st');
    }

    // Si GraphQL falla, intentar detalle por GraphQL directo (ya intentado) -> devolver error
    throw Exception('No se pudo obtener detalle de Pokémon por GraphQL');
  }

  // Obtiene la cadena evolutiva desde GraphQL por id de cadena
  Future<List<Pokemon>> _fetchEvolutionChain(int chainId) async {
    // Usar caché si existe
    if (_evolutionChainCache.containsKey(chainId)) return _evolutionChainCache[chainId]!;
    try {
      final options = QueryOptions(document: gql(_evolutionChainQuery), variables: {'id': chainId});
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      if (!result.hasException && result.data != null) {
        final chain = result.data!['pokemon_v2_evolutionchain_by_pk'] as Map<String, dynamic>?;
        if (chain != null && chain['pokemonspecies'] is List) {
          final speciesList = chain['pokemonspecies'] as List<dynamic>;
          final List<Pokemon> out = [];
          for (final sp in speciesList) {
            final pokemons = sp['pokemon_v2_pokemons'] as List<dynamic>?;
            if (pokemons != null) {
              for (final p in pokemons) {
                final spriteList = (p['pokemon_v2_pokemonsprites'] as List<dynamic>?);
                String? spriteUrl;
                if (spriteList != null && spriteList.isNotEmpty) {
                  final spritesJson = spriteList[0]['sprites'];
                  if (spritesJson is String) {
                    try {
                      final decoded = jsonDecode(spritesJson);
                      spriteUrl = decoded['front_default'] as String?;
                    } catch (_) {}
                  } else if (spritesJson is Map) {
                    spriteUrl = spritesJson['front_default'] as String?;
                  }
                }
                final typesList = (p['pokemon_v2_pokemontypes'] as List<dynamic>?);
                final List<String> types = typesList != null
                    ? List<String>.from(typesList.map((t) => (t['pokemon_v2_type']['name'] as String)))
                    : <String>[];
                final pokemon = Pokemon(id: p['id'] as int, name: p['name'] as String, spriteUrl: spriteUrl, types: types);
                out.add(pokemon);
                // Guardar datos mínimos en caché
                _detailsCache[pokemon.id] = _detailsCache[pokemon.id] ?? pokemon;
              }
            }
          }
          _evolutionChainCache[chainId] = out;
          return out;
        }
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error fetching evolution chain via GraphQL: $e');
      debugPrint('$st');
    }
    return [];
  }

  Future<List<Pokemon>> _fetchPageGraphQL({int limit = 20, int offset = 0, List<String>? types}) async {
    // Obtiene una página de pokémon usando GraphQL (reemplaza cualquier fallback REST previo)
    try {
      final options = QueryOptions(
        document: gql(_listQuery),
        variables: {'limit': limit, 'offset': offset, 'orderBy': [{'id': 'asc'}]},
        fetchPolicy: FetchPolicy.networkOnly,
      );
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          var list = _mapFromGraphQL(data);
          if (types != null && types.isNotEmpty) {
            final lowerTypes = types.map((t) => t.toLowerCase()).toList();
            list = list.where((p) => p.types.any((t) => lowerTypes.contains(t.toLowerCase()))).toList();
          }
          return list;
        }
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error fetching page via GraphQL: $e');
      debugPrint('$st');
    }
    return [];
  }

  // Helper GraphQL para obtener pokemons por lista de ids
  Future<List<Pokemon>> _fetchByIdsGraphQL(List<int> ids) async {
    if (ids.isEmpty) return [];
    // Intentar servir desde caché parcial
    final missingIds = <int>[];
    final fromCache = <Pokemon>[];
    for (final id in ids) {
      if (_detailsCache.containsKey(id)) {
        fromCache.add(_detailsCache[id]!);
      } else {
        missingIds.add(id);
      }
    }
    if (missingIds.isEmpty) return fromCache;
    try {
      final options = QueryOptions(document: gql(_byIdsQuery), variables: {'ids': ids}, fetchPolicy: FetchPolicy.networkOnly);
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          final fetched = _mapFromGraphQL(data);
          // Guardar en _detailsCache solo los detalles mínimos si no existen
          for (final p in fetched) {
            _detailsCache[p.id] = _detailsCache[p.id] ?? p;
          }
          return [...fromCache, ...fetched];
        }
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error fetching by ids via GraphQL: $e');
      debugPrint('$st');
    }
    return [];
  }

  // Batch: obtener detalles (abilities, stats, categories) por lista de ids
  Future<List<Pokemon>> _fetchDetailsByIdsGraphQL(List<int> ids) async {
    if (ids.isEmpty) return [];
    // separar ids ya cacheados
    final missingIds = <int>[];
    final fromCache = <Pokemon>[];
    for (final id in ids) {
      final cached = _detailsCache[id];
      if (cached != null) fromCache.add(cached);
      else missingIds.add(id);
    }
    if (missingIds.isEmpty) return fromCache;
    try {
      final options = QueryOptions(document: gql(_detailsByIdsQuery), variables: {'ids': missingIds}, fetchPolicy: FetchPolicy.networkOnly);
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) return _mapDetailedFromGraphQL(data);
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error al obtener detalles por ids vía GraphQL: $e');
      debugPrint('$st');
    }
    return [];
  }

  List<Pokemon> _mapFromGraphQL(List<dynamic> data) {
    return data.map((item) {
      final id = item['id'] as int;
      final name = item['name'] as String;
      final spriteUrl = _getSpriteUrl(item['pokemon_v2_pokemonsprites']);
      final types = _getTypes(item['pokemon_v2_pokemontypes']);
      return Pokemon(id: id, name: name, spriteUrl: spriteUrl, types: types);
    }).toList();
  }

  List<Pokemon> _mapDetailedFromGraphQL(List<dynamic> data) {
    return data.map((item) {
      final id = item['id'] as int;
      final name = item['name'] as String;
      final spriteUrl = _getSpriteUrl(item['pokemon_v2_pokemonsprites']);
      final types = _getTypes(item['pokemon_v2_pokemontypes']);
      final height = (item['height'] as num?)?.toDouble();
      final weight = (item['weight'] as num?)?.toDouble();

      // Abilities
      final abilitiesList = <String>[];
      if (item['pokemon_v2_pokemonabilities'] is List) {
        for (final a in item['pokemon_v2_pokemonabilities'] as List<dynamic>) {
          final an = a['pokemon_v2_ability']?['name'];
          if (an != null) abilitiesList.add(an as String);
        }
      }

      // Stats
      final statsMap = <String, int>{};
      if (item['pokemon_v2_pokemonstats'] is List) {
        for (final s in item['pokemon_v2_pokemonstats'] as List<dynamic>) {
          final statName = s['pokemon_v2_stat']?['name'];
          final base = s['base_stat'];
          if (statName != null && base != null) statsMap[statName as String] = (base as int);
        }
      }

      // Categories derived from species (is_legendary, is_mythical)
      List<String>? categories;
      bool? isLegendary;
      bool? isMythical;
      try {
        final specy = item['pokemon_v2_pokemonspecy'];
        if (specy != null) {
          isLegendary = specy['is_legendary'] as bool?;
          isMythical = specy['is_mythical'] as bool?;
          final cats = <String>[];
          if (isLegendary == true) cats.add('legendario');
          if (isMythical == true) cats.add('mitico');
          categories = cats;
        }
      } catch (_) {}

      return Pokemon(
        id: id,
        name: name,
        spriteUrl: spriteUrl,
        types: types,
        height: height,
        weight: weight,
        abilities: abilitiesList,
        stats: statsMap,
        categories: categories,
        isLegendary: isLegendary,
        isMythical: isMythical,
      );
    }).toList();
  }

  String? _getSpriteUrl(dynamic spritesData) {
    if (spritesData == null) return null;
    final spritesList = spritesData is List ? spritesData : [spritesData];
    for (var sprite in spritesList) {
      final url = sprite['sprites']['front_default'];
      if (url != null && url is String) return url;
    }
    return null;
  }

  List<String> _getTypes(dynamic typesData) {
    if (typesData == null) return [];
    final typesList = typesData is List ? typesData : [typesData];
    return typesList.map<String>((t) => t['pokemon_v2_type']['name'] as String).toList();
  }

  Future<List<Pokemon>> _filterByCategories(List<Pokemon> list, List<String> categories) async {
    // Filtrar por categorías usando lógica existente (si aplica)
    final Set<String> catSet = categories.map((c) => c.toLowerCase()).toSet();
    List<Pokemon> filtered = list.where((p) {
      // Si tiene alguna categoría que coincida, incluir
      if (p.categories != null && p.categories!.isNotEmpty) {
        for (final c in p.categories!) {
          if (catSet.contains(c.toLowerCase())) return true;
        }
      }
      return false;
    }).toList();

    // Si hay categorías "pesadas", hacer un segundo filtrado más exhaustivo obteniendo detalles por GraphQL
    final Set<String> heavyCats = {'legendario', 'mítico', 'mitico', 'mega', 'gigantamax'};
    if (catSet.any((c) => heavyCats.contains(c))) {
      // Mejor: hacer una única consulta batch para obtener detalles (abilities, stats, species) y filtrar en memoria
      final ids = filtered.map((p) => p.id).toList();
      final details = await _fetchDetailsByIdsGraphQL(ids);
      final Map<int, Pokemon> byId = {for (var d in details) d.id: d};
      filtered = filtered.where((p) {
        final d = byId[p.id];
        if (d == null) return false;
        if (d.categories != null && d.categories!.isNotEmpty) {
          for (final c in d.categories!) {
            if (catSet.contains(c.toLowerCase())) return true;
          }
        }
        return false;
      }).toList();
    }

    return filtered;
  }
}
