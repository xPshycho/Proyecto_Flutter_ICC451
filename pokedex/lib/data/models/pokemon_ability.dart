/// Modelo que representa una habilidad de Pokémon
class PokemonAbility {
  final String name;
  final bool isHidden;
  final String? effect;

  const PokemonAbility({
    required this.name,
    this.isHidden = false,
    this.effect,
  });

  /// Crea una instancia desde datos GraphQL
  factory PokemonAbility.fromGraphQL(Map<String, dynamic> data) {
    final ability = data['pokemon_v2_ability'] as Map<String, dynamic>?;
    final isHidden = data['is_hidden'] as bool? ?? false;

    String name = '';
    String? effect;

    if (ability != null) {
      // Intentar obtener nombre en español
      final abilityNames = ability['pokemon_v2_abilitynames'] as List<dynamic>?;
      if (abilityNames != null && abilityNames.isNotEmpty) {
        name = abilityNames[0]['name'] as String? ?? ability['name'] as String? ?? '';
      } else {
        name = ability['name'] as String? ?? '';
      }

      // Intentar obtener efecto en español
      final effectTexts = ability['pokemon_v2_abilityeffecttexts'] as List<dynamic>?;
      if (effectTexts != null && effectTexts.isNotEmpty) {
        final shortEffect = effectTexts[0]['short_effect'] as String?;
        if (shortEffect != null && shortEffect.isNotEmpty) {
          effect = shortEffect;
        }
      }

      // Fallback: intentar obtener flavor text en español
      if (effect == null || effect.isEmpty) {
        final flavorTexts = ability['pokemon_v2_abilityflavortexts'] as List<dynamic>?;
        if (flavorTexts != null && flavorTexts.isNotEmpty) {
          final flavorText = flavorTexts[0]['flavor_text'] as String?;
          if (flavorText != null && flavorText.isNotEmpty) {
            effect = flavorText.replaceAll('\n', ' ').replaceAll('\f', ' ').trim();
          }
        }
      }
    }

    return PokemonAbility(
      name: name,
      isHidden: isHidden,
      effect: effect,
    );
  }

  /// Formatea el nombre de la habilidad (capitaliza palabras)
  String get formattedName {
    if (name.isEmpty) return '';
    return name.split('-').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  /// Obtiene el efecto truncado a un límite de caracteres
  String getEffectTruncated([int maxLength = 160]) {
    if (effect == null || effect!.isEmpty) {
      return 'Sin descripción disponible';
    }
    if (effect!.length <= maxLength) {
      return effect!;
    }
    return '${effect!.substring(0, maxLength)}...';
  }

  @override
  String toString() => 'PokemonAbility(name: $name, isHidden: $isHidden)';
}

