import 'package:flutter/material.dart';
import '../../data/models/pokemon.dart';
import '../../core/constants/pokemon_constants.dart';

/// Widget que representa una carta Pokémon estilo TCG para compartir
class PokemonCardWidget extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonCardWidget({
    super.key,
    required this.pokemon,
  });

  @override
  Widget build(BuildContext context) {
    final capitalizedName = '${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)}';
    final primaryType = pokemon.types.isNotEmpty
        ? PokemonConstants.toSpanishType(pokemon.types.first)
        : 'Normal';
    final typeColor = PokemonConstants.getTypeColor(primaryType);

    // Variables de tamaño para la imagen de fondo
    const double backgroundImageWidth = 287;
    const double backgroundImageHeight = 237;

    return Container(
      width: 319,
      height: 585,
      decoration: BoxDecoration(
        // Borde plateado exterior
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFE8E8E8),
            Color(0xFFBDBDBD),
            Color(0xFFE8E8E8),
            Color(0xFFBDBDBD),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            // Fondo del color del tipo
            color: typeColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header: Nombre y tipo en la misma línea
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      capitalizedName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 2,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                    // Icono del tipo
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.catching_pokemon,
                          color: typeColor,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Contenedor de imagen con borde plateado
                Container(
                  width: double.infinity,
                  height: 280,
                  decoration: BoxDecoration(
                    // Borde plateado fino
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE8E8E8),
                        Color(0xFFBDBDBD),
                        Color(0xFFE8E8E8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(9),
                      child: Column(
                        children: [
                          // Área de la imagen con fondo y sprite
                          Expanded(
                            child: Stack(
                              children: [
                                // Fondo de la imagen con tamaño fijo
                                Center(
                                  child: SizedBox(
                                    width: backgroundImageWidth,
                                    height: backgroundImageHeight,
                                    child: Image.asset(
                                      'assets/images/backgrounds/card/default.png',
                                      width: backgroundImageWidth,
                                      height: backgroundImageHeight,
                                      fit: BoxFit.fill,
                                      errorBuilder: (context, error, stackTrace) {
                                        return Container(
                                          width: backgroundImageWidth,
                                          height: backgroundImageHeight,
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: [
                                                Colors.blue[200]!,
                                                Colors.blue[50]!,
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                // Sprite del Pokémon
                                Center(
                                  child: pokemon.spriteUrl != null
                                      ? Image.network(
                                          pokemon.spriteUrl!,
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.contain,
                                          errorBuilder: (context, error, stackTrace) {
                                            return const Icon(
                                              Icons.catching_pokemon,
                                              size: 120,
                                              color: Colors.grey,
                                            );
                                          },
                                        )
                                      : const Icon(
                                          Icons.catching_pokemon,
                                          size: 120,
                                          color: Colors.grey,
                                        ),
                                ),
                              ],
                            ),
                          ),
                          // Información básica (Número, Peso, Altura) - dentro del contenedor de imagen
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: const BoxDecoration(
                              color: Color(0xFFD9D9D9),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(9),
                                bottomRight: Radius.circular(9),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  '#${pokemon.id.toString().padLeft(3, '0')}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  pokemon.weight != null
                                      ? '${(pokemon.weight! / 10).toStringAsFixed(1)}kg'
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  pokemon.height != null
                                      ? '${(pokemon.height! / 10).toStringAsFixed(1)}m'
                                      : 'N/A',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Descripción del Pokémon
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        pokemon.description ?? 'Este Pokémon es único y especial en su especie. Se caracteriza por su lealtad y fuerza, siendo un compañero ideal para cualquier entrenador.',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.3,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

