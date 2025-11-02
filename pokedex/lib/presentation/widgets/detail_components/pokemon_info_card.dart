import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonInfoCard extends StatelessWidget {
  final Pokemon pokemon;
  final Function(int)? onEvolutionTap;

  const PokemonInfoCard({
    super.key,
    required this.pokemon,
    this.onEvolutionTap,
  });

  String _formatPokemonName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          // ID
          Text(
            '#${pokemon.id.toString().padLeft(3, '0')}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withAlpha(153),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Nombre
          Text(
            _formatPokemonName(pokemon.name),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Tipos
          _buildTypes(),
          const SizedBox(height: 24),

          // Descripción (si existe)
          _buildDescription(),
          const SizedBox(height: 24),

          // Línea evolutiva (si existe)
          // if (pokemon.evolutions != null && pokemon.evolutions!.isNotEmpty)
          //   _buildEvolutionLine(),

          if (pokemon.evolutions != null && pokemon.evolutions!.isNotEmpty)
            const SizedBox(height: 24),

          // Peso y Altura
          Row(
            children: [
              Expanded(child: _buildStatCard(
                icon: Icons.monitor_weight_outlined,
                label: 'PESO',
                value: pokemon.weight != null
                    ? '${(pokemon.weight! / 10).toStringAsFixed(1)} kg'
                    : 'N/A',
              )),
              const SizedBox(width: 16),
              Expanded(child: _buildStatCard(
                icon: Icons.height,
                label: 'ALTURA',
                value: pokemon.height != null
                    ? '${(pokemon.height! / 10).toStringAsFixed(1)} m'
                    : 'N/A',
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypes() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: pokemon.types.map((type) {
        final spanishType = PokemonConstants.toSpanishType(type);
        final typeColor = PokemonConstants.getTypeColor(spanishType);
        final icon = PokemonConstants.getTypeIcon(spanishType);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: typeColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                SvgPicture.asset(
                  icon,
                  width: 16,
                  height: 16,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                spanishType,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription() {
    // Mostrar la descripción si existe; si no, construir un resumen corto usando tipos y categorías
    final desc = pokemon.description ?? _buildFallbackDescription();
    return Text(
      desc,
      style: const TextStyle(
        fontSize: 14,
        height: 1.5,
      ),
    );
  }

  String _buildFallbackDescription() {
    final parts = <String>[];
    if (pokemon.types.isNotEmpty) {
      final types = pokemon.types.map((t) => PokemonConstants.toSpanishType(t)).join(' / ');
      parts.add('Tipo: $types.');
    }
    if (pokemon.categories != null && pokemon.categories!.isNotEmpty) {
      parts.add('Categorías: ${pokemon.categories!.join(', ')}.');
    }
    if (parts.isEmpty) return 'Descripción no disponible.';
    return parts.join(' ');
  }

  /// Construye la línea evolutiva compacta
  // Widget _buildEvolutionLine() {
  //   final evolutions = pokemon.evolutions!;
  //
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       Row(
  //         children: [
  //           Icon(Icons.change_circle_outlined, size: 16, color: Colors.grey[700]),
  //           const SizedBox(width: 8),
  //           const Text(
  //             'LÍNEA EVOLUTIVA',
  //             style: TextStyle(
  //               fontSize: 10,
  //               fontWeight: FontWeight.bold,
  //               letterSpacing: 1.2,
  //             ),
  //           ),
  //         ],
  //       ),
  //       const SizedBox(height: 12),
  //       SingleChildScrollView(
  //         scrollDirection: Axis.horizontal,
  //         child: Row(
  //           children: List.generate(
  //             evolutions.length * 2 - 1,
  //             (index) {
  //               if (index.isOdd) {
  //                 // Flecha entre evoluciones
  //                 return Padding(
  //                   padding: const EdgeInsets.symmetric(horizontal: 6),
  //                   child: Icon(
  //                     Icons.arrow_forward,
  //                     size: 16,
  //                     color: Colors.grey[600],
  //                   ),
  //                 );
  //               } else {
  //                 // Elemento de evolución
  //                 final evolutionIndex = index ~/ 2;
  //                 final evolution = evolutions[evolutionIndex];
  //                 final isCurrentPokemon = evolution.id == pokemon.id;
  //
  //                 return _buildEvolutionLineItem(
  //                   evolution: evolution,
  //                   isCurrentPokemon: isCurrentPokemon,
  //                 );
  //               }
  //             },
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  /// Construye un elemento individual de la línea evolutiva
  Widget _buildEvolutionLineItem({
    required Pokemon evolution,
    required bool isCurrentPokemon,
  }) {
    final primaryType = evolution.types.isNotEmpty
        ? PokemonConstants.toSpanishType(evolution.types.first)
        : 'Normal';
    final typeColor = PokemonConstants.getTypeColor(primaryType);

    return GestureDetector(
      onTap: () => onEvolutionTap?.call(evolution.id),
      child: Container(
        width: 60,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentPokemon
              ? typeColor.withAlpha(51)
              : Colors.grey.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentPokemon
                ? typeColor
                : Colors.grey.withAlpha(76),
            width: isCurrentPokemon ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Imagen
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withAlpha(76),
              ),
              child: evolution.spriteUrl != null
                  ? Image.network(
                      evolution.spriteUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.catching_pokemon,
                          size: 24,
                          color: typeColor,
                        );
                      },
                    )
                  : Icon(
                      Icons.catching_pokemon,
                      size: 24,
                      color: typeColor,
                    ),
            ),
            const SizedBox(height: 6),
            // Nombre
            Text(
              _formatPokemonName(evolution.name),
              style: TextStyle(
                fontSize: 9,
                fontWeight: isCurrentPokemon ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            // ID
            Text(
              'Nº${evolution.id.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontSize: 8,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withAlpha(25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
