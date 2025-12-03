import 'package:equatable/equatable.dart';
import '../../../data/models/pokemon_move.dart';

abstract class MovesEvent extends Equatable {
  const MovesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMoves extends MovesEvent {
  final int pokemonId;
  final bool forceRefresh;

  const LoadMoves(this.pokemonId, {this.forceRefresh = false});

  @override
  List<Object?> get props => [pokemonId, forceRefresh];
}

class LoadMoreMoves extends MovesEvent {
  const LoadMoreMoves();
}

class ApplyMovesFilters extends MovesEvent {
  final List<String>? types;
  final List<String>? learnMethods;
  final List<String>? versionGroups;

  const ApplyMovesFilters({
    this.types,
    this.learnMethods,
    this.versionGroups,
  });

  @override
  List<Object?> get props => [types, learnMethods, versionGroups];
}

class SortMoves extends MovesEvent {
  final String sortBy; // 'name', 'level', 'power'
  final bool ascending;

  const SortMoves(this.sortBy, this.ascending);

  @override
  List<Object?> get props => [sortBy, ascending];
}

class ClearMovesFilters extends MovesEvent {
  const ClearMovesFilters();
}

class SearchMoves extends MovesEvent {
  final String query;

  const SearchMoves(this.query);

  @override
  List<Object?> get props => [query];
}
