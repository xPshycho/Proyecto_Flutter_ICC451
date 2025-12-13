import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_constants.dart';
import 'home_page.dart';

/// Página del Quiz de Pokémon - Diseño Simplificado (Green Theme)
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  String _selectedMode = 'Silueta';
  // Definimos el color verde principal para usarlo en toda la UI
  final Color _mainGreen = const Color(0xFF4FC43C);
  final Color _darkBackground = const Color(0xFF222222);

  void _onHomePressed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          _buildPikachuBackground(),
          _buildMainContent(),
        ],
      ),
    );
  }

  /// Pikachu silueta estática de fondo
  Widget _buildPikachuBackground() {
    return Positioned(
      top: -AppConstants.pikachuSize / 2 + 80,
      left: MediaQuery.of(context).size.width - AppConstants.pikachuSize / 2 - 50,
      child: Opacity(
        opacity: 0.15, // Opacidad reducida para mayor simplicidad visual
        child: ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Color(0xFF424242),
            BlendMode.srcIn,
          ),
          child: SvgPicture.asset(
            'assets/icons/pikachu_2d.svg',
            width: AppConstants.pikachuSize,
            height: AppConstants.pikachuSize,
            fit: BoxFit.contain,
          ),
        ),
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
            _buildQuizButton(),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    _buildHallOfFame(),
                    const SizedBox(height: 16),
                    _buildAchievementsButton(),
                    const SizedBox(height: 16),
                    _buildModeSelection(),
                    const SizedBox(height: 24),
                    _buildPlayButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Botón superior estilo pokedex_page
  Widget _buildQuizButton() {
    return Row(
      children: [
        IconButton(
          onPressed: _onHomePressed,
          icon: const Icon(Icons.home_rounded),
          iconSize: AppConstants.pokedexButtonIconSize,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Expanded(
          child: Center(
            child: TextButton.icon(
              onPressed: () {
                // Futuro: menú de opciones del quiz
              },
              icon: Icon(
                Icons.quiz_outlined,
                size: AppConstants.pokedexButtonIconSize,
                color: _mainGreen,
              ),
              label: Text(
                'Poke Quiz',
                style: TextStyle(
                  fontSize: AppConstants.pokedexButtonFontSize,
                  color: _mainGreen,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppConstants.pokedexButtonIconSize),
      ],
    );
  }

  /// Construye el contenedor del Salón de la Fama
  /// Simplificado: Eliminado el gradiente gris, ahora es fondo plano oscuro con borde sutil.
  Widget _buildHallOfFame() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _darkBackground, // Fondo plano simple
        border: Border.all(color: Color(0xFFA2A2A2), width: 2),
      ),
      child: Column(
        children: [
          const Text(
            "Salón de la Fama",
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          // NO TOCAR _buildRankRow (Mantenido intacto como se solicitó)
          _buildRankRow(
            rank: 1,
            name: "Ash",
            time: "1:00:34",
            score: "99,999",
            trophyAsset: "assets/images/trophies/first.png",
          ),
          _buildRankRow(
            rank: 2,
            name: "Cac",
            time: "0:20:24",
            score: "9,999",
            trophyAsset: "assets/images/trophies/second.png",
          ),
          _buildRankRow(
            rank: 3,
            name: "z2z",
            time: "0:10:48",
            score: "1,320",
            trophyAsset: "assets/images/trophies/third.png",
          ),
          _buildRankRow(rank: 4, name: "nic", time: "0:03:20", score: "643"),
          _buildRankRow(rank: 5, name: "mis", time: "0:00:40", score: "100"),
        ],
      ),
    );
  }

  /// WIDGET INTACTO - NO MODIFICADO
  Widget _buildRankRow({
    required int rank,
    required String name,
    required String time,
    required String score,
    String? trophyAsset,
  }) {
    Color gradientColor = const Color(0xFF323232);

    if (rank == 1) {
      gradientColor = const Color(0xFFFFF58D);
    } else if (rank == 2) {
      gradientColor = const Color(0xFFF8F8F8);
    } else if (rank == 3) {
      gradientColor = const Color(0xFFF0CF90);
    }

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          gradientColor,
          const Color(0xFF323232),
        ],
        stops: const [0.0, 0.25],
      ),
      border: Border.all(color: Color(0x33FFFFFF), width: 1),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      height: 40,
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: trophyAsset != null
                  ? Image.asset(trophyAsset, width: 22, height: 22)
                  : Text(
                "$rank.",
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 80,
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                score,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de logros
  /// Simplificado: Eliminado el morado. Ahora es oscuro con borde verde.
  Widget _buildAchievementsButton() {
    return InkWell(
      onTap: () {
        print("Abriendo logros...");
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _darkBackground, // Fondo plano
        ),
        child: Stack(
          children: const [
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: EdgeInsets.only(left: 16.0),
                child: Text(
                  "Logros",
                  style: TextStyle(
                    fontFamily: 'Pixelated',
                    fontSize: 20,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
            ),
            Positioned(
              top: 10, // Ajustado ligeramente
              right: 14,
              child: Text(
                "0/99",
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 14,
                  color: Colors.white54,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el panel de selección de modalidad
  /// Simplificado: Eliminado gradiente morado y texto naranja. Todo unificado.
  Widget _buildModeSelection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _darkBackground, // Fondo plano
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Modalidad",
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 20,
              color: _mainGreen, // Texto verde en lugar de naranja
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),
          _buildRadioOption("Silueta", "x 1"),
          _buildRadioOption("Descripción", "x 1.5"),
          _buildRadioOption("Numero", "x 2"),
          _buildRadioOption("Sonido", "x 3"),
        ],
      ),
    );
  }

  /// Construye una opción de radio button
  /// Simplificado: El indicador activo ahora es verde en lugar de solo blanco.
  Widget _buildRadioOption(String label, String multiplier) {
    bool isSelected = _selectedMode == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // Fondo sutilmente verde si está seleccionado, transparente si no
          color: isSelected ? _mainGreen.withOpacity(0.1) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: isSelected ? _mainGreen : Colors.white54,
                    width: 2
                ),
              ),
              child: Center(
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Relleno verde si está seleccionado
                    color: isSelected ? _mainGreen : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Pixelated',
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const Spacer(),
            Text(
              multiplier,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                color: Colors.white38,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón principal de jugar
  /// Simplificado: Gradiente reducido para ser menos agresivo, mantiene el verde.
  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 4, // Elevación reducida
        ),
        onPressed: () {
          print("Iniciando juego en modo: $_selectedMode");
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: _mainGreen, // Color plano o gradiente muy sutil
          ),
          child: const Center(
            child: Text(
              "Jugar",
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 24,
                color: Colors.white,
                letterSpacing: 3.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}