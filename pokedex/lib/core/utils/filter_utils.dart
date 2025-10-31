import '../constants/pokemon_constants.dart';

/// Utilidades para filtrado de Pokémon
class FilterUtils {
  FilterUtils._();

  /// Verifica si un ID está en alguno de los rangos de región
  static bool isInGenerationRange(int id, List<String> regions) {
    if (regions.isEmpty) return true;

    // Convertir regiones a generaciones para verificar el rango
    return regions.any((region) {
      final gen = PokemonConstants.regionToGen(region);
      final range = PokemonConstants.getGenerationRange(gen);
      return id >= range[0] && id <= range[1];
    });
  }

  /// Extrae valores de tipo bool de un mapa de filtros
  static bool getBoolFilter(Map<String, dynamic> filters, String key) {
    return filters[key] as bool? ?? false;
  }

  /// Extrae valores de tipo lista de un mapa de filtros
  static List<String> getListFilter(Map<String, dynamic> filters, String key) {
    return (filters[key] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }
}
