import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/pokemon.dart';
import '../../data/favorites_service.dart';
import '../../core/constants/pokemon_constants.dart';

class PokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;
  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final favService = Provider.of<FavoritesService>(context, listen: true);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Imagen
                  SizedBox(
                    width: 91,
                    height: 91,
                    child: pokemon.spriteUrl != null
                        ? Image.network(
                            pokemon.spriteUrl!,
                            width: 91,
                            height: 91,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 91,
                                height: 91,
                                color: colorScheme.onSurface.withAlpha(25),
                                child: Icon(
                                  Icons.catching_pokemon,
                                  size: 40,
                                  color: colorScheme.onSurface.withAlpha(128),
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 91,
                            height: 91,
                            color: colorScheme.onSurface.withAlpha(25),
                            child: Icon(
                              Icons.catching_pokemon,
                              size: 40,
                              color: colorScheme.onSurface.withAlpha(128),
                            ),
                          ),
                  ),

                  const SizedBox(width: 12),

                  // Texto y tipos - alineados con la imagen
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 26, top: 4, bottom: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ID
                          Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(
                              color: colorScheme.onSurface.withAlpha(140),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.visible,
                            maxLines: 1,
                          ),

                          const SizedBox(height: 2),

                          // Nombre
                          Text(
                            pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 6),

                          // Tipos
                          Flexible(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: pokemon.types.map((t) {
                                  final spanishType = PokemonConstants.toSpanishType(t);
                                  final typeColor = PokemonConstants.getTypeColor(spanishType);
                                  final icon = PokemonConstants.getTypeIcon(spanishType);
                                  return Container(
                                    margin: const EdgeInsets.only(right: 6),
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: typeColor,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: typeColor.withAlpha(204),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (icon != null) ...[
                                          SvgPicture.asset(
                                            icon,
                                            width: 12,
                                            height: 12,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                        ],
                                        Text(
                                          spanishType,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                            height: 1.2,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Botón de favorito en la esquina superior derecha
            Positioned(
              top: 4,
              right: 4,
              child: SizedBox(
                width: 30,
                height: 30,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  iconSize: 18,
                  icon: Icon(
                    favService.isFavorite(pokemon.id) ? Icons.favorite : Icons.favorite_border,
                    color: favService.isFavorite(pokemon.id) ? Colors.red : colorScheme.onSurface,
                  ),
                  onPressed: () => favService.toggleFavorite(pokemon),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
