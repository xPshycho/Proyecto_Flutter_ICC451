import 'package:equatable/equatable.dart';
import '../../../data/models/pokemon.dart';

/// Estados del PokemonBloc
abstract class PokemonState extends Equatable {
  const PokemonState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PokemonInitial extends PokemonState {
  const PokemonInitial();
}

/// Estado de carga
class PokemonLoading extends PokemonState {
  const PokemonLoading();
}

/// Estado cargando más (paginación)
class PokemonLoadingMore extends PokemonState {
  final List<Pokemon> currentPokemons;

  const PokemonLoadingMore(this.currentPokemons);

  @override
  List<Object?> get props => [currentPokemons];
}

/// Estado con datos cargados exitosamente
class PokemonLoaded extends PokemonState {
  final List<Pokemon> pokemons;
  final bool hasReachedMax;
  final String? searchQuery;
  final List<String> activeTypes;
  final List<String> activeRegions;
  final List<String> activeCategories;
  final bool showFavorites;
  final bool showNoFavorites;
  final String sortBy;
  final bool ascending;

  const PokemonLoaded({
    required this.pokemons,
    this.hasReachedMax = false,
    this.searchQuery,
    this.activeTypes = const [],
    this.activeRegions = const [],
    this.activeCategories = const [],
    this.showFavorites = false,
    this.showNoFavorites = false,
    this.sortBy = 'id',
    this.ascending = true,
  });

  /// Copia el estado con valores actualizados
  PokemonLoaded copyWith({
    List<Pokemon>? pokemons,
    bool? hasReachedMax,
    String? searchQuery,
    List<String>? activeTypes,
    List<String>? activeRegions,
    List<String>? activeCategories,
    bool? showFavorites,
    bool? showNoFavorites,
    String? sortBy,
    bool? ascending,
  }) {
    return PokemonLoaded(
      pokemons: pokemons ?? this.pokemons,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
      activeTypes: activeTypes ?? this.activeTypes,
      activeRegions: activeRegions ?? this.activeRegions,
      activeCategories: activeCategories ?? this.activeCategories,
      showFavorites: showFavorites ?? this.showFavorites,
      showNoFavorites: showNoFavorites ?? this.showNoFavorites,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Verifica si hay filtros activos
  bool get hasActiveFilters {
    return activeTypes.isNotEmpty ||
        activeRegions.isNotEmpty ||
        activeCategories.isNotEmpty ||
        showFavorites ||
        showNoFavorites;
  }

  @override
  List<Object?> get props => [
        pokemons,
        hasReachedMax,
        searchQuery,
        activeTypes,
        activeRegions,
        activeCategories,
        showFavorites,
        showNoFavorites,
        sortBy,
        ascending,
      ];
}

/// Estado de error
class PokemonError extends PokemonState {
  final String message;
  final List<Pokemon>? cachedPokemons;

  const PokemonError({
    required this.message,
    this.cachedPokemons,
  });

  @override
  List<Object?> get props => [message, cachedPokemons];
}

