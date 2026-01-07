import 'package:equatable/equatable.dart';
import '../../../data/models/pokemon_move.dart';

abstract class MovesState extends Equatable {
  const MovesState();

  @override
  List<Object?> get props => [];
}

class MovesInitial extends MovesState {
  const MovesInitial();
}

class MovesLoading extends MovesState {
  const MovesLoading();
}

class MovesLoadingMore extends MovesState {
  final List<PokemonMove> currentMoves;
  final List<String>? appliedTypes;
  final List<String>? appliedLearnMethods;
  final List<String>? appliedVersionGroups;
  final String? currentSortBy;
  final bool? currentAscending;
  final String? currentSearchQuery;

  const MovesLoadingMore(
    this.currentMoves, {
    this.appliedTypes,
    this.appliedLearnMethods,
    this.appliedVersionGroups,
    this.currentSortBy,
    this.currentAscending,
    this.currentSearchQuery,
  });

  @override
  List<Object?> get props => [
        currentMoves,
        appliedTypes,
        appliedLearnMethods,
        appliedVersionGroups,
        currentSortBy,
        currentAscending,
        currentSearchQuery,
      ];
}

class MovesLoaded extends MovesState {
  final List<PokemonMove> moves;
  final List<PokemonMove> filteredMoves;
  final int currentPage;
  final int totalMoves;
  final bool hasReachedMax;
  final List<String>? appliedTypes;
  final List<String>? appliedLearnMethods;
  final List<String>? appliedVersionGroups;
  final String? currentSortBy;
  final bool currentAscending;
  final String? currentSearchQuery;

  const MovesLoaded({
    required this.moves,
    required this.filteredMoves,
    this.currentPage = 0,
    this.totalMoves = 0,
    this.hasReachedMax = false,
    this.appliedTypes,
    this.appliedLearnMethods,
    this.appliedVersionGroups,
    this.currentSortBy,
    this.currentAscending = true,
    this.currentSearchQuery,
  });

  MovesLoaded copyWith({
    List<PokemonMove>? moves,
    List<PokemonMove>? filteredMoves,
    int? currentPage,
    int? totalMoves,
    bool? hasReachedMax,
    List<String>? appliedTypes,
    List<String>? appliedLearnMethods,
    List<String>? appliedVersionGroups,
    String? currentSortBy,
    bool? currentAscending,
    String? currentSearchQuery,
  }) {
    return MovesLoaded(
      moves: moves ?? this.moves,
      filteredMoves: filteredMoves ?? this.filteredMoves,
      currentPage: currentPage ?? this.currentPage,
      totalMoves: totalMoves ?? this.totalMoves,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      appliedTypes: appliedTypes ?? this.appliedTypes,
      appliedLearnMethods: appliedLearnMethods ?? this.appliedLearnMethods,
      appliedVersionGroups: appliedVersionGroups ?? this.appliedVersionGroups,
      currentSortBy: currentSortBy ?? this.currentSortBy,
      currentAscending: currentAscending ?? this.currentAscending,
      currentSearchQuery: currentSearchQuery ?? this.currentSearchQuery,
    );
  }

  @override
  List<Object?> get props => [
        moves,
        filteredMoves,
        currentPage,
        totalMoves,
        hasReachedMax,
        appliedTypes,
        appliedLearnMethods,
        appliedVersionGroups,
        currentSortBy,
        currentAscending,
        currentSearchQuery,
      ];

  bool get hasActiveFilters =>
      (appliedTypes?.isNotEmpty ?? false) ||
      (appliedLearnMethods?.isNotEmpty ?? false) ||
      (appliedVersionGroups?.isNotEmpty ?? false) ||
      (currentSearchQuery?.isNotEmpty ?? false);
}

class MovesError extends MovesState {
  final String message;

  const MovesError(this.message);

  @override
  List<Object?> get props => [message];
}

