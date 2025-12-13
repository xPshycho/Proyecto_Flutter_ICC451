import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/models/pokemon_move.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../core/constants/pokemon_constants.dart';
import '../../bloc/moves/moves_bloc.dart';
import '../../bloc/moves/moves_event.dart';
import '../../bloc/moves/moves_state.dart';
import '../moves_filters_widget.dart';
import '../moves_sort_widget.dart';

enum MoveSortOption { nombre, poder, precision, pp }

class PokemonMovesetSection extends StatelessWidget {
  final Pokemon pokemon;
  final PokemonRepository repository;

  const PokemonMovesetSection({
    super.key,
    required this.pokemon,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MovesBloc(repository),
      child: PokemonMovesetContent(pokemon: pokemon),
    );
  }
}

class PokemonMovesetContent extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonMovesetContent({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonMovesetContent> createState() => _PokemonMovesetContentState();
}

class _PokemonMovesetContentState extends State<PokemonMovesetContent> {
  bool _isExpanded = false;
  bool _showFilters = false;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isScrolledToEnd) {
      context.read<MovesBloc>().add(const LoadMoreMoves());
    }
  }

  bool get _isScrolledToEnd {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      context.read<MovesBloc>().add(LoadMoves(widget.pokemon.id));
    }
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
    });
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
          children: [
            Expanded(
              child: Text(
                'Lista de movimientos',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isExpanded) ...[
              IconButton(
                icon: Icon(_showFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
                onPressed: _toggleFilters,
                iconSize: 16,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                tooltip: _showFilters ? 'Ocultar filtros' : 'Mostrar filtros',
              ),
            ],
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return BlocConsumer<MovesBloc, MovesState>(
      listener: (context, state) {
        if (state is MovesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is MovesLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is MovesError) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is! MovesLoaded) {
          return const SizedBox.shrink();
        }

        return Column(
          children: [
            if (_showFilters) ...[
              MovesFiltersWidget(
                selectedTypes: state.appliedTypes,
                selectedLearnMethods: state.appliedLearnMethods,
                selectedVersionGroups: state.appliedVersionGroups,
                searchQuery: state.currentSearchQuery,
                onFiltersChanged: (types, methods, versions) {
                  context.read<MovesBloc>().add(ApplyMovesFilters(
                    types: types,
                    learnMethods: methods,
                    versionGroups: versions,
                  ));
                },
                onSearchChanged: (query) {
                  context.read<MovesBloc>().add(SearchMoves(query));
                },
                onClearFilters: () {
                  context.read<MovesBloc>().add(const ClearMovesFilters());
                },
              ),
              const SizedBox(height: 16),
            ],
            if (state.hasActiveFilters || state.currentSortBy != null) ...[
              MovesSortWidget(
                currentSortBy: state.currentSortBy,
                currentAscending: state.currentAscending,
                onSortChanged: (sortBy, ascending) {
                  context.read<MovesBloc>().add(SortMoves(sortBy, ascending));
                },
              ),
              const SizedBox(height: 8),
            ],
            _buildMovesList(state),
          ],
        );
      },
    );
  }

  Widget _buildMovesList(MovesLoaded state) {
    if (state.filteredMoves.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
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
            'Total: ${state.totalMoves} movimientos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (state.hasActiveFilters)
            Text(
              'Mostrando: ${state.filteredMoves.length}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.blue[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 300),
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: ListView.separated(
                controller: _scrollController,
                itemCount: state.filteredMoves.length +
                    (state is MovesLoadingMore ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index >= state.filteredMoves.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  return _buildMoveChip(state.filteredMoves[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoveChip(PokemonMove move) {
    final typeColor = PokemonConstants.getTypeColor(move.typeNameSpanish);
    final icon = PokemonConstants.getTypeIcon(move.typeNameSpanish);

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
            if (icon != null) ...[
              SvgPicture.asset(
                icon,
                width: 12,
                height: 12,
                colorFilter: const ColorFilter.mode(
                  Colors.white,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 6),
            ],

            // Learn method indicator
            if (move.level != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Nv.${move.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else if (move.learnMethod != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  move.learnMethodSpanish,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            Flexible(
              child: Text(
                move.displayName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
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
      if (move.learnMethod != null) 'Método: ${move.learnMethodSpanish}',
      if (move.level != null) 'Nivel: ${move.level}',
      if (move.versionGroup != null) 'Versión: ${move.versionGroupSpanish}',
    ];
    return parts.join('\n');
  }
}
