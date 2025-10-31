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
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Imagen (reduced size)
              SizedBox(
                width: 91,
                height: 91,
                child: pokemon.spriteUrl != null
                    ? Image.network(pokemon.spriteUrl!, width: 91, height: 91, fit: BoxFit.contain)
                    : Container(width: 91, height: 91, color: Colors.grey[200]),

              ),

              const SizedBox(width: 8),

              // Texto y tipos
              Flexible(
                fit: FlexFit.loose,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // ID: usar Expanded para evitar overflow
                        Expanded(
                          child: Text(
                            '#${pokemon.id.toString().padLeft(3, '0')}',
                            style: TextStyle(color: colorScheme.onSurface.withAlpha(140), fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),

                        // Botón favorito con ancho fijo y sin padding excesivo (reduced)
                        SizedBox(
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
                      ],
                    ),

                    const SizedBox(height: 6),
                    // Nombre con tamaño ligeramente menor
                    Text(
                      pokemon.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    // Mostrar tipos en una fila desplazable horizontalmente para evitar overflow vertical
                    SizedBox(
                      height: 24,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: pokemon.types.map((t) {
                            // Traducir el tipo de inglés a español
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
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
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
            ],
          ),
        ),
      ),
    );
  }
}
