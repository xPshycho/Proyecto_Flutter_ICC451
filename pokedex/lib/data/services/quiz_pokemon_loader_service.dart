import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/pokemon.dart';
import '../repositories/pokemon_repository.dart';
import 'graphql_query_service.dart';
import 'pokemon_mapper_service.dart';

/// Servicio optimizado para cargar Pokémon en lotes para el quiz
/// Soporta carga de nombres traducidos según el idioma seleccionado
class QuizPokemonLoaderService {
  final PokemonRepository repository;
  final int languageId;

  // Configuración de carga
  static const int batchSize = 10;
  static const int minPokemonId = 1;
  static const int maxPokemonId = 1025;
  static const int maxRetries = 5;

  // Cache de Pokémon precargados
  final List<Pokemon> _preloadedPokemons = [];
  final Set<int> _usedPokemonIds = {};
  final Set<int> _availableIds = {};
  final Set<int> _failedIds = {}; // IDs que fallaron al cargar

  // Estado de carga
  bool _isLoading = false;
  bool _isInitialized = false;

  QuizPokemonLoaderService(this.repository, {this.languageId = 7});

  /// Inicializa el servicio y prepara los IDs disponibles
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('QuizLoader: Initializing with languageId: $languageId...');

    // Crear set de IDs disponibles (1-1025)
    _availableIds.clear();
    _failedIds.clear();
    for (int i = minPokemonId; i <= maxPokemonId; i++) {
      _availableIds.add(i);
    }

    _isInitialized = true;
    debugPrint('QuizLoader: Initialized with ${_availableIds.length} available IDs');
  }

  /// Precarga el primer lote de Pokémon
  Future<void> preloadInitialBatch() async {
    if (!_isInitialized) await initialize();

    debugPrint('QuizLoader: Preloading initial batch...');
    await _loadNextBatch();
    debugPrint('QuizLoader: Initial batch loaded (${_preloadedPokemons.length} Pokémon)');
  }

  /// Obtiene el siguiente Pokémon y gestiona la precarga
  Future<Pokemon?> getNextPokemon() async {
    // Si no hay suficientes Pokémon precargados, cargar más
    if (_preloadedPokemons.length < 3 && _availableIds.isNotEmpty) {
      await _loadNextBatch();
    }

    // Si no hay más Pokémon disponibles
    if (_preloadedPokemons.isEmpty) {
      debugPrint('QuizLoader: No more Pokémon available');
      return null;
    }

    // Tomar el primero de la lista
    final pokemon = _preloadedPokemons.removeAt(0);
    _usedPokemonIds.add(pokemon.id);

    debugPrint('QuizLoader: Delivered Pokémon #${pokemon.id} (${_preloadedPokemons.length} remaining in cache, ${_availableIds.length} available IDs)');

    return pokemon;
  }

  /// Genera opciones incorrectas para un Pokémon con reintentos
  Future<List<Pokemon>> generateIncorrectOptions(int correctId) async {
    final incorrectPokemons = <Pokemon>[];
    final usedIdsInThisQuestion = <int>{correctId}; // Solo IDs usados en ESTA pregunta
    int attempts = 0;
    final maxAttempts = 20; // Máximo de intentos totales

    while (incorrectPokemons.length < 3 && attempts < maxAttempts) {
      attempts++;

      // Generar un ID aleatorio que no hayamos usado en ESTA pregunta
      int? randomId = _getRandomAvailableId(usedIdsInThisQuestion);

      if (randomId == null) {
        debugPrint('QuizLoader: No more IDs available for incorrect options');
        break;
      }

      usedIdsInThisQuestion.add(randomId);

      try {
        final pokemon = await repository.fetchPokemonDetail(randomId);
        incorrectPokemons.add(pokemon);
        debugPrint('QuizLoader: Loaded incorrect option #$randomId (${incorrectPokemons.length}/3)');
      } catch (e) {
        debugPrint('QuizLoader: Failed to load incorrect option #$randomId, trying another...');
        _failedIds.add(randomId);
        // Continuar al siguiente intento
      }
    }

    if (incorrectPokemons.length < 3) {
      debugPrint('QuizLoader: WARNING - Only got ${incorrectPokemons.length}/3 incorrect options after $attempts attempts');
    }

    return incorrectPokemons;
  }

  /// Obtiene un ID aleatorio disponible que no esté en la lista de excluidos
  /// Solo excluye IDs de la pregunta actual, no de preguntas anteriores
  int? _getRandomAvailableId(Set<int> excludedIds) {
    final random = Random();
    final candidates = <int>[];

    // Crear lista de candidatos excluyendo solo IDs de la pregunta actual y fallidos persistentes
    for (int i = minPokemonId; i <= maxPokemonId; i++) {
      if (!excludedIds.contains(i) && !_failedIds.contains(i)) {
        candidates.add(i);
      }
    }

    if (candidates.isEmpty) {
      // Si no hay candidatos, permitir usar IDs fallidos como último recurso
      // pero aún respetando los IDs excluidos de la pregunta actual
      for (int i = minPokemonId; i <= maxPokemonId; i++) {
        if (!excludedIds.contains(i)) {
          candidates.add(i);
        }
      }
    }

    if (candidates.isEmpty) return null;

    return candidates[random.nextInt(candidates.length)];
  }

  /// Carga el siguiente lote de Pokémon
  Future<void> _loadNextBatch() async {
    if (_isLoading || _availableIds.isEmpty) return;

    _isLoading = true;

    try {
      // Seleccionar IDs aleatorios del conjunto disponible, evitando los que fallaron
      final idsToLoad = _selectRandomIdsAvoidingFailed(batchSize);

      if (idsToLoad.isEmpty) {
        debugPrint('QuizLoader: No more IDs available to load');
        return;
      }

      debugPrint('QuizLoader: Loading batch of ${idsToLoad.length} Pokémon...');

      // Cargar Pokémon en paralelo para mejor rendimiento
      final futures = idsToLoad.map((id) => _loadPokemon(id));
      final results = await Future.wait(futures);

      // Agregar solo los exitosos
      int successCount = 0;
      for (int i = 0; i < results.length; i++) {
        final pokemon = results[i];
        if (pokemon != null) {
          _preloadedPokemons.add(pokemon);
          successCount++;
        } else {
          // Marcar como fallido
          _failedIds.add(idsToLoad[i]);
        }
      }

      // Remover IDs intentados del conjunto disponible
      _availableIds.removeAll(idsToLoad);

      debugPrint('QuizLoader: Batch loaded successfully ($successCount/${idsToLoad.length})');

      if (_failedIds.isNotEmpty) {
        debugPrint('QuizLoader: Total failed IDs so far: ${_failedIds.length}');
      }

      // Si obtuvimos muy pocos, intentar cargar más inmediatamente
      if (successCount < batchSize ~/ 2 && _availableIds.isNotEmpty) {
        debugPrint('QuizLoader: Low success rate, loading another batch...');
        _isLoading = false;
        await _loadNextBatch();
      }
    } catch (e) {
      debugPrint('QuizLoader: Error loading batch: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Selecciona IDs aleatorios evitando los que ya fallaron
  List<int> _selectRandomIdsAvoidingFailed(int count) {
    final random = Random();
    final availableList = _availableIds
        .where((id) => !_failedIds.contains(id))
        .toList();

    // Si no hay suficientes IDs no-fallidos, incluir algunos fallidos
    if (availableList.length < count) {
      final fallbackIds = _availableIds
          .where((id) => _failedIds.contains(id))
          .toList();
      availableList.addAll(fallbackIds);
    }

    final selected = <int>[];
    final actualCount = min(count, availableList.length);

    for (int i = 0; i < actualCount; i++) {
      final index = random.nextInt(availableList.length);
      selected.add(availableList.removeAt(index));
    }

    return selected;
  }

  /// Carga un Pokémon individual con manejo de errores mejorado
  Future<Pokemon?> _loadPokemon(int id) async {
    try {
      final pokemon = await repository.fetchPokemonDetail(id);
      return pokemon;
    } catch (e) {
      debugPrint('QuizLoader: Error loading Pokémon #$id: $e');
      return null;
    }
  }

  /// Obtiene estadísticas del servicio
  Map<String, dynamic> getStats() {
    return {
      'preloaded': _preloadedPokemons.length,
      'used': _usedPokemonIds.length,
      'available': _availableIds.length,
      'failed': _failedIds.length,
      'total': maxPokemonId,
      'isLoading': _isLoading,
    };
  }

  /// Reinicia el servicio
  void reset() {
    debugPrint('QuizLoader: Resetting...');
    _preloadedPokemons.clear();
    _usedPokemonIds.clear();
    _availableIds.clear();
    _failedIds.clear();
    _isInitialized = false;
    _isLoading = false;
  }

  /// Verifica si hay más Pokémon disponibles
  bool get hasMorePokemons => _availableIds.isNotEmpty || _preloadedPokemons.isNotEmpty;

  /// Obtiene el total de Pokémon usados
  int get totalUsed => _usedPokemonIds.length;
}