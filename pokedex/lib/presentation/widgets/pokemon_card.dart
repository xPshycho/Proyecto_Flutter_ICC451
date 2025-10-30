import 'package:flutter/material.dart';
import '../../data/models/pokemon.dart';
import 'FilterBoxes/pokemon_type_colors.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;
  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : null;
    final bgColor = primaryType != null ? PokemonTypeColors.getTypeColor(primaryType) : colorScheme.surface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen
              if (pokemon.spriteUrl != null)
                Image.network(pokemon.spriteUrl!, width: 72, height: 72, fit: BoxFit.contain)
              else
                Container(width: 72, height: 72, color: Colors.grey[200]),

              const SizedBox(width: 12),

              // Texto y tipos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${pokemon.id.toString().padLeft(3, '0')}', style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(pokemon.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: pokemon.types.map((t) {
                        final typeColor = PokemonTypeColors.getTypeColor(t);
                        final icon = PokemonTypeColors.getTypeIcon(t);
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: typeColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (icon != null) ...[
                                Image.asset(icon, width: 14, height: 14),
                                const SizedBox(width: 6),
                              ],
                              Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

