import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/models/pokemon_move.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../core/constants/pokemon_constants.dart';
import 'section_card.dart';

enum MoveSortOption { nombre, poder, precision, pp }

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
  List<PokemonMove>? _moves;
  bool _isLoading = false;
  String? _error;
  bool _showFilters = false;
  MoveSortOption _sortOption = MoveSortOption.nombre;
  bool _ascending = true;

  // Para optimización de scroll
  static const int _itemsPerBatch = 20;
  int _displayedItemsCount = _itemsPerBatch;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadMoves();
    _setupScrollListener();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 50) {
        _loadMoreItems();
      }
    });
  }

  void _loadMoreItems() {
    if (_moves == null) return;

    final totalItems = _getSortedMoves().length;
    if (_displayedItemsCount < totalItems) {
      setState(() {
        _displayedItemsCount = (_displayedItemsCount + _itemsPerBatch).clamp(0, totalItems);
      });
    }
  }

  void _resetDisplayedItems() {
    setState(() {
      _displayedItemsCount = _itemsPerBatch;
    });
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _loadMoves() async {
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
        _error = 'Error al cargar movimientos';
        _isLoading = false;
      });
    }
  }

  List<PokemonMove> _getSortedMoves() {
    if (_moves == null) return [];

    final sortedMoves = List<PokemonMove>.from(_moves!);

    sortedMoves.sort((a, b) {
      final comparison = switch (_sortOption) {
        MoveSortOption.nombre => a.displayName.compareTo(b.displayName),
        MoveSortOption.poder => (a.power ?? 0).compareTo(b.power ?? 0),
        MoveSortOption.precision => (a.accuracy ?? 0).compareTo(b.accuracy ?? 0),
        MoveSortOption.pp => (a.pp ?? 0).compareTo(b.pp ?? 0),
      };

      return _ascending ? comparison : -comparison;
    });

    return sortedMoves;
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'MOVIMIENTOS',
      icon: Icons.sports_martial_arts,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 20),
          onPressed: () {
            // Future implementation
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Icon(
            _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            size: 20,
          ),
          onPressed: () => setState(() => _showFilters = !_showFilters),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_showFilters) ...[
            _buildFilterSection(),
            const SizedBox(height: 16),
          ],
          _buildContent(),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.close, size: 16),
              const SizedBox(width: 8),
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip('Nombre', MoveSortOption.nombre, Colors.grey[700]!),
              _buildFilterChip('Poder', MoveSortOption.poder, Colors.grey[700]!),
              _buildFilterChip('PP', MoveSortOption.pp, Colors.grey[700]!),
              _buildFilterChip('Precisión', MoveSortOption.precision, Colors.grey[700]!),
              _buildSortOrderChip(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, MoveSortOption option, Color color) {
    final isSelected = _sortOption == option;

    return GestureDetector(
      onTap: () => _changeSortOption(option),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildSortOrderChip() {
    return GestureDetector(
      onTap: () {
        setState(() => _ascending = !_ascending);
        _resetDisplayedItems();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.red[600],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _ascending ? 'ASC' : 'DESC',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              _ascending ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 16,
              color: Colors.white,
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
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
    }

    final sortedMoves = _getSortedMoves();

    if (sortedMoves.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: Text('No se encontraron movimientos')),
      );
    }

    final displayedMoves = sortedMoves.take(_displayedItemsCount).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fixed the overflow issue here
        if (sortedMoves.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Total: ${sortedMoves.length} movimientos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ConstrainedBox(
          constraints: const BoxConstraints(
            maxHeight: 250, // Increased height to show more moves like in the image
          ),
          child: Scrollbar(
            controller: _scrollController,
            thumbVisibility: true,
            child: ListView.separated(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              itemCount: displayedMoves.length +
                         (displayedMoves.length < sortedMoves.length ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                if (index >= displayedMoves.length) {
                  return _buildLoadingIndicator();
                }

                return _buildMoveItem(displayedMoves[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Redesigned to match the reference images exactly
  Widget _buildMoveItem(PokemonMove move, int index) {
    final typeColor = PokemonConstants.getTypeColor(move.typeNameSpanish);
    final icon = PokemonConstants.getTypeIcon(move.typeNameSpanish);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          // Type icon
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

          // Level/Learn info (like "Lvl. 1", "Lvl. 33", "HUEVO", "TM. 133")
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getMoveLearnMethod(move, index),
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Move name
          Expanded(
            child: Text(
              move.displayName,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),

          // Move category icon (Physical/Special/Status)
          _buildMoveTypeIcon(move),
        ],
      ),
    );
  }

  String _getMoveLearnMethod(PokemonMove move, int index) {
    // Simulate different learn methods like in the reference
    final methods = ['Lvl. 1', 'Lvl. 15', 'Lvl. 33', 'HUEVO', 'TM. 133', 'MT. 163'];
    return methods[index % methods.length];
  }

  Widget _buildMoveTypeIcon(PokemonMove move) {
    // Physical, Special, or Status move icons
    if (move.damageClass == 'physical') {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.flash_on, // Physical attack icon
          size: 16,
          color: Colors.white,
        ),
      );
    } else if (move.damageClass == 'special') {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.auto_awesome, // Special attack icon
          size: 16,
          color: Colors.white,
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.visibility, // Status move icon
          size: 16,
          color: Colors.white,
        ),
      );
    }
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Cargando más movimientos...',
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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

  void _changeSortOption(MoveSortOption option) {
    setState(() {
      if (_sortOption == option) {
        _ascending = !_ascending;
      } else {
        _sortOption = option;
        _ascending = true;
      }
    });
    _resetDisplayedItems();
  }
}
