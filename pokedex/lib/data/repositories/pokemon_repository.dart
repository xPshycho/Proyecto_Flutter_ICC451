import 'dart:async';
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

  // Query para obtener forms (variantes) por lista de pokemon ids
  static const String _formsByPokemonIdsQuery = r'''
    query getFormsByPokemonIds($ids: [Int!]) {
      pokemon_v2_pokemonform(where: {pokemon_id: {_in: $ids}}) {
        id
        pokemon_id
        name
        form_name
        is_default
        is_battle_only
        is_mega
      }
    }
  ''';

  // Query específica para obtener mega evoluciones
  static const String _megaEvolutionsQuery = r'''
    query getMegaEvolutions($pokemonId: Int!) {
      pokemon_v2_pokemonform(where: {pokemon_id: {_eq: $pokemonId}, is_mega: {_eq: true}}) {
        id
        pokemon_id
        name
        form_name
        is_default
        is_battle_only
        is_mega
      }
    }
  ''';

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
        pokemon_v2_pokemonspecy {
          evolution_chain_id
          pokemon_v2_pokemonspeciesflavortexts(where: {language_id: {_eq: 9}}, limit: 1) {
            flavor_text
          }
        }
      }
    }
  ''';

  // Query para obtener cadena evolutiva por id
  static const String _evolutionChainQuery = r'''
    query getEvolutionChain($id: Int!) {
      pokemon_v2_evolutionchain_by_pk(id: $id) {
        id
        baby_trigger_item_id
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
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

  // Query auxiliar: obtener pokemons asociados a una especie (por si la relación no viene anidada)
  static const String _pokemonsBySpeciesQuery = r'''
    query getPokemonsBySpecies($speciesId: Int!) {
      pokemon_v2_pokemon(where: {pokemon_v2_pokemonspecy: {id: {_eq: $speciesId}}}, order_by: {id: asc}) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      }
    }
  ''';

  // Query de test para verificar formas disponibles
  static const String _testMegaFormsQuery = r'''
    query getTestMegaForms {
      pokemon_v2_pokemonform(limit: 20) {
        id
        pokemon_id
        name
        form_name
        is_mega
        is_default
      }
    }
  ''';

  // Query para búsqueda por nombre
  static const String _searchByNameQuery = r'''
    query searchPokemonByName($name: String!, $limit: Int!, $offset: Int!) {
      pokemon_v2_pokemon(
        where: {name: {_ilike: $name}}, 
        limit: $limit, 
        offset: $offset,
        order_by: {id: asc}
      ) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { id is_legendary is_mythical evolution_chain_id }
      }
    }
  ''';

  // Caché de páginas pequeña para evitar refetching de las mismas páginas
  final Map<int, List<Pokemon>> _pageCache = {};

  // Caché global usado para operaciones costosas (filtrado por categorías)
  static List<Pokemon>? _allCache;

  // Caché de detalles por ID para evitar llamadas repetidas (abilities, stats, species)
  final Map<int, Pokemon> _detailsCache = {};

  // Caché de cadenas evolutivas por chainId
  final Map<int, List<Pokemon>> _evolutionChainCache = {};

  // Caché de forms por pokemon id
  final Map<int, List<dynamic>> _formsCache = {};

  // Flag para test de mega evoluciones
  bool _testDone = false;

  /// Limpia el caché del cliente GraphQL
  Future<void> clearGraphQLCache() async {
    try {
      client.cache.store.reset();
      debugPrint('GraphQL cache cleared successfully');
    } catch (e) {
      debugPrint('Error clearing GraphQL cache: $e');
    }
  }

  /// Verifica si un Pokémon es una forma regional/especial basado en su ID
  bool _isRegionalOrSpecialForm(int id) {
    // Los IDs superiores a 10000 generalmente son formas regionales/especiales
    return id > 10000;
  }

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
              if (sortBy == 'name') {
                list.sort((a, b) => a.name.compareTo(b.name) * (ascending == true ? 1 : -1));
              } else if (sortBy == 'id') {
                list.sort((a, b) => (a.id - b.id) * (ascending == true ? 1 : -1));
              }
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
          if (sortBy == 'name') {
            list.sort((a, b) => a.name.compareTo(b.name) * (ascending == true ? 1 : -1));
          } else if (sortBy == 'id') {
            list.sort((a, b) => (a.id - b.id) * (ascending == true ? 1 : -1));
          }
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

  /// Verifica si un error es relacionado con problemas de caché
  bool _isCacheRelatedError(Object error) {
    final errorString = error.toString().toLowerCase();
    return errorString.contains('cachemiss') ||
           errorString.contains('cache.readquery') ||
           errorString.contains('round trip cache');
  }

  /// Obtiene detalles completos de un Pokémon incluyendo evoluciones y formas
  Future<Pokemon> fetchPokemonDetail(int id) async {
    // Test de mega evoluciones solo la primera vez
    if (!_testDone) {
      _testDone = true;
      await testMegaEvolutions();
      await testSpecificPokemonForms();
    }

    // Verificar si ya está en caché y retornarlo directamente
    if (_detailsCache.containsKey(id)) {
      debugPrint('Returning cached Pokemon for ID: $id');
      final cachedPokemon = _detailsCache[id]!;

      // Si el Pokemon cacheado tiene datos completos, devolverlo
      if (cachedPokemon.abilities != null && cachedPokemon.abilities!.isNotEmpty) {
        return cachedPokemon;
      }
    }

    try {
      final options = QueryOptions(
        document: gql(_detailQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork, // Intentar caché primero, luego red
        errorPolicy: ErrorPolicy.all, // Manejar errores de manera más flexible
      );

      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          return await _processDetailedPokemon(data, id);
        }
      }

      // Si hay errores de caché pero tenemos datos, intentar procesarlos
      if (result.exception != null && result.data != null) {
        debugPrint('GraphQL cache warning for ID $id: ${result.exception}');
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          return await _processDetailedPokemon(data, id);
        }
      }

      debugPrint('GraphQL detail error for ID $id: ${result.exception}');

      // Si es un error de caché, limpiar automáticamente y reintentar
      if (result.exception != null && _isCacheRelatedError(result.exception!)) {
        debugPrint('Cache-related error detected, clearing cache and retrying...');
        await clearGraphQLCache();
        return await _fetchPokemonDetailFallback(id);
      }

      // Fallback: intentar sin caché
      return await _fetchPokemonDetailFallback(id);

    } catch (e, st) {
      debugPrint('GraphQL detail exception for ID $id: $e');
      debugPrint('$st');

      // Si es un error de caché, limpiar automáticamente y reintentar
      if (_isCacheRelatedError(e)) {
        debugPrint('Cache-related exception detected, clearing cache and retrying...');
        await clearGraphQLCache();
        return await _fetchPokemonDetailFallback(id);
      }

      // Fallback: intentar sin caché
      return await _fetchPokemonDetailFallback(id);
    }
  }

  /// Fallback para obtener detalles de Pokémon sin usar caché
  Future<Pokemon> _fetchPokemonDetailFallback(int id) async {
    try {
      debugPrint('Attempting fallback fetch for Pokemon ID: $id');

      final options = QueryOptions(
        document: gql(_detailQuery),
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.ignore, // Ignorar errores de caché
      );

      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds * 2));

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          return await _processDetailedPokemon(data, id);
        }
      }

      debugPrint('Fallback also failed for ID $id: ${result.exception}');
    } catch (e) {
      debugPrint('Fallback exception for ID $id: $e');
    }

    throw Exception('No se pudo obtener detalle de Pokémon ID: $id');
  }

  /// Procesa los datos detallados de un Pokémon desde GraphQL
  Future<Pokemon> _processDetailedPokemon(Map<String, dynamic> data, int id) async {
    var pokemon = _mapSingleFromGraphQL(data);

    // Obtener descripción si existe
    try {
      final specy = data['pokemon_v2_pokemonspecy'];
      if (specy != null && specy['pokemon_v2_pokemonspeciesflavortexts'] is List) {
        final texts = specy['pokemon_v2_pokemonspeciesflavortexts'] as List<dynamic>;
        if (texts.isNotEmpty) {
          final ft = texts[0]['flavor_text'] as String?;
          if (ft != null && ft.trim().isNotEmpty) {
            final cleaned = ft.replaceAll('\n', ' ').replaceAll('\f', ' ').trim();
            pokemon = pokemon.copyWith(description: cleaned);
          }
        }
      }
    } catch (e) {
      debugPrint('Error processing description for ID $id: $e');
    }

    // Obtener formas del pokemon
    List<dynamic> forms = [];
    try {
      final formsData = await _fetchFormsByPokemonIds([pokemon.id]);
      forms = formsData[pokemon.id] ?? [];
    } catch (e) {
      debugPrint('Error fetching forms for ID $id: $e');
    }

    // Obtener cadena evolutiva completa
    List<Pokemon>? evolutions;
    try {
      final species = data['pokemon_v2_pokemonspecy'];
      if (species != null && species['evolution_chain_id'] != null) {
        final chainId = species['evolution_chain_id'] as int;
        evolutions = await _fetchEvolutionChain(chainId);
        debugPrint('Fetched ${evolutions.length} evolutions for Pokemon ${pokemon.name}');
      }
    } catch (e) {
      debugPrint('Error fetching evolution chain for ID $id: $e');
    }

    // Crear el Pokemon final con todas las propiedades
    final finalPokemon = Pokemon(
      id: pokemon.id,
      name: pokemon.name,
      spriteUrl: pokemon.spriteUrl,
      types: pokemon.types,
      height: pokemon.height,
      weight: pokemon.weight,
      abilities: pokemon.abilities,
      stats: pokemon.stats,
      categories: pokemon.categories,
      isLegendary: pokemon.isLegendary,
      isMythical: pokemon.isMythical,
      evolutions: evolutions,
      forms: forms,
      description: pokemon.description,
    );

    // Actualizar caché con datos completos
    _detailsCache[id] = finalPokemon;

    debugPrint('Final Pokemon ${finalPokemon.name}: evolutions=${finalPokemon.evolutions?.length}, forms=${finalPokemon.forms?.length}');
    return finalPokemon;
  }

  /// Obtiene la cadena evolutiva completa desde GraphQL
  Future<List<Pokemon>> _fetchEvolutionChain(int chainId) async {
    // Usar caché si existe
    if (_evolutionChainCache.containsKey(chainId)) {
      return _evolutionChainCache[chainId]!;
    }

    try {
      final options = QueryOptions(document: gql(_evolutionChainQuery), variables: {'id': chainId});
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));

      if (!result.hasException && result.data != null) {
        final chain = result.data!['pokemon_v2_evolutionchain_by_pk'] as Map<String, dynamic>?;
        if (chain != null && chain['pokemon_v2_pokemonspecies'] is List) {
          final speciesList = chain['pokemon_v2_pokemonspecies'] as List<dynamic>;
          debugPrint('PokemonRepository: evolution chain (graphql) returned ${speciesList.length} species for chainId $chainId');

          final List<Pokemon> evolutionChain = [];

          for (final species in speciesList) {
            var pokemons = species['pokemon_v2_pokemons'] as List<dynamic>?;

            // Si no hay pokémons directamente, buscarlos por species id
            if (pokemons == null || pokemons.isEmpty) {
              try {
                final speciesId = species['id'] as int?;
                if (speciesId != null) {
                  final opts = QueryOptions(document: gql(_pokemonsBySpeciesQuery), variables: {'speciesId': speciesId});
                  final res2 = await client.query(opts).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
                  if (!res2.hasException && res2.data != null) {
                    pokemons = res2.data!['pokemon_v2_pokemon'] as List<dynamic>?;
                  }
                }
              } catch (_) {}
            }

            if (pokemons != null) {
              for (final pokemonData in pokemons) {
                final spriteUrl = _getSpriteUrl(pokemonData['pokemon_v2_pokemonsprites']);
                final types = _getTypes(pokemonData['pokemon_v2_pokemontypes']);

                final pokemon = Pokemon(
                  id: pokemonData['id'] as int,
                  name: pokemonData['name'] as String,
                  spriteUrl: spriteUrl,
                  types: types,
                );

                evolutionChain.add(pokemon);

                // Guardar datos mínimos en caché
                _detailsCache[pokemon.id] = _detailsCache[pokemon.id] ?? pokemon;
              }
            }
          }

          // Obtener formas en batch para todos los pokémons de la cadena
          final pokemonIds = evolutionChain.map((p) => p.id).toList();
          try {
            final formsMap = await _fetchFormsByPokemonIds(pokemonIds);

            // Adjuntar formas a cada Pokemon
            final withForms = evolutionChain.map((p) {
              final forms = formsMap[p.id] ?? [];
              return p.copyWith(forms: forms);
            }).toList();

            _evolutionChainCache[chainId] = withForms;
            debugPrint('PokemonRepository: Cached ${withForms.length} evolutions for chain $chainId');
            return withForms;
          } catch (_) {
            _evolutionChainCache[chainId] = evolutionChain;
            debugPrint('PokemonRepository: Cached ${evolutionChain.length} evolutions for chain $chainId (no forms)');
            return evolutionChain;
          }
        } else {
          debugPrint('PokemonRepository: No species found in evolution chain $chainId');
        }
      } else {
        debugPrint('PokemonRepository: GraphQL error fetching evolution chain: ${result.exception}');
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
    if (ids.isEmpty) {
      return [];
    }
    // separar ids ya cacheados
    final missingIds = <int>[];
    final fromCache = <Pokemon>[];
    for (final id in ids) {
      final cached = _detailsCache[id];
      if (cached != null) {
        fromCache.add(cached);
      } else {
        missingIds.add(id);
      }
    }
    if (missingIds.isEmpty) {
      return fromCache;
    }
    try {
      final options = QueryOptions(document: gql(_detailsByIdsQuery), variables: {'ids': missingIds}, fetchPolicy: FetchPolicy.networkOnly);
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));
      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          return _mapDetailedFromGraphQL(data);
        }
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error al obtener detalles por ids vía GraphQL: $e');
      debugPrint('$st');
    }
    return [];
  }

  /// Obtiene las formas/variantes para una lista de pokemon ids en batch
  /// Devuelve un mapa pokemonId -> lista de PokemonForm
  Future<Map<int, List<dynamic>>> _fetchFormsByPokemonIds(List<int> ids) async {
    final result = <int, List<dynamic>>{};
    if (ids.isEmpty) return result;

    final missing = <int>[];
    for (final id in ids) {
      if (_formsCache.containsKey(id)) {
        result[id] = _formsCache[id]!;
      } else {
        missing.add(id);
      }
    }
    if (missing.isEmpty) return result;

    debugPrint('Fetching forms for Pokemon IDs: $missing');

    try {
      final options = QueryOptions(document: gql(_formsByPokemonIdsQuery), variables: {'ids': missing});
      final res = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));

      if (!res.hasException && res.data != null) {
        final data = res.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        debugPrint('Received ${data?.length ?? 0} forms from GraphQL');

        if (data != null) {
          for (final formData in data) {
            final pokemonId = formData['pokemon_id'] as int;

            // Crear PokemonForm desde los datos GraphQL
            final form = _createPokemonFormFromGraphQL(formData);

            final list = result[pokemonId] ?? <dynamic>[];
            list.add(form);
            result[pokemonId] = list;

            debugPrint('Added form for Pokemon $pokemonId: ${form['name']} (is_mega: ${form['is_mega']})');
          }

          // Cachear los resultados
          for (final id in missing) {
            _formsCache[id] = result[id] ?? [];
            if (result[id]?.isNotEmpty == true) {
              debugPrint('Cached ${result[id]!.length} forms for Pokemon $id');
            }
          }
        }
      } else {
        debugPrint('GraphQL error fetching forms: ${res.exception}');
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error fetching forms by ids: $e');
      debugPrint('$st');
    }

    return result;
  }

  /// Crea un objeto PokemonForm desde datos GraphQL
  dynamic _createPokemonFormFromGraphQL(Map<String, dynamic> formData) {
    try {
      debugPrint('Creating form from data: ${formData.toString()}');

      final form = {
        'id': formData['id'] as int,
        'pokemon_id': formData['pokemon_id'] as int,
        'name': formData['name'] as String?,
        'form_name': formData['form_name'] as String?,
        'is_default': (formData['is_default'] as bool?) ?? false,
        'is_battle_only': (formData['is_battle_only'] as bool?) ?? false,
        'is_mega': formData['is_mega'] as bool?,
        'sprite_url': null, // Por ahora sin sprites para debugging
        'types': <String>[], // Por ahora sin tipos para debugging
      };

      debugPrint('Created form: ${form.toString()}');
      return form;
    } catch (e) {
      debugPrint('Error creating PokemonForm: $e');
      return formData; // Fallback a datos originales
    }
  }

  /// Extrae tipos de un objeto pokemon en los datos de forma
  List<String> _getTypesFromPokemon(dynamic pokemonData) {
    if (pokemonData == null) return [];
    try {
      final types = pokemonData['pokemon_v2_pokemontypes'] as List<dynamic>?;
      if (types != null) {
        return types.map((t) => t['pokemon_v2_type']['name'] as String).toList();
      }
    } catch (_) {}
    return [];
  }

  /// Obtiene específicamente las mega evoluciones de un Pokémon
  Future<List<dynamic>> fetchMegaEvolutions(int pokemonId) async {
    try {
      final options = QueryOptions(
        document: gql(_megaEvolutionsQuery),
        variables: {'pokemonId': pokemonId}
      );
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        if (data != null) {
          return data.map((formData) => _createPokemonFormFromGraphQL(formData)).toList();
        }
      }
    } catch (e, st) {
      debugPrint('PokemonRepository: error fetching mega evolutions: $e');
      debugPrint('$st');
    }

    return [];
  }

  /// Función de test para verificar mega evoluciones disponibles
  Future<void> testMegaEvolutions() async {
    try {
      final options = QueryOptions(document: gql(_testMegaFormsQuery));
      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        debugPrint('Test: Found ${data?.length ?? 0} total forms in database');
        if (data != null) {
          int megaCount = 0;
          int regionalCount = 0;
          int specialCount = 0;

          for (final form in data) {
            final formName = form['name'] ?? '';
            final isMega = form['is_mega'] as bool? ?? false;
            final isDefault = form['is_default'] as bool? ?? false;

            if (!isDefault) {
              debugPrint('Test form: $formName (is_mega: $isMega)');

              if (isMega) {
                megaCount++;
              } else if (formName.contains('alola') || formName.contains('galar') ||
                        formName.contains('hisui') || formName.contains('paldea')) {
                regionalCount++;
              } else {
                specialCount++;
              }
            }
          }

          debugPrint('Test summary: $megaCount mega, $regionalCount regional, $specialCount special forms');
        }
      } else {
        debugPrint('Test: Error fetching forms: ${result.exception}');
      }
    } catch (e) {
      debugPrint('Test: Exception fetching forms: $e');
    }
  }

  /// Busca Pokémon por nombre usando GraphQL
  Future<List<Pokemon>> searchPokemonByName(String query, {int limit = 20, int offset = 0}) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      final searchPattern = '%${query.toLowerCase()}%';
      final options = QueryOptions(
        document: gql(_searchByNameQuery),
        variables: {
          'name': searchPattern,
          'limit': limit,
          'offset': offset,
        }
      );

      final result = await client.query(options).timeout(Duration(seconds: AppConstants.graphqlTimeoutSeconds));

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          debugPrint('Search: Found ${data.length} Pokémon for query "$query"');
          return _mapDetailedFromGraphQL(data);
        }
      } else {
        debugPrint('Search error: ${result.exception}');
      }
    } catch (e, st) {
      debugPrint('Search exception: $e');
      debugPrint('$st');
    }

    return [];
  }

  /// Obtiene Pokémon específicos para testing (Charizard, Mewtwo, etc.)
  Future<void> testSpecificPokemonForms() async {
    final testIds = [6, 150, 26, 103, 94]; // Charizard, Mewtwo, Raichu, Exeggutor, Gengar

    for (final id in testIds) {
      try {
        final pokemon = await fetchPokemonDetail(id);
        debugPrint('Test Pokemon ${pokemon.name}: ${pokemon.forms?.length ?? 0} forms found');
        if (pokemon.forms != null && pokemon.forms!.isNotEmpty) {
          for (final form in pokemon.forms!) {
            if (form is Map<String, dynamic>) {
              final name = form['name'] ?? form['form_name'] ?? 'Unknown';
              final isMega = form['is_mega'] ?? false;
              debugPrint('  Form: $name (is_mega: $isMega)');
            }
          }
        }
      } catch (e) {
        debugPrint('Error testing Pokemon $id: $e');
      }
    }
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

  // Mapea un solo objeto GraphQL a Pokemon reutilizando la lógica existente
  Pokemon _mapSingleFromGraphQL(Map<String, dynamic> item) {
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

    // Species-derived categories
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

    final pokemon = Pokemon(
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

    // cache minimal
    _detailsCache[id] = _detailsCache[id] ?? pokemon;
    return pokemon;
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
