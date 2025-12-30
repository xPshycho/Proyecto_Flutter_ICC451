import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../data/services/quiz_ranking_service.dart';
import '../../../data/services/quiz_pokemon_loader_service.dart';
import '../../../data/services/achievement_service.dart';
import '../../../data/services/language_service.dart';
import '../../../data/models/quiz_ranking.dart';
import 'quiz_event.dart';
import 'quiz_state.dart';

/// BLoC para gestionar la lógica del quiz de Pokémon
class QuizBloc extends Bloc<QuizEvent, QuizState> {
  final PokemonRepository repository;
  final QuizRankingService rankingService;
  final AchievementService achievementService;
  final int languageId;
  late final QuizPokemonLoaderService _loaderService;

  Timer? _gameTimer;
  DateTime? _startTime;
  String? _playerName;

  // Para tracking de logros
  final List<int> _correctPokemonIdsThisGame = [];
  int _maxStreakThisGame = 0;

  // Constantes del juego
  static const int initialTime = 30;
  static const int timeBonus = 5;
  static const int timePenalty = 5; // Penalidad por respuesta incorrecta
  static const int basePoints = 10;
  static const int streakForBonus = 10;

  QuizBloc({
    required this.repository,
    required this.rankingService,
    required this.achievementService,
    this.languageId = LanguageService.spanishLanguageId,
  }) : super(const QuizInitial()) {
    _loaderService = QuizPokemonLoaderService(repository, languageId: languageId);

    on<InitializeQuiz>(_onInitializeQuiz);
    on<StartQuiz>(_onStartQuiz);
    on<LoadNextQuestion>(_onLoadNextQuestion);
    on<AnswerSelected>(_onAnswerSelected);
    on<UpdateTimer>(_onUpdateTimer);
    on<EndQuiz>(_onEndQuiz);
    on<SaveQuizResult>(_onSaveQuizResult);
    on<ResetQuiz>(_onResetQuiz);
  }

  Future<void> _onInitializeQuiz(InitializeQuiz event, Emitter<QuizState> emit) async {
    try {
      emit(const QuizLoading());

      // Guardar nombre del jugador
      _playerName = event.playerName;

      // Inicializar el servicio de carga
      await _loaderService.initialize();

      // Precargar el primer lote
      await _loaderService.preloadInitialBatch();

      emit(QuizReadyToStart(
        mode: event.mode,
        playerName: _playerName!,
      ));
    } catch (e) {
      debugPrint('Error initializing quiz: $e');
      emit(QuizError('Error al inicializar el quiz: $e'));
    }
  }

  Future<void> _onStartQuiz(StartQuiz event, Emitter<QuizState> emit) async {
    try {
      final currentState = state;
      if (currentState is! QuizReadyToStart) {
        emit(const QuizError('El quiz no está listo para iniciar'));
        return;
      }

      _startTime = DateTime.now();
      final questionData = await _loadQuestion();

      if (questionData == null) {
        emit(const QuizError('No se pudo cargar la pregunta inicial'));
        return;
      }

      emit(QuizPlaying(
        mode: event.mode,
        playerName: _playerName!,
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        score: 0,
        consecutiveCorrect: 0,
        currentMultiplier: event.mode.baseMultiplier,
        remainingTime: initialTime,
        totalQuestions: 0,
        correctAnswers: 0,
        incorrectAnswers: 0,
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
      final questionData = await _loadQuestion();

      if (questionData == null) {
        emit(const QuizError('No se pudo cargar la siguiente pregunta'));
        return;
      }

      emit(currentState.copyWith(
        currentPokemon: questionData['correct'],
        options: questionData['options'],
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

      // Tracking de logros - agregar ID y actualizar racha
      _correctPokemonIdsThisGame.add(currentState.currentPokemon.id);
      if (newConsecutive > _maxStreakThisGame) {
        _maxStreakThisGame = newConsecutive;
      }

      // Pequeña pausa antes de cargar la siguiente pregunta
      await Future.delayed(const Duration(milliseconds: 500));

      // Cargar siguiente pregunta
      final questionData = await _loadQuestion();

      if (questionData == null) {
        add(const EndQuiz());
        return;
      }

      emit(QuizPlaying(
        mode: currentState.mode,
        playerName: currentState.playerName,
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        score: newScore,
        consecutiveCorrect: newConsecutive,
        currentMultiplier: newMultiplier,
        remainingTime: newTime,
        totalQuestions: currentState.totalQuestions + 1,
        correctAnswers: currentState.correctAnswers + 1,
        incorrectAnswers: currentState.incorrectAnswers,
      ));
    } else {
      // Respuesta incorrecta
      emit(QuizIncorrectAnswer(
        previousState: currentState,
        selectedPokemonId: event.selectedPokemonId,
        correctPokemon: currentState.currentPokemon,
      ));

      await Future.delayed(const Duration(milliseconds: 500));

      // Resetear racha pero continuar
      final questionData = await _loadQuestion();

      if (questionData == null) {
        add(const EndQuiz());
        return;
      }

      emit(QuizPlaying(
        mode: currentState.mode,
        playerName: currentState.playerName,
        currentPokemon: questionData['correct'],
        options: questionData['options'],
        score: currentState.score,
        consecutiveCorrect: 0, // Reset streak
        currentMultiplier: currentState.mode.baseMultiplier, // Reset to base
        remainingTime: currentState.remainingTime - timePenalty, // Aplicar penalización
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

    // Actualizar logros
    await achievementService.updateAfterGame(
      correctAnswers: currentState.correctAnswers,
      totalTime: totalTime.inSeconds,
      maxStreak: _maxStreakThisGame,
      mode: currentState.mode.displayName,
      correctPokemonIds: _correctPokemonIdsThisGame,
    );

    // Verificar si entra en el top 5
    final enteredTop5 = await rankingService.wouldEnterTop5(
      currentState.score,
      totalTime,
    );

    // Obtener estadísticas del loader
    final stats = _loaderService.getStats();
    debugPrint('QuizBloc: Game ended - Stats: $stats');

    emit(QuizFinished(
      mode: currentState.mode,
      playerName: currentState.playerName,
      finalScore: currentState.score,
      totalTime: totalTime,
      totalQuestions: currentState.totalQuestions,
      correctAnswers: currentState.correctAnswers,
      incorrectAnswers: currentState.incorrectAnswers,
      maxStreak: _maxStreakThisGame,
      enteredTop5: enteredTop5,
    ));
  }

  Future<void> _onSaveQuizResult(
    SaveQuizResult event,
    Emitter<QuizState> emit,
  ) async {
    final currentState = state;
    if (currentState is! QuizFinished) return;

    // Usar el nombre guardado o el del evento
    final playerName = event.playerName ?? currentState.playerName;

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
    _playerName = null;
    _loaderService.reset();
    emit(const QuizInitial());
  }

  /// Carga una pregunta usando el servicio optimizado
  Future<Map<String, dynamic>?> _loadQuestion() async {
    try {
      // Obtener el siguiente Pokémon del servicio de precarga
      final correctPokemon = await _loaderService.getNextPokemon();

      if (correctPokemon == null) {
        debugPrint('QuizBloc: No more Pokémon available');
        return null;
      }

      // Generar opciones incorrectas
      final incorrectPokemons = await _loaderService.generateIncorrectOptions(
        correctPokemon.id,
      );

      if (incorrectPokemons.length < 3) {
        debugPrint('QuizBloc: Failed to load enough incorrect options');
        return null;
      }

      // Crear lista de opciones y mezclar
      final options = [correctPokemon, ...incorrectPokemons];
      options.shuffle();

      return {
        'correct': correctPokemon,
        'options': options,
      };
    } catch (e) {
      debugPrint('QuizBloc: Error loading question: $e');
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
    _loaderService.reset();
    return super.close();
  }
}
