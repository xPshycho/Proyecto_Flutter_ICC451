import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../data/services/quiz_ranking_service.dart';
import '../../../data/models/quiz_mode.dart';
import '../../../data/models/quiz_ranking.dart';
import '../../../data/models/pokemon.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

/// BLoC para gestionar la lógica del quiz de Pokémon
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final PokemonRepository repository;
  final QuizRankingService rankingService;

  Timer? _gameTimer;
  DateTime? _startTime;

  // Constantes del juego
  static const int initialTime = 30;
  static const int timeBonus = 5;
  static const int basePoints = 10;
  static const int maxPokemonId = 1025;
  static const int streakForBonus = 10;

  QuizBloc({
    required this.repository,
    required this.rankingService,
  }) : super(const QuizInitial()) {
    on<StartQuiz>(_onStartQuiz);
    on<LoadNextQuestion>(_onLoadNextQuestion);
    on<AnswerSelected>(_onAnswerSelected);
    on<UpdateTimer>(_onUpdateTimer);
    on<EndQuiz>(_onEndQuiz);
    on<SaveQuizResult>(_onSaveQuizResult);
    on<ResetQuiz>(_onResetQuiz);
  }

  Future<void> _onStartQuiz(StartQuiz event, Emitter<QuizState> emit) async {
    try {
      emit(const QuizLoading());

      _startTime = DateTime.now();
      final questionData = await _loadQuestion(<int>{});

      if (questionData == null) {
        emit(const QuizError('No se pudo cargar la pregunta inicial'));
        return;
      }

      emit(QuizPlaying(
        mode: event.mode,
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        score: 0,
        consecutiveCorrect: 0,
        currentMultiplier: event.mode.baseMultiplier,
        remainingTime: initialTime,
        usedPokemonIds: {questionData['correct'].id},
      ));

      // Iniciar el timer
      _startGameTimer();
    } catch (e) {
      debugPrint('Error starting quiz: $e');
      emit(QuizError('Error al iniciar el quiz: $e'));
    }
  }

  Future<void> _onLoadNextQuestion(
    LoadNextQuestion event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizPlaying) return;

    try {
      final questionData = await _loadQuestion(currentState.usedPokemonIds);

      if (questionData == null) {
        emit(const QuizError('No se pudo cargar la siguiente pregunta'));
        return;
      }

      final updatedUsedIds = Set<int>.from(currentState.usedPokemonIds)
        ..add(questionData['correct'].id);

      emit(currentState.copyWith(
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        usedPokemonIds: updatedUsedIds,
      ));
    } catch (e) {
      debugPrint('Error loading next question: $e');
      emit(QuizError('Error al cargar la siguiente pregunta: $e'));
    }
  }

  Future<void> _onAnswerSelected(
    AnswerSelected event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizPlaying) return;

    final isCorrect = event.selectedPokemonId == currentState.currentPokemon.id;

    if (isCorrect) {
      // Respuesta correcta
      final newConsecutive = currentState.consecutiveCorrect + 1;

      // Calcular multiplicador (incrementa cada 10 aciertos consecutivos)
      final bonusMultiplier = (newConsecutive ~/ streakForBonus).toDouble();
      final newMultiplier = currentState.mode.baseMultiplier + bonusMultiplier;

      // Calcular puntos
      final pointsEarned = (basePoints * newMultiplier).round();
      final newScore = currentState.score + pointsEarned;

      // Agregar tiempo bonus
      final newTime = currentState.remainingTime + timeBonus;

      emit(QuizCorrectAnswer(
        previousState: currentState,
        pointsEarned: pointsEarned,
      ));

      // Pequeña pausa antes de cargar la siguiente pregunta
      await Future.delayed(const Duration(milliseconds: 500));

      // Cargar siguiente pregunta
      final questionData = await _loadQuestion(currentState.usedPokemonIds);

      if (questionData == null) {
        add(const EndQuiz());
        return;
      }

      final updatedUsedIds = Set<int>.from(currentState.usedPokemonIds)
        ..add(questionData['correct'].id);

      emit(QuizPlaying(
        mode: currentState.mode,
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        score: newScore,
        consecutiveCorrect: newConsecutive,
        currentMultiplier: newMultiplier,
        remainingTime: newTime,
        usedPokemonIds: updatedUsedIds,
        totalQuestions: currentState.totalQuestions + 1,
        correctAnswers: currentState.correctAnswers + 1,
        incorrectAnswers: currentState.incorrectAnswers,
      ));
    } else {
      // Respuesta incorrecta
      emit(QuizIncorrectAnswer(
        previousState: currentState,
        correctPokemon: currentState.currentPokemon,
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      // Resetear racha pero continuar
      final questionData = await _loadQuestion(currentState.usedPokemonIds);

      if (questionData == null) {
        add(const EndQuiz());
        return;
      }

      final updatedUsedIds = Set<int>.from(currentState.usedPokemonIds)
        ..add(questionData['correct'].id);

      emit(QuizPlaying(
        mode: currentState.mode,
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        score: currentState.score,
        consecutiveCorrect: 0, // Reset streak
        currentMultiplier: currentState.mode.baseMultiplier, // Reset to base
        remainingTime: currentState.remainingTime,
        usedPokemonIds: updatedUsedIds,
        totalQuestions: currentState.totalQuestions + 1,
        correctAnswers: currentState.correctAnswers,
        incorrectAnswers: currentState.incorrectAnswers + 1,
      ));
    }
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<QuizState> emit) {
    final currentState = state;
    if (currentState is! QuizPlaying) return;

    final newTime = currentState.remainingTime - 1;

    if (newTime <= 0) {
      add(const EndQuiz());
      return;
    }

    emit(currentState.copyWith(remainingTime: newTime));
  }

  Future<void> _onEndQuiz(EndQuiz event, Emitter<QuizState> emit) async {
    _stopGameTimer();

    final currentState = state;
    if (currentState is! QuizPlaying) return;

    final totalTime = _startTime != null
        ? DateTime.now().difference(_startTime!)
        : Duration.zero;

    // Verificar si entra en el top 5
    final enteredTop5 = await rankingService.wouldEnterTop5(
      currentState.score,
      totalTime,
    );

    emit(QuizFinished(
      mode: currentState.mode,
      finalScore: currentState.score,
      totalTime: totalTime,
      totalQuestions: currentState.totalQuestions,
      correctAnswers: currentState.correctAnswers,
      incorrectAnswers: currentState.incorrectAnswers,
      enteredTop5: enteredTop5,
    ));
  }

  Future<void> _onSaveQuizResult(
    SaveQuizResult event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizFinished) return;

    // Validar nombre (máximo 3 caracteres, mayúsculas)
    String playerName = event.playerName.trim().toUpperCase();
    if (playerName.isEmpty || playerName.length > 3) {
      playerName = 'ASH'; // Valor por defecto
    }

    final entry = QuizRankingEntry(
      playerName: playerName,
      score: currentState.finalScore,
      time: currentState.totalTime,
      date: DateTime.now(),
    );

    await rankingService.addEntry(entry);
    debugPrint('Quiz result saved: $playerName - ${currentState.finalScore}');
  }

  void _onResetQuiz(ResetQuiz event, Emitter<QuizState> emit) {
    _stopGameTimer();
    _startTime = null;
    emit(const QuizInitial());
  }

  /// Carga una pregunta con el pokémon correcto y 3 opciones incorrectas
  Future<Map<String, dynamic>?> _loadQuestion(Set<int> usedIds) async {
    try {
      // Generar ID aleatorio que no haya sido usado
      int correctId;
      int attempts = 0;
      do {
        correctId = Random().nextInt(maxPokemonId) + 1;
        attempts++;
        if (attempts > 100) {
          // Si hemos usado casi todos los pokémon, permitir repetición
          usedIds.clear();
          correctId = Random().nextInt(maxPokemonId) + 1;
          break;
        }
      } while (usedIds.contains(correctId));

      // Obtener el pokémon correcto
      final correctPokemon = await repository.fetchPokemonDetail(correctId);

      // Generar 3 IDs incorrectos
      final incorrectIds = <int>[];
      while (incorrectIds.length < 3) {
        final id = Random().nextInt(maxPokemonId) + 1;
        if (id != correctId && !incorrectIds.contains(id)) {
          incorrectIds.add(id);
        }
      }

      // Obtener pokémon incorrectos
      final incorrectPokemons = await Future.wait(
        incorrectIds.map((id) => repository.fetchPokemonDetail(id)),
      );

      // Crear lista de opciones y mezclar
      final options = [correctPokemon, ...incorrectPokemons];
      options.shuffle();

      return {
        'correct': correctPokemon,
        'options': options,
      };
    } catch (e) {
      debugPrint('Error loading question: $e');
      return null;
    }
  }

  void _startGameTimer() {
    _stopGameTimer();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const UpdateTimer());
    });
  }

  void _stopGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = null;
  }

  @override
  Future<void> close() {
    _stopGameTimer();
    return super.close();
  }
}

