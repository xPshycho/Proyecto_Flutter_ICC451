import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonHeader extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback onBack;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final VoidCallback? onSpriteTap;

  const PokemonHeader({
    super.key,
    required this.pokemon,
    required this.onBack,
    required this.onFavoriteToggle,
    required this.isFavorite,
    this.onSpriteTap,
  });

  @override
  State<PokemonHeader> createState() => _PokemonHeaderState();
}

class _PokemonHeaderState extends State<PokemonHeader> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final primaryType = widget.pokemon.types.isNotEmpty
        ? PokemonConstants.toSpanishType(widget.pokemon.types.first)
        : 'Normal';
    final typeColor = PokemonConstants.getTypeColor(primaryType);
    final typeIcon = PokemonConstants.getTypeIcon(primaryType);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Stack(
        children: [
          // Círculo de fondo con el ícono del tipo (con color)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withAlpha(128),
              ),
              child: typeIcon != null
                  ? Center(
                      child: SvgPicture.asset(
                        typeIcon,
                        width: 150,
                        height: 150,
                        colorFilter: ColorFilter.mode(
                          colorScheme.surface.withAlpha(178),
                          BlendMode.srcIn,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Imagen del Pokémon (debe estar ANTES de los botones para que no bloquee los clics)
          Center(
            child: GestureDetector(
              onTapDown: widget.onSpriteTap != null ? (_) => setState(() => _isPressed = true) : null,
              onTapUp: widget.onSpriteTap != null ? (_) {
                setState(() => _isPressed = false);
                widget.onSpriteTap?.call();
              } : null,
              onTapCancel: widget.onSpriteTap != null ? () => setState(() => _isPressed = false) : null,
              child: AnimatedScale(
                scale: _isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: widget.pokemon.spriteUrl != null
                    ? Image.network(
                        widget.pokemon.spriteUrl!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.catching_pokemon,
                            size: 200,
                            color: colorScheme.onSurface.withAlpha(128),
                          );
                        },
                      )
                    : Icon(
                        Icons.catching_pokemon,
                        size: 200,
                        color: colorScheme.onSurface.withAlpha(128),
                      ),
              ),
            ),
          ),

          // Botones de navegación (deben estar AL FINAL para que estén en el frente)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de regreso
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onBack,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colorScheme.onSurface.withAlpha(128),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back,
                          color: colorScheme.surface,
                          size: 24,
                        ),
                      ),
                    ),
                  ),

                  // Botón de favorito
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onFavoriteToggle,
                      borderRadius: BorderRadius.circular(30),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: widget.isFavorite
                              ? Colors.red.withAlpha(230)
                              : colorScheme.onSurface.withAlpha(128),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(51),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: widget.isFavorite ? Colors.white : colorScheme.surface,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
