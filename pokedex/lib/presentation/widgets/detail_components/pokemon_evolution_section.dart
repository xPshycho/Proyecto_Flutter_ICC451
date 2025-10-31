import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonEvolutionSection extends StatelessWidget {
  final Pokemon pokemon;
  final Function(int)? onEvolutionTap;

  const PokemonEvolutionSection({
    super.key,
    required this.pokemon,
    this.onEvolutionTap,
  });

  String _formatPokemonName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  // Extrae etiquetas de forms a partir de `pokemon.forms` (misma heurística que en la tarjeta)
  List<String> _extractFormLabelsFromPokemon(Pokemon pokemon) {
    final labels = <String>{};
    final forms = pokemon.forms;
    if (forms == null) return [];
    for (final f in forms) {
      try {
        if (f is Map) {
          final isMega = f['is_mega'] as bool?;
          final name = (f['name'] ?? f['form_name'] ?? '') as String? ?? '';
          final lower = name.toLowerCase();
          if (isMega == true || lower.contains('mega')) labels.add('MEGA');
          if (lower.contains('alola') || lower.contains('alolan')) labels.add('ALOLA');
          if (lower.contains('galar')) labels.add('GALAR');
          if (lower.contains('hisui') || lower.contains('hisuan')) labels.add('HISUI');
          if (lower.contains('paldea') || lower.contains('paldean')) labels.add('PALDEA');
          if (lower.contains('gmax') || lower.contains('gigantamax')) labels.add('GIGANTAMAX');
          if (lower.contains('primal')) labels.add('PRIMAL');
        }
      } catch (_) {}
    }
    return labels.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (pokemon.evolutions == null || pokemon.evolutions!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.change_circle_outlined, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'EVOLUCIONES',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEvolutionChain(),
      ],
    );
  }

  Widget _buildEvolutionChain() {
    final evolutions = pokemon.evolutions!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          evolutions.length * 2 - 1,
          (index) {
            if (index.isOdd) {
              // Arrow between evolutions
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.arrow_forward,
                  size: 24,
                  color: Colors.grey[600],
                ),
              );
            } else {
              // Evolution item
              final evolutionIndex = index ~/ 2;
              final evolution = evolutions[evolutionIndex];
              final isCurrentPokemon = evolution.id == pokemon.id;

              return _buildEvolutionItem(
                evolution: evolution,
                isCurrentPokemon: isCurrentPokemon,
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildEvolutionItem({
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
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCurrentPokemon
              ? typeColor.withAlpha(51)
              : Colors.grey.withAlpha(25),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCurrentPokemon
                ? typeColor
                : Colors.grey.withAlpha(76),
            width: isCurrentPokemon ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          children: [
            // Imagen
            Container(
              width: 70,
              height: 70,
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
                          size: 40,
                          color: typeColor,
                        );
                      },
                    )
                  : Icon(
                      Icons.catching_pokemon,
                      size: 40,
                      color: typeColor,
                    ),
            ),
            const SizedBox(height: 8),
            // Nombre
            Text(
              _formatPokemonName(evolution.name),
              style: TextStyle(
                fontSize: 11,
                fontWeight: isCurrentPokemon ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            // Mostrar etiquetas de forma si existen
            Builder(builder: (context) {
              final labels = _extractFormLabelsFromPokemon(evolution);
              if (labels.isEmpty) return const SizedBox.shrink();
              return Wrap(
                spacing: 4,
                alignment: WrapAlignment.center,
                children: labels.map((lbl) {
                  final bg = lbl == 'MEGA' ? Colors.orange : Colors.blueGrey;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
                    child: Text(lbl, style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              );
            }),
            const SizedBox(height: 4),
            // ID
            Text(
              'Nº${evolution.id.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            // Tipos
            Wrap(
              spacing: 4,
              alignment: WrapAlignment.center,
              children: evolution.types.take(2).map((type) {
                final spanishType = PokemonConstants.toSpanishType(type);
                final typeColor = PokemonConstants.getTypeColor(spanishType);

                return Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: typeColor,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
