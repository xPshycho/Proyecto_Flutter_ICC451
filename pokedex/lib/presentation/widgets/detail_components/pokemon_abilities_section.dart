import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/models/pokemon_ability.dart';
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
      title: 'HABILIDADES',
      icon: Icons.stars,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: pokemon.abilities.map((ability) => _buildAbilityChip(context, ability)).toList(),
      ),
    );
  }

  Widget _buildAbilityChip(BuildContext context, PokemonAbility ability) {
    return GestureDetector(
      onTap: () => _showAbilityDialog(context, ability),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: ability.isHidden
              ? Colors.purple.withAlpha(25)
              : Colors.blue.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: ability.isHidden
                ? Colors.purple.withAlpha(76)
                : Colors.blue.withAlpha(76),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (ability.isHidden) ...[
              Icon(
                Icons.visibility_off,
                size: 18,
                color: Colors.purple.withAlpha(180),
              ),
              const SizedBox(width: 6),
            ],
            Text(
              ability.formattedName,
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: ability.isHidden ? Colors.purple : Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAbilityDialog(BuildContext context, PokemonAbility ability) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.stars,
              color: ability.isHidden ? Colors.purple : Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                ability.formattedName,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: ability.isHidden ? Colors.purple : Colors.blue,
                ),
              ),
            ),
            if (ability.isHidden)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.visibility_off,
                      size: 24,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
          ],
        ),
        content: Text(
          ability.getEffectTruncated(160),
          style: const TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cerrar',
              style: TextStyle(
                fontFamily: 'Pixelated',
                color: ability.isHidden ? Colors.purple : Colors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
