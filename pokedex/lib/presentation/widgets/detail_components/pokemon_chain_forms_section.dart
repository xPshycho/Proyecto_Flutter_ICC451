import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import 'pokemon_forms_section.dart';

/// Sección que muestra formas/variantes derivadas de TODA la cadena evolutiva.
///
/// Caso de uso: Bulbasaur no tiene mega, pero Venusaur sí. En el detalle de Bulbasaur
/// queremos mostrar también las megas/variantes de su línea evolutiva.
class PokemonChainFormsSection extends StatelessWidget {
  final Pokemon pokemon;
  final bool isShiny;
  final void Function(int pokemonId)? onFormTap;

  const PokemonChainFormsSection({
    super.key,
    required this.pokemon,
    this.isShiny = false,
    this.onFormTap,
  });

  @override
  Widget build(BuildContext context) {
    final chainForms = pokemon.formsChain;
    if (chainForms == null || chainForms.isEmpty) return const SizedBox.shrink();

    final proxy = pokemon.copyWith(forms: chainForms);

    // Renderizamos: header "FORMAS (CADENA)" + contenido de categorías.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_tree_outlined, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'FORMAS (CADENA)',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _FormsContentOnly(pokemon: proxy, isShiny: isShiny, onFormTap: onFormTap),
      ],
    );
  }
}

/// Reutiliza la lógica de `PokemonFormsSection` pero sin pintar su header "FORMAS".
class _FormsContentOnly extends PokemonFormsSection {
  const _FormsContentOnly({
    required super.pokemon,
    required super.isShiny,
    required super.onFormTap,
  });

  @override
  Widget build(BuildContext context) {
    final categorizedForms = categorizeFormsFromPokemon();

    if (categorizedForms.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...categorizedForms.entries.map((entry) => buildFormsCategory(
              entry.key,
              entry.value,
            )),
      ],
    );
  }
}
