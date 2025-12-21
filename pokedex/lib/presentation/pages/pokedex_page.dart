import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'pokedex_page.dart';
import 'map_page.dart';
import 'quiz_home_page.dart';

import '../widgets/search_box.dart';
import '../widgets/bottom_filter_menu.dart';
import '../widgets/floating_sort_menu.dart';
import '../widgets/bottom_menu.dart';
import '../widgets/error_view.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/pokemon_card.dart';
import '../../data/models/pokemon.dart';
import 'pokemon_detail_page.dart';
import 'home_page.dart';
import 'map_page.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive_utils.dart';
import '../bloc/pokemon/pokemon_bloc.dart';
import '../bloc/pokemon/pokemon_event.dart';
import '../bloc/pokemon/pokemon_state.dart';
import '../bloc/pokemon_detail/pokemon_detail_bloc.dart';
import '../bloc/pokemon_detail/pokemon_detail_event.dart';

class PokedexPage extends StatefulWidget {
  const PokedexPage({super.key});

  @override
  State<PokedexPage> createState() => _PokedexPageState();
}

class _PokedexPageState extends State<PokedexPage> with SingleTickerProviderStateMixin {
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
      onHomePressed: () => _onHomePressed(),
    );
  }

  Future<void> _showPokedexMenu() async {
    await showBottomMenu(
      context,
      onPokedexPressed: () => _onPokedexPressed(),
      onMapaPressed: () => _onMapaPressed(),
      onHelpPressed: () => _onHelpPressed(),
      onHomePressed: () => _onHomePressed(),
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

  void _onHomePressed() {
    debugPrint('Home presionado');
    Navigator.pop(context);
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF121212),
              Color(0xFF313131),
              Color(0xFF121212),
            ],
            stops: [0.0, 0.25, 0.8],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 100),
                // Botón Pokedex (rojo)
                RetroMenuButton(
                  label: 'Pokedex',
                  iconAsset: 'assets/icons/pokeball.svg',
                  iconSize: 400,
                  iconRotation: -10,
                  iconOffsetX: 140,
                  iconOffsetY: 10,
                  baseColor: const Color(0xFFFC2A2A),
                  midColor: const Color(0xFFA12020),
                  shadowColor: const Color(0xFF521212),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const PokedexPage()),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Botón Mapa (azul)
                RetroMenuButton(
                  label: 'Mapa',
                  iconAsset: 'assets/icons/map.svg',
                  iconSize: 145,
                  iconRotation: 0,
                  iconOffsetX: 100,
                  iconOffsetY: 0,
                  baseColor: const Color(0xFF3E51B2),
                  midColor: const Color(0xFF2A387E),
                  shadowColor: const Color(0xFF1E1E50),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const MapPage()),
                    );
                  },
                ),

                const SizedBox(height: 12),

                // Botón Quiz (verde)
                RetroMenuButton(
                  label: 'Quiz',
                  iconAsset: 'assets/icons/pikachu_2d.svg',
                  iconSize: 200,
                  iconRotation: 0,
                  iconOffsetX: 130,
                  iconOffsetY: 0,
                  baseColor: const Color(0xFF46FC2A),
                  midColor: const Color(0xFF45A120),
                  shadowColor: const Color(0xFF256215),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const QuizHomePage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget personalizado para botones del menú principal
///
/// Crea un botón con estilo retro que incluye:
/// - Gradiente de color personalizable
/// - Borde metalizado
/// - Icono SVG con transparencia y rotación
/// - Control individual de tamaño y posición del icono
/// - Texto centrado
class RetroMenuButton extends StatelessWidget {
  final String label;
  final Color baseColor;
  final Color midColor;
  final Color shadowColor;
  final String? iconAsset;
  final double iconSize;
  final double iconRotation;
  final double iconOffsetX;
  final double iconOffsetY;
  final VoidCallback onPressed;

  const RetroMenuButton({
    super.key,
    required this.label,
    required this.baseColor,
    required this.midColor,
    required this.shadowColor,
    this.iconAsset,
    this.iconSize = 300,
    this.iconRotation = 0,
    this.iconOffsetX = 0,
    this.iconOffsetY = 0,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 150,
        width: double.infinity,

        // Borde exterior metalizado
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFFFFF),
              Color(0xFF92959A),
              Color(0xFFE8E8E8),
              Color(0xFF5B5B5B),
            ],
            stops: [0.0, 0.3, 0.6, 1.0],
          ),
        ),

        padding: const EdgeInsets.all(4.0),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  baseColor,
                  midColor,
                  shadowColor,
                ],
                stops: const [0.0, 0.5, 0.90],
              ),
            ),
            child: Stack(
              children: [
                // Icono de fondo
                if (iconAsset != null)
                  Positioned.fill(
                    child: OverflowBox(
                      maxWidth: double.infinity,
                      maxHeight: double.infinity,
                      alignment: Alignment.center,
                      child: Transform.translate(
                        offset: Offset(iconOffsetX, iconOffsetY),
                        child: Transform.rotate(
                          angle: iconRotation * math.pi / 180,
                          child: SvgPicture.asset(
                            iconAsset!,
                            width: iconSize,
                            height: iconSize,
                            // CAMBIO CLAVE AQUÍ:
                            // .contain respeta el tamaño exacto sin intentar recortar ni estirar
                            fit: BoxFit.contain,
                            colorFilter: const ColorFilter.mode(
                              Color(0x33000000), // Negro con transparencia (ajustado a tu gusto anterior)
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                // Texto centrado
                Center(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Pixelated',
                      color: Colors.white,
                      fontSize: 36,
                      letterSpacing: 2.0,
                      shadows: [
                        Shadow(
                          offset: Offset(5, 5),
                          color: Colors.black,
                          blurRadius: 0,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
