import 'package:flutter/material.dart';
import '../../../core/constants/quiz_translations.dart';
import '../../../data/models/quiz_mode.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/services/language_service.dart';
import 'package:provider/provider.dart';

/// Widget que muestra el atributo del Pokémon según la modalidad del quiz
class QuizDisplayArea extends StatelessWidget {
  final QuizMode mode;
  final Pokemon pokemon;
  final VoidCallback? onSoundPlay;
  final bool showResult;

  const QuizDisplayArea({
    super.key,
    required this.mode,
    required this.pokemon,
    this.onSoundPlay,
    this.showResult = false,
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
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (mode) {
      case QuizMode.silhouette:
        return _buildSilhouette();
      case QuizMode.description:
        return _buildDescription(context);
      case QuizMode.number:
        return _buildNumber();
      case QuizMode.sound:
        return _buildSound(context);
    }
  }

  /// Muestra la silueta del Pokémon (sprite en negro) o el sprite a color si ya se respondió
  Widget _buildSilhouette() {
    return Center(
      child: pokemon.spriteUrl != null
          ? AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: showResult
                  ? Image.network(
                      pokemon.spriteUrl!,
                      key: ValueKey('color_${pokemon.id}'),
                      width: 250,
                      height: 250,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.catching_pokemon,
                          size: 120,
                          color: Colors.white,
                        );
                      },
                    )
                  : ColorFiltered(
                      key: ValueKey('silhouette_${pokemon.id}'),
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
                    ),
            )
          : Icon(
              Icons.catching_pokemon,
              size: 120,
              color: showResult ? Colors.white : Colors.black,
            ),
    );
  }

  /// Muestra la descripción del Pokémon
  Widget _buildDescription(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final tr = QuizTranslations.forLanguage(languageService.currentLanguage);

    final description = pokemon.description ?? tr.mysteriousPokemon;

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
  Widget _buildSound(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context, listen: false);
    final tr = QuizTranslations.forLanguage(languageService.currentLanguage);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            tr.listenToSound,
            style: const TextStyle(
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
          Text(
            tr.tapToPlay,
            style: const TextStyle(
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
