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
    IconData? icon;

    if (showResult) {
      if (isCorrect) {
        // Opción correcta siempre se muestra en verde
        backgroundColor = const Color(0xFF4FC43C);
        borderColor = const Color(0xFF3DA82E);
        textColor = Colors.black;
        icon = Icons.check_circle;
      } else if (isSelected) {
        // Opción incorrecta que fue seleccionada se muestra en rojo
        backgroundColor = Colors.red.shade700;
        borderColor = Colors.red.shade900;
        textColor = Colors.white;
        icon = Icons.cancel;
      } else {
        // Otras opciones se muestran deshabilitadas
        backgroundColor = const Color(0xFF2A2A2A);
        borderColor = const Color(0xFF444444);
        textColor = Colors.white54;
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
                  if (showResult && icon != null) ...[
                    Icon(
                      icon,
                      color: isCorrect ? Colors.black : Colors.white,
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
