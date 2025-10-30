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
          return _mapSingleFromGraphQL(data);
        }
      } else {
        debugPrint('GraphQL detail error: ${result.exception}');
      }
    } catch (e, st) {
      debugPrint('GraphQL detail exception: $e');
      debugPrint('$st');
    }

    // Fallback REST detail
    return _fetchDetailFromRest(id);
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

    return Pokemon(id: item['id'] as int, name: item['name'] as String, spriteUrl: spriteUrl, types: types);
  }

  Future<List<Pokemon>> _fetchFromRest({int limit = 20, int offset = 0, List<String>? types}) async {
    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon?limit=$limit&offset=$offset');
    final res = await http.get(url);
    if (res.statusCode != 200) throw Exception('REST status ${res.statusCode}');
    final body = jsonDecode(res.body) as Map<String, dynamic>;
    final results = body['results'] as List<dynamic>?;
    if (results == null) return [];

    final list = await Future.wait(results.map((item) async {
      final name = item['name'] as String;
      final rawUrl = item['url'] as String;
      final match = RegExp(r'/pokemon/(\d+)/').firstMatch(rawUrl);
      int id = 0;
      if (match != null) id = int.tryParse(match.group(1) ?? '0') ?? 0;
      final spriteUrl = id > 0 ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/$id.png' : null;
      // Opcional: obtener tipos desde REST por Pokemon detail
      final detail = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
      List<String> types = [];
      if (detail.statusCode == 200) {
        final db = jsonDecode(detail.body) as Map<String, dynamic>;
        final t = (db['types'] as List<dynamic>?)?.map((e) => e['type']['name'] as String).toList() ?? [];
        types = t;
      }
      return Pokemon(id: id, name: name, spriteUrl: spriteUrl, types: types);
    }));

    final filtered = types != null && types.isNotEmpty ? list.where((p) => p.types.any((t) => types.contains(t))).toList() : list;
    return filtered;
  }

  Future<Pokemon> _fetchDetailFromRest(int id) async {
    final res = await http.get(Uri.parse('https://pokeapi.co/api/v2/pokemon/$id'));
    if (res.statusCode != 200) throw Exception('REST status ${res.statusCode}');
    final db = jsonDecode(res.body) as Map<String, dynamic>;
    final spriteUrl = (db['sprites']?['other']?['official-artwork']?['front_default']) as String?;
    final types = (db['types'] as List<dynamic>?)?.map((e) => e['type']['name'] as String).toList() ?? [];
    return Pokemon(id: db['id'] as int, name: db['name'] as String, spriteUrl: spriteUrl, types: types);
  }
}
