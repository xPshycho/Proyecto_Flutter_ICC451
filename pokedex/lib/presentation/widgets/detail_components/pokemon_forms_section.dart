import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

/// Sección que muestra las formas alternativas y mega evoluciones de un Pokémon
class PokemonFormsSection extends StatelessWidget {
  final Pokemon pokemon;

  /// Si es true, intenta mostrar sprites shiny (si existen).
  final bool isShiny;

  /// Navegación opcional al detalle al tocar una forma.
  final void Function(int pokemonId)? onFormTap;

  const PokemonFormsSection({
    super.key,
    required this.pokemon,
    this.isShiny = false,
    this.onFormTap,
  });

  String _formatPokemonName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  /// Procesa las formas del Pokémon y las agrupa por tipo
  @protected
  Map<String, List<Map<String, dynamic>>> categorizeFormsFromPokemon() {
    debugPrint('PokemonFormsSection: Processing forms for ${pokemon.name} (ID: ${pokemon.id})');
    debugPrint('Pokemon forms: ${pokemon.forms}');

    final categorized = <String, List<Map<String, dynamic>>>{
      'Mega Evoluciones': <Map<String, dynamic>>[],
      'Formas Regionales': <Map<String, dynamic>>[],
      'Formas Especiales': <Map<String, dynamic>>[],
    };

    final forms = pokemon.forms;
    if (forms == null || forms.isEmpty) {
      debugPrint('PokemonFormsSection: No forms found for ${pokemon.name}');
      return {};
    }

    debugPrint('PokemonFormsSection: Found ${forms.length} forms for ${pokemon.name}');

    for (final f in forms) {
      try {
        if (f is Map<String, dynamic>) {
          final isMega = f['is_mega'] as bool? ?? false;
          final name = (f['name'] ?? f['form_name'] ?? '') as String;
          final isDefault = f['is_default'] as bool? ?? false;
          final formPokemonId = f['pokemon_id'] as int?;

          debugPrint('PokemonFormsSection: Processing form - name: $name, is_mega: $isMega, is_default: $isDefault');

          final lower = name.toLowerCase();

          bool hasVariantKeyword(String s) {
            return s.contains('mega') ||
                s.contains('gmax') ||
                s.contains('gigantamax') ||
                s.contains('alola') ||
                s.contains('alolan') ||
                s.contains('galar') ||
                s.contains('galarian') ||
                s.contains('hisui') ||
                s.contains('hisuian') ||
                s.contains('paldea') ||
                s.contains('paldean') ||
                s.contains('primal') ||
                s.contains('origin') ||
                s.contains('zen') ||
                s.contains('therian') ||
                s.contains('incarnate') ||
                s.contains('blade') ||
                s.contains('shield') ||
                s.contains('altered') ||
                s.contains('sky') ||
                s.contains('land') ||
                s.contains('black') ||
                s.contains('white');
          }

          final hasVariant = isMega || hasVariantKeyword(lower) || name.contains('-');

          // En PokeAPI/GraphQL, muchas formas/variantes vienen con `is_default: true`.
          // Solo saltamos el Pokémon base del detalle.
          final isBaseOfCurrentPokemon =
              (formPokemonId != null && formPokemonId == pokemon.id) && !hasVariant;

          if (isBaseOfCurrentPokemon) {
            debugPrint('PokemonFormsSection: Skipping base form for current pokemon: $name');
            continue;
          }

          // Además, si estamos renderizando "formas de cadena" (proxy) pueden colarse
          // los Pokémon base de otras etapas (ivysaur, venusaur) que NO son formas.
          // Los filtramos: no tienen keywords, no tienen '-' y no son mega.
          final isBaseOfOtherPokemon =
              (formPokemonId != null && formPokemonId != pokemon.id) &&
              isDefault &&
              !hasVariant;

          if (isBaseOfOtherPokemon) {
            debugPrint('PokemonFormsSection: Skipping base form from other pokemon in chain: $name');
            continue;
          }

          // Categorizar mega evoluciones
          if (isMega || lower.contains('mega')) {
            categorized['Mega Evoluciones']!.add(f);
            debugPrint('PokemonFormsSection: Added mega evolution: $name');
          }
          // Categorizar formas regionales
          else if (lower.contains('alola') || lower.contains('alolan') ||
              lower.contains('galar') || lower.contains('galarian') ||
              lower.contains('hisui') || lower.contains('hisuian') ||
              lower.contains('paldea') || lower.contains('paldean')) {
            categorized['Formas Regionales']!.add(f);
            debugPrint('PokemonFormsSection: Added regional form: $name');
          }
          // Categorizar formas especiales
          else if (lower.contains('gmax') || lower.contains('gigantamax') ||
              lower.contains('primal') || lower.contains('origin') ||
              lower.contains('zen') || lower.contains('therian') ||
              lower.contains('incarnate') || lower.contains('blade') ||
              lower.contains('shield') || lower.contains('altered') ||
              lower.contains('sky') || lower.contains('land') ||
              lower.contains('black') || lower.contains('white') ||
              name.contains('-')) {
            categorized['Formas Especiales']!.add(f);
            debugPrint('PokemonFormsSection: Added special form: $name');
          }
          // Si no encaja en las categorías, es especial
          else {
            categorized['Formas Especiales']!.add(f);
            debugPrint('PokemonFormsSection: Added uncategorized form as special: $name');
          }
        }
      } catch (e) {
        debugPrint('Error procesando forma: $e');
      }
    }

    // Remover categorías vacías
    categorized.removeWhere((key, value) => value.isEmpty);
    debugPrint('PokemonFormsSection: Final categories: ${categorized.keys.toList()}');

    return categorized;
  }

  /// Obtiene el nombre mostrable de una forma
  String _getDisplayName(Map<String, dynamic> form) {
    final name = form['name'] as String? ?? '';
    final formName = form['form_name'] as String? ?? '';

    if (formName.isNotEmpty) return _formatPokemonName(formName);
    if (name.isNotEmpty) {
      // Extraer la parte específica de la forma del nombre completo
      final parts = name.split('-');
      if (parts.length > 1) {
        return parts.skip(1).map((p) => _formatPokemonName(p)).join(' ');
      }
      return _formatPokemonName(name);
    }
    return 'Forma Alternativa';
  }

  /// Obtiene la etiqueta de tipo de forma
  String _getFormLabel(Map<String, dynamic> form) {
    final isMega = form['is_mega'] as bool? ?? false;
    final name = (form['name'] ?? form['form_name'] ?? '') as String;
    final lower = name.toLowerCase();

    if (isMega || lower.contains('mega')) return 'MEGA';
    if (lower.contains('alola')) return 'ALOLA';
    if (lower.contains('galar')) return 'GALAR';
    if (lower.contains('hisui')) return 'HISUI';
    if (lower.contains('paldea')) return 'PALDEA';
    if (lower.contains('gmax') || lower.contains('gigantamax')) return 'GMAX';
    if (lower.contains('primal')) return 'PRIMAL';
    return 'ESPECIAL';
  }

  /// Obtiene el color para la etiqueta de forma
  Color _getLabelColor(String label) {
    switch (label) {
      case 'MEGA':
        return Colors.orange;
      case 'ALOLA':
        return Colors.blue;
      case 'GALAR':
        return Colors.purple;
      case 'HISUI':
        return Colors.green;
      case 'PALDEA':
        return Colors.red;
      case 'GMAX':
        return Colors.pink;
      case 'PRIMAL':
        return Colors.deepOrange;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorizedForms = categorizeFormsFromPokemon();

    if (categorizedForms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.transform, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'FORMAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...categorizedForms.entries.map((entry) => buildFormsCategory(
          entry.key,
          entry.value,
        )),
      ],
    );
  }

  Widget buildFormsCategory(String categoryName, List<Map<String, dynamic>> forms) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          categoryName,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: forms.map((form) => _buildFormItem(form)).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildFormItem(Map<String, dynamic> form) {
    final normalSpriteUrl = form['sprite_url'] as String?;
    // Heurística: sprite shiny en GitHub sprites (la mayoría de ids existen)
    final formPokemonId = form['pokemon_id'] as int?;
    final shinySpriteUrl = formPokemonId != null
        ? 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/shiny/$formPokemonId.png'
        : null;

    final spriteUrl = isShiny && shinySpriteUrl != null ? shinySpriteUrl : normalSpriteUrl;

    final label = _getFormLabel(form);
    final labelColor = _getLabelColor(label);
    final displayName = _getDisplayName(form);

    final fromChain = formPokemonId != null && formPokemonId != pokemon.id;

    final primaryType = pokemon.types.isNotEmpty
        ? PokemonConstants.toSpanishType(pokemon.types.first)
        : 'Normal';
    final typeColor = PokemonConstants.getTypeColor(primaryType);

    final canNavigate = onFormTap != null && formPokemonId != null;

    final card = Container(
      margin: const EdgeInsets.only(right: 12),
      width: 120,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withAlpha(76),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: typeColor.withAlpha(76),
            ),
            child: spriteUrl != null
                ? Image.network(
                    spriteUrl,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback a normal si shiny falla.
                      if (isShiny && normalSpriteUrl != null) {
                        return Image.network(
                          normalSpriteUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.catching_pokemon,
                            size: 40,
                            color: typeColor,
                          ),
                        );
                      }
                      return Icon(
                        Icons.catching_pokemon,
                        size: 40,
                        color: typeColor,
                      );
                    },
                  )
                : Icon(
                    Icons.catching_pokemon,
                    size: 40,
                    color: typeColor,
                  ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: labelColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            displayName,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (fromChain) ...[
            const SizedBox(height: 4),
            Text(
              'De la cadena',
              style: TextStyle(fontSize: 9, color: Colors.grey[600], fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
          if (canNavigate) ...[
            const SizedBox(height: 4),
            Icon(Icons.open_in_new, size: 14, color: Colors.grey[600]),
          ],
        ],
      ),
    );

    if (!canNavigate) return card;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => onFormTap!(formPokemonId!),
      child: card,
    );
  }
}
