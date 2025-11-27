import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonHeader extends StatefulWidget {
  final Pokemon pokemon;
  final VoidCallback onBack;
  final VoidCallback onFavoriteToggle;
  final bool isFavorite;
  final VoidCallback? onSpriteTap;
  final VoidCallback? onSoundTap;
  final VoidCallback? onShinyToggle;
  final VoidCallback? onShareTap;
  final bool isShiny;

  const PokemonHeader({
    super.key,
    required this.pokemon,
    required this.onBack,
    required this.onFavoriteToggle,
    required this.isFavorite,
    this.onSpriteTap,
    this.onSoundTap,
    this.onShinyToggle,
    this.onShareTap,
    this.isShiny = false,
  });

  @override
  State<PokemonHeader> createState() => _PokemonHeaderState();
}

class _PokemonHeaderState extends State<PokemonHeader> with TickerProviderStateMixin {
  bool _isPressed = false;
  bool _isSoundPressed = false;
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

  @override
  void didUpdateWidget(PokemonHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Animar cuando cambia el estado de favorito
    if (oldWidget.isFavorite != widget.isFavorite) {
      _favoriteAnimationController.forward(from: 0.0);
    }
  }

  Widget _buildSpriteImage(bool isShiny, ColorScheme colorScheme) {
    // Determine which sprite URL to use
    String? spriteUrl;
    if (isShiny && widget.pokemon.shinySpriteUrl != null) {
      spriteUrl = widget.pokemon.shinySpriteUrl;
    } else {
      spriteUrl = widget.pokemon.spriteUrl;
    }

    // Add key to AnimatedSwitcher so it recognizes sprite changes
    return Container(
      key: ValueKey<String>('${widget.pokemon.id}_${isShiny ? 'shiny' : 'normal'}'),
      child: spriteUrl != null
          ? Image.network(
              spriteUrl,
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final primaryType = widget.pokemon.types.isNotEmpty
        ? PokemonConstants.toSpanishType(widget.pokemon.types.first)
        : 'Normal';
    final typeColor = PokemonConstants.getTypeColor(primaryType);
    final typeIcon = PokemonConstants.getTypeIcon(primaryType);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Theme-aware colors for icons
    final bool isDark = theme.brightness == Brightness.dark;
    final Color defaultIconColor = isDark ? Colors.white : Colors.black;
    final Color blurBgColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(15);

    return Container(
      height: 350,
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      child: Stack(
        children: [
          // Background circle with type icon
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

          // Pokémon sprite (center)
          Center(
            child: Hero(
              tag: 'pokemon_${widget.pokemon.id}',
              child: GestureDetector(
                onTapDown: widget.onSpriteTap != null ? (_) => setState(() => _isPressed = true) : null,
                onTapUp: widget.onSpriteTap != null
                    ? (_) {
                        setState(() => _isPressed = false);
                        widget.onSpriteTap?.call();
                      }
                    : null,
                onTapCancel: widget.onSpriteTap != null ? () => setState(() => _isPressed = false) : null,
                child: AnimatedScale(
                  scale: _isPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: _buildSpriteImage(widget.isShiny, colorScheme),
                  ),
                ),
              ),
            ),
          ),

          // Navigation buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back button with blur effect
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onBack,
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: blurBgColor,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              color: defaultIconColor,
                              size: 22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Right-side unified button group with blur
                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          color: blurBgColor,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Favorite
                            InkWell(
                              onTap: widget.onFavoriteToggle,
                              borderRadius: BorderRadius.circular(20),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: widget.isFavorite
                                      ? Colors.red.withAlpha(220)
                                      : Colors.transparent,
                                ),
                                child: ScaleTransition(
                                  scale: _favoriteScaleAnimation,
                                  child: RotationTransition(
                                    turns: _favoriteRotationAnimation,
                                    child: Icon(
                                      widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: widget.isFavorite ? Colors.white : defaultIconColor,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Sound
                            InkWell(
                              onTap: () {
                                widget.onSoundTap?.call();
                                setState(() => _isSoundPressed = true);
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (mounted) setState(() => _isSoundPressed = false);
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.volume_up,
                                  color: _isSoundPressed ? Colors.blueAccent : defaultIconColor,
                                  size: 22,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Shiny
                            InkWell(
                              onTap: widget.onShinyToggle,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.auto_awesome,
                                  color: widget.isShiny ? Colors.amber : defaultIconColor,
                                  size: 22,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            // Share
                            InkWell(
                              onTap: widget.onShareTap,
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                width: 36,
                                height: 36,
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.share,
                                  color: defaultIconColor,
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
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
