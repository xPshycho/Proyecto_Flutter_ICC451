import 'package:flutter/material.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/models/pokemon_move.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../core/constants/pokemon_constants.dart';

class PokemonMovesetSection extends StatefulWidget {
  final Pokemon pokemon;
  final PokemonRepository repository;

  const PokemonMovesetSection({
    super.key,
    required this.pokemon,
    required this.repository,
  });

  @override
  State<PokemonMovesetSection> createState() => _PokemonMovesetSectionState();
}

class _PokemonMovesetSectionState extends State<PokemonMovesetSection> {
  bool _isExpanded = false;
  List<PokemonMove>? _moves;
  bool _isLoading = false;
  String? _error;

  Future<void> _loadMoves() async {
    if (_moves != null) return; // Ya se cargaron

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final moves = await widget.repository.fetchPokemonMoves(widget.pokemon.id);
      setState(() {
        _moves = moves;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar movimientos: $e';
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded && _moves == null) {
      _loadMoves();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        if (_isExpanded) ...[
          const SizedBox(height: 16),
          _buildContent(),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Lista de movimientos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    }

    if (_moves == null || _moves!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No se encontraron movimientos'),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Total: ${_moves!.length} movimientos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _moves!.map((move) => _buildMoveChip(move)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveChip(PokemonMove move) {
    final typeColor = PokemonConstants.getTypeColor(move.typeNameSpanish);

    return Tooltip(
      message: _buildMoveTooltip(move),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: typeColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              move.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildMoveTooltip(PokemonMove move) {
    final parts = <String>[
      'Tipo: ${move.typeNameSpanish}',
      if (move.power != null) 'Poder: ${move.power}',
      if (move.accuracy != null) 'Precisión: ${move.accuracy}%',
      if (move.pp != null) 'PP: ${move.pp}',
      if (move.damageClass != null) 'Clase: ${move.damageClass}',
    ];
    return parts.join('\n');
  }
}

