import '../constants/pokemon_constants.dart';
import '../exceptions/invalid_pokemon_id_exception.dart';

/// Utilidades para validación de Pokémon
class PokemonValidationUtils {
  PokemonValidationUtils._();

  /// Valida que un ID de Pokémon sea válido para consulta por defecto
  ///
  /// Lanza [InvalidPokemonIdException] si:
  /// - El ID está fuera del rango 1-1025
  /// - El ID corresponde a una forma regional (> 10000)
  static void validateDefaultPokemon(int id) {
    if (!PokemonConstants.isDefaultPokemon(id)) {
      if (id > 10000) {
        throw InvalidPokemonIdException.regionalForm(id);
      } else {
        throw InvalidPokemonIdException.outOfRange(id);
      }
    }
  }

  /// Verifica si un ID es válido sin lanzar excepción
  static bool isValidDefaultPokemon(int id) {
    return PokemonConstants.isDefaultPokemon(id) && id <= 10000;
  }

  /// Obtiene el tipo de problema con un ID específico
  static String? getValidationMessage(int id) {
    if (id < PokemonConstants.minDefaultPokemonId) {
      return 'El ID debe ser mayor a 0';
    }

    if (id > PokemonConstants.maxDefaultPokemonId) {
      if (id > 10000) {
        return 'Este ID corresponde a una forma regional o especial';
      } else {
        return 'El ID está fuera del rango de Pokémon por defecto (1-1025)';
      }
    }

    return null; // ID válido
  }
}
