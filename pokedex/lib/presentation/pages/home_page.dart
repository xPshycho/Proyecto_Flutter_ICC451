import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../widgets/search_box.dart';
import '../widgets/bottom_filter_menu.dart';
import '../widgets/floating_sort_menu.dart';
import '../widgets/bottom_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  static const double _bottomSpacerHeight = 300.0;
  static const double _pokedexButtonIconSize = 32.0;
  static const double _pokedexButtonFontSize = 20.0;
  static const double _pokeballSize = 250.0;
  static const double _pokeballOpacity = 0.8;

  // Colores del pokeball más notorios
  static const Color _pokeballDefaultColor = Color(0xFF424242); // Gris oscuro
  static const Color _pokeballActiveColor = Color(0xFF424242); // Rojo brillante

  // Parámetros de rotación de la pokeball (en vueltas completas)
  // 0.0 = 0°, 0.25 = 90°, 0.5 = 180°, 1.0 = 360°
  static const double _pokeballRotationStart = -0.025;
  static const double _pokeballRotationEnd = 0.1;

  // Tiempo de la animación de la pokeball
  static const int _pokeballAnimationDurationMs = 1000;

  // Curva de animación
  static const Curve _pokeballAnimationCurve = Curves.bounceIn;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  bool _isRotated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: _pokeballAnimationDurationMs),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: _pokeballRotationStart,
      end: _pokeballRotationEnd,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: _pokeballAnimationCurve,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Pokeball SVG de fondo con animación, posicionada en la parte superior
          Positioned(
            top: -_pokeballSize/2 + 80,
            left: MediaQuery.of(context).size.width - _pokeballSize/2 - 50,
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Opacity(
                  opacity: _pokeballOpacity,
                  child: Transform.rotate(
                    angle: _rotationAnimation.value * 3.14159 * 2,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        _isRotated ? _pokeballActiveColor : _pokeballDefaultColor,
                        BlendMode.srcIn,
                      ),
                      child: SvgPicture.asset(
                        'assets/icons/pokeaball.svg',
                        width: _pokeballSize,
                        height: _pokeballSize,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPokedexButton(context),

                  // Search box and filter icons row
                  Row(
                    children: [
                      // Search box
                      Expanded(
                        child: SearchBox(
                          hintText: 'Buscar Pokemon',
                          height: 32.0,
                          onChanged: (value) {
                            debugPrint('Searching for: $value');
                          },
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Sort button
                      IconButton(
                        onPressed: () {
                          showSortMenu(
                            context,
                            onApplySort: (option, order) {
                              debugPrint('Ordenar por: $option, orden: $order');
                            },
                          );
                        },
                        icon: const Icon(Icons.sort, size: 32),
                        tooltip: 'Sort',
                        color: colorScheme.onSurface,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),

                      // Filter icon button
                      IconButton(
                        onPressed: () {
                          showFilterMenu(
                            context,
                            onApplyFilters: (filters) {
                              debugPrint('Filtros aplicados: $filters');
                            },
                          );
                        },
                        icon: const Icon(Icons.filter_alt, size: 32),
                        tooltip: 'Filter',
                        color: colorScheme.onSurface,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  SizedBox(height: _bottomSpacerHeight),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el botón principal de Pokedex que abre el menú inferior
  Widget _buildPokedexButton(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: TextButton.icon(
        onPressed: _onPokedexButtonPressed,
        icon: const Icon(
          Icons.menu_book_outlined,
          size: _pokedexButtonIconSize,
        ),
        label: const Text(
          'Pokedex',
          style: TextStyle(fontSize: _pokedexButtonFontSize),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 8.0,
            vertical: 4.0,
          ),
        ),
      ),
    );
  }

  /// Maneja el evento de presionar el botón Pokedex
  void _onPokedexButtonPressed() async {
    // Activar la animación al abrir el menú
    setState(() {
      _isRotated = true;
    });
    _animationController.forward();

    // Mostrar el menú y esperar a que se cierre
    await _showPokedexMenu(context);

    // Revertir la animación cuando se cierra el menú
    setState(() {
      _isRotated = false;
    });
    _animationController.reverse();
  }

  /// Muestra el menú inferior con las opciones de Pokedex, Mapa y Ayuda
  Future<void> _showPokedexMenu(BuildContext context) async {
    await showBottomMenu(
      context,
      onPokedexPressed: () => _onPokedexPressed(context),
      onMapaPressed: () => _onMapaPressed(context),
      onHelpPressed: () => _onHelpPressed(context),
    );
  }

  /// Callback cuando se presiona "Pokedex Nacional"
  void _onPokedexPressed(BuildContext context) {
    debugPrint('Pokedex Nacional presionado');
    Navigator.pop(context);
  }

  /// Callback cuando se presiona "Mapa"
  void _onMapaPressed(BuildContext context) {
    debugPrint('Mapa presionado');
    Navigator.pop(context);
  }

  /// Callback cuando se presiona "Ayuda"
  void _onHelpPressed(BuildContext context) {
    debugPrint('Ayuda presionado');
    Navigator.pop(context);
  }
}
