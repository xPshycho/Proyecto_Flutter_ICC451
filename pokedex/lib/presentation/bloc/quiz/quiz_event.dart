import 'package:equatable/equatable.dart';
import '../../../data/models/quiz_mode.dart';

/// Eventos para el QuizBloc
abstract class QuizEvent extends Equatable {
  const QuizEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializa el quiz con el nombre del jugador y precarga Pokémon
class InitializeQuiz extends QuizEvent {
  final QuizMode mode;
  final String playerName;

  const InitializeQuiz({
    required this.mode,
    required this.playerName,
  });

  @override
  List<Object?> get props => [mode, playerName];
}

/// Inicia una nueva partida de quiz
class StartQuiz extends QuizEvent {
  final QuizMode mode;

  const StartQuiz(this.mode);

  @override
  List<Object?> get props => [mode];
}

/// Carga la siguiente pregunta
class LoadNextQuestion extends QuizEvent {
  const LoadNextQuestion();
}

/// Respuesta seleccionada por el usuario
class AnswerSelected extends QuizEvent {
  final int selectedPokemonId;

  const AnswerSelected(this.selectedPokemonId);

  @override
  List<Object?> get props => [selectedPokemonId];
}

/// Actualización del timer
class UpdateTimer extends QuizEvent {
  const UpdateTimer();
}

/// Finaliza el quiz
class EndQuiz extends QuizEvent {
  const EndQuiz();
}

/// Guarda el resultado en el ranking
class SaveQuizResult extends QuizEvent {
  final String? playerName;

  const SaveQuizResult([this.playerName]);

  @override
  List<Object?> get props => [playerName];
}

/// Reinicia el quiz
class ResetQuiz extends QuizEvent {
  const ResetQuiz();
}
