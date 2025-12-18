import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import 'pokemon_forms_section.dart';

/// Sección que muestra formas/variantes derivadas de TODA la cadena evolutiva.
///
/// Caso de uso: Bulbasaur no tiene mega, pero Venusaur sí. En el detalle de Bulbasaur
/// queremos mostrar también las megas/variantes de su línea evolutiva.
class PokemonChainFormsSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonChainFormsSection({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    final chainForms = pokemon.formsChain;
    if (chainForms == null || chainForms.isEmpty) return const SizedBox.shrink();

    // Reutilizamos el UI de PokemonFormsSection construyendo un Pokemon “fake”
    // que mantiene los tipos del pokemon actual pero usa formsChain como forms.
    final proxy = pokemon.copyWith(forms: chainForms);

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
        PokemonFormsSection(pokemon: proxy),
      ],
    );
  }
}

