import 'package:equatable/equatable.dart';
import '../../../data/models/pokemon.dart';

/// Eventos para el FavoritesBloc
abstract class FavoritesEvent extends Equatable {
  const FavoritesEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para alternar favorito
class ToggleFavorite extends FavoritesEvent {
  final Pokemon pokemon;

  const ToggleFavorite(this.pokemon);

  @override
  List<Object?> get props => [pokemon];
}

/// Evento para cargar favoritos
class LoadFavorites extends FavoritesEvent {
  const LoadFavorites();
}

