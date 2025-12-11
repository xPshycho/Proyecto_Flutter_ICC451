import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;
import 'pokedex_page.dart';
import 'map_page.dart';
import 'quiz_page.dart';

/// Página principal con menú de navegación
///
/// Muestra tres botones principales para acceder a:
/// - Pokedex: Lista completa de Pokémon
/// - Mapa: Mapa interactivo
/// - Quiz: Juego de adivinanzas
class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  iconAsset: 'assets/icons/pokeaball.svg',
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
                      MaterialPageRoute(builder: (_) => const QuizPage()),
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
