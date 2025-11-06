import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';

class PokemonAbilitiesSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonAbilitiesSection({
    super.key,
    required this.pokemon,
  });

  String _formatAbilityName(String ability) {
    return ability.split('-').map((word) =>
      word[0].toUpperCase() + word.substring(1)
    ).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    if (pokemon.abilities.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stars, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'HABILIDAD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: pokemon.abilities.map((ability) {
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
          }).toList(),
        ),
      ],
    );
  }
}

