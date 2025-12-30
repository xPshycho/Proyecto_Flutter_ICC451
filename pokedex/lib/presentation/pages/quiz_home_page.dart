import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/quiz_translations.dart';
import '../../data/models/quiz_mode.dart';
import '../../data/models/quiz_ranking.dart';
import '../../data/services/quiz_ranking_service.dart';
import '../../data/services/achievement_service.dart';
import '../../data/services/language_service.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../bloc/quiz/quiz_event.dart';
import 'home_page.dart';
import 'quiz_page.dart';
import 'achievements_page.dart';

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
  final AchievementService _achievementService = AchievementService();
  List<QuizRankingEntry> _rankings = [];
  bool _isLoadingRankings = true;

  // Traducciones
  QuizTranslations get tr => QuizTranslations.forLanguage(Provider.of<LanguageService>(context, listen: false).currentLanguage);

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Usar el LanguageService del Provider
    final languageService = Provider.of<LanguageService>(context, listen: false);

    // Actualizar el modo seleccionado al idioma actual
    final tr = QuizTranslations.forLanguage(languageService.currentLanguage);
    _selectedMode = tr.silhouette;

    _loadRankings();
    _achievementService.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadRankings() async {
    final rankings = await _rankingService.getTop5();
    if (mounted) {
      setState(() {
        _rankings = rankings;
        _isLoadingRankings = false;
      });
    }
  }

  void _onHomePressed() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomePage()),
      (route) => false,
    );
  }

  void _onPlayPressed() {
    _showPlayerNameDialog();
  }

  /// Cambia el idioma y recarga la página
  Future<void> _onLanguageChanged() async {
    // Usar el LanguageService del Provider
    final languageService = Provider.of<LanguageService>(context, listen: false);
    await languageService.toggleLanguage();

    // Actualizar el modo seleccionado al nuevo idioma
    final tr = QuizTranslations.forLanguage(languageService.currentLanguage);
    _selectedMode = tr.silhouette;

    if (mounted) {
      setState(() {});
    }
  }

  /// Muestra el modal para ingresar el nombre del jugador
  void _showPlayerNameDialog() {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 350),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _mainGreen,
              width: 3,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.catching_pokemon,
                  color: Color(0xFF4FC43C),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  tr.enterTrainerName,
                  style: const TextStyle(
                    fontFamily: 'Pixelated',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  textAlign: TextAlign.center,
                  maxLength: 3,
                  autofocus: true,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z]')),
                    UpperCaseTextFormatter(),
                  ],
                  style: const TextStyle(
                    fontFamily: 'Pixelated',
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 12,
                  ),
                  decoration: InputDecoration(
                    counterText: '',
                    hintText: 'ASH',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.2),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _mainGreen,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _mainGreen,
                        width: 2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: _mainGreen,
                        width: 3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(dialogContext),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.white30,
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          tr.cancel,
                          style: const TextStyle(
                            fontFamily: 'Pixelated',
                            fontSize: 12,
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          String playerName = nameController.text.trim().toUpperCase();
                          if (playerName.isEmpty) {
                            playerName = 'ASH';
                          }
                          Navigator.pop(dialogContext);
                          _startQuiz(playerName);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _mainGreen,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          tr.start,
                          style: const TextStyle(
                            fontFamily: 'Pixelated',
                            fontSize: 12,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Inicia el quiz con el nombre del jugador
  void _startQuiz(String playerName) {
    final mode = _getModeFromSelectedName(_selectedMode);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => QuizBloc(
            repository: RepositoryProvider.of<PokemonRepository>(context),
            rankingService: _rankingService,
            achievementService: _achievementService,
            languageId: Provider.of<LanguageService>(context, listen: false).languageId,
          )..add(InitializeQuiz(mode: mode, playerName: playerName)),
          child: QuizPage(mode: mode, languageService: Provider.of<LanguageService>(context, listen: false)),
        ),
      ),
    ).then((_) {
      // Recargar rankings cuando vuelva de la partida
      _loadRankings();
      setState(() {}); // Refresh para actualizar el contador de logros
    });
  }

  /// Convierte el nombre del modo seleccionado al enum QuizMode
  QuizMode _getModeFromSelectedName(String modeName) {
    // Comparar con traducciones en español e inglés
    final lowerMode = modeName.toLowerCase();

    if (lowerMode == 'silueta' || lowerMode == 'silhouette') {
      return QuizMode.silhouette;
    } else if (lowerMode == 'descripción' || lowerMode == 'descripcion' || lowerMode == 'description') {
      return QuizMode.description;
    } else if (lowerMode == 'número' || lowerMode == 'numero' || lowerMode == 'number') {
      return QuizMode.number;
    } else if (lowerMode == 'sonido' || lowerMode == 'sound') {
      return QuizMode.sound;
    }

    return QuizMode.silhouette;
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
        opacity: 0.15,
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
                tr.quizTitle,
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
        // Botón de cambio de idioma
        _buildLanguageButton(),
      ],
    );
  }

  /// Botón para cambiar el idioma
  Widget _buildLanguageButton() {
    return InkWell(
      onTap: _onLanguageChanged,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _darkBackground,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _mainGreen, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              Provider.of<LanguageService>(context, listen: false).languageFlag,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 4),
            Text(
              Provider.of<LanguageService>(context, listen: false).currentLanguage.toUpperCase(),
              style: const TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el contenedor del Salón de la Fama
  Widget _buildHallOfFame() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _darkBackground,
        border: Border.all(color: const Color(0xFFA2A2A2), width: 2),
      ),
      child: Column(
        children: [
          Text(
            tr.hallOfFame,
            style: const TextStyle(
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                tr.noRecordsYet,
                textAlign: TextAlign.center,
                style: const TextStyle(
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
      border: Border.all(color: const Color(0x33FFFFFF), width: 1),
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
  Widget _buildAchievementsButton() {
    final stats = _achievementService.getStats();
    final totalAchievements = 27;
    final unlockedCount = stats['totalGamesPlayed']! > 0 ? 1 : 0;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => AchievementsPage(languageService: Provider.of<LanguageService>(context, listen: false)),
          ),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        height: 80,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: _darkBackground,
          border: Border.all(color: _mainGreen, width: 2),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Row(
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      color: Color(0xFF4FC43C),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      tr.achievements,
                      style: const TextStyle(
                        fontFamily: 'Pixelated',
                        fontSize: 20,
                        color: Colors.white,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 14,
              child: Text(
                "$unlockedCount/$totalAchievements",
                style: const TextStyle(
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
  Widget _buildModeSelection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: _darkBackground,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.mode,
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 20,
              color: _mainGreen,
              letterSpacing: 2.0,
            ),
          ),
          const SizedBox(height: 10),
          _buildModeOption(tr.silhouette, "x1.0", Icons.catching_pokemon),
          _buildModeOption(tr.description, "x1.5", Icons.description),
          _buildModeOption(tr.number, "x2.0", Icons.pin),
          _buildModeOption(tr.sound, "x3.0", Icons.volume_up),
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
          children: [
            const Icon(Icons.play_arrow_rounded, size: 32, color: Colors.black),
            const SizedBox(width: 8),
            Text(
              tr.play,
              style: const TextStyle(
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

/// Formateador para convertir el texto a mayúsculas automáticamente
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
