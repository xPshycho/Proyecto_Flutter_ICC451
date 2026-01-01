import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/models/pokemon.dart';
import '../../core/constants/pokemon_constants.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';

class PokemonCard extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;
  const PokemonCard({super.key, required this.pokemon, this.onTap});

  @override
  State<PokemonCard> createState() => _PokemonCardState();
}

class _PokemonCardState extends State<PokemonCard> with SingleTickerProviderStateMixin {
  late AnimationController _favoriteAnimationController;
  late Animation<double> _favoriteScaleAnimation;
  late Animation<double> _favoriteRotationAnimation;

  @override
  void initState() {
    super.initState();
    _favoriteAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _favoriteScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.1)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.1, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_favoriteAnimationController);

    _favoriteRotationAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 0.05),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: -0.05),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: -0.05, end: 0.05),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.05, end: 0.0),
        weight: 25,
      ),
    ]).animate(_favoriteAnimationController);
  }

  @override
  void dispose() {
    _favoriteAnimationController.dispose();
    super.dispose();
  }

  // Extrae etiquetas de categorías del Pokémon
  List<String> _extractFormLabels() {
    final labels = <String>{};

    // Primero usar las categorías asignadas al Pokémon
    final categories = widget.pokemon.categories;
    if (categories != null) {
      for (final cat in categories) {
        final lower = cat.toLowerCase();
        if (lower == 'mega') labels.add('MEGA');
        if (lower == 'gigantamax') labels.add('GIGANTAMAX');
        if (lower.contains('alola')) labels.add('ALOLA');
        if (lower.contains('galar')) labels.add('GALAR');
        if (lower.contains('hisui')) labels.add('HISUI');
        if (lower.contains('paldea')) labels.add('PALDEA');
      }
    }

    // Si no hay categorías, extraer del nombre del Pokémon
    if (labels.isEmpty) {
      final name = widget.pokemon.name.toLowerCase();
      if (name.contains('-mega')) labels.add('MEGA');
      if (name.contains('-gmax')) labels.add('GIGANTAMAX');
      if (name.contains('-alola')) labels.add('ALOLA');
      if (name.contains('-galar')) labels.add('GALAR');
      if (name.contains('-hisui')) labels.add('HISUI');
      if (name.contains('-paldea')) labels.add('PALDEA');
    }

    return labels.toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: widget.onTap,
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
                    child: Hero(
                      tag: 'pokemon_${widget.pokemon.id}',
                      child: widget.pokemon.spriteUrl != null
                          ? Image.network(
                              widget.pokemon.spriteUrl!,
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
                                '#${widget.pokemon.id.toString().padLeft(3, '0')}',
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

                              // Labels de forms (MEGA, GMAX, etc.)
                              Flexible(
                                child: Builder(builder: (context) {
                                  final labels = _extractFormLabels();
                                  if (labels.isEmpty) return const SizedBox.shrink();
                                  return Wrap(
                                    spacing: 4,
                                    runSpacing: 2,
                                    children: labels.take(1).map((lbl) {
                                      // Acortar etiquetas largas
                                      final displayLabel = lbl == 'GIGANTAMAX' ? 'GMAX' : lbl;
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
                                          displayLabel,
                                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                }),
                              ),
                            ]
                          ),

                          if(_extractFormLabels().isEmpty)
                            const SizedBox(height: 6),
                          // Nombre
                          Text(
                            widget.pokemon.name[0].toUpperCase() + widget.pokemon.name.substring(1),
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
                                children: widget.pokemon.types.map((t) {
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
              child: BlocBuilder<FavoritesBloc, FavoritesState>(
                builder: (context, state) {
                  final isFavorite = state is FavoritesLoaded && state.isFavorite(widget.pokemon.id);

                  return SizedBox(
                    width: 30,
                    height: 30,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 18,
                      icon: ScaleTransition(
                        scale: _favoriteScaleAnimation,
                        child: RotationTransition(
                          turns: _favoriteRotationAnimation,
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : colorScheme.onSurface,
                          ),
                        ),
                      ),
                      onPressed: () {
                        _favoriteAnimationController.forward(from: 0.0);
                        context.read<FavoritesBloc>().add(ToggleFavorite(widget.pokemon));
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
