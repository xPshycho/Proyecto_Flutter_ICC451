import 'package:flutter/material.dart';
import '../../../data/models/quiz_mode.dart';
import '../../../data/models/pokemon.dart';

/// Widget que muestra el atributo del Pokémon según la modalidad del quiz
class QuizDisplayArea extends StatelessWidget {
  final QuizMode mode;
  final Pokemon pokemon;
  final VoidCallback? onSoundPlay;

  const QuizDisplayArea({
    super.key,
    required this.mode,
    required this.pokemon,
    this.onSoundPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4FC43C),
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    switch (mode) {
      case QuizMode.silhouette:
        return _buildSilhouette();
      case QuizMode.description:
        return _buildDescription();
      case QuizMode.number:
        return _buildNumber();
      case QuizMode.sound:
        return _buildSound();
    }
  }

  /// Muestra la silueta del Pokémon (sprite en negro)
  Widget _buildSilhouette() {
    return Center(
      child: pokemon.spriteUrl != null
          ? ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.black,
                BlendMode.srcIn,
              ),
              child: Image.network(
                pokemon.spriteUrl!,
                width: 250,
                height: 250,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.catching_pokemon,
                    size: 120,
                    color: Colors.black,
                  );
                },
              ),
            )
          : const Icon(
              Icons.catching_pokemon,
              size: 120,
              color: Colors.black,
            ),
    );
  }

  /// Muestra la descripción del Pokémon
  Widget _buildDescription() {
    final description = pokemon.description ??
        'Un misterioso Pokémon del que se sabe muy poco...';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description,
                size: 48,
                color: Color(0xFF4FC43C),
              ),
              const SizedBox(height: 16),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Muestra el número del Pokémon
  Widget _buildNumber() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Nº',
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 32,
              color: Color(0xFF4FC43C),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            pokemon.id.toString().padLeft(4, '0'),
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 80,
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 8,
            ),
          ),
        ],
      ),
    );
  }

  /// Muestra un botón de sonido para reproducir el cry
  Widget _buildSound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Escucha el sonido',
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 18,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 24),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onSoundPlay,
              borderRadius: BorderRadius.circular(100),
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4FC43C),
                ),
                child: const Icon(
                  Icons.volume_up,
                  size: 80,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Toca para reproducir',
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 14,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }
}

