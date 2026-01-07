import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../data/favorites_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/pokemon_constants.dart';
import '../../../data/models/pokemon.dart';
import 'pokemon_event.dart';
import 'pokemon_state.dart';


/// BLoC para gestionar el estado de la lista de Pokémon
class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final PokemonRepository repository;
  final FavoritesService favoritesService;

  // Estado interno
  int _offset = 0;
  String _currentQuery = '';
  List<String> _currentTypes = [];
  List<String> _currentRegions = [];
  List<String> _currentCategories = [];
  bool _showFavorites = false;
  bool _showNoFavorites = false;
  String _sortBy = 'id';
  bool _ascending = true;

  PokemonBloc({
    required this.repository,
    required this.favoritesService,
  }) : super(const PokemonInitial()) {
    // Registrar handlers con transformador para evitar llamadas múltiples
    on<LoadPokemonList>(_onLoadPokemonList, transformer: restartable());
    on<LoadMorePokemons>(_onLoadMorePokemons);
    on<SearchPokemon>(_onSearchPokemon, transformer: restartable());
    on<ClearSearch>(_onClearSearch, transformer: restartable());
    on<ApplyFilters>(_onApplyFilters, transformer: restartable());
    on<ApplySort>(_onApplySort, transformer: restartable());
    on<ClearFilters>(_onClearFilters);
    on<RefreshPokemonList>(_onRefreshPokemonList);
  }

  /// Maneja la carga inicial de Pokémon
  Future<void> _onLoadPokemonList(
    LoadPokemonList event,
    Emitter<PokemonState> emit,
  ) async {
    try {
      if (event.refresh) {
        _offset = 0;
        await repository.clearGraphQLCache();
      }

      emit(const PokemonLoading());

      final pokemons = await _fetchPokemons();

      _offset = pokemons.length;

      emit(PokemonLoaded(
        pokemons: pokemons,
        hasReachedMax: pokemons.length < AppConstants.defaultPageSize,
        searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
        activeTypes: _currentTypes,
        activeRegions: _currentRegions,
        activeCategories: _currentCategories,
        showFavorites: _showFavorites,
        showNoFavorites: _showNoFavorites,
        sortBy: _sortBy,
        ascending: _ascending,
      ));
    } catch (e) {
      debugPrint('Error loading pokemon list: $e');
      emit(PokemonError(message: 'Error al cargar Pokémon: $e'));
    }
  }

  /// Maneja la carga de más Pokémon (paginación)
  Future<void> _onLoadMorePokemons(
    LoadMorePokemons event,
    Emitter<PokemonState> emit,
  ) async {
    final currentState = state;
    if (currentState is! PokemonLoaded) return;
    if (currentState.hasReachedMax) return;

    try {
      emit(PokemonLoadingMore(currentState.pokemons));

      final newPokemons = await _fetchPokemons();

      if (newPokemons.isEmpty) {
        emit(currentState.copyWith(hasReachedMax: true));
        return;
      }

      final allPokemons = List<Pokemon>.from(currentState.pokemons)
        ..addAll(newPokemons);

      _offset = allPokemons.length;

      emit(currentState.copyWith(
        pokemons: allPokemons,
        hasReachedMax: newPokemons.length < AppConstants.defaultPageSize,
      ));
    } catch (e) {
      debugPrint('Error loading more pokemons: $e');
      emit(PokemonError(
        message: 'Error al cargar más Pokémon: $e',
        cachedPokemons: currentState.pokemons,
      ));
    }
  }

  /// Maneja la búsqueda de Pokémon
  Future<void> _onSearchPokemon(
    SearchPokemon event,
    Emitter<PokemonState> emit,
  ) async {
    try {
      _currentQuery = event.query.trim();
      _offset = 0;

      emit(const PokemonLoading());

      final pokemons = await _fetchPokemons();

      _offset = pokemons.length;

      emit(PokemonLoaded(
        pokemons: pokemons,
        hasReachedMax: pokemons.length < AppConstants.defaultPageSize,
        searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
        activeTypes: _currentTypes,
        activeRegions: _currentRegions,
        activeCategories: _currentCategories,
        showFavorites: _showFavorites,
        showNoFavorites: _showNoFavorites,
        sortBy: _sortBy,
        ascending: _ascending,
      ));
    } catch (e) {
      debugPrint('Error searching pokemon: $e');
      emit(PokemonError(message: 'Error en la búsqueda: $e'));
    }
  }

  /// Maneja la limpieza de búsqueda (mantiene filtros y ordenamiento)
  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<PokemonState> emit,
  ) async {
    try {
      _currentQuery = '';
      _offset = 0;

      emit(const PokemonLoading());

      final pokemons = await _fetchPokemons();

      _offset = pokemons.length;

      emit(PokemonLoaded(
        pokemons: pokemons,
        hasReachedMax: pokemons.length < AppConstants.defaultPageSize,
        searchQuery: null,
        activeTypes: _currentTypes,
        activeRegions: _currentRegions,
        activeCategories: _currentCategories,
        showFavorites: _showFavorites,
        showNoFavorites: _showNoFavorites,
        sortBy: _sortBy,
        ascending: _ascending,
      ));
    } catch (e) {
      debugPrint('Error clearing search: $e');
      emit(PokemonError(message: 'Error al limpiar búsqueda: $e'));
    }
  }

  /// Maneja la aplicación de filtros
  Future<void> _onApplyFilters(
    ApplyFilters event,
    Emitter<PokemonState> emit,
  ) async {
    try {
      _currentTypes = event.types;
      _currentRegions = event.regions;
      _currentCategories = event.categories;
      _showFavorites = event.favorites;
      _showNoFavorites = event.noFavorites;
      _offset = 0;

      emit(const PokemonLoading());

      final pokemons = await _fetchPokemons();

      _offset = pokemons.length;

      emit(PokemonLoaded(
        pokemons: pokemons,
        hasReachedMax: pokemons.length < AppConstants.defaultPageSize,
        searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
        activeTypes: _currentTypes,
        activeRegions: _currentRegions,
        activeCategories: _currentCategories,
        showFavorites: _showFavorites,
        showNoFavorites: _showNoFavorites,
        sortBy: _sortBy,
        ascending: _ascending,
      ));
    } catch (e) {
      debugPrint('Error applying filters: $e');
      emit(PokemonError(message: 'Error al aplicar filtros: $e'));
    }
  }

  /// Maneja la aplicación de ordenamiento
  Future<void> _onApplySort(
    ApplySort event,
    Emitter<PokemonState> emit,
  ) async {
    try {
      _sortBy = event.sortBy;
      _ascending = event.ascending;
      _offset = 0;

      emit(const PokemonLoading());

      final pokemons = await _fetchPokemons();

      _offset = pokemons.length;

      emit(PokemonLoaded(
        pokemons: pokemons,
        hasReachedMax: pokemons.length < AppConstants.defaultPageSize,
        searchQuery: _currentQuery.isEmpty ? null : _currentQuery,
        activeTypes: _currentTypes,
        activeRegions: _currentRegions,
        activeCategories: _currentCategories,
        showFavorites: _showFavorites,
        showNoFavorites: _showNoFavorites,
        sortBy: _sortBy,
        ascending: _ascending,
      ));
    } catch (e) {
      debugPrint('Error applying sort: $e');
      emit(PokemonError(message: 'Error al ordenar: $e'));
    }
  }

  /// Limpia todos los filtros
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<PokemonState> emit,
  ) async {
    _currentTypes = [];
    _currentRegions = [];
    _currentCategories = [];
    _showFavorites = false;
    _showNoFavorites = false;
    _currentQuery = '';
    _sortBy = 'id';
    _ascending = true;

    add(const LoadPokemonList(refresh: true));
  }

  /// Refresca la lista completa
  Future<void> _onRefreshPokemonList(
    RefreshPokemonList event,
    Emitter<PokemonState> emit,
  ) async {
    add(const LoadPokemonList(refresh: true));
  }

  /// Método privado para obtener Pokémon con los filtros actuales
  Future<List<Pokemon>> _fetchPokemons() async {
    List<Pokemon> pokemons;

    // Si hay búsqueda, usar searchPokemonByName
    if (_currentQuery.isNotEmpty) {
      pokemons = await repository.searchPokemonByName(
        _currentQuery,
        limit: AppConstants.defaultPageSize,
        offset: _offset,
      );
    } else {
      // Convertir tipos de español a API si es necesario
      final apiTypes = _currentTypes.isNotEmpty
          ? PokemonConstants.toApiTypes(_currentTypes)
          : null;

      pokemons = await repository.fetchPokemons(
        limit: AppConstants.defaultPageSize,
        offset: _offset,
        types: apiTypes,
        regions: _currentRegions.isNotEmpty ? _currentRegions : null,
        categories: _currentCategories.isNotEmpty ? _currentCategories : null,
        sortBy: _sortBy,
        ascending: _ascending,
      );
    }

    // Aplicar filtros de favoritos en memoria
    if (_showFavorites) {
      pokemons = pokemons.where((p) => favoritesService.isFavorite(p.id)).toList();
    } else if (_showNoFavorites) {
      pokemons = pokemons.where((p) => !favoritesService.isFavorite(p.id)).toList();
    }

    return pokemons;
  }
}

