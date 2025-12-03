/// Modelo para la efectividad de tipos
class TypeEffectiveness {
  final String attackingType;
  final String defendingType;
  final double multiplier;

  const TypeEffectiveness({
    required this.attackingType,
    required this.defendingType,
    required this.multiplier,
  });

  bool get isSuperEffective => multiplier > 1.0;
  bool get isNotVeryEffective => multiplier < 1.0 && multiplier > 0.0;
  bool get isNoEffect => multiplier == 0.0;
  bool get isNormalEffective => multiplier == 1.0;
}

/// Resultado de efectividad calculada para un Pokémon
class PokemonTypeEffectiveness {
  final Map<String, double> attackingTypeMultipliers;

  const PokemonTypeEffectiveness(this.attackingTypeMultipliers);

  /// Obtiene tipos por categoría de efectividad
  List<String> get superEffectiveTypes => _getTypesByMultiplier((m) => m >= 4.0);
  List<String> get veryEffectiveTypes => _getTypesByMultiplier((m) => m == 2.0);
  List<String> get resistantTypes => _getTypesByMultiplier((m) => m == 0.5);
  List<String> get veryResistantTypes => _getTypesByMultiplier((m) => m <= 0.25 && m > 0);
  List<String> get immuneTypes => _getTypesByMultiplier((m) => m == 0.0);

  List<String> _getTypesByMultiplier(bool Function(double) condition) {
    return attackingTypeMultipliers.entries
        .where((entry) => condition(entry.value))
        .map((entry) => entry.key)
        .toList()
      ..sort();
  }

  /// Obtiene el multiplicador para un tipo atacante
  double getMultiplier(String attackingType) {
    return attackingTypeMultipliers[attackingType] ?? 1.0;
  }
}
