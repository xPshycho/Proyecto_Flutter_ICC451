import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonWeaknessesSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonWeaknessesSection({
    super.key,
    required this.pokemon,
  });

  List<String> _getWeaknesses() {
    // Mapa simplificado de debilidades por tipo
    final Map<String, List<String>> typeWeaknesses = {
      'Fuego': ['Agua', 'Tierra', 'Roca'],
      'Agua': ['Eléctrico', 'Planta'],
      'Planta': ['Fuego', 'Hielo', 'Veneno', 'Volador', 'Bicho'],
      'Eléctrico': ['Tierra'],
      'Hielo': ['Fuego', 'Lucha', 'Roca', 'Acero'],
      'Lucha': ['Volador', 'Psíquico', 'Hada'],
      'Veneno': ['Tierra', 'Psíquico'],
      'Tierra': ['Agua', 'Planta', 'Hielo'],
      'Volador': ['Eléctrico', 'Hielo', 'Roca'],
      'Psíquico': ['Bicho', 'Fantasma', 'Siniestro'],
      'Bicho': ['Fuego', 'Volador', 'Roca'],
      'Roca': ['Agua', 'Planta', 'Lucha', 'Tierra', 'Acero'],
      'Fantasma': ['Fantasma', 'Siniestro'],
      'Dragón': ['Hielo', 'Dragón', 'Hada'],
      'Siniestro': ['Lucha', 'Bicho', 'Hada'],
      'Acero': ['Fuego', 'Lucha', 'Tierra'],
      'Hada': ['Veneno', 'Acero'],
      'Normal': ['Lucha'],
    };

    final Set<String> weaknesses = {};

    for (final type in pokemon.types) {
      final spanishType = PokemonConstants.toSpanishType(type);
      final typeWeaks = typeWeaknesses[spanishType] ?? [];
      weaknesses.addAll(typeWeaks);
    }

    return weaknesses.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final weaknesses = _getWeaknesses();

    if (weaknesses.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'DEBILIDADES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: weaknesses.map((weakness) {
            final typeColor = PokemonConstants.getTypeColor(weakness);
            final icon = PokemonConstants.getTypeIcon(weakness);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(51),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: typeColor.withAlpha(128),
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    SvgPicture.asset(
                      icon,
                      width: 14,
                      height: 14,
                      colorFilter: ColorFilter.mode(
                        typeColor,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    weakness,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: typeColor,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

