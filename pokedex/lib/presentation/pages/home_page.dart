import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/search_box.dart';
import '../widgets/bottom_filter_menu.dart';
import '../widgets/floating_sort_menu.dart';
import '../widgets/bottom_menu.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/pokemon_card.dart';
import '../../data/models/pokemon.dart';
import '../../data/favorites_service.dart';
import 'pokemon_detail_page.dart';
import '../widgets/FilterBoxes/pokemon_type_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/pokemon_constants.dart';
import '../../core/utils/filter_utils.dart';
import '../../core/utils/responsive_utils.dart';
import '../../domain/models/pokemon_filters.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  // Controllers
  final ScrollController _scrollController = ScrollController();
  late final AnimationController _animationController;
  late final Animation<double> _rotationAnimation;

  // State
  final List<Pokemon> _pokemons = [];
  PokemonFilters _filters = const PokemonFilters();
  String _query = '';
  int _offset = 0;
  bool _loading = false;
  bool _error = false;
  String _errorMessage = '';
  bool _isRotated = false;

  // UI State para filtros seleccionados (español)
  List<String> _selectedTypesSpanish = [];
  List<String> _selectedRegions = [];
  List<String> _selectedCategories = [];

  // Colores
  static const Color _pokeballDefaultColor = Color(0xFF424242);
  static const Color _pokeballActiveColor = Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeScrollListener();
    _loadMore();
  }

  void _initializeAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: AppConstants.pokeballAnimationDuration),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: AppConstants.pokeballRotationStart,
      end: AppConstants.pokeballRotationEnd,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.bounceIn,
    ));
  }

  void _initializeScrollListener() {
    _scrollController.addListener(() {
      if (_shouldLoadMore()) {
        _loadMore();
      }
    });
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.scrollThreshold &&
        !_loading &&
        !_error;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ==================== Data Loading ====================

  Future<void> _refresh() async {
    setState(() {
      _pokemons.clear();
      _offset = 0;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = '';
    });

    try {
      final repo = context.read<PokemonRepository>();
      final favService = context.read<FavoritesService>();

      final list = await repo.fetchPokemons(
        limit: AppConstants.defaultPageSize,
        offset: _offset,
        types: _filters.types,
        regions: _filters.regions,
        categories: _filters.categories,
        sortBy: _filters.sortBy,
        ascending: _filters.ascending,
      );

      final filtered = _applyLocalFilters(list);

      setState(() {
        _pokemons.addAll(filtered);
        _offset += AppConstants.defaultPageSize;
      });

      _applyFavoriteFilters(favService);
      _applyRegionFilters();
    } catch (e, st) {
      _handleError(e, st);
    } finally {
      setState(() => _loading = false);
    }
  }

  List<Pokemon> _applyLocalFilters(List<Pokemon> list) {
    return list.where((pokemon) {
      final matchesQuery = _matchesSearchQuery(pokemon);
      final matchesTypes = _matchesTypeFilter(pokemon);
      return matchesQuery && matchesTypes;
    }).toList();
  }

  bool _matchesSearchQuery(Pokemon pokemon) {
    return _query.isEmpty || pokemon.name.toLowerCase().contains(_query.toLowerCase());
  }

  bool _matchesTypeFilter(Pokemon pokemon) {
    if (_filters.types.isEmpty) return true;
    final pokemonTypes = pokemon.types.map((t) => t.toLowerCase()).toList();
    return pokemonTypes.any((t) => _filters.types.contains(t));
  }

  void _applyFavoriteFilters(FavoritesService favService) {
    if (_filters.favorites) {
      setState(() {
        _pokemons.retainWhere((p) => favService.isFavorite(p.id));
      });
    }

    if (_filters.noFavorites) {
      setState(() {
        _pokemons.retainWhere((p) => !favService.isFavorite(p.id));
      });
    }
  }
  void _applyRegionFilters() {
    if (_filters.regions.isEmpty) return;

    setState(() {
      _pokemons.retainWhere((pokemon) =>
          FilterUtils.isInGenerationRange(pokemon.id, _filters.regions));
    });
  }

  void _handleError(Object error, StackTrace stackTrace) {
    debugPrint('Error fetching pokemons: $error');
    debugPrint('$stackTrace');
    setState(() {
      _error = true;
      _errorMessage = error.toString();
    });
  }

  // ==================== Filter Management ====================

  Future<void> _applyFilterMap(Map<String, dynamic> filterMap) async {
    final favoritos = FilterUtils.getBoolFilter(filterMap, 'favoritos');
    final noFavoritos = FilterUtils.getBoolFilter(filterMap, 'noFavoritos');
    final tiposSpanish = FilterUtils.getListFilter(filterMap, 'tipos');
    final tiposApi = PokemonTypeColors.toApiTypes(tiposSpanish);
    final regiones = FilterUtils.getListFilter(filterMap, 'regiones');
    final categorias = FilterUtils.getListFilter(filterMap, 'categorias');

    setState(() {
      _filters = PokemonFilters(
        favorites: favoritos,
        noFavorites: noFavoritos,
        types: tiposApi,
        regions: regiones,
        categories: categorias,
        sortBy: _filters.sortBy,
        ascending: _filters.ascending,
      );

      _selectedTypesSpanish = tiposSpanish;
      _selectedRegions = regiones;
      _selectedCategories = categorias;

      _pokemons.clear();
      _offset = 0;
    });

    await _loadMore();
  }

  Future<void> _applySort(SortOption option, SortOrder order) async {
    final sortBy = _getSortField(option);
    final ascending = order == SortOrder.asc;

    setState(() {
      _filters = _filters.copyWith(sortBy: sortBy, ascending: ascending);
      _pokemons.clear();
      _offset = 0;
    });

    await _loadMore();
  }

  String _getSortField(SortOption option) {
    switch (option) {
      case SortOption.numero:
        return 'id';
      case SortOption.nombre:
        return 'name';
      case SortOption.tipo:
        return 'name'; // TODO: Implementar ordenamiento por tipo
    }
  }

  void _clearAllFilters() {
    setState(() {
      _filters = _filters.reset();
      _selectedTypesSpanish = [];
      _selectedRegions = [];
      _selectedCategories = [];
      _pokemons.clear();
      _offset = 0;
    });
    _loadMore();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
      _pokemons.clear();
      _offset = 0;
    });
    _loadMore();
  }

  // ==================== Navigation ====================

  void _showMenu() async {
    await showBottomMenu(
      context,
      onPokedexPressed: () => Navigator.pop(context),
      onMapaPressed: () => _onMapaPressed(),
      onHelpPressed: () => _onHelpPressed(),
    );
  }

  Future<void> _showPokedexMenu() async {
    await showBottomMenu(
      context,
      onPokedexPressed: () => _onPokedexPressed(),
      onMapaPressed: () => _onMapaPressed(),
      onHelpPressed: () => _onHelpPressed(),
    );
  }

  void _onPokedexPressed() {
    debugPrint('Pokedex Nacional presionado');
    Navigator.pop(context);
  }

  void _onMapaPressed() {
    debugPrint('Mapa presionado');
    Navigator.pop(context);
  }

  void _onHelpPressed() {
    debugPrint('Ayuda presionado');
    Navigator.pop(context);
  }

  Future<void> _onPokedexButtonPressed() async {
    setState(() => _isRotated = true);
    _animationController.forward();

    await _showPokedexMenu();

    setState(() => _isRotated = false);
    _animationController.reverse();
  }

  void _navigateToPokemonDetail(Pokemon pokemon) {
    final repo = context.read<PokemonRepository>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(
          id: pokemon.id,
          repository: repo,
        ),
      ),
    );
  }

  // ==================== UI Builders ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildPokeballBackground(),
          _buildMainContent(),
        ],
      ),
      floatingActionButton: _buildMenuButton(),
    );
  }

  Widget _buildPokeballBackground() {
    return Positioned(
      top: -AppConstants.pokeballSize / 2 + 80,
      left: MediaQuery.of(context).size.width - AppConstants.pokeballSize / 2 - 50,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Opacity(
            opacity: AppConstants.pokeballOpacity,
            child: Transform.rotate(
              angle: _rotationAnimation.value * 3.14159 * 2,
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _isRotated ? _pokeballActiveColor : _pokeballDefaultColor,
                  BlendMode.srcIn,
                ),
                child: SvgPicture.asset(
                  'assets/icons/pokeaball.svg',
                  width: AppConstants.pokeballSize,
                  height: AppConstants.pokeballSize,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPokedexButton(),
            const SizedBox(height: 12),
            _buildSearchBar(),
            const SizedBox(height: 18),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: _buildPokemonGrid(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokedexButton() {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: _onPokedexButtonPressed,
        icon: const Icon(
          Icons.menu_book_outlined,
          size: AppConstants.pokedexButtonIconSize,
        ),
        label: const Text(
          'Pokedex',
          style: TextStyle(fontSize: AppConstants.pokedexButtonFontSize),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: SearchBox(
            hintText: 'Buscar Pokemon',
            height: AppConstants.searchBoxHeight,
            onChanged: _onSearchChanged,
          ),
        ),
        const SizedBox(width: 8),
        _buildIconButton(
          icon: Icons.sort,
          onPressed: () => _showSortMenu(),
          colorScheme: colorScheme,
        ),
        _buildIconButton(
          icon: Icons.filter_alt,
          onPressed: () => _showFilterMenu(),
          colorScheme: colorScheme,
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onPressed,
    required ColorScheme colorScheme,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: AppConstants.iconButtonSize),
      color: colorScheme.onSurface,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }

  void _showSortMenu() {
    showSortMenu(
      context,
      onApplySort: (option, order) => _applySort(option, order),
    );
  }

  void _showFilterMenu() {
    showFilterMenu(
      context,
      onApplyFilters: (filters) => _applyFilterMap(filters),
      initialFilters: _buildInitialFiltersMap(),
    );
  }

  Map<String, dynamic> _buildInitialFiltersMap() {
    return {
      'favoritos': _filters.favorites,
      'noFavoritos': _filters.noFavorites,
      'tipos': _selectedTypesSpanish,
      'regiones': _selectedRegions,
      'categorias': _selectedCategories,
      'filtro4': [],
      'filtro5': [],
    };
  }

  Widget _buildPokemonGrid() {
    if (_error && _pokemons.isEmpty) {
      return _buildErrorView();
    }

    if (_pokemons.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        if (_filters.hasActiveFilters) _buildActiveFiltersChip(),
        Expanded(child: _buildResponsiveGrid()),
      ],
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
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

  Widget _buildActiveFiltersChip() {
    final activeFilters = _filters.getActiveFilterLabels();

    return Container(
      padding: const EdgeInsets.all(8),
      color: Colors.grey[200],
      child: Row(
        children: [
          const Text(
            'Filtros activos: ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Wrap(
              spacing: 8,
              runSpacing: 4,
              children: activeFilters.map((filter) {
                if (_selectedTypesSpanish.contains(filter)) {
                  return _buildActiveTypeChip(filter);
                }
                return Chip(
                  label: Text(filter, style: const TextStyle(fontSize: 12)),
                  backgroundColor: Colors.blue[100],
                );
              }).toList(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearAllFilters,
            tooltip: 'Limpiar filtros',
          )
        ],
      ),
    );
  }

  Widget _buildActiveTypeChip(String type) {
    final typeColor = PokemonTypeColors.getTypeColor(type);
    final icon = PokemonTypeColors.getTypeIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Image.asset(icon, width: 14, height: 14),
            const SizedBox(width: 4),
          ],
          Text(
            type,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = ResponsiveUtils.calculateCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = ResponsiveUtils.calculateChildAspectRatio(constraints.maxWidth);

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(12),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: _pokemons.length + (_loading ? 1 : 0),
          itemBuilder: _buildGridItem,
        );
      },
    );
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

  Widget _buildMenuButton() {
    return FloatingActionButton(
      onPressed: _showMenu,
      child: const Icon(Icons.menu),
    );
  }
}
