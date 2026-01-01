import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonEvolutionSection extends StatelessWidget {
  final Pokemon pokemon;
  final Function(int)? onEvolutionTap;
  final bool isShiny;

  // IDs de la familia Eevee
  static const int _eeveeId = 133;
  static const Set<int> _eeveelutionIds = {
    134, // Vaporeon
    135, // Jolteon
    136, // Flareon
    196, // Espeon
    197, // Umbreon
    470, // Leafeon
    471, // Glaceon
    700, // Sylveon
  };

  // IDs de la familia Deoxys
  static const int _deoxysNormalId = 386;
  static const Set<int> _deoxysFormIds = {
    10001, // Deoxys-Attack
    10002, // Deoxys-Defense
    10003, // Deoxys-Speed
  };

  const PokemonEvolutionSection({
    super.key,
    required this.pokemon,
    this.onEvolutionTap,
    this.isShiny = false,
  });

  String _formatPokemonName(String name) {
    return name[0].toUpperCase() + name.substring(1);
  }

  Widget _buildEvolutionSprite(Pokemon evolution, Color typeColor, {double size = 70}) {
    String? spriteUrl;
    if (isShiny && evolution.shinySpriteUrl != null) {
      spriteUrl = evolution.shinySpriteUrl;
    } else {
      spriteUrl = evolution.spriteUrl;
    }

    if (spriteUrl != null) {
      return Image.network(
        spriteUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.catching_pokemon,
            size: size * 0.6,
            color: typeColor,
          );
        },
      );
    } else {
      return Icon(
        Icons.catching_pokemon,
        size: size * 0.6,
        color: typeColor,
      );
    }
  }

  /// Verifica si es la familia de Eevee
  bool _isEeveeFamily() {
    if (pokemon.id == _eeveeId) return true;
    if (_eeveelutionIds.contains(pokemon.id)) return true;

    // Verificar si alguna evolución es Eevee o eeveelution
    if (pokemon.evolutions != null) {
      for (final evo in pokemon.evolutions!) {
        if (evo.id == _eeveeId || _eeveelutionIds.contains(evo.id)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Verifica si es la familia de Deoxys
  bool _isDeoxysFamily() {
    if (pokemon.id == _deoxysNormalId) return true;
    if (_deoxysFormIds.contains(pokemon.id)) return true;

    // Verificar si alguna evolución es Deoxys o sus formas
    if (pokemon.evolutions != null) {
      for (final evo in pokemon.evolutions!) {
        if (evo.id == _deoxysNormalId || _deoxysFormIds.contains(evo.id)) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (pokemon.evolutions == null || pokemon.evolutions!.isEmpty) {
      // Para Deoxys, mostrar sus formas aunque no tenga evoluciones tradicionales
      if (_isDeoxysFamily()) {
        return _buildDeoxysFormsSection();
      }
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
              'LÍNEA EVOLUTIVA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildEvolutionDisplay(),
      ],
    );
  }

  Widget _buildEvolutionDisplay() {
    if (_isEeveeFamily()) {
      return _buildEeveeEvolutionTree();
    } else if (_isDeoxysFamily()) {
      return _buildDeoxysFormsTree();
    } else {
      return _buildEvolutionChain();
    }
  }

  /// Construye la sección de formas de Deoxys cuando no hay evoluciones
  Widget _buildDeoxysFormsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.change_circle_outlined, size: 20, color: Colors.grey[700]),
            const SizedBox(width: 8),
            const Text(
              'FORMAS DE DEOXYS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDeoxysFormsTree(),
      ],
    );
  }

  /// Construye el árbol de formas de Deoxys
  Widget _buildDeoxysFormsTree() {
    // Crear lista de formas de Deoxys
    final List<_DeoxysForm> deoxysFormsList = [
      _DeoxysForm(id: _deoxysNormalId, name: 'Deoxys', formName: 'Normal'),
      _DeoxysForm(id: 10001, name: 'Deoxys-Attack', formName: 'Ataque'),
      _DeoxysForm(id: 10002, name: 'Deoxys-Defense', formName: 'Defensa'),
      _DeoxysForm(id: 10003, name: 'Deoxys-Speed', formName: 'Velocidad'),
    ];

    // Forma normal es el origen
    final normalForm = deoxysFormsList.first;
    final otherForms = deoxysFormsList.skip(1).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Deoxys Normal (origen)
          _buildDeoxysFormItem(
            formData: normalForm,
            isCurrentPokemon: pokemon.id == normalForm.id,
          ),
          const SizedBox(width: 8),
          // Conector y ramas
          _buildDeoxysFormBranches(otherForms),
        ],
      ),
    );
  }

  /// Construye las ramas de formas de Deoxys
  Widget _buildDeoxysFormBranches(List<_DeoxysForm> forms) {
    if (forms.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Línea horizontal hacia las ramas
        Container(
          width: 20,
          height: 2,
          color: Colors.grey[400],
        ),
        // Contenedor con línea vertical y ramas
        CustomPaint(
          painter: _BranchLinePainter(
            itemCount: forms.length,
            itemHeight: 95,
            color: Colors.grey[400]!,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: forms.map((form) {
              return _buildDeoxysFormRow(form);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Construye una fila de forma de Deoxys
  Widget _buildDeoxysFormRow(_DeoxysForm form) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Espacio para la línea vertical
          const SizedBox(width: 2),
          // Línea horizontal hacia el nodo
          Container(
            width: 20,
            height: 2,
            color: Colors.grey[400],
          ),
          // Flecha con etiqueta de forma
          _buildDeoxysFormArrow(form.formName),
          // Nodo de la forma
          _buildDeoxysFormItem(
            formData: form,
            isCurrentPokemon: pokemon.id == form.id,
          ),
        ],
      ),
    );
  }

  /// Flecha con etiqueta de forma para Deoxys
  Widget _buildDeoxysFormArrow(String formName) {
    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 16,
            color: Colors.purple[400],
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
            ),
            child: Text(
              formName,
              style: TextStyle(
                fontSize: 7,
                fontWeight: FontWeight.bold,
                color: Colors.purple[700],
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Item de forma de Deoxys
  Widget _buildDeoxysFormItem({
    required _DeoxysForm formData,
    required bool isCurrentPokemon,
  }) {
    final typeColor = PokemonConstants.getTypeColor('Psíquico');
    final spriteUrl = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/${formData.id}.png';

    return GestureDetector(
      onTap: () => onEvolutionTap?.call(formData.id),
      child: Container(
        width: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentPokemon
              ? typeColor.withAlpha(51)
              : Colors.grey.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentPokemon ? typeColor : Colors.grey.withAlpha(76),
            width: isCurrentPokemon ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withAlpha(76),
              ),
              child: Image.network(
                spriteUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.catching_pokemon,
                    size: 30,
                    color: typeColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 4),
            Text(
              formData.formName,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isCurrentPokemon ? FontWeight.bold : FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              'Nº${formData.id > 10000 ? formData.id.toString() : formData.id.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontSize: 7,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el árbol de evoluciones de Eevee
  Widget _buildEeveeEvolutionTree() {
    final evolutions = pokemon.evolutions!;

    // Encontrar Eevee
    final eevee = evolutions.firstWhere(
      (e) => e.id == _eeveeId,
      orElse: () => evolutions.first,
    );

    // Obtener las eeveelutions
    final eeveelutions = evolutions
        .where((e) => _eeveelutionIds.contains(e.id))
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Eevee (origen)
          _buildEvolutionItem(
            evolution: eevee,
            isCurrentPokemon: eevee.id == pokemon.id,
          ),
          const SizedBox(width: 8),
          // Conector y ramas
          _buildEeveeBranches(eeveelutions),
        ],
      ),
    );
  }

  /// Construye las ramas de evolución de Eevee
  Widget _buildEeveeBranches(List<Pokemon> eeveelutions) {
    if (eeveelutions.isEmpty) return const SizedBox.shrink();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Línea horizontal hacia las ramas
        Container(
          width: 20,
          height: 2,
          color: Colors.grey[400],
        ),
        // Contenedor con línea vertical y ramas
        CustomPaint(
          painter: _BranchLinePainter(
            itemCount: eeveelutions.length,
            itemHeight: 95,
            color: Colors.grey[400]!,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: eeveelutions.asMap().entries.map((entry) {
              final eeveelution = entry.value;
              return _buildEeveelutionRow(eeveelution);
            }).toList(),
          ),
        ),
      ],
    );
  }

  /// Construye una fila de eeveelution con flecha y condición
  Widget _buildEeveelutionRow(Pokemon eeveelution) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Espacio para la línea vertical (pintada por CustomPaint)
          const SizedBox(width: 2),
          // Línea horizontal hacia el nodo
          Container(
            width: 20,
            height: 2,
            color: Colors.grey[400],
          ),
          // Flecha con condición
          _buildCompactEvolutionArrow(eeveelution),
          // Nodo de la eeveelution
          _buildCompactEvolutionItem(
            evolution: eeveelution,
            isCurrentPokemon: eeveelution.id == pokemon.id,
          ),
        ],
      ),
    );
  }

  /// Flecha compacta con condición de evolución
  Widget _buildCompactEvolutionArrow(Pokemon nextEvolution) {
    final details = nextEvolution.evolutionDetails;
    String? detailText;

    if (details != null && details.isNotEmpty) {
      final detail = details.values.first;
      detailText = detail.getDisplayText();
    }

    return Container(
      width: 75,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_forward,
            size: 16,
            color: Colors.grey[600],
          ),
          if (detailText != null && detailText.isNotEmpty) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                detailText,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Item compacto de evolución para las ramas
  Widget _buildCompactEvolutionItem({
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
        width: 85,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentPokemon
              ? typeColor.withAlpha(51)
              : Colors.grey.withAlpha(25),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentPokemon ? typeColor : Colors.grey.withAlpha(76),
            width: isCurrentPokemon ? 2.5 : 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withAlpha(76),
              ),
              child: _buildEvolutionSprite(evolution, typeColor, size: 50),
            ),
            const SizedBox(height: 4),
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
            Text(
              'Nº${evolution.id.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontSize: 7,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Métodos originales para cadenas lineales ====================

  Widget _buildEvolutionChain() {
    final evolutions = pokemon.evolutions!;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          evolutions.length * 2 - 1,
          (index) {
            if (index.isOdd) {
              final evolutionIndex = (index + 1) ~/ 2;
              final nextEvolution = evolutions[evolutionIndex];
              return _buildEvolutionArrow(nextEvolution);
            } else {
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

  Widget _buildEvolutionArrow(Pokemon nextEvolution) {
    final details = nextEvolution.evolutionDetails;
    String? detailText;

    if (details != null && details.isNotEmpty) {
      final detail = details.values.first;
      detailText = detail.getDisplayText();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.arrow_forward,
            size: 24,
            color: Colors.grey[600],
          ),
          if (detailText != null && detailText.isNotEmpty) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              ),
              child: Text(
                detailText,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ),
          ],
        ],
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
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: typeColor.withAlpha(76),
              ),
              child: _buildEvolutionSprite(evolution, typeColor),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 4),
            Text(
              'Nº${evolution.id.toString().padLeft(3, '0')}',
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
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

/// Clase helper para datos de formas de Deoxys
class _DeoxysForm {
  final int id;
  final String name;
  final String formName;

  const _DeoxysForm({
    required this.id,
    required this.name,
    required this.formName,
  });
}

/// Painter para dibujar la línea vertical de conexión de las ramas
class _BranchLinePainter extends CustomPainter {
  final int itemCount;
  final double itemHeight;
  final Color color;

  _BranchLinePainter({
    required this.itemCount,
    required this.itemHeight,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (itemCount <= 1) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Calcular posiciones
    final firstItemCenterY = itemHeight / 2;
    final lastItemCenterY = (itemCount - 1) * itemHeight + itemHeight / 2;

    // Dibujar línea vertical que conecta todas las ramas
    canvas.drawLine(
      Offset(0, firstItemCenterY),
      Offset(0, lastItemCenterY),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _BranchLinePainter oldDelegate) {
    return itemCount != oldDelegate.itemCount ||
        itemHeight != oldDelegate.itemHeight ||
        color != oldDelegate.color;
  }
}
