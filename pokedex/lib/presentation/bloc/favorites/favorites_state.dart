import 'package:equatable/equatable.dart';

/// Estados del FavoritesBloc
abstract class FavoritesState extends Equatable {
  const FavoritesState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class FavoritesInitial extends FavoritesState {
  const FavoritesInitial();
}

/// Estado con lista de IDs de favoritos
class FavoritesLoaded extends FavoritesState {
  final List<int> favoriteIds;

  const FavoritesLoaded(this.favoriteIds);

  /// Verifica si un ID es favorito
  bool isFavorite(int id) => favoriteIds.contains(id);

  @override
  List<Object?> get props => [favoriteIds];
}

