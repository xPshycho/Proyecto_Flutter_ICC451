import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/pokemon_move.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../core/constants/app_constants.dart';
import 'moves_event.dart';
import 'moves_state.dart';

class MovesBloc extends Bloc<MovesEvent, MovesState> {
  final PokemonRepository _repository;

  // Datos completos sin filtrar
  List<PokemonMove> _allMoves = [];
  int _pokemonId = 0;

  MovesBloc(this._repository) : super(const MovesInitial()) {
    on<LoadMoves>(_onLoadMoves);
    on<LoadMoreMoves>(_onLoadMoreMoves);
    on<ApplyMovesFilters>(_onApplyFilters);
    on<SortMoves>(_onSortMoves);
    on<ClearMovesFilters>(_onClearFilters);
    on<SearchMoves>(_onSearchMoves);
  }

  Future<void> _onLoadMoves(LoadMoves event, Emitter<MovesState> emit) async {
    if (!event.forceRefresh && _pokemonId == event.pokemonId && _allMoves.isNotEmpty) {
      // Ya tenemos los datos, aplicar filtros actuales
      _emitFilteredMoves(emit);
      return;
    }

    emit(const MovesLoading());

    try {
      _pokemonId = event.pokemonId;
      _allMoves = await _repository.fetchPokemonMoves(event.pokemonId);

      emit(MovesLoaded(
        moves: _allMoves,
        filteredMoves: _getPagedMoves(_allMoves, 0),
        totalMoves: _allMoves.length,
        hasReachedMax: _allMoves.length <= AppConstants.defaultPageSize,
      ));
    } catch (e) {
      emit(MovesError('Error al cargar movimientos: $e'));
    }
  }

  Future<void> _onLoadMoreMoves(LoadMoreMoves event, Emitter<MovesState> emit) async {
    if (state is! MovesLoaded) return;

    final currentState = state as MovesLoaded;
    if (currentState.hasReachedMax) return;

    emit(MovesLoadingMore(
      currentState.filteredMoves,
      appliedTypes: currentState.appliedTypes,
      appliedLearnMethods: currentState.appliedLearnMethods,
      appliedVersionGroups: currentState.appliedVersionGroups,
      currentSortBy: currentState.currentSortBy,
      currentAscending: currentState.currentAscending,
      currentSearchQuery: currentState.currentSearchQuery,
    ));

    try {
      final filteredAndSorted = _applyAllFilters(
        appliedTypes: currentState.appliedTypes,
        appliedLearnMethods: currentState.appliedLearnMethods,
        appliedVersionGroups: currentState.appliedVersionGroups,
        sortBy: currentState.currentSortBy,
        ascending: currentState.currentAscending,
        searchQuery: currentState.currentSearchQuery,
      );

      final nextPage = currentState.currentPage + 1;
      final newMoves = _getPagedMoves(filteredAndSorted, nextPage);
      final allDisplayedMoves = [...currentState.filteredMoves, ...newMoves];

      emit(currentState.copyWith(
        filteredMoves: allDisplayedMoves,
        currentPage: nextPage,
        hasReachedMax: allDisplayedMoves.length >= filteredAndSorted.length,
      ));
    } catch (e) {
      emit(MovesError('Error al cargar más movimientos: $e'));
    }
  }

  Future<void> _onApplyFilters(ApplyMovesFilters event, Emitter<MovesState> emit) async {
    if (state is! MovesLoaded) return;

    final currentState = state as MovesLoaded;

    final filteredAndSorted = _applyAllFilters(
      appliedTypes: event.types,
      appliedLearnMethods: event.learnMethods,
      appliedVersionGroups: event.versionGroups,
      sortBy: currentState.currentSortBy,
      ascending: currentState.currentAscending,
      searchQuery: currentState.currentSearchQuery,
    );

    emit(currentState.copyWith(
      filteredMoves: _getPagedMoves(filteredAndSorted, 0),
      currentPage: 0,
      appliedTypes: event.types,
      appliedLearnMethods: event.learnMethods,
      appliedVersionGroups: event.versionGroups,
      hasReachedMax: filteredAndSorted.length <= AppConstants.defaultPageSize,
    ));
  }

  Future<void> _onSortMoves(SortMoves event, Emitter<MovesState> emit) async {
    if (state is! MovesLoaded) return;

    final currentState = state as MovesLoaded;

    final filteredAndSorted = _applyAllFilters(
      appliedTypes: currentState.appliedTypes,
      appliedLearnMethods: currentState.appliedLearnMethods,
      appliedVersionGroups: currentState.appliedVersionGroups,
      sortBy: event.sortBy,
      ascending: event.ascending,
      searchQuery: currentState.currentSearchQuery,
    );

    emit(currentState.copyWith(
      filteredMoves: _getPagedMoves(filteredAndSorted, 0),
      currentPage: 0,
      currentSortBy: event.sortBy,
      currentAscending: event.ascending,
      hasReachedMax: filteredAndSorted.length <= AppConstants.defaultPageSize,
    ));
  }

  Future<void> _onClearFilters(ClearMovesFilters event, Emitter<MovesState> emit) async {
    if (state is! MovesLoaded) return;

    final currentState = state as MovesLoaded;

    emit(currentState.copyWith(
      filteredMoves: _getPagedMoves(_allMoves, 0),
      currentPage: 0,
      appliedTypes: null,
      appliedLearnMethods: null,
      appliedVersionGroups: null,
      currentSortBy: null,
      currentAscending: true,
      currentSearchQuery: null,
      hasReachedMax: _allMoves.length <= AppConstants.defaultPageSize,
    ));
  }

  Future<void> _onSearchMoves(SearchMoves event, Emitter<MovesState> emit) async {
    if (state is! MovesLoaded) return;

    final currentState = state as MovesLoaded;

    final filteredAndSorted = _applyAllFilters(
      appliedTypes: currentState.appliedTypes,
      appliedLearnMethods: currentState.appliedLearnMethods,
      appliedVersionGroups: currentState.appliedVersionGroups,
      sortBy: currentState.currentSortBy,
      ascending: currentState.currentAscending,
      searchQuery: event.query,
    );

    emit(currentState.copyWith(
      filteredMoves: _getPagedMoves(filteredAndSorted, 0),
      currentPage: 0,
      currentSearchQuery: event.query,
      hasReachedMax: filteredAndSorted.length <= AppConstants.defaultPageSize,
    ));
  }

  List<PokemonMove> _applyAllFilters({
    List<String>? appliedTypes,
    List<String>? appliedLearnMethods,
    List<String>? appliedVersionGroups,
    String? sortBy,
    bool? ascending,
    String? searchQuery,
  }) {
    var filtered = List<PokemonMove>.from(_allMoves);

    // Filtro por tipo
    if (appliedTypes != null && appliedTypes.isNotEmpty) {
      filtered = filtered.where((move) {
        return appliedTypes.contains(move.typeNameSpanish);
      }).toList();
    }

    // Filtro por método de aprendizaje
    if (appliedLearnMethods != null && appliedLearnMethods.isNotEmpty) {
      filtered = filtered.where((move) {
        return appliedLearnMethods.contains(move.learnMethodSpanish);
      }).toList();
    }

    // Filtro por grupo de versión
    if (appliedVersionGroups != null && appliedVersionGroups.isNotEmpty) {
      filtered = filtered.where((move) {
        return appliedVersionGroups.contains(move.versionGroupSpanish);
      }).toList();
    }

    // Filtro por búsqueda
    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((move) {
        return move.nameSpanish.toLowerCase().contains(query) ||
            move.name.toLowerCase().contains(query);
      }).toList();
    }

    // Ordenamiento
    if (sortBy != null) {
      filtered.sort((a, b) {
        int comparison = 0;

        switch (sortBy) {
          case 'name':
            comparison = a.nameSpanish.compareTo(b.nameSpanish);
            break;
          case 'level':
            final aLevel = a.level ?? 999;
            final bLevel = b.level ?? 999;
            comparison = aLevel.compareTo(bLevel);
            break;
          case 'power':
            final aPower = a.power ?? 0;
            final bPower = b.power ?? 0;
            comparison = aPower.compareTo(bPower);
            break;
          case 'type':
            comparison = a.typeNameSpanish.compareTo(b.typeNameSpanish);
            break;
        }

        return (ascending ?? true) ? comparison : -comparison;
      });
    }

    return filtered;
  }

  List<PokemonMove> _getPagedMoves(List<PokemonMove> moves, int page) {
    final startIndex = page * AppConstants.defaultPageSize;
    final endIndex = (startIndex + AppConstants.defaultPageSize).clamp(0, moves.length);

    if (startIndex >= moves.length) return [];

    return moves.sublist(startIndex, endIndex);
  }

  void _emitFilteredMoves(Emitter<MovesState> emit) {
    if (state is MovesLoaded) {
      final currentState = state as MovesLoaded;
      final filteredAndSorted = _applyAllFilters(
        appliedTypes: currentState.appliedTypes,
        appliedLearnMethods: currentState.appliedLearnMethods,
        appliedVersionGroups: currentState.appliedVersionGroups,
        sortBy: currentState.currentSortBy,
        ascending: currentState.currentAscending,
        searchQuery: currentState.currentSearchQuery,
      );

      emit(currentState.copyWith(
        filteredMoves: _getPagedMoves(filteredAndSorted, 0),
        currentPage: 0,
        hasReachedMax: filteredAndSorted.length <= AppConstants.defaultPageSize,
      ));
    }
  }
}
