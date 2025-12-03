import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import 'section_card.dart';

class PokemonAbilitiesSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonAbilitiesSection({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    if (pokemon.abilities.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'HABILIDAD',
      icon: Icons.stars,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pokemon.abilities.map(_buildAbilityChip).toList(),
      ),
    );
  }

  Widget _buildAbilityChip(String ability) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(25),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withAlpha(76),
          width: 1.5,
        ),
      ),
      child: Text(
        _formatAbilityName(ability),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.blue,
        ),
      ),
    );
  }

  String _formatAbilityName(String ability) {
    return ability.split('-').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }
}

