import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import '../models/pokemon.dart';

class PokemonRepository {
  final GraphQLClient client;
  PokemonRepository(this.client);

  // Query para lista de pokémon con tipos y sprites
  static const String _listQuery = r'''
    query getPokemons($limit: Int!, $offset: Int!) {
      pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: {id: asc}) {
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

  Future<List<Pokemon>> fetchPokemons({int limit = 20, int offset = 0, List<String>? types, int? generation}) async {
    // Intento GraphQL primero
    try {
      final options = QueryOptions(
        document: gql(_listQuery),
        variables: {'limit': limit, 'offset': offset},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final result = await client.query(options);
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          var list = _mapFromGraphQL(data);
          debugPrint('PokemonRepository: GraphQL returned ${list.length} items');
          // Aplicar filtros locales si GraphQL no los soporta directamente
          if (types != null && types.isNotEmpty) {
            list = list.where((p) => p.types.any((t) => types.contains(t.toLowerCase()))).toList();
            debugPrint('PokemonRepository: after type filter ${list.length} items');
          }
          // Nota: generación no está implementada en el GraphQL público; fallback a REST si necesario
          return list;
        }
      } else {
        debugPrint('GraphQL fetch error: ${result.exception}');
      }
    } catch (e, st) {
      debugPrint('GraphQL error: $e');
      debugPrint('$st');
    }

    // Fallback a REST
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
          final sprite = (db['sprites']?['other']?['official-artwork']?['front_default']) as String?;
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
    final spriteUrl = (db['sprites']?['other']?['official-artwork']?['front_default']) as String?;
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
}
