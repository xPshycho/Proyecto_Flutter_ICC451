import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';

class PokemonStatsSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonStatsSection({
    super.key,
    required this.pokemon,
  });

  String _translateStatName(String stat) {
    final translations = {
      'hp': 'PS',
      'attack': 'Ataque',
      'defense': 'Defensa',
      'special-attack': 'At. Esp.',
      'special-defense': 'Def. Esp.',
      'speed': 'Velocidad',
    };
    return translations[stat] ?? stat;
  }

  Color _getStatColor(String stat) {
    final colors = {
      'hp': Colors.red,
      'attack': Colors.orange,
      'defense': Colors.blue,
      'special-attack': Colors.purple,
      'special-defense': Colors.green,
      'speed': Colors.pink,
    };
    return colors[stat] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (pokemon.stats.isEmpty) return const SizedBox.shrink();

    // Ordenar stats en el orden correcto
    final orderedStats = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.analytics_outlined, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'ESTADÍSTICAS BASE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...orderedStats.where((stat) => pokemon.stats.containsKey(stat)).map((stat) {
          final value = pokemon.stats[stat]!;
          final percentage = (value / 255).clamp(0.0, 1.0);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 90,
                  child: Text(
                    _translateStatName(stat),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(
                  width: 35,
                  child: Text(
                    value.toString(),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: percentage,
                      backgroundColor: Colors.grey.withAlpha(51),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getStatColor(stat),
                      ),
                      minHeight: 8,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
