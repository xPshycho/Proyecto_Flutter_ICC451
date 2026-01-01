import 'dart:async';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/pokemon.dart';
import '../models/pokemon_move.dart';
import '../models/evolution_detail.dart';
import '../services/graphql_query_service.dart';
import '../services/pokemon_mapper_service.dart';
import '../services/data_services.dart';
import '../../core/constants/pokemon_constants.dart';
import '../../core/constants/app_constants.dart';

class PokemonRepository {
  final GraphQLClient client;
  final int languageId;
  late final GraphQLExecutor _executor;

  // Cachés específicos por tipo de dato
  final _pageCache = CacheService<List<Pokemon>>();
  final _detailsCache = CacheService<Pokemon>();
  final _evolutionChainCache = CacheService<List<Pokemon>>();
  final _formsCache = CacheService<List<dynamic>>();

  List<Pokemon>? _allCache;
  bool _testDone = false;

  PokemonRepository(this.client, {this.languageId = 9}) {
    _executor = GraphQLExecutor(client);
  }

  /// Limpia el caché de GraphQL y todos los cachés internos
  Future<void> clearGraphQLCache() async {
    await _executor.clearCache();
    _pageCache.clear();
    _detailsCache.clear();
    _evolutionChainCache.clear();
    _formsCache.clear();
    _allCache = null;
    debugPrint('All caches cleared');
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

    // Determinar si hay filtros activos
    final hasActiveFilters = (types != null && types.isNotEmpty) ||
        (regions != null && regions.isNotEmpty) ||
        normalizedCategories.isNotEmpty;

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

    // Ordenar por tipo requiere caché completo (GraphQL no puede ordenar por tipo)
    if (sortBy == 'type') {
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
      onlyDefault: !hasActiveFilters, // Solo default cuando no hay filtros
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
        query: GraphQLQueryService.detailWithLanguage,
        variables: {
          'id': id,
          'languageId': this.languageId,
        },
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

    const heavyCategories = {'legendario', 'mitico', 'mega', 'gigantamax'};
    return categories.any((c) => heavyCategories.contains(_normalizeString(c)));
  }

  /// Verifica si un Pokémon tiene detalles completos
  bool _hasCompleteDetails(Pokemon pokemon) {
    final hasAbilities = pokemon.abilities.isNotEmpty;
    final hasForms = pokemon.forms != null; // en detalle debe venir al menos lista vacía
    final hasEvolutions = pokemon.evolutions != null; // en detalle debe venir al menos lista (o vacía)

    return hasAbilities && hasForms && hasEvolutions;
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

    // Aplicar filtros de región usando generation_id si hay caché completo
    if (regions != null && regions.isNotEmpty) {
      final generationIds = PokemonConstants.getGenerationIds(regions);
      if (generationIds.isNotEmpty) {
        list = PokemonFilterService.filterByGenerationIds(
          list,
          generationIds,
          (p) => p.generationId,
        );
      }
    }

    // Filtrar por categorías (ya están enriquecidas en _ensureAllCached)
    list = await _filterByCategories(list, categories);

    // Aplicar filtros de tipo usando datos precargados del caché
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
        typeExtractor: (p) => p.types,
      );
    }

    // Paginar
    final paginated = PokemonFilterService.paginate(list, offset, limit);

    // Enriquecer SOLO la página actual con categorías de formas
    debugPrint('Enriching ${paginated.length} pokemon in current page with form categories');
    final enriched = await _enrichWithFormCategoriesProgressive(paginated);

    return enriched;
  }

  /// Obtiene Pokémon de forma paginada
  Future<List<Pokemon>> _fetchPaginated({
    required int limit,
    required int offset,
    List<String>? types,
    List<String>? regions,
    String? sortBy,
    bool? ascending,
    bool onlyDefault = false, // Nuevo parámetro para filtrar solo por isDefault
  }) async {
    // Crear clave de caché que incluya filtros
    final cacheKey = _createCacheKey(offset, types, regions, sortBy, ascending);
    final cached = _pageCache.get(cacheKey);
    if (cached != null) {
      debugPrint('Returning cached page for key: $cacheKey');
      return cached;
    }

    try {
      final orderBy = sortBy != null
          ? [{sortBy: ascending == true ? 'asc' : 'desc'}]
          : [{'id': 'asc'}];

      List<Pokemon> result;

      // Determinar qué query usar basado en los filtros
      if (types != null && types.isNotEmpty && regions != null && regions.isNotEmpty) {
        // Filtros de tipos Y regiones
        final generationIds = PokemonConstants.getGenerationIds(regions);
        if (generationIds.isNotEmpty) {
          result = await _fetchByTypesAndGenerations(
            limit: limit,
            offset: offset,
            typeNames: types,
            generationIds: generationIds,
            orderBy: orderBy,
          );
        } else {
          result = [];
        }
      } else if (types != null && types.isNotEmpty) {
        // Solo filtros de tipos
        result = await _fetchByTypes(
          limit: limit,
          offset: offset,
          typeNames: types,
          orderBy: orderBy,
        );
      } else if (regions != null && regions.isNotEmpty) {
        // Solo filtros de regiones
        final generationIds = PokemonConstants.getGenerationIds(regions);
        if (generationIds.isNotEmpty) {
          result = await _fetchByGenerationIds(
            limit: limit,
            offset: offset,
            generationIds: generationIds,
            types: null,
            sortBy: sortBy,
            ascending: ascending,
          );
        } else {
          result = [];
        }
      } else {
        // Sin filtros específicos
        result = await _fetchWithoutFilters(
          limit: limit,
          offset: offset,
          orderBy: orderBy,
        );
      }

      // Aplicar filtro adicional por isDefault si es necesario
      if (onlyDefault) {
        result = result.where((pokemon) => pokemon.isDefault == true).toList();
      }

      _pageCache.put(cacheKey, result);
      return result;
    } catch (e) {
      debugPrint('GraphQL error: $e');
      return [];
    }
  }

  /// Crea una clave de caché basada en parámetros
  String _createCacheKey(int offset, List<String>? types, List<String>? regions, String? sortBy, bool? ascending) {
    final parts = [
      'offset:$offset',
      if (types != null && types.isNotEmpty) 'types:${types.join(',')}',
      if (regions != null && regions.isNotEmpty) 'regions:${regions.join(',')}',
      if (sortBy != null) 'sort:$sortBy:${ascending ?? true}',
    ];
    return parts.join('|');
  }

  /// Obtiene Pokémon filtrados por generation_ids
  Future<List<Pokemon>> _fetchByGenerationIds({
    required int limit,
    required int offset,
    required List<int> generationIds,
    List<String>? types,
    String? sortBy,
    bool? ascending,
  }) async {
    try {
      final orderBy = sortBy != null
          ? [{sortBy: ascending == true ? 'asc' : 'desc'}]
          : [{'id': 'asc'}];

      final result = await _executor.executeQuery(
        query: GraphQLQueryService.listByGenerationIds,
        variables: {
          'limit': limit,
          'offset': offset,
          'orderBy': orderBy,
          'generationIds': generationIds,
        },
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          return PokemonMapperService.mapList(data);
        }
      }
    } catch (e) {
      debugPrint('GraphQL error filtering by generation_ids: $e');
    }

    return [];
  }

  /// Obtiene Pokémon filtrados por tipos
  Future<List<Pokemon>> _fetchByTypes({
    required int limit,
    required int offset,
    required List<String> typeNames,
    required List<Map<String, String>> orderBy,
  }) async {
    try {
      // Si hay 2 tipos, necesitamos traer más registros y filtrar en memoria
      // porque GraphQL con _in trae los que tengan UNO u OTRO tipo
      final fetchLimit = typeNames.length == 2 ? limit * 5 : limit;

      final result = await _executor.executeQuery(
        query: GraphQLQueryService.listByTypes,
        variables: {
          'limit': fetchLimit,
          'offset': offset,
          'orderBy': orderBy,
          'typeNames': typeNames,
        },
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          var pokemons = PokemonMapperService.mapList(data);

          // Si hay 2 tipos, filtrar en memoria para obtener SOLO los que tengan AMBOS
          if (typeNames.length == 2) {
            pokemons = PokemonFilterService.filterByTypes(
              pokemons,
              typeNames,
              (p) => p.types,
            );

            // Aplicar paginación después del filtro
            if (pokemons.length > limit) {
              pokemons = pokemons.take(limit).toList();
            }
          }

          return pokemons;
        }
      }
    } catch (e) {
      debugPrint('GraphQL error filtering by types: $e');
    }
    return [];
  }

  /// Obtiene Pokémon filtrados por tipos y generaciones
  Future<List<Pokemon>> _fetchByTypesAndGenerations({
    required int limit,
    required int offset,
    required List<String> typeNames,
    required List<int> generationIds,
    required List<Map<String, String>> orderBy,
  }) async {
    try {
      // Si hay 2 tipos, necesitamos traer más registros y filtrar en memoria
      final fetchLimit = typeNames.length == 2 ? limit * 5 : limit;

      final result = await _executor.executeQuery(
        query: GraphQLQueryService.listByTypesAndGenerations,
        variables: {
          'limit': fetchLimit,
          'offset': offset,
          'orderBy': orderBy,
          'typeNames': typeNames,
          'generationIds': generationIds,
        },
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          var pokemons = PokemonMapperService.mapList(data);

          // Si hay 2 tipos, filtrar en memoria para obtener SOLO los que tengan AMBOS
          if (typeNames.length == 2) {
            pokemons = PokemonFilterService.filterByTypes(
              pokemons,
              typeNames,
              (p) => p.types,
            );

            // Aplicar paginación después del filtro
            if (pokemons.length > limit) {
              pokemons = pokemons.take(limit).toList();
            }
          }

          return pokemons;
        }
      }
    } catch (e) {
      debugPrint('GraphQL error filtering by types and generations: $e');
    }
    return [];
  }

  /// Obtiene Pokémon sin filtros específicos
  Future<List<Pokemon>> _fetchWithoutFilters({
    required int limit,
    required int offset,
    required List<Map<String, String>> orderBy,
  }) async {
    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.listWithSpecies,
        variables: {
          'limit': limit,
          'offset': offset,
          'orderBy': orderBy,
        },
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemon'] as List<dynamic>?;
        if (data != null) {
          return PokemonMapperService.mapList(data);
        }
      }
    } catch (e) {
      debugPrint('GraphQL error fetching without filters: $e');
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

    // Enriquecer TODO el caché con Mega/Gigantamax usando UNA query batch masiva
    debugPrint('Enriching all pokemon with form categories using single batch query...');
    _allCache = await _enrichAllWithFormCategoriesBatch(_allCache ?? []);

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

    // Solo aplicar ordenamiento y paginación aquí
    // Los filtros de tipo ya se aplicaron en la query GraphQL
    if (sortBy != null) {
      list = PokemonFilterService.sort(
        list,
        sortBy,
        ascending ?? true,
        (p) => p.name,
        (p) => p.id,
        typeExtractor: (p) => p.types,
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

    // Obtener formas (del pokémon actual)
    final forms = await _fetchFormsByPokemonIds([pokemon.id]);
    final pokemonForms = forms[pokemon.id] ?? [];

    // Obtener cadena evolutiva
    List<Pokemon>? evolutions;
    int? chainId;
    try {
      final species = data['pokemon_v2_pokemonspecy'];
      if (species != null && species['evolution_chain_id'] != null) {
        chainId = species['evolution_chain_id'] as int;
        evolutions = await _fetchEvolutionChain(chainId);
      }
    } catch (e) {
      debugPrint('Error fetching evolution chain: $e');
    }

    // ====== NUEVO: formas agregadas de TODA la cadena (para mostrar megas/variantes del árbol) ======
    // Nota: no dependemos de las "forms" cargadas en cada evolución, porque esa carga
    // por pokemon_id suele perder megas/variantes que viven en otros pokemon_id.
    final formsChain = <dynamic>[];
    if (chainId != null) {
      try {
        final chainForms = await _fetchFormsByEvolutionChainId(chainId);
        formsChain.addAll(chainForms);
      } catch (e) {
        debugPrint('Error fetching chain forms: $e');
      }
    }

    // Dedupe de formas de cadena
    final dedupedChain = <dynamic>[];
    final seenChain = <String>{};
    for (final f in formsChain) {
      if (f is Map) {
        final key = '${f['id'] ?? ''}|${f['pokemon_id'] ?? ''}|${f['name'] ?? ''}|${f['form_name'] ?? ''}';
        if (seenChain.add(key)) dedupedChain.add(f);
      }
    }

    // Crear Pokémon final
    final finalPokemon = pokemon.copyWith(
      evolutions: evolutions,
      forms: pokemonForms,
      formsChain: dedupedChain,
    );

    _detailsCache.put(id, finalPokemon);
    return finalPokemon;
  }

  /// Obtiene formas para una cadena evolutiva completa
  Future<List<dynamic>> _fetchFormsByEvolutionChainId(int chainId) async {
    // Por simplicidad no cacheamos aqu 00: el detalle ya cachea el Pokémon final.
    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.formsByEvolutionChainId,
        variables: {'chainId': chainId},
        fetchPolicy: FetchPolicy.networkOnly,
        errorPolicy: ErrorPolicy.ignore,
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        if (data != null) {
          return data
              .whereType<Map<String, dynamic>>()
              .map(PokemonMapperService.createForm)
              .toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching forms by evolution chain id: $e');
    }

    return [];
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
    final evolutionDetailsMap = <int, Map<int, EvolutionDetail>>{};

    for (final species in speciesList) {
      final speciesId = species['id'] as int?;
      var pokemons = species['pokemon_v2_pokemons'] as List<dynamic>?;

      if (pokemons == null || pokemons.isEmpty) {
        if (speciesId != null) {
          pokemons = await _fetchPokemonsBySpecies(speciesId);
        }
      }

      if (pokemons != null && pokemons.isNotEmpty) {
        final basePokemon = pokemons.firstWhere(
          (p) => (p['id'] as int) == speciesId,
          orElse: () => pokemons!.first,
        );

        final pokemon = PokemonMapperService.mapBasic(basePokemon);
        evolutionChain.add(pokemon);
        _detailsCache.put(pokemon.id, _detailsCache.get(pokemon.id) ?? pokemon);
      }

      final evolutions = species['pokemon_v2_pokemonevolutions'] as List<dynamic>?;
      if (evolutions != null && speciesId != null) {
        for (final evo in evolutions) {
          try {
            final detail = EvolutionDetail.fromGraphQL({
              ...evo,
              'evolves_from_species_id': speciesId,
            });

            final evolvedSpeciesId = detail.evolvesToSpeciesId;
            if (!evolutionDetailsMap.containsKey(evolvedSpeciesId)) {
              evolutionDetailsMap[evolvedSpeciesId] = {};
            }
            evolutionDetailsMap[evolvedSpeciesId]![speciesId] = detail;
          } catch (e) {
            debugPrint('Error parsing evolution detail: $e');
          }
        }
      }
    }

    final pokemonIds = evolutionChain.map((p) => p.id).toList();
    final formsMap = await _fetchFormsByPokemonIds(pokemonIds);

    final speciesIdMap = <int, int>{};
    for (final species in speciesList) {
      final speciesId = species['id'] as int?;
      if (speciesId != null) {
        speciesIdMap[speciesId] = speciesId;
      }
    }

    final withFormsAndDetails = evolutionChain.map((p) {
      final forms = formsMap[p.id] ?? [];
      final speciesId = speciesIdMap[p.id] ?? p.id;
      final details = evolutionDetailsMap[speciesId];

      return p.copyWith(
        forms: forms,
        evolutionDetails: details,
      );
    }).toList();

    return withFormsAndDetails;
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
  /// Usa _fetchFormsByEvolutionChainId como en el detalle
  Future<List<Pokemon>> _enrichWithFormCategories(List<Pokemon> list) async {
    if (list.isEmpty) return list;

    debugPrint('Starting to enrich ${list.length} pokemon with form categories using evolution chains');

    int enrichedCount = 0;
    int megaCount = 0;
    int gigaCount = 0;

    // Agrupar por evolution_chain_id y cachear las formas por cadena
    final chainMap = <int, List<Pokemon>>{};
    for (final pokemon in list) {
      final chainId = pokemon.evolutionChainId;
      if (chainId != null) {
        chainMap.putIfAbsent(chainId, () => []).add(pokemon);
      }
    }

    debugPrint('Grouped ${list.length} pokemon into ${chainMap.length} evolution chains');

    // Obtener formas para cada cadena (igual que en _processDetailedPokemon)
    final chainFormsMap = <int, List<dynamic>>{};
    for (final chainId in chainMap.keys) {
      try {
        final forms = await _fetchFormsByEvolutionChainId(chainId);
        chainFormsMap[chainId] = forms;
        if (forms.isNotEmpty) {
          debugPrint('Chain $chainId: ${forms.length} forms found');
        }
      } catch (e) {
        debugPrint('Error fetching forms for chain $chainId: $e');
      }
    }

    // Enriquecer cada pokémon
    final result = list.map((pokemon) {
      final chainId = pokemon.evolutionChainId;
      final chainForms = chainId != null ? (chainFormsMap[chainId] ?? []) : [];

      // Filtrar solo las formas que pertenecen a este Pokémon específico
      final pokemonForms = chainForms.where((f) {
        final pokemonId = f['pokemon_id'] as int?;
        return pokemonId == pokemon.id;
      }).toList();

      if (pokemonForms.isEmpty) return pokemon;

      final categories = List<String>.from(pokemon.categories ?? []);

      // Detectar Mega: is_mega=true o form_name contiene "mega"
      final hasMega = pokemonForms.any((f) {
        final isMega = f['is_mega'] as bool? ?? false;
        if (isMega) return true;

        final name = (f['name'] as String? ?? '').toLowerCase();
        final formName = (f['form_name'] as String? ?? '').toLowerCase();

        // Patrón: "-mega" en name o "mega" en form_name (evita "meganium")
        return name.contains('-mega') || formName == 'mega' || formName.startsWith('mega-');
      });

      if (hasMega && !categories.contains('mega')) {
        categories.add('mega');
        enrichedCount++;
        megaCount++;
        debugPrint('  ✓ Mega: ${pokemon.name} (ID: ${pokemon.id})');
      }

      // Detectar Gigantamax: form_name contiene "gmax"
      final hasGigantamax = pokemonForms.any((f) {
        final name = (f['name'] as String? ?? '').toLowerCase();
        final formName = (f['form_name'] as String? ?? '').toLowerCase();

        return name.contains('-gmax') || formName == 'gmax' ||
               formName.contains('gigantamax') || name.contains('gigantamax');
      });

      if (hasGigantamax && !categories.contains('gigantamax')) {
        categories.add('gigantamax');
        enrichedCount++;
        gigaCount++;
        debugPrint('  ✓ Gigantamax: ${pokemon.name} (ID: ${pokemon.id})');
      }

      // Crear nuevo Pokemon si se agregaron categorías
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
          generationId: pokemon.generationId,
          evolutionChainId: pokemon.evolutionChainId,
          forms: pokemonForms,
        );
      }

      return pokemon;
    }).toList();

    debugPrint('Enriched $enrichedCount pokemon with form categories');
    debugPrint('  - Mega: $megaCount pokemon');
    debugPrint('  - Gigantamax: $gigaCount pokemon');
    return result;
  }

  /// Filtra por categorías
  Future<List<Pokemon>> _filterByCategories(
    List<Pokemon> list,
    List<String> categories,
  ) async {
    if (categories.isEmpty) return list;

    final catSet = categories.map((c) => _normalizeString(c)).toSet();
    debugPrint('Filtering by categories: $catSet (original: $categories)');

    final filtered = list.where((p) {
      if (p.categories != null && p.categories!.isNotEmpty) {
        final pokemonCats = p.categories!.map((c) => _normalizeString(c)).toSet();
        final hasMatch = pokemonCats.any((c) => catSet.contains(c));

        if (hasMatch) {
          debugPrint('  ✓ ${p.name} (ID: ${p.id}) - categories: ${p.categories}');
        }

        return hasMatch;
      }
      return false;
    }).toList();

    debugPrint('Found ${filtered.length} pokemon with categories from ${list.length} total');
    return filtered;
  }

  /// Normaliza strings para comparación (minúsculas, sin acentos)
  String _normalizeString(String str) {
    return str
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .trim();
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

  /// Versión progresiva optimizada: enriquece solo un grupo pequeño de Pokémon
  /// Hace UNA consulta batch para todas las cadenas del grupo
  Future<List<Pokemon>> _enrichWithFormCategoriesProgressive(List<Pokemon> list) async {
    if (list.isEmpty) return list;

    // Obtener los chain IDs únicos del grupo
    final chainIds = list
        .where((p) => p.evolutionChainId != null)
        .map((p) => p.evolutionChainId!)
        .toSet()
        .toList();

    if (chainIds.isEmpty) return list;

    debugPrint('Progressive enrichment: ${list.length} pokemon, ${chainIds.length} unique chains');

    // UNA SOLA query batch para todas las cadenas del grupo
    final allForms = await _fetchFormsByMultipleChains(chainIds);

    // Agrupar formas por chain_id
    final chainFormsMap = <int, List<dynamic>>{};
    for (final form in allForms) {
      if (form['pokemon_v2_pokemon'] != null) {
        final pokemonData = form['pokemon_v2_pokemon'];
        if (pokemonData['pokemon_v2_pokemonspecy'] != null) {
          final chainId = pokemonData['pokemon_v2_pokemonspecy']['evolution_chain_id'] as int?;
          if (chainId != null) {
            chainFormsMap.putIfAbsent(chainId, () => []).add(form);
          }
        }
      }
    }

    // Enriquecer cada pokémon
    int megaCount = 0;
    int gigaCount = 0;

    final result = list.map((pokemon) {
      final chainId = pokemon.evolutionChainId;
      if (chainId == null) return pokemon;

      final chainForms = chainFormsMap[chainId] ?? [];
      if (chainForms.isEmpty) return pokemon;

      // Filtrar solo las formas que pertenecen a este Pokémon específico
      final pokemonForms = chainForms.where((f) {
        final pokemonData = f['pokemon_v2_pokemon'];
        if (pokemonData == null) return false;
        final pokemonId = pokemonData['id'] as int?;
        return pokemonId == pokemon.id;
      }).toList();

      if (pokemonForms.isEmpty) return pokemon;

      final categories = List<String>.from(pokemon.categories ?? []);

      // Detectar Mega
      final hasMega = pokemonForms.any((f) {
        final isMega = f['is_mega'] as bool? ?? false;
        if (isMega) return true;

        final name = (f['name'] as String? ?? '').toLowerCase();
        final formName = (f['form_name'] as String? ?? '').toLowerCase();

        return name.contains('-mega') || formName == 'mega' || formName.startsWith('mega-');
      });

      // Detectar Gigantamax
      final hasGigantamax = pokemonForms.any((f) {
        final name = (f['name'] as String? ?? '').toLowerCase();
        final formName = (f['form_name'] as String? ?? '').toLowerCase();

        return name.contains('-gmax') || formName == 'gmax' ||
               formName.contains('gigantamax') || name.contains('gigantamax');
      });

      if (hasMega && !categories.contains('mega')) {
        categories.add('mega');
        megaCount++;
      }

      if (hasGigantamax && !categories.contains('gigantamax')) {
        categories.add('gigantamax');
        gigaCount++;
      }

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
          generationId: pokemon.generationId,
          evolutionChainId: pokemon.evolutionChainId,
          forms: pokemonForms,
        );
      }

      return pokemon;
    }).toList();

    if (megaCount > 0 || gigaCount > 0) {
      debugPrint('  ✓ Enriched: $megaCount Mega, $gigaCount Gigantamax');
    }

    return result;
  }

  /// Obtiene formas para múltiples cadenas evolutivas en UNA sola query batch
  /// Retorna datos RAW para preservar pokemon_v2_pokemon con evolution_chain_id
  Future<List<dynamic>> _fetchFormsByMultipleChains(List<int> chainIds) async {
    if (chainIds.isEmpty) return [];

    try {
      final result = await _executor.executeQuery(
        query: GraphQLQueryService.formsByMultipleChains,
        variables: {'chainIds': chainIds},
      );

      if (!result.hasException && result.data != null) {
        final data = result.data!['pokemon_v2_pokemonform'] as List<dynamic>?;
        if (data != null) {
          // Retornar datos RAW sin transformar para preservar pokemon_v2_pokemon
          return data.whereType<Map<String, dynamic>>().toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching forms for multiple chains: $e');
    }

    return [];
  }

  /// Enriquece el caché con formas Mega/Gigantamax como Pokémon separados
  Future<List<Pokemon>> _enrichAllWithFormCategoriesBatch(List<Pokemon> list) async {
    if (list.isEmpty) return list;

    final allChainIds = list
        .where((p) => p.evolutionChainId != null)
        .map((p) => p.evolutionChainId!)
        .toSet()
        .toList();

    if (allChainIds.isEmpty) return list;

    debugPrint('Batch enrichment: ${list.length} pokemon, ${allChainIds.length} unique chains');

    final allForms = await _fetchFormsByMultipleChains(allChainIds);
    debugPrint('Fetched ${allForms.length} total forms');

    final specialFormPokemon = <Pokemon>[];
    final processedFormIds = <int>{};

    for (final rawForm in allForms) {
      final formId = rawForm['id'] as int?;
      final pokemonId = rawForm['pokemon_id'] as int?;
      if (formId == null || pokemonId == null) continue;
      if (processedFormIds.contains(formId)) continue;

      // Usar DTO para procesar la forma
      final form = PokemonMapperService.createForm(rawForm);
      final name = (form['name'] as String? ?? '').toLowerCase();
      final formName = (form['form_name'] as String? ?? '').toLowerCase();
      final isMegaFlag = form['is_mega'] as bool? ?? false;

      // Determinar categoría de forma EXCLUYENTE
      String? category;
      if (isMegaFlag || name.contains('-mega') || formName == 'mega' || formName.startsWith('mega-')) {
        category = 'mega';
      } else if (name.contains('-gmax') || formName == 'gmax' || formName.contains('gigantamax')) {
        category = 'gigantamax';
      }

      if (category == null) continue;
      processedFormIds.add(formId);

      // Extraer tipos usando DTO
      final pokemonData = rawForm['pokemon_v2_pokemon'];
      List<String> types = PokemonMapperService.extractTypesFromPokemon(pokemonData);

      // Fallback: buscar tipos del Pokémon base
      if (types.isEmpty) {
        int? speciesId;
        if (pokemonData != null && pokemonData is Map) {
          final specyData = pokemonData['pokemon_v2_pokemonspecy'];
          if (specyData != null && specyData is Map) {
            speciesId = specyData['id'] as int?;
          }
        }
        if (speciesId != null) {
          final basePokemon = list.where((p) => p.id == speciesId).firstOrNull;
          types = basePokemon?.types ?? [];
        }
      }

      // Extraer evolution_chain_id
      int? chainId;
      if (pokemonData != null && pokemonData is Map) {
        final specyData = pokemonData['pokemon_v2_pokemonspecy'];
        if (specyData != null && specyData is Map) {
          chainId = specyData['evolution_chain_id'] as int?;
        }
      }

      // Usar sprite del DTO
      final spriteUrl = form['sprite_url'] as String? ??
          'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/$pokemonId.png';

      final formPokemon = Pokemon(
        id: pokemonId,
        name: form['name'] as String? ?? 'Unknown',
        spriteUrl: spriteUrl,
        types: types,
        categories: [category],
        evolutionChainId: chainId,
      );

      specialFormPokemon.add(formPokemon);
    }

    debugPrint('Created ${specialFormPokemon.length} special form pokemon entries');
    debugPrint('  - Mega: ${specialFormPokemon.where((p) => p.categories?.contains('mega') == true).length}');
    debugPrint('  - Gigantamax: ${specialFormPokemon.where((p) => p.categories?.contains('gigantamax') == true).length}');

    final result = List<Pokemon>.from(list);
    result.addAll(specialFormPokemon);

    // Eliminar duplicados por ID
    final uniqueById = <int, Pokemon>{};
    for (final p in result) {
      uniqueById[p.id] = p;
    }

    debugPrint('Total pokemon after enrichment: ${uniqueById.length}');
    return uniqueById.values.toList()..sort((a, b) => a.id.compareTo(b.id));
  }
}
