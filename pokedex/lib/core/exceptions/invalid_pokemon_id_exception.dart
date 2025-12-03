/// Excepción personalizada para IDs de Pokémon inválidos
class InvalidPokemonIdException implements Exception {
  final int pokemonId;
  final String reason;

  const InvalidPokemonIdException({
    required this.pokemonId,
    required this.reason,
  });

  @override
  String toString() {
    return 'InvalidPokemonIdException: $reason (ID: $pokemonId)';
  }

  /// Crea una excepción para IDs fuera del rango por defecto
  factory InvalidPokemonIdException.outOfRange(int id) {
    return InvalidPokemonIdException(
      pokemonId: id,
      reason: 'El ID $id está fuera del rango de Pokémon por defecto (1-1025)',
    );
  }

  /// Crea una excepción para formas regionales
  factory InvalidPokemonIdException.regionalForm(int id) {
    return InvalidPokemonIdException(
      pokemonId: id,
      reason: 'El ID $id corresponde a una forma regional o especial',
    );
  }

  /// Verifica si el ID corresponde a una forma regional
  bool get isRegionalForm => pokemonId > 10000;

  /// Verifica si el ID es demasiado alto
  bool get isTooHigh => pokemonId > 1025;
}
