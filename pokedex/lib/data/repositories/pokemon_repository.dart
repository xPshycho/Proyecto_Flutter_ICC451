import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonRepository {
  final GraphQLClient client;
  PokemonRepository(this.client);

  // Small page cache to avoid refetching the same pages
  final Map<int, List<Pokemon>> _pageCache = {};

  // Global cache used for expensive operations (category filtering)
  static List<Pokemon>? _allCache;

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
        pokemon_v2_pokemonsprites {
          sprites
        }
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
        pokemon_v2_pokemonspecy {
          evolution_chain_id
        }
      }
    }
  ''';

  // Helper: ensure '_allCache' is populated (fetch in chunks to avoid single huge request)
  Future<void> _ensureAllCached() async {
    if (_allCache != null) return;
    final chunk = 250; // reasonable chunk size
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
          result = await client.query(options).timeout(const Duration(seconds: 8));
        } on TimeoutException catch (te) {
          debugPrint('PokemonRepository: GraphQL chunk timeout at offset $offset: $te');
          break;
        }
        if (result.hasException || result.data == null) {
          debugPrint('PokemonRepository: Error fetching chunk at offset $offset: ${result.exception}');
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
      debugPrint('PokemonRepository: _ensureAllCached error: $e');
      debugPrint('$st');
    }
    _allCache = accumulated;
    debugPrint('PokemonRepository: cached total ${_allCache?.length ?? 0} pokemons');
  }

  Future<List<Pokemon>> fetchPokemons({int limit = 20, int offset = 0, List<String>? types, List<String>? regions, List<String>? categories, String? sortBy, bool? ascending}) async {
    final bool hasCategories = categories != null && categories.isNotEmpty;

    // If categories requested, ensure we have the full cache so we can filter reliably
    if (hasCategories) {
      await _ensureAllCached();
      var list = List<Pokemon>.from(_allCache ?? []);

      // Apply types filter if present
      if (types != null && types.isNotEmpty) {
        final lower = types.map((t) => t.toLowerCase()).toList();
        list = list.where((p) => p.types.any((t) => lower.contains(t.toLowerCase()))).toList();
      }

      // Apply regions filter if present
      if (regions != null && regions.isNotEmpty) {
        final ranges = regions.map((region) {
          // Convertir región a generación y obtener rango
          switch (region) {
            case 'Kanto': return [1,151];
            case 'Johto': return [152,251];
            case 'Hoenn': return [252,386];
            case 'Sinnoh': return [387,493];
            case 'Teselia': return [494,649];
            case 'Kalos': return [650,721];
            case 'Alola': return [722,809];
            case 'Galar': return [810,905];
            case 'Paldea': return [906,1000];
          }
          return [0,9999];
        }).toList();
        list = list.where((p) => ranges.any((r) => p.id >= r[0] && p.id <= r[1])).toList();
      }

      // Apply category filtering using existing helper
      list = await _filterByCategories(list, categories);

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
        result = await client.query(options).timeout(const Duration(seconds: 8));
      } on TimeoutException catch (te) {
        debugPrint('PokemonRepository: GraphQL page timeout at offset $offset: $te');
        // fallback to REST
        final restList = await _fetchFromRest(limit: limit, offset: offset, types: types);
        _pageCache[cacheKey] = restList;
        return restList;
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
            final ranges = regions.map((region) {
              switch (region) {
                case 'Kanto': return [1,151];
                case 'Johto': return [152,251];
                case 'Hoenn': return [252,386];
                case 'Sinnoh': return [387,493];
                case 'Teselia': return [494,649];
                case 'Kalos': return [650,721];
                case 'Alola': return [722,809];
                case 'Galar': return [810,905];
                case 'Paldea': return [906,1000];
              }
              return [0,9999];
            }).toList();

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

    // Fallback a REST (same as before)
    try {
      final restList = await _fetchFromRest(limit: limit, offset: offset, types: types);
      debugPrint('PokemonRepository: REST returned ${restList.length} items');
      return restList;
    } catch (e, st) {
      debugPrint('REST fallback error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  Future<Pokemon> fetchPokemonDetail(int id) async {
    try {
      final options = QueryOptions(document: gql(_detailQuery), variables: {'id': id});
      final result = await client.query(options);
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          final pokemon = _mapSingleFromGraphQL(data);
          // Intentar obtener especies/evolución si existe campo
          try {
            final species = data['pokemon_v2_pokemonspecy'];
            if (species != null && species['evolution_chain_id'] != null) {
              final chainId = species['evolution_chain_id'] as int;
              // obtener cadena evolutiva por REST (GraphQL no expone chain details fácilmente)
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

    // Fallback REST detail
    final p = await _fetchDetailFromRest(id);
    try {
      // Attempt to fetch evolution chain via REST species endpoint
      final speciesRes = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id'));
      if (speciesRes.statusCode == 200) {
        final sp = jsonDecode(speciesRes.body) as Map<String, dynamic>;
        final chainUrl = sp['evolution_chain']?['url'] as String?;
        if (chainUrl != null) {
          final match = RegExp(r'/evolution-chain/(\d+)/').firstMatch(chainUrl);
          if (match != null) {
            final chainId = int.tryParse(match.group(1) ?? '0') ?? 0;
            if (chainId > 0) {
              final evols = await _fetchEvolutionChain(chainId);
              return Pokemon(id: p.id, name: p.name, spriteUrl: p.spriteUrl, types: p.types, height: p.height, weight: p.weight, evolutions: evols);
            }
          }
        }
      }
    } catch (_) {}

    return p;
  }

  // Obtiene la cadena evolutiva desde PokeAPI REST por id de cadena
  Future<List<Pokemon>> _fetchEvolutionChain(int chainId) async {
    final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/evolution-chain/$chainId'));
    if (res.statusCode != 200) return [];
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final chain = body['chain'] as Map<String, dynamic>?;
    if (chain == null) return [];

    final List<int> ids = [];
    void traverse(node) {
      if (node == null) return;
      final species = node['species'] as Map<String, dynamic>?;
      if (species != null) {
        final url = species['url'] as String?;
        if (url != null) {
          final m = RegExp(r'/pokemon-species/(\d+)/').firstMatch(url);
          if (m != null) ids.add(int.tryParse(m.group(1) ?? '0') ?? 0);
        }
      }
      final evolves = node['evolves_to'] as List<dynamic>?;
      if (evolves != null && evolves.isNotEmpty) {
        for (final e in evolves) { traverse(e); }
      }
    }

    traverse(chain);
    // Obtener detalles de cada id
    final list = await Future.wait(ids.map((id) async {
      try {
        final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
        if (res.statusCode == 200) {
          final db = jsonDecode(res.body) as Map<String, dynamic>;
          final sprite = db['sprites']?['front_default'] as String?;
          final types = (db['types'] as List<dynamic>?)?.map((e) => e['type']['name'] as String).toList() ?? [];
          return Pokemon(id: id, name: db['name'] as String, spriteUrl: sprite, types: types);
        }
      } catch (_) {}
      return Pokemon(id: id, name: 'unknown', spriteUrl: null);
    }));

    return list;
  }

  Future<List<Pokemon>> _fetchFromRest({int limit = 20, int offset = 0, List<String>? types}) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('REST status ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>?;
    if (results == null) return [];

    final list = await Future.wait(results.map((item) async {
      final name = item['name'] as String? ?? '';
      final rawUrl = item['url'] as String? ?? '';
      final match = RegExp(r'/pokemon/(\d+)/').firstMatch(rawUrl);
      int id = 0;
      if (match != null) id = int.tryParse(match.group(1) ?? '0') ?? 0;
      String? spriteUrl;
      List<String> pTypes = [];
      List<String> abilities = [];
      Map<String, int> stats = {};
      int? height;
      int? weight;

      if (id > 0) {
        try {
          final detailRes = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
          if (detailRes.statusCode == 200) {
            final db = jsonDecode(detailRes.body) as Map<String, dynamic>;
            spriteUrl = (db['sprites']?['other']?['official-artwork']?['front_default']) as String?;
            pTypes = (db['types'] as List<dynamic>?)?.map((e) => (e['type']?['name'] as String?) ?? '').where((s) => s.isNotEmpty).toList() ?? [];
            abilities = (db['abilities'] as List<dynamic>?)?.map((e) => (e['ability']?['name'] as String?) ?? '').where((s) => s.isNotEmpty).toList() ?? [];
            if (db['stats'] is List) {
              for (final s in db['stats']) {
                final statName = s['stat']?['name'] as String?;
                final base = s['base_stat'] as int?;
                if (statName != null && base != null) stats[statName] = base;
              }
            }
            height = db['height'] as int?;
            weight = db['weight'] as int?;
          }
        } catch (_) {}
      }

      return Pokemon(id: id, name: name, spriteUrl: spriteUrl, types: pTypes, abilities: abilities, stats: stats, height: height, weight: weight);
    }));

    if (types != null && types.isNotEmpty) {
      final lowerTypes = types.map((t) => t.toLowerCase()).toList();
      return list.where((p) => p.types.any((t) => lowerTypes.contains(t.toLowerCase()))).toList();
    }

    return list;
  }

  Future<Pokemon> _fetchDetailFromRest(int id) async {
    final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
    if (res.statusCode != 200) throw Exception('REST status ${res.statusCode}');
    final db = jsonDecode(res.body) as Map<String, dynamic>;
    final spriteUrl = db['sprites']?['front_default'] as String?;
    final types = (db['types'] as List<dynamic>?)?.map((e) => e['type']['name'] as String).toList() ?? [];
    final abilities = (db['abilities'] as List<dynamic>?)?.map((e) => e['ability']?['name'] as String? ?? '').where((s) => s.isNotEmpty).toList() ?? [];
    final stats = <String, int>{};
    if (db['stats'] is List) {
      for (final s in db['stats']) {
        final statName = s['stat']?['name'] as String?;
        final base = s['base_stat'] as int?;
        if (statName != null && base != null) stats[statName] = base;
      }
    }
    return Pokemon(id: db['id'] as int, name: db['name'] as String, spriteUrl: spriteUrl, types: types, abilities: abilities, stats: stats, height: db['height'] as int?, weight: db['weight'] as int?);
  }

  List<Pokemon> _mapFromGraphQL(List<dynamic> data) {
    return data.map((item) {
      final spriteList = (item['pokemon_v2_pokemonsprites'] as List<dynamic>?);
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

      final typesList = (item['pokemon_v2_pokemontypes'] as List<dynamic>?);
      // Asegurar que types sea List<String>
      final List<String> types = typesList != null
          ? List<String>.from(typesList.map((t) => (t['pokemon_v2_type']['name'] as String)))
          : <String>[];

      return Pokemon(id: item['id'] as int, name: item['name'] as String, spriteUrl: spriteUrl, types: types);
    }).toList();
  }

  Pokemon _mapSingleFromGraphQL(dynamic item) {
    final spriteList = (item['pokemon_v2_pokemonsprites'] as List<dynamic>?);
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

    final typesList = (item['pokemon_v2_pokemontypes'] as List<dynamic>?);
    final List<String> types = typesList != null
        ? List<String>.from(typesList.map((t) => (t['pokemon_v2_type']['name'] as String)))
        : <String>[];

    // abilities and stats may not be present in GraphQL selection; try to read if available
    List<String> abilities = [];
    Map<String, int> stats = {};
    try {
      if (item['pokemon_v2_pokemonabilities'] != null) {
        final ab = item['pokemon_v2_pokemonabilities'] as List<dynamic>;
        abilities = ab.map((a) => a['pokemon_v2_ability']['name'] as String).toList();
      }
    } catch (_) {}

    return Pokemon(id: item['id'] as int, name: item['name'] as String, spriteUrl: spriteUrl, types: types, abilities: abilities, stats: stats);
  }

  // Cache para reducir consultas REST repetidas
  final Map<int, Map<String, dynamic>> _speciesCache = {};
  final Map<int, Map<String, dynamic>> _pokemonDetailCache = {};

  Future<List<Pokemon>> _filterByCategories(List<Pokemon> list, List<String> categories) async {
    final result = <Pokemon>[];

    // Prefetch species and details for all pokemons that are not cached yet
    final idsToFetch = <int>[];
    for (final p in list) {
      if (!_speciesCache.containsKey(p.id) || !_pokemonDetailCache.containsKey(p.id)) {
        idsToFetch.add(p.id);
      }
    }
    if (idsToFetch.isNotEmpty) {
      await _prefetchCaches(idsToFetch);
    }

    for (final p in list) {
      final matches = await _matchesAnyCategory(p, categories);
      if (matches) result.add(p);
    }
    return result;
  }

  // Prefetch species and pokemon details in batches with limited concurrency
  Future<void> _prefetchCaches(List<int> ids) async {
    if (ids.isEmpty) return;
    const int batchSize = 20; // adjust for concurrency
    for (var i = 0; i < ids.length; i += batchSize) {
      final batch = ids.sublist(i, (i + batchSize) > ids.length ? ids.length : (i + batchSize));
      await Future.wait(batch.map((id) async {
        // species
        if (!_speciesCache.containsKey(id)) {
          try {
            final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/$id')).timeout(const Duration(seconds: 6));
            if (res.statusCode == 200) {
              final species = jsonDecode(res.body) as Map<String, dynamic>;
              _speciesCache[id] = species;
            }
          } catch (_) {}
        }
        // detail
        if (!_pokemonDetailCache.containsKey(id)) {
          try {
            final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id')).timeout(const Duration(seconds: 6));
            if (res.statusCode == 200) {
              final detail = jsonDecode(res.body) as Map<String, dynamic>;
              _pokemonDetailCache[id] = detail;
            }
          } catch (_) {}
        }
      }));
    }
  }

  Future<bool> _matchesAnyCategory(Pokemon p, List<String> categories) async {
    // If categories list empty -> true
    if (categories.isEmpty) return true;

    // Fetch species once
    Map<String, dynamic>? species;
    if (_speciesCache.containsKey(p.id)) {
      species = _speciesCache[p.id];
    } else {
      try {
        final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon-species/${p.id}'));
        if (res.statusCode == 200) {
          species = jsonDecode(res.body) as Map<String, dynamic>;
          _speciesCache[p.id] = species;
        }
      } catch (_) {}
    }

    // Fetch pokemon detail if needed (for forms/names)
    Map<String, dynamic>? detail;
    if (_pokemonDetailCache.containsKey(p.id)) {
      detail = _pokemonDetailCache[p.id];
    } else {
      try {
        final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/${p.id}'));
        if (res.statusCode == 200) {
          detail = jsonDecode(res.body) as Map<String, dynamic>;
          _pokemonDetailCache[p.id] = detail;
        }
      } catch (_) {}
    }

    for (final catRaw in categories) {
      final cat = catRaw.trim();
      switch (cat) {
        case 'Legendario':
          if (species != null && species['is_legendary'] == true) return true;
          break;
        case 'Mítico':
        case 'Mitico':
          if (species != null && species['is_mythical'] == true) return true;
          break;
        case 'Mega':
          if (detail != null) {
            final name = (detail['name'] as String?) ?? '';
            if (name.contains('mega')) return true;
            final forms = detail['forms'] as List<dynamic>?;
            if (forms != null && forms.any((f) => (f['name'] as String).contains('mega'))) return true;
          }
          break;
        case 'Gigantamax':
          if (detail != null) {
            final name = (detail['name'] as String?) ?? '';
            if (name.contains('gmax') || name.contains('gigantamax') || name.contains('g-max')) {
              return true;
            }
            final forms = detail['forms'] as List<dynamic>?;
            if (forms != null && forms.any((f) {
              final n = (f['name'] as String?) ?? '';
              return n.contains('gmax') || n.contains('gigantamax') || n.contains('g-max');
            })) {
              return true;
            }
          }
          break;
        case 'Starter':
          if (_isStarter(p.id)) {
            return true;
          }
          break;
        case 'Ultra Bestia':
          if (p.id >= 793 && p.id <= 807) {
            return true;
          }
          break;
        default:
          break;
      }
    }

    return false;
  }

  bool _isStarter(int id) {
    // Lista compacta de starters clásicos por generación (ids)
    const Map<int, List<int>> startersByGen = {
      1: [1,4,7],
      2: [152,155,158],
      3: [252,255,258],
      4: [387,390,393],
      5: [494,497,500],
      6: [650,653,656],
      7: [722,725,728],
      8: [810,813,816],
      9: [906,909,912]
    };

    for (final v in startersByGen.values) {
      if (v.contains(id)) return true;
    }
    return false;
  }
}
