import 'package:equatable/equatable.dart';

/// Eventos para el PokemonBloc
abstract class PokemonEvent extends Equatable {
  const PokemonEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar la página inicial de Pokémon
class LoadPokemonList extends PokemonEvent {
  final bool refresh;

  const LoadPokemonList({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

/// Evento para cargar más Pokémon (paginación)
class LoadMorePokemons extends PokemonEvent {
  const LoadMorePokemons();
}

/// Evento para buscar Pokémon por nombre
class SearchPokemon extends PokemonEvent {
  final String query;

  const SearchPokemon(this.query);

  @override
  List<Object?> get props => [query];
}

/// Evento para aplicar filtros
class ApplyFilters extends PokemonEvent {
  final List<String> types;
  final List<String> regions;
  final List<String> categories;
  final bool favorites;
  final bool noFavorites;

  const ApplyFilters({
    this.types = const [],
    this.regions = const [],
    this.categories = const [],
    this.favorites = false,
    this.noFavorites = false,
  });

  @override
  List<Object?> get props => [types, regions, categories, favorites, noFavorites];
}

/// Evento para aplicar ordenamiento
class ApplySort extends PokemonEvent {
  final String sortBy;
  final bool ascending;

  const ApplySort({
    required this.sortBy,
    required this.ascending,
  });

  @override
  List<Object?> get props => [sortBy, ascending];
}

/// Evento para limpiar filtros
class ClearFilters extends PokemonEvent {
  const ClearFilters();
}

/// Evento para refrescar la lista
class RefreshPokemonList extends PokemonEvent {
  const RefreshPokemonList();
}

