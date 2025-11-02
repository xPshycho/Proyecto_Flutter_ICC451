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

  // Extrae etiquetas simples a partir de `pokemon.forms`.
  // Busca flags explícitos (`is_mega`) y keywords en `name`/`form_name`.
  List<String> _extractFormLabels() {
    final labels = <String>{};
    final forms = pokemon.forms;
    if (forms == null) return [];
    for (final f in forms) {
      try {
        if (f is Map) {
          final isMega = f['is_mega'] as bool?;
          final name = (f['name'] ?? f['form_name'] ?? '') as String? ?? '';
          final lower = name.toLowerCase();
          if (isMega == true || lower.contains('mega')) labels.add('MEGA');
          if (lower.contains('alola') || lower.contains('alolan')) labels.add('ALOLA');
          if (lower.contains('galar')) labels.add('GALAR');
          if (lower.contains('hisui') || lower.contains('hisuan')) labels.add('HISUI');
          if (lower.contains('paldea') || lower.contains('paldean')) labels.add('PALDEA');
          if (lower.contains('gmax') || lower.contains('gigantamax')) labels.add('GIGANTAMAX');
          if (lower.contains('primal')) labels.add('PRIMAL');
          if (lower.contains('lunar') || lower.contains('cosplay')) labels.add('SPECIAL');
        }
      } catch (_) {}
    }
    return labels.toList();
  }

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
                      padding: const EdgeInsets.only(right: 26, top: 8, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // ID
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '#${pokemon.id.toString().padLeft(3, '0')}',
                                style: TextStyle(
                                  color: colorScheme.onSurface.withAlpha(140),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                  letterSpacing: 0.5,
                                ),
                                overflow: TextOverflow.visible,
                                maxLines: 1,
                              ),

                              const SizedBox(width: 8),

                              // Labels de forms (MEGA, Alola, etc.)
                              Builder(builder: (context) {
                                final labels = _extractFormLabels();
                                if (labels.isEmpty) return const SizedBox.shrink();
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: labels.map((lbl) {
                                      final color = lbl == 'MEGA'
                                          ? Colors.orange
                                          : lbl == 'GIGANTAMAX'
                                          ? Colors.purple
                                          : Colors.blueGrey;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: color,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          lbl,
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              }),
                            ]
                          ),

                          if(_extractFormLabels().isEmpty)
                            const SizedBox(height: 6),
                          // Nombre
                          Text(
                            pokemon.name[0].toUpperCase() + pokemon.name.substring(1),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          // Tipos
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: pokemon.types.map((t) {
                                  final spanishType = PokemonConstants.toSpanishType(t);
                                  final typeColor = PokemonConstants.getTypeColor(spanishType);
                                  final icon = PokemonConstants.getTypeIcon(spanishType);
                                  return Container(
                                    margin: const EdgeInsets.only(right: 4),
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: typeColor,
                                      borderRadius: BorderRadius.circular(16),
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
                                            width: 10,
                                            height: 10,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.white,
                                              BlendMode.srcIn,
                                            ),
                                          ),
                                          const SizedBox(width: 3),
                                        ],
                                        Text(
                                          spanishType,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                            height: 1.1,
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
