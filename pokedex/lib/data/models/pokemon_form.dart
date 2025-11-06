import 'dart:convert';

/// Modelo que representa una forma/variante de un Pokémon (no un Pokémon separado).
///
/// Ejemplos de forms:
/// - Mega Evolutions: charizard-mega-x, charizard-mega-y (normalmente `is_mega` o name contiene "mega")
/// - Formas regionales: rattata-alola, meowth-galar
/// - Formas especiales: gigantamax, primal, event-specific (lunar, etc.)
///
/// Razonamiento: una `PokemonForm` es una variante del `Pokemon` base. Mantenerlas separadas
/// evita duplicar stats y mantiene la entidad principal (`Pokemon`) como fuente de verdad.

class PokemonForm {
  final int id;
  final int pokemonId;
  final String? name; // e.g. "charizard-mega-x" or "rattata-alola"
  final String? formName; // alternate field
  final bool isDefault;
  final bool isBattleOnly;
  final bool? isMega; // may be null if schema doesn't expose it
  final String? spriteUrl;

  PokemonForm({
    required this.id,
    required this.pokemonId,
    this.name,
    this.formName,
    this.isDefault = false,
    this.isBattleOnly = false,
    this.isMega,
    this.spriteUrl,
  });

  factory PokemonForm.fromGraphQL(Map<String, dynamic> json) {
    String? sprite;
    try {
      final sprites = json['pokemon_v2_pokemonsprites'] as List<dynamic>?;
      if (sprites != null && sprites.isNotEmpty) {
        final s = sprites[0]['sprites'];
        if (s is String) {
          try {
            final decoded = s.startsWith('{') ? jsonDecode(s) : null;
            sprite = decoded != null ? decoded['front_default'] as String? : null;
          } catch (_) {
            // ignore
          }
        } else if (s is Map) {
          sprite = s['front_default'] as String?;
        }
      }
    } catch (_) {}

    return PokemonForm(
      id: json['id'] as int,
      pokemonId: json['pokemon_id'] as int,
      name: json['name'] as String?,
      formName: json['form_name'] as String?,
      isDefault: (json['is_default'] as bool?) ?? false,
      isBattleOnly: (json['is_battle_only'] as bool?) ?? false,
      isMega: json['is_mega'] as bool?,
      spriteUrl: sprite,
    );
  }
}
