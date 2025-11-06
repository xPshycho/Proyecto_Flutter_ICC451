/// Modelo para el estado de filtros de Pokémon
class PokemonFilters {
  final bool favorites;
  final bool noFavorites;
  final List<String> types;
  final List<String> categories;
  final List<String> regions;
  final String sortBy;
  final bool ascending;

  const PokemonFilters({
    this.favorites = false,
    this.noFavorites = false,
    this.types = const [],
    this.categories = const [],
    this.regions = const [],
    this.sortBy = 'id',
    this.ascending = true,
  });

  /// Crea una copia con valores actualizados
  PokemonFilters copyWith({
    bool? favorites,
    bool? noFavorites,
    List<String>? types,
    List<String>? categories,
    List<String>? regions,
    String? sortBy,
    bool? ascending,
  }) {
    return PokemonFilters(
      favorites: favorites ?? this.favorites,
      noFavorites: noFavorites ?? this.noFavorites,
      types: types ?? this.types,
      categories: categories ?? this.categories,
      regions: regions ?? this.regions,
      sortBy: sortBy ?? this.sortBy,
      ascending: ascending ?? this.ascending,
    );
  }

  /// Resetea todos los filtros a valores por defecto
  PokemonFilters reset() {
    return const PokemonFilters();
  }

  /// Verifica si hay filtros activos
  bool get hasActiveFilters {
    return favorites ||
        noFavorites ||
        types.isNotEmpty ||
        categories.isNotEmpty ||
        regions.isNotEmpty;
  }

  /// Obtiene lista de filtros activos para mostrar
  List<String> getActiveFilterLabels() {
    final List<String> labels = [];
    if (favorites) labels.add('Favoritos');
    if (noFavorites) labels.add('No Favoritos');
    labels.addAll(types);
    labels.addAll(regions);
    labels.addAll(categories);
    return labels;
  }
}
