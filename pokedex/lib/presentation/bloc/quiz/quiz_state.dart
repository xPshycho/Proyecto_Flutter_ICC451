import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_mode.dart';
import '../../../data/models/pokemon.dart';

/// Estados del QuizBloc
abstract class QuizState extends Equatable {
  const QuizState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class QuizInitial extends QuizState {
  const QuizInitial();
}

/// Estado de carga
class QuizLoading extends QuizState {
  const QuizLoading();
}

/// Estado listo para iniciar (después de precargar)
class QuizReadyToStart extends QuizState {
  final QuizMode mode;
  final String playerName;

  const QuizReadyToStart({
    required this.mode,
    required this.playerName,
  });

  @override
  List<Object?> get props => [mode, playerName];
}

/// Estado de juego activo
class QuizPlaying extends QuizState {
  final QuizMode mode;
  final String playerName;
  final Pokemon currentPokemon;
  final List<Pokemon> options; // 4 opciones (1 correcta + 3 incorrectas)
  final int score;
  final int consecutiveCorrect;
  final double currentMultiplier;
  final int remainingTime; // en segundos

  // Estadísticas para futuros logros
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;

  const QuizPlaying({
    required this.mode,
    required this.playerName,
    required this.currentPokemon,
    required this.options,
    required this.score,
    required this.consecutiveCorrect,
    required this.currentMultiplier,
    required this.remainingTime,
    this.totalQuestions = 0,
    this.correctAnswers = 0,
    this.incorrectAnswers = 0,
  });

  QuizPlaying copyWith({
    Pokemon? currentPokemon,
    List<Pokemon>? options,
    int? score,
    int? consecutiveCorrect,
    double? currentMultiplier,
    int? remainingTime,
    int? totalQuestions,
    int? correctAnswers,
    int? incorrectAnswers,
  }) {
    return QuizPlaying(
      mode: mode,
      playerName: playerName,
      currentPokemon: currentPokemon ?? this.currentPokemon,
      options: options ?? this.options,
      score: score ?? this.score,
      consecutiveCorrect: consecutiveCorrect ?? this.consecutiveCorrect,
      currentMultiplier: currentMultiplier ?? this.currentMultiplier,
      remainingTime: remainingTime ?? this.remainingTime,
      totalQuestions: totalQuestions ?? this.totalQuestions,
      correctAnswers: correctAnswers ?? this.correctAnswers,
      incorrectAnswers: incorrectAnswers ?? this.incorrectAnswers,
    );
  }

  @override
  List<Object?> get props => [
        mode,
        playerName,
        currentPokemon,
        options,
        score,
        consecutiveCorrect,
        currentMultiplier,
        remainingTime,
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
      ];
}

/// Estado cuando se responde correctamente
class QuizCorrectAnswer extends QuizState {
  final QuizPlaying previousState;
  final int pointsEarned;

  const QuizCorrectAnswer({
    required this.previousState,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [previousState, pointsEarned];
}

/// Estado cuando se responde incorrectamente
class QuizIncorrectAnswer extends QuizState {
  final QuizPlaying previousState;
  final Pokemon correctPokemon;
  final int selectedPokemonId; // ID de la opción incorrecta seleccionada

  const QuizIncorrectAnswer({
    required this.previousState,
    required this.correctPokemon,
    required this.selectedPokemonId,
  });

  @override
  List<Object?> get props => [previousState, correctPokemon, selectedPokemonId];
}

/// Estado de finalización del quiz
class QuizFinished extends QuizState {
  final QuizMode mode;
  final String playerName;
  final int finalScore;
  final Duration totalTime;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int maxStreak;
  final bool enteredTop5;

  const QuizFinished({
    required this.mode,
    required this.playerName,
    required this.finalScore,
    required this.totalTime,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.maxStreak,
    this.enteredTop5 = false,
  });

  @override
  List<Object?> get props => [
        mode,
        playerName,
        finalScore,
        totalTime,
        totalQuestions,
        correctAnswers,
        incorrectAnswers,
        maxStreak,
        enteredTop5,
      ];
}

/// Estado de error
class QuizError extends QuizState {
  final String message;

  const QuizError(this.message);

  @override
  List<Object?> get props => [message];
}
