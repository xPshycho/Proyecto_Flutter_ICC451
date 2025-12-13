import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/quiz_mode.dart';
import '../../data/models/quiz_ranking.dart';
import '../../data/services/quiz_ranking_service.dart';
import 'home_page.dart';
import 'quiz_page.dart';

/// Página del Quiz de Pokémon - Diseño Simplificado (Green Theme)
class QuizHomePage extends StatefulWidget {
  const QuizHomePage({super.key});

  @override
  State<QuizHomePage> createState() => _QuizHomePageState();
}

class _QuizHomePageState extends State<QuizHomePage> {
  String _selectedMode = 'Silueta';
  final Color _mainGreen = const Color(0xFF4FC43C);
  final Color _darkBackground = const Color(0xFF222222);
  final QuizRankingService _rankingService = QuizRankingService();
  List<QuizRankingEntry> _rankings = [];
  bool _isLoadingRankings = true;

  @override
  void initState() {
    super.initState();
    _loadRankings();
  }

  Future<void> _loadRankings() async {
    final rankings = await _rankingService.getTop5();
    setState(() {
      _rankings = rankings;
      _isLoadingRankings = false;
    });
  }

  void _onHomePressed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void _onPlayPressed() {
    final mode = QuizMode.fromString(_selectedMode);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuizPage(mode: mode),
      ),
    ).then((_) {
      // Recargar rankings cuando vuelva de la partida
      _loadRankings();
    });
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
          if (_isLoadingRankings)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC43C)),
              ),
            )
          else if (_rankings.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No hay registros aún.\n¡Sé el primero en jugar!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            )
          else
            ..._rankings.asMap().entries.map((entry) {
              final index = entry.key;
              final ranking = entry.value;
              return _buildRankRow(
                rank: index + 1,
                name: ranking.playerName,
                time: ranking.formattedTime,
                score: ranking.formattedScore,
                trophyAsset: index == 0
                    ? "assets/images/trophies/first.png"
                    : index == 1
                        ? "assets/images/trophies/second.png"
                        : index == 2
                            ? "assets/images/trophies/third.png"
                            : null,
              );
            }),
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
          _buildModeOption("Silueta", "x1.0", Icons.catching_pokemon),
          _buildModeOption("Descripción", "x1.5", Icons.description),
          _buildModeOption("Número", "x2.0", Icons.pin),
          _buildModeOption("Sonido", "x3.0", Icons.volume_up),
        ],
      ),
    );
  }

  Widget _buildModeOption(String mode, String multiplier, IconData icon) {
    final bool isSelected = _selectedMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = mode;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: isSelected ? _mainGreen : Colors.grey.shade800,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : Colors.white70,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                mode,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 16,
                  color: isSelected ? Colors.black : Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.black.withValues(alpha: 0.2)
                    : _mainGreen.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                multiplier,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 14,
                  color: isSelected ? Colors.black : _mainGreen,
                  fontWeight: FontWeight.bold,
                ),
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
      height: 60,
      child: ElevatedButton(
        onPressed: _onPlayPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _mainGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.play_arrow_rounded, size: 32, color: Colors.black),
            SizedBox(width: 8),
            Text(
              "JUGAR",
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 24,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
