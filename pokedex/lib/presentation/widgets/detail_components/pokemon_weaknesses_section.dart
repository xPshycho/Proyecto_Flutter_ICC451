import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonWeaknessesSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonWeaknessesSection({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveness = pokemon.typeEffectiveness;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              const Text(
                'DAÑO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildMultiplierBadges(),
          const SizedBox(height: 16),
          _buildTypeEffectivenessGrid(effectiveness),
        ],
      ),
    );
  }

  Widget _buildMultiplierBadges() {
    final multipliers = [4.0, 2.0, 1.0, 0.5, 0.25, 0.0];

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: multipliers.map((multiplier) {
        String label;
        if (multiplier == 4.0) {
          label = '×4';
        } else if (multiplier == 2.0) {
          label = '×2';
        } else if (multiplier == 1.0) {
          label = '×1';
        } else if (multiplier == 0.5) {
          label = '×½';
        } else if (multiplier == 0.25) {
          label = '×¼';
        } else {
          label = '×0';
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypeEffectivenessGrid(dynamic effectiveness) {
    final typeMultipliers = <String, double>{};

    for (final type in effectiveness.superEffectiveTypes) {
      typeMultipliers[type] = 4.0;
    }
    for (final type in effectiveness.veryEffectiveTypes) {
      typeMultipliers[type] = 2.0;
    }
    for (final type in effectiveness.resistantTypes) {
      typeMultipliers[type] = 0.5;
    }
    for (final type in effectiveness.veryResistantTypes) {
      typeMultipliers[type] = 0.25;
    }
    for (final type in effectiveness.immuneTypes) {
      typeMultipliers[type] = 0.0;
    }

    if (typeMultipliers.isEmpty) return const SizedBox.shrink();

    final sortedEntries = typeMultipliers.entries.toList()
      ..sort((a, b) {
        final multiplierCompare = b.value.compareTo(a.value);
        if (multiplierCompare != 0) return multiplierCompare;
        return a.key.compareTo(b.key);
      });

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedEntries.map((entry) {
        return _buildTypeChipWithMultiplier(entry.key, entry.value);
      }).toList(),
    );
  }

  Widget _buildTypeChipWithMultiplier(String type, double multiplier) {
    final typeColor = PokemonConstants.getTypeColor(type);
    final icon = PokemonConstants.getTypeIcon(type);

    String multiplierText;
    if (multiplier == 4.0) {
      multiplierText = '×4';
    } else if (multiplier == 2.0) {
      multiplierText = '×2';
    } else if (multiplier == 0.5) {
      multiplierText = '×½';
    } else if (multiplier == 0.25) {
      multiplierText = '×¼';
    } else if (multiplier == 0.0) {
      multiplierText = '×0';
    } else {
      multiplierText = '×1';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            type,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              multiplierText,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
