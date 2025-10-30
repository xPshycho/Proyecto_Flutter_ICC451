import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/pokemon.dart';
import '../../data/favorites_service.dart';
import 'FilterBoxes/pokemon_type_colors.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;
  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final primaryType = pokemon.types.isNotEmpty ? pokemon.types.first : null;

    final favService = Provider.of<FavoritesService>(context, listen: true);

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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ID: usar Expanded para evitar overflow
                        Expanded(
                          child: Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6), fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Botón favorito con ancho fijo y sin padding excesivo
                        SizedBox(
                          width: 36,
                          height: 36,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            iconSize: 20,
                            icon: Icon(
                              favService.isFavorite(pokemon.id) ? Icons.favorite : Icons.favorite_border,
                              color: favService.isFavorite(pokemon.id) ? Colors.red : colorScheme.onSurface,
                            ),
                            onPressed: () => favService.toggleFavorite(pokemon),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Nombre con una sola línea y ellipsis para evitar overflow
                    Text(
                      pokemon.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
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
