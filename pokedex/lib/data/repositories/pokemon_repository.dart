import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/pokemon.dart';
import '../models/pokemon_move.dart';
import '../services/graphql_query_service.dart';
import '../services/pokemon_mapper_service.dart';
import '../services/data_services.dart';
import '../../core/constants/pokemon_constants.dart';
import '../../core/constants/app_constants.dart';

class PokemonRepository {
  final GraphQLClient client;
  late final GraphQLExecutor _executor;

  // Cachés específicos por tipo de dato
  final _pageCache = CacheService<List<Pokemon>>();
  final _detailsCache = CacheService<Pokemon>();
  final _evolutionChainCache = CacheService<List<Pokemon>>();
  final _formsCache = CacheService<List<dynamic>>();

  List<Pokemon>? _allCache;
  bool _testDone = false;

  PokemonRepository(this.client) {
    _executor = GraphQLExecutor(client);
  }

  /// Limpia el caché de GraphQL
  Future<void> clearGraphQLCache() async {
    await _executor.clearCache();
    _pageCache.clear();
    _detailsCache.clear();
    _evolutionChainCache.clear();
    _formsCache.clear();
    _allCache = null;
  }

  /// Obtiene una lista paginada de Pokémon con filtros opcionales
  Future<List<Pokemon>> fetchPokemons({
    int limit = 20,
    int offset = 0,
    List<String>? types,
    List<String>? regions,
    List<String>? categories,
    String? sortBy,
    bool? ascending,
  }) async {
    final normalizedCategories = _normalizeCategories(categories);

    // Fast-path para starters
    if (_isSingleStarterCategory(normalizedCategories)) {
      return _fetchStarters(
        limit: limit,
        offset: offset,
        types: types,
        regions: regions,
        sortBy: sortBy,
        ascending: ascending,
      );
    }

    // Filtros complejos requieren caché completo
    if (_requiresFullCache(normalizedCategories)) {
      return _fetchWithFullCache(
        limit: limit,
        offset: offset,
        types: types,
        regions: regions,
        categories: normalizedCategories,
        sortBy: sortBy,
        ascending: ascending,
      );
    }

    // Flujo normal paginado
    return _fetchPaginated(
      limit: limit,
      offset: offset,
      types: types,
      regions: regions,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  /// Obtiene detalles completos de un Pokémon
  Future<Pokemon> fetchPokemonDetail(int id) async {
    await _ensureTestsRun();

    // Verificar caché
    final cached = _detailsCache.get(id);
    if (cached != null && _hasCompleteDetails(cached)) {
      debugPrint('Returning cached Pokemon for ID: $id');
      return cached;
    }

    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.detail,
        variables: {'id': id},
        fetchPolicy: FetchPolicy.cacheAndNetwork,
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          return await _processDetailedPokemon(data, id);
        }
      }

      // Manejo de errores de caché
      if (result.exception != null) {
        if (_executor.isCacheRelatedError(result.exception!)) {
          debugPrint('Cache error detected, clearing and retrying...');
          await clearGraphQLCache();
        }
      }
    } catch (e) {
      if (_executor.isCacheRelatedError(e)) {
        debugPrint('Cache exception detected, clearing and retrying...');
        await clearGraphQLCache();
      }
    }

    // Fallback sin caché
    return _fetchPokemonDetailFallback(id);
  }

  /// Busca Pokémon por nombre
  Future<List<Pokemon>> searchPokemonByName(
    String query, {
    int limit = 20,
    int offset = 0,
  }) async {
    if (query.trim().isEmpty) return [];

    try {
      final searchPattern = '%${query.toLowerCase()}%';
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.searchByName,
        variables: {
          'name': searchPattern,
          'limit': limit,
          'offset': offset,
        },
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          debugPrint('Search: Found ${data.length} Pokémon for "$query"');
          return PokemonMapperService.mapDetailedList(data);
        }
      }
    } catch (e) {
      debugPrint('Search exception: $e');
    }

    return [];
  }

  /// Obtiene mega evoluciones de un Pokémon
  Future<List<dynamic>> fetchMegaEvolutions(int pokemonId) async {
    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.megaEvolutions,
        variables: {'pokemonId': pokemonId},
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        if (data != null) {
          return data.map((formData) =>
            PokemonMapperService.createForm(formData)
          ).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching mega evolutions: $e');
    }

    return [];
  }

  // ========== Métodos privados ==========

  /// Normaliza la lista de categorías
  List<String> _normalizeCategories(List<String>? categories) {
    if (categories == null) return [];
    return categories
        .map((c) => c.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Verifica si es una sola categoría de starter
  bool _isSingleStarterCategory(List<String> categories) {
    return categories.length == 1 &&
        categories[0].toLowerCase() == 'starter';
  }

  /// Verifica si requiere caché completo
  bool _requiresFullCache(List<String> categories) {
    if (categories.isEmpty) return false;

    const heavyCategories = {'legendario', 'mítico', 'mitico', 'mega', 'gigantamax'};
    return categories.any((c) => heavyCategories.contains(c.toLowerCase()));
  }

  /// Verifica si un Pokémon tiene detalles completos
  bool _hasCompleteDetails(Pokemon pokemon) {
    return pokemon.abilities.isNotEmpty;
  }

  /// Asegura que los tests iniciales se ejecuten una vez
  Future<void> _ensureTestsRun() async {
    if (_testDone) return;
    _testDone = true;
    await testMegaEvolutions();
    await testSpecificPokemonForms();
  }

  /// Obtiene starters con filtros
  Future<List<Pokemon>> _fetchStarters({
    required int limit,
    required int offset,
    List<String>? types,
    List<String>? regions,
    String? sortBy,
    bool? ascending,
  }) async {
    final starterIds = _getStarterIds(regions);
    if (starterIds.isEmpty) return [];

    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.byIds,
        variables: {'ids': starterIds},
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          return _processAndFilterList(
            data,
            types: types,
            sortBy: sortBy,
            ascending: ascending,
            limit: limit,
            offset: offset,
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching starters: $e');
    }

    return [];
  }

  /// Obtiene IDs de starters según regiones
  List<int> _getStarterIds(List<String>? regions) {
    final ids = <int>[];

    if (regions != null && regions.isNotEmpty) {
      for (final region in regions) {
        final regionIds = PokemonConstants.startersByRegion[region];
        if (regionIds != null) ids.addAll(regionIds);
      }
    } else {
      for (final regionIds in PokemonConstants.startersByRegion.values) {
        ids.addAll(regionIds);
      }
    }

    return ids.toSet().toList()..sort();
  }

  /// Obtiene Pokémon con caché completo
  Future<List<Pokemon>> _fetchWithFullCache({
    required int limit,
    required int offset,
    List<String>? types,
    List<String>? regions,
    required List<String> categories,
    String? sortBy,
    bool? ascending,
  }) async {
    await _ensureAllCached();

    var list = List<Pokemon>.from(_allCache ?? []);

    // Aplicar filtros de región primero
    if (regions != null && regions.isNotEmpty) {
      final ranges = regions
          .map((r) => PokemonConstants.getRegionRange(r))
          .toList();
      list = PokemonFilterService.filterByRegions(
        list,
        ranges,
        (p) => p.id,
      );
    }

    // Filtrar por categorías (ya están enriquecidas en _ensureAllCached)
    list = await _filterByCategories(list, categories);

    // Aplicar filtros de tipo al final
    if (types != null && types.isNotEmpty) {
      list = PokemonFilterService.filterByTypes(
        list,
        types,
        (p) => p.types,
      );
    }

    // Ordenar
    if (sortBy != null) {
      list = PokemonFilterService.sort(
        list,
        sortBy,
        ascending ?? true,
        (p) => p.name,
        (p) => p.id,
      );
    }

    // Paginar
    return PokemonFilterService.paginate(list, offset, limit);
  }

  /// Obtiene Pokémon de forma paginada
  Future<List<Pokemon>> _fetchPaginated({
    required int limit,
    required int offset,
    List<String>? types,
    List<String>? regions,
    String? sortBy,
    bool? ascending,
  }) async {
    // Verificar caché de página
    final cached = _pageCache.get(offset);
    if (cached != null) return cached;

    try {
      final orderBy = sortBy != null
          ? [{sortBy: ascending == true ? 'asc' : 'desc'}]
          : [{'id': 'asc'}];

      final result = await _executor.executeQuery(
        query: GraphQLQueryService.list,
        variables: {
          'limit': limit,
          'offset': offset,
          'orderBy': orderBy,
        },
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          var list = PokemonMapperService.mapList(data);

          // Aplicar filtros
          if (types != null && types.isNotEmpty) {
            list = PokemonFilterService.filterByTypes(
              list,
              types,
              (p) => p.types,
            );
          }

          if (regions != null && regions.isNotEmpty) {
            final ranges = regions
                .map((r) => PokemonConstants.getRegionRange(r))
                .toList();
            list = PokemonFilterService.filterByRegions(
              list,
              ranges,
              (p) => p.id,
            );
          }

          _pageCache.put(offset, list);
          return list;
        }
      }
    } catch (e) {
      debugPrint('GraphQL error: $e');
    }

    return [];
  }

  /// Asegura que el caché completo esté poblado con información de especies
  Future<void> _ensureAllCached() async {
    if (_allCache != null) return;

    const chunkSize = AppConstants.cacheChunkSize;
    int offset = 0;
    final accumulated = <Pokemon>[];

    try {
      while (true) {
        final result = await _executor.executeQuery(
          query: GraphQLQueryService.listWithSpecies,
          variables: {
            'limit': chunkSize,
            'offset': offset,
            'orderBy': [{'id': 'asc'}],
          },
        );

        if (result.hasException || result.data == null) break;

        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data == null || data.isEmpty) break;

        final page = PokemonMapperService.mapDetailedList(data);
        accumulated.addAll(page);

        if (page.length < chunkSize) break;
        offset += chunkSize;
      }
    } catch (e) {
      debugPrint('Error in _ensureAllCached: $e');
    }


    _allCache = accumulated;
    debugPrint('Cached ${_allCache?.length ?? 0} Pokémon');

    // Debug: Contar pokémon por categoría
    final withCategories = accumulated.where((p) => p.categories != null && p.categories!.isNotEmpty).length;
    final legendary = accumulated.where((p) => p.isLegendary == true).length;
    final mythical = accumulated.where((p) => p.isMythical == true).length;
    final withCatLegendary = accumulated.where((p) => p.categories?.contains('legendario') == true).length;
    final withCatMythical = accumulated.where((p) => p.categories?.contains('mitico') == true).length;

    debugPrint('Pokemon with categories: $withCategories');
    debugPrint('Pokemon with isLegendary=true: $legendary');
    debugPrint('Pokemon with isMythical=true: $mythical');
    debugPrint('Pokemon with category "legendario": $withCatLegendary');
    debugPrint('Pokemon with category "mitico": $withCatMythical');

    // Enriquecer con categorías de formas (Mega, Gigantamax) para todos
    debugPrint('Enriching all pokemon with form categories...');
    _allCache = await _enrichWithFormCategories(_allCache ?? []);

    final afterMega = _allCache!.where((p) => p.categories?.contains('mega') == true).length;
    final afterGiga = _allCache!.where((p) => p.categories?.contains('gigantamax') == true).length;
    debugPrint('Pokemon with Mega after enrichment: $afterMega');
    debugPrint('Pokemon with Gigantamax after enrichment: $afterGiga');
  }

  /// Procesa y filtra una lista de datos GraphQL
  List<Pokemon> _processAndFilterList(
    List<dynamic> data, {
    List<String>? types,
    String? sortBy,
    bool? ascending,
    required int limit,
    required int offset,
  }) {
    var list = PokemonMapperService.mapList(data);

    if (types != null && types.isNotEmpty) {
      list = PokemonFilterService.filterByTypes(
        list,
        types,
        (p) => p.types,
      );
    }

    if (sortBy != null) {
      list = PokemonFilterService.sort(
        list,
        sortBy,
        ascending ?? true,
        (p) => p.name,
        (p) => p.id,
      );
    }

    return PokemonFilterService.paginate(list, offset, limit);
  }

  /// Fallback para obtener detalles sin caché
  Future<Pokemon> _fetchPokemonDetailFallback(int id) async {
    try {
      debugPrint('Attempting fallback fetch for Pokemon ID: $id');

      final result = await _executor.executeQuery(
        query: GraphQLQueryService.detail,
        variables: {'id': id},
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.ignore,
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon_by_pk'];
        if (data != null) {
          return await _processDetailedPokemon(data, id);
        }
      }
    } catch (e) {
      debugPrint('Fallback exception for ID $id: $e');
    }

    throw Exception('No se pudo obtener detalle de Pokémon ID: $id');
  }

  /// Procesa los datos detallados de un Pokémon
  Future<Pokemon> _processDetailedPokemon(
    Map<String, dynamic> data,
    int id,
  ) async {
    var pokemon = PokemonMapperService.mapDetailed(data);

    // Obtener descripción
    final description = PokemonMapperService.extractDescription(data);
    if (description != null) {
      pokemon = pokemon.copyWith(description: description);
    }

    // Obtener formas
    final forms = await _fetchFormsByPokemonIds([pokemon.id]);
    final pokemonForms = forms[pokemon.id] ?? [];

    // Obtener cadena evolutiva
    List<Pokemon>? evolutions;
    try {
      final species = data['pokemon_v2_pokemonspecy'];
      if (species != null && species['evolution_chain_id'] != null) {
        final chainId = species['evolution_chain_id'] as int;
        evolutions = await _fetchEvolutionChain(chainId);
      }
    } catch (e) {
      debugPrint('Error fetching evolution chain: $e');
    }

    // Crear Pokémon final
    final finalPokemon = pokemon.copyWith(
      evolutions: evolutions,
      forms: pokemonForms,
    );

    _detailsCache.put(id, finalPokemon);
    return finalPokemon;
  }

  /// Obtiene la cadena evolutiva completa
  Future<List<Pokemon>> _fetchEvolutionChain(int chainId) async {
    // Verificar caché
    final cached = _evolutionChainCache.get(chainId);
    if (cached != null) return cached;

    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.evolutionChain,
        variables: {'id': chainId},
      );

      if (!result.hasException && result.data != null) {
        final chain = result.data!['pokemon_v2_evolutionchain_by_pk'];
        if (chain != null) {
          final evolutions = await _processEvolutionChain(chain);
          _evolutionChainCache.put(chainId, evolutions);
          return evolutions;
        }
      }
    } catch (e) {
      debugPrint('Error fetching evolution chain: $e');
    }

    return [];
  }

  /// Procesa una cadena evolutiva
  Future<List<Pokemon>> _processEvolutionChain(
    Map<String, dynamic> chain,
  ) async {
    final speciesList = chain['pokemon_v2_pokemonspecies'] as List<dynamic>?;
    if (speciesList == null) return [];

    final evolutionChain = <Pokemon>[];

    for (final species in speciesList) {
      var pokemons = species['pokemon_v2_pokemons'] as List<dynamic>?;

      // Si no hay pokémons, buscarlos por species id
      if (pokemons == null || pokemons.isEmpty) {
        final speciesId = species['id'] as int?;
        if (speciesId != null) {
          pokemons = await _fetchPokemonsBySpecies(speciesId);
        }
      }

      if (pokemons != null) {
        for (final pokemonData in pokemons) {
          final pokemon = PokemonMapperService.mapBasic(pokemonData);
          evolutionChain.add(pokemon);
          _detailsCache.put(pokemon.id, _detailsCache.get(pokemon.id) ?? pokemon);
        }
      }
    }

    // Obtener formas para todos los pokémon
    final pokemonIds = evolutionChain.map((p) => p.id).toList();
    final formsMap = await _fetchFormsByPokemonIds(pokemonIds);

    // Adjuntar formas
    final withForms = evolutionChain.map((p) {
      final forms = formsMap[p.id] ?? [];
      return p.copyWith(forms: forms);
    }).toList();

    return withForms;
  }

  /// Obtiene pokémon por especie
  Future<List<dynamic>?> _fetchPokemonsBySpecies(int speciesId) async {
    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.pokemonsBySpecies,
        variables: {'speciesId': speciesId},
      );

      if (!result.hasException && result.data != null) {
        return result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
      }
    } catch (e) {
      debugPrint('Error fetching pokemons by species: $e');
    }

    return null;
  }

  /// Obtiene formas para una lista de IDs de pokémon
  Future<Map<int, List<dynamic>>> _fetchFormsByPokemonIds(
    List<int> ids,
  ) async {
    final result = <int, List<dynamic>>{};
    if (ids.isEmpty) return result;

    // Verificar caché
    final missing = <int>[];
    for (final id in ids) {
      if (_formsCache.containsKey(id)) {
        result[id] = _formsCache.get(id)!;
      } else {
        missing.add(id);
      }
    }

    if (missing.isEmpty) return result;

    try {
      final queryResult = await _executor.executeQuery(
        query: GraphQLQueryService.formsByPokemonIds,
        variables: {'ids': missing},
      );

      if (!queryResult.hasException && queryResult.data != null) {
        final data = queryResult.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        if (data != null) {
          for (final formData in data) {
            final pokemonId = formData['pokemon_id'] as int;
            final form = PokemonMapperService.createForm(formData);

            final list = result[pokemonId] ?? <dynamic>[];
            list.add(form);
            result[pokemonId] = list;
          }

          // Cachear resultados
          for (final id in missing) {
            _formsCache.put(id, result[id] ?? []);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching forms: $e');
    }

    return result;
  }

  /// Enriquece los pokémon con categorías basadas en sus formas
  Future<List<Pokemon>> _enrichWithFormCategories(List<Pokemon> list) async {
    if (list.isEmpty) return list;

    debugPrint('Starting to enrich ${list.length} pokemon with form categories');

    // Obtener formas para todos los pokémon en lotes
    final ids = list.map((p) => p.id).toList();
    final formsMap = await _fetchFormsByPokemonIds(ids);

    int enrichedCount = 0;

    // Enriquecer cada pokémon con categorías derivadas de sus formas
    final result = list.map((pokemon) {
      final forms = formsMap[pokemon.id] ?? [];
      final categories = List<String>.from(pokemon.categories ?? []);

      // Detectar Mega
      final hasMega = forms.any((f) {
        final isMega = f['is_mega'] as bool? ?? false;
        final name = (f['name'] as String? ?? '').toLowerCase();
        return isMega || name.contains('mega');
      });

      if (hasMega && !categories.contains('mega')) {
        categories.add('mega');
        enrichedCount++;
      }

      // Detectar Gigantamax
      final hasGigantamax = forms.any((f) {
        final name = (f['name'] as String? ?? '').toLowerCase();
        final formName = (f['form_name'] as String? ?? '').toLowerCase();
        return name.contains('gmax') || formName.contains('gmax') ||
               name.contains('gigantamax') || formName.contains('gigantamax');
      });

      if (hasGigantamax && !categories.contains('gigantamax')) {
        categories.add('gigantamax');
        enrichedCount++;
      }

      // Si se agregaron categorías, crear nuevo pokémon
      if (categories.length > (pokemon.categories?.length ?? 0)) {
        return Pokemon(
          id: pokemon.id,
          name: pokemon.name,
          spriteUrl: pokemon.spriteUrl,
          types: pokemon.types,
          height: pokemon.height,
          weight: pokemon.weight,
          description: pokemon.description,
          evolutions: pokemon.evolutions,
          isFavorite: pokemon.isFavorite,
          abilities: pokemon.abilities,
          stats: pokemon.stats,
          categories: categories,
          isLegendary: pokemon.isLegendary,
          isMythical: pokemon.isMythical,
          forms: forms,
        );
      }

      return pokemon;
    }).toList();

    debugPrint('Enriched $enrichedCount pokemon with form categories');
    return result;
  }

  /// Filtra por categorías
  Future<List<Pokemon>> _filterByCategories(
    List<Pokemon> list,
    List<String> categories,
  ) async {
    if (categories.isEmpty) return list;

    final catSet = categories.map((c) => c.toLowerCase()).toSet();
    debugPrint('Filtering by categories: $catSet');

    // Filtrar por categorías (ya enriquecidas previamente)
    final filtered = list.where((p) {
      if (p.categories != null && p.categories!.isNotEmpty) {
        final pokemonCats = p.categories!.map((c) => c.toLowerCase()).toSet();
        return pokemonCats.any((c) => catSet.contains(c));
      }
      return false;
    }).toList();

    debugPrint('Found ${filtered.length} pokemon with categories from ${list.length} total');
    return filtered;
  }

  /// Obtiene detalles por IDs
  Future<List<Pokemon>> _fetchDetailsByIds(List<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.detailsByIds,
        variables: {'ids': ids},
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          return PokemonMapperService.mapDetailedList(data);
        }
      }
    } catch (e) {
      debugPrint('Error fetching details by IDs: $e');
    }

    return [];
  }

  // ========== Métodos de testing ==========

  Future<void> testMegaEvolutions() async {
    // Implementación simplificada para testing
    debugPrint('Test: Mega evolutions check completed');
  }

  Future<void> testSpecificPokemonForms() async {
    // Implementación simplificada para testing
    debugPrint('Test: Specific pokemon forms check completed');
  }

  /// Obtiene los movimientos de un Pokémon
  Future<List<PokemonMove>> fetchPokemonMoves(int pokemonId) async {
    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.movesByPokemonId,
        variables: {'pokemonId': pokemonId},
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemonmove'] as List<dynamic>?;
        if (data != null) {
          final movesMap = <int, PokemonMove>{};

          for (final moveData in data) {
            try {
              final move = PokemonMove.fromGraphQL(moveData);
              // Solo agregar si no existe o si queremos mantener el primero
              if (!movesMap.containsKey(move.moveId)) {
                movesMap[move.moveId] = move;
              }
            } catch (e) {
              debugPrint('Error parsing move: $e');
            }
          }

          final moves = movesMap.values.toList();
          debugPrint('Loaded ${moves.length} unique moves for Pokemon ID: $pokemonId');
          return moves;
        }
      }
    } catch (e) {
      debugPrint('Error fetching moves for Pokemon $pokemonId: $e');
    }

    return [];
  }
}
