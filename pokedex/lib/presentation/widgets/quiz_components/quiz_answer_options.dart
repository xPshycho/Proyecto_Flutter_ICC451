import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';

/// Widget que muestra las 4 opciones de respuesta
class QuizAnswerOptions extends StatelessWidget {
  final List<Pokemon> options;
  final int correctPokemonId;
  final bool showResult;
  final int? selectedPokemonId;
  final Function(int) onAnswerSelected;

  const QuizAnswerOptions({
    super.key,
    required this.options,
    required this.correctPokemonId,
    required this.showResult,
    required this.selectedPokemonId,
    required this.onAnswerSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final pokemon = options[index];
        return _buildOptionButton(pokemon);
      },
    );
  }

  Widget _buildOptionButton(Pokemon pokemon) {
    final isCorrect = pokemon.id == correctPokemonId;
    final isSelected = pokemon.id == selectedPokemonId;

    Color backgroundColor;
    Color borderColor;
    Color textColor = Colors.white;

    if (showResult) {
      if (isCorrect) {
        backgroundColor = const Color(0xFF4FC43C);
        borderColor = const Color(0xFF3DA82E);
        textColor = Colors.black;
      } else if (isSelected && !isCorrect) {
        backgroundColor = Colors.red.shade700;
        borderColor = Colors.red.shade900;
      } else {
        backgroundColor = const Color(0xFF2A2A2A);
        borderColor = const Color(0xFF444444);
      }
    } else {
      backgroundColor = const Color(0xFF2A2A2A);
      borderColor = const Color(0xFF4FC43C);
    }

    final pokemonName = pokemon.name[0].toUpperCase() + pokemon.name.substring(1);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: showResult ? null : () => onAnswerSelected(pokemon.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 3),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showResult && isCorrect) ...[
                    const Icon(
                      Icons.check_circle,
                      color: Colors.black,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (showResult && isSelected && !isCorrect) ...[
                    const Icon(
                      Icons.cancel,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      pokemonName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pixelated',
                        fontSize: 16,
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

