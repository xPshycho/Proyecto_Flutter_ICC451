import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/search_box.dart';
import '../widgets/bottom_filter_menu.dart';
import '../widgets/floating_sort_menu.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/error_view.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/pokemon_card.dart';
import '../../data/models/pokemon.dart';
import 'pokemon_detail_page.dart';
import 'map_page.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_utils.dart';
import '../bloc/pokemon/pokemon_bloc.dart';
import '../bloc/pokemon/pokemon_event.dart';
import '../bloc/pokemon/pokemon_state.dart';
import '../bloc/pokemon_detail/pokemon_detail_bloc.dart';
import '../bloc/pokemon_detail/pokemon_detail_event.dart';

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

  // UI State local (solo animaciones)
  bool _isRotated = false;

  // Debouncing para búsqueda
  Timer? _searchDebounceTimer;

  // UI State para ordenamiento
  SortOption _selectedSortOption = SortOption.numero;
  SortOrder _selectedSortOrder = SortOrder.asc;

  // Colores
  static const Color _pokeballDefaultColor = Color(0xFF424242);
  static const Color _pokeballActiveColor = Color(0xFF424242);

  @override
  void initState() {
    super.initState();
    _initializeAnimation();
    _initializeScrollListener();
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
        context.read<PokemonBloc>().add(const LoadMorePokemons());
      }
    });
  }

  bool _shouldLoadMore() {
    return _scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - AppConstants.scrollThreshold;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }

  // ==================== Event Handlers ====================

  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();

    if (value.trim().isEmpty) {
      context.read<PokemonBloc>().add(const LoadPokemonList(refresh: true));
      return;
    }

    _searchDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      context.read<PokemonBloc>().add(SearchPokemon(value.trim()));
    });
  }

  Future<void> _applyFilterMap(Map<String, dynamic> filterMap) async {
    final favoritos = filterMap['favoritos'] as bool? ?? false;
    final noFavoritos = filterMap['noFavoritos'] as bool? ?? false;
    final tiposSpanish = (filterMap['tipos'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final regiones = (filterMap['regiones'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final categorias = (filterMap['categorias'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    context.read<PokemonBloc>().add(ApplyFilters(
          types: tiposSpanish,
          regions: regiones,
          categories: categorias,
          favorites: favoritos,
          noFavorites: noFavoritos,
        ));
  }

  Future<void> _applySort(SortOption option, SortOrder order) async {
    final sortBy = _getSortField(option);
    final ascending = order == SortOrder.asc;

    setState(() {
      _selectedSortOption = option;
      _selectedSortOrder = order;
    });

    context.read<PokemonBloc>().add(ApplySort(
          sortBy: sortBy,
          ascending: ascending,
        ));
  }

  String _getSortField(SortOption option) {
    switch (option) {
      case SortOption.numero:
        return 'id';
      case SortOption.nombre:
        return 'name';
      case SortOption.tipo:
        return 'name';
    }
  }

  void _clearAllFilters() {
    context.read<PokemonBloc>().add(const ClearFilters());
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
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPage()),
    );
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

  void _navigateToPokemonDetail(Pokemon pokemon) async {
    final repo = RepositoryProvider.of<PokemonRepository>(context);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PokemonDetailBloc(repository: repo)
            ..add(LoadPokemonDetail(pokemon.id)),
          child: PokemonDetailPage(
            id: pokemon.id,
            repository: repo,
          ),
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
              angle: _rotationAnimation.value,
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
              child: BlocConsumer<PokemonBloc, PokemonState>(
                listener: (context, state) {
                  if (state is PokemonError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<PokemonBloc>().add(const RefreshPokemonList());
                    },
                    child: _buildPokemonGrid(state),
                  );
                },
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
      initialOption: _selectedSortOption,
      initialOrder: _selectedSortOrder,
    );
  }

  void _showFilterMenu() {
    final state = context.read<PokemonBloc>().state;

    Map<String, dynamic> initialFilters = {};
    if (state is PokemonLoaded) {
      initialFilters = {
        'favoritos': state.showFavorites,
        'noFavoritos': state.showNoFavorites,
        'tipos': state.activeTypes,
        'regiones': state.activeRegions,
        'categorias': state.activeCategories,
      };
    }

    showFilterMenu(
      context,
      onApplyFilters: (filters) => _applyFilterMap(filters),
      initialFilters: initialFilters,
    );
  }

  Widget _buildPokemonGrid(PokemonState state) {
    if (state is PokemonLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PokemonError && state.cachedPokemons == null) {
      return _buildErrorView(state.message);
    }

    if (state is PokemonLoaded) {
      return _buildResponsiveGrid(state.pokemons, state.hasReachedMax);
    }

    if (state is PokemonLoadingMore) {
      return _buildResponsiveGrid(state.currentPokemons, false, isLoadingMore: true);
    }

    return const SizedBox.shrink();
  }

  Widget _buildErrorView(String message) {
    return ErrorView(
      title: 'No se pudieron cargar los Pokémon',
      message: message,
      onRetry: () {
        context.read<PokemonBloc>().add(const LoadPokemonList(refresh: true));
      },
      showAppBar: false,
    );
  }

  Widget _buildResponsiveGrid(List<Pokemon> pokemons, bool hasReachedMax, {bool isLoadingMore = false}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = ResponsiveUtils.calculateCrossAxisCount(constraints.maxWidth);
        final childAspectRatio = ResponsiveUtils.calculateChildAspectRatio(constraints.maxWidth);

        return GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 0,
            crossAxisSpacing: 0,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: pokemons.length + (isLoadingMore || !hasReachedMax ? 1 : 0),
          itemBuilder: (context, index) => _buildGridItem(context, index, pokemons, isLoadingMore),
        );
      },
    );
  }

  Widget _buildGridItem(BuildContext context, int index, List<Pokemon> pokemons, bool isLoadingMore) {
    if (index >= pokemons.length) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final pokemon = pokemons[index];
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
