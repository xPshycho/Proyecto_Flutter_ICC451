import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../../data/favorites_service.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_page.dart';
import '../widgets/bottom_filter_menu.dart';
import '../../core/constants/pokemon_constants.dart';

class PokedexListPage extends StatefulWidget {
  final PokemonRepository repository;
  const PokedexListPage({super.key, required this.repository});

  @override
  State<PokedexListPage> createState() => _PokedexListPageState();
}

class _PokedexListPageState extends State<PokedexListPage> {
  final ScrollController _scrollController = ScrollController();
  List<Pokemon> _pokemons = [];
  bool _loading = false;
  bool _error = false;
  String _errorMessage = '';
  int _offset = 0;
  final int _limit = 24;
  String _query = '';
  List<String> _typeFilters = [];
  List<String> _categoryFilters = [];
  List<String> _regionFilters = [];

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loading && !_error) {
        _loadMore();
      }
    });
  }

  Future<void> _refresh() async {
    // Limpiar caché del repositorio
    await widget.repository.clearGraphQLCache();

    setState(() {
      _pokemons = [];
      _offset = 0;
      _error = false;
      _errorMessage = '';
    });
    await _loadMore();
  }

  Future<void> _applyFilterMap(Map<String, dynamic> filters) async {
    final favoritos = filters['favoritos'] as bool? ?? false;
    final tiposSpanish = (filters['tipos'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    final tiposApi = PokemonConstants.toApiTypes(tiposSpanish);
    final regiones = (filters['regiones'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];
    final categorias = (filters['categorias'] as List<dynamic>?)
        ?.map((e) => e.toString())
        .toList() ?? [];

    // Limpiar caché del repositorio cuando cambien los filtros
    await widget.repository.clearGraphQLCache();

    setState(() {
      _typeFilters = tiposApi;
      _categoryFilters = categorias;
      _regionFilters = regiones;
      _pokemons = [];
      _offset = 0;
      _error = false;
      _errorMessage = '';
    });

    // Cargar nuevos datos con filtros
    await _loadMore();

    // Aplicar filtro de favoritos solo en la UI (ya que no está en el repositorio)
    if (favoritos) {
      _applyFavoritesFilter();
    }
  }

  void _applyFavoritesFilter() {
    final favService = Provider.of<FavoritesService>(context, listen: false);
    final filteredFavs = _pokemons.where((p) => favService.isFavorite(p.id)).toList();
    setState(() {
      _pokemons = filteredFavs;
    });
  }


  Future<void> _loadMore() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = '';
    });

    try {
      final list = await widget.repository.fetchPokemons(
        limit: _limit,
        offset: _offset,
        types: _typeFilters,
        regions: _regionFilters,
        categories: _categoryFilters,
      );

      final filtered = _filterPokemons(list);

      setState(() {
        _pokemons.addAll(filtered);
        _offset += _limit;
      });
    } catch (e, st) {
      debugPrint('Error fetching pokemons: $e');
      debugPrint('$st');
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Pokemon> _filterPokemons(List<Pokemon> list) {
    return list.where((p) {
      final matchesQuery = _query.isEmpty ||
          p.name.toLowerCase().contains(_query.toLowerCase());
      return matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar Pokémon...',
          border: InputBorder.none,
          isDense: true,
        ),
        onChanged: _onSearchChanged,
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: _showFilters,
        ),
      ],
    );
  }

  void _onSearchChanged(String value) {
    _query = value;
    _pokemons = [];
    _offset = 0;
    _loadMore();
  }

  void _showFilters() {
    showFilterMenu(context, onApplyFilters: _applyFilterMap);
  }

  Widget _buildBody() {
    if (_error && _pokemons.isEmpty) {
      return _buildErrorView();
    }

    if (_pokemons.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildPokemonGrid();
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            const Text(
              'No se pudieron cargar los Pokémon',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMore,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gridConfig = _calculateGridConfig(constraints.maxWidth);

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: gridConfig['crossAxisCount'],
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: gridConfig['aspectRatio'],
          ),
          itemCount: _pokemons.length + (_loading ? 1 : 0),
          itemBuilder: _buildGridItem,
        );
      },
    );
  }

  Map<String, dynamic> _calculateGridConfig(double width) {
    int crossAxisCount = 2;
    double childAspectRatio = 3 / 2.2;

    if (width >= 1200) {
      crossAxisCount = 5;
      childAspectRatio = 3 / 1.8;
    } else if (width >= 1000) {
      crossAxisCount = 4;
      childAspectRatio = 3 / 1.9;
    } else if (width >= 700) {
      crossAxisCount = 3;
      childAspectRatio = 3 / 2.0;
    } else if (width >= 480) {
      crossAxisCount = 2;
      childAspectRatio = 3 / 2.2;
    } else {
      crossAxisCount = 1;
      childAspectRatio = 3 / 1.2;
    }

    return {
      'crossAxisCount': crossAxisCount,
      'aspectRatio': childAspectRatio,
    };
  }

  Widget _buildGridItem(BuildContext context, int index) {
    if (index >= _pokemons.length) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pokemon = _pokemons[index];
    return PokemonCard(
      pokemon: pokemon,
      onTap: () => _navigateToPokemonDetail(pokemon),
    );
  }

  void _navigateToPokemonDetail(Pokemon pokemon) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(
          id: pokemon.id,
          repository: widget.repository,
        ),
      ),
    );
  }
}
