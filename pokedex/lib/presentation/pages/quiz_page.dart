import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/quiz_translations.dart';
import '../../data/models/quiz_mode.dart';
import '../../data/services/audio_service.dart';
import '../../data/services/language_service.dart';
import '../bloc/quiz/quiz_bloc.dart';
import '../bloc/quiz/quiz_event.dart';
import '../bloc/quiz/quiz_state.dart';
import '../widgets/quiz_components/quiz_display_area.dart';
import '../widgets/quiz_components/quiz_answer_options.dart';
import '../widgets/quiz_components/quiz_stats_bar.dart';
import '../widgets/quiz_components/quiz_game_over_dialog.dart';

/// Página principal del quiz de Pokémon
class QuizPage extends StatefulWidget {
  final QuizMode mode;
  final LanguageService languageService;

  const QuizPage({
    super.key,
    required this.mode,
    required this.languageService,
  });

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  final AudioService _audioService = AudioService();

  // Traducciones
  QuizTranslations get tr => QuizTranslations.forLanguage(widget.languageService.currentLanguage);

  @override
  void dispose() {
    _audioService.stopCry();
    super.dispose();
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF4FC43C), width: 2),
          ),
          title: Text(
            tr.exitQuiz,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              color: Colors.white,
              fontSize: 18,
            ),
          ),
          content: Text(
            tr.loseProgress,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                tr.cancel,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white70,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC43C),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                tr.exit,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuizBloc, QuizState>(
      listener: (context, state) {
        if (state is QuizFinished) {
          _showGameOverDialog(context, state);
        } else if (state is QuizPlaying && widget.mode == QuizMode.sound) {
          // Reproducir cry automáticamente en modo sonido
          _audioService.playCry(state.currentPokemon.id);
        } else if (state is QuizReadyToStart) {
          // Auto-iniciar cuando esté listo
          context.read<QuizBloc>().add(StartQuiz(widget.mode));
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: state is! QuizPlaying,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop && state is QuizPlaying) {
              _showExitConfirmation();
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: _buildBody(context, state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, QuizState state) {
    if (state is QuizLoading) {
      return _buildLoadingScreen();
    }

    if (state is QuizReadyToStart) {
      return _buildLoadingScreen(message: tr.preparingQuiz);
    }

    if (state is QuizError) {
      return _buildErrorScreen(state);
    }

    if (state is QuizPlaying || state is QuizCorrectAnswer || state is QuizIncorrectAnswer) {
      final playingState = state is QuizPlaying
          ? state
          : state is QuizCorrectAnswer
              ? state.previousState
              : (state as QuizIncorrectAnswer).previousState;

      // Determinar el ID seleccionado para mostrar en rojo/verde
      int? selectedId;
      if (state is QuizCorrectAnswer) {
        selectedId = playingState.currentPokemon.id; // Respuesta correcta
      } else if (state is QuizIncorrectAnswer) {
        selectedId = state.selectedPokemonId; // Respuesta incorrecta seleccionada
      }

      final showResult = state is QuizCorrectAnswer || state is QuizIncorrectAnswer;

      // Determinar el cambio de tiempo para la animación
      int? timeChange;
      if (state is QuizCorrectAnswer) {
        timeChange = 5; // +5 segundos
      } else if (state is QuizIncorrectAnswer) {
        timeChange = -5; // -5 segundos
      }

      return Column(
        children: [
          // Barra superior con estadísticas
          QuizStatsBar(
            score: playingState.score,
            multiplier: playingState.currentMultiplier,
            remainingTime: playingState.remainingTime,
            consecutiveCorrect: playingState.consecutiveCorrect,
            onExitPressed: _showExitConfirmation,
            timeChange: timeChange,
          ),

          const SizedBox(height: 16),

          // Área de visualización del atributo
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: QuizDisplayArea(
                mode: widget.mode,
                pokemon: playingState.currentPokemon,
                onSoundPlay: () => _audioService.playCry(playingState.currentPokemon.id),
                showResult: showResult,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Opciones de respuesta
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: QuizAnswerOptions(
                options: playingState.options,
                correctPokemonId: playingState.currentPokemon.id,
                showResult: showResult,
                selectedPokemonId: selectedId,
                onAnswerSelected: (pokemonId) {
                  context.read<QuizBloc>().add(AnswerSelected(pokemonId));
                },
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingScreen({String? message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC43C)),
          ),
          const SizedBox(height: 24),
          Text(
            message ?? tr.loadingPokemon,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            tr.pleaseWait,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 12,
              color: Colors.white54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorScreen(QuizError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              tr.errorOccurred,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 14,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC43C),
              ),
              child: Text(
                tr.back,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGameOverDialog(BuildContext context, QuizFinished state) {
    _audioService.stopCry();

    // Guardar automáticamente el resultado ANTES de mostrar el diálogo
    context.read<QuizBloc>().add(SaveQuizResult(state.playerName));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => QuizGameOverDialog(
          mode: state.mode,
          finalScore: state.finalScore,
          totalTime: state.totalTime,
          totalQuestions: state.totalQuestions,
          correctAnswers: state.correctAnswers,
          incorrectAnswers: state.incorrectAnswers,
          enteredTop5: state.enteredTop5,
          languageService: widget.languageService,
          onSaveResult: (playerName) {
            // Ya se guardó automáticamente, pero mantenemos por compatibilidad
          },
          onClose: () {
            Navigator.pop(dialogContext);
            Navigator.pop(context);
          },
        ),
      );
    });
  }
}

