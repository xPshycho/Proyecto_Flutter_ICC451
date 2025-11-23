import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/favorites_service.dart';
import 'favorites_event.dart';
import 'favorites_state.dart';

/// BLoC para gestionar el estado de favoritos
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {
  final FavoritesService favoritesService;

  FavoritesBloc({required this.favoritesService})
      : super(const FavoritesInitial()) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);

    // Cargar favoritos al inicializar
    add(const LoadFavorites());
  }

  /// Carga la lista de favoritos
  void _onLoadFavorites(LoadFavorites event, Emitter<FavoritesState> emit) {
    final favoriteIds = favoritesService.all;
    emit(FavoritesLoaded(favoriteIds));
  }

  /// Alterna el estado de favorito de un Pokémon
  void _onToggleFavorite(ToggleFavorite event, Emitter<FavoritesState> emit) {
    favoritesService.toggleFavorite(event.pokemon);
    final favoriteIds = favoritesService.all;
    emit(FavoritesLoaded(favoriteIds));
  }
}
