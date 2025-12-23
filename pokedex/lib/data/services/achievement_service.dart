import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement.dart';
import '../../core/utils/pokemon_utils.dart';

/// Servicio para gestionar logros del quiz
class AchievementService {
  static const String _unlockedPokemonKey = 'unlocked_pokemon_ids';
  static const String _statsKey = 'quiz_stats';

  // Estadísticas globales
  int _totalGamesPlayed = 0;
  int _totalCorrectAnswers = 0;
  int _bestStreak = 0;
  int _correctInModeSilhouette = 0;
  int _correctInModeSound = 0;
  int _correctInModeNumber = 0;
  int _correctInModeDescription = 0;

  // Colección de Pokémon descubiertos
  Set<int> _unlockedPokemonIds = {};

  /// Lista completa de logros
  final List<Achievement> _allAchievements = [
    // ========== ARCEUS (Máxima dificultad) ==========
    Achievement(
      id: 'ach_arceus_001',
      difficulty: AchievementDifficulty.arceus,
      name: 'Gotta Catch \'em all!',
      description: 'Acierta la totalidad de los 1025 Pokémon en una sola partida sin perder.',
      targetValue: 1025,
      type: AchievementType.singleSession,
    ),
    Achievement(
      id: 'ach_arceus_002',
      difficulty: AchievementDifficulty.arceus,
      name: 'Dialga: Señor del Tiempo',
      description: 'Mantén una sola partida activa durante 60 minutos acumulando tiempo extra.',
      targetValue: 3600,
      type: AchievementType.singleSession,
    ),
    Achievement(
      id: 'ach_arceus_003',
      difficulty: AchievementDifficulty.arceus,
      name: 'Shiny Hunter',
      description: 'Alcanza un total histórico de 10,000 respuestas correctas acumuladas.',
      targetValue: 10000,
      type: AchievementType.cumulativeTotalCorrect,
    ),

    // ========== MAESTRO POKÉMON ==========
    Achievement(
      id: 'ach_master_001',
      difficulty: AchievementDifficulty.maestro,
      name: 'Noivern: Ecolocalización',
      description: 'Acierta 100 Pokémon jugando exclusivamente en la modalidad \'Sonido\'.',
      targetValue: 100,
      type: AchievementType.cumulativeModeSound,
    ),
    Achievement(
      id: 'ach_master_002',
      difficulty: AchievementDifficulty.maestro,
      name: 'Porygon: Procesamiento de Datos',
      description: 'Adivina 100 Pokémon en la modalidad \'Número\'.',
      targetValue: 100,
      type: AchievementType.cumulativeModeNumber,
    ),
    Achievement(
      id: 'ach_master_003',
      difficulty: AchievementDifficulty.maestro,
      name: 'Profesor Oak: Erudito',
      description: 'Adivina 100 Pokémon en la modalidad \'Descripción\'.',
      targetValue: 100,
      type: AchievementType.cumulativeModeDesc,
    ),
    Achievement(
      id: 'ach_master_004',
      difficulty: AchievementDifficulty.maestro,
      name: 'Ditto: Transformación',
      description: 'Adivina 100 Pokémon en la modalidad \'Silueta\'.',
      targetValue: 100,
      type: AchievementType.cumulativeModeSilhouette,
    ),

    // ========== CAMPEONES DE REGIONES ==========
    Achievement(
      id: 'ach_region_001',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Kanto',
      description: 'Registra aciertos de los primeros 151 Pokémon (Gen 1).',
      targetValue: 151,
      type: AchievementType.collectionRegionKanto,
    ),
    Achievement(
      id: 'ach_region_002',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Johto',
      description: 'Registra aciertos de todos los Pokémon de Johto (ID 152-251).',
      targetValue: 100,
      type: AchievementType.collectionRegionJohto,
    ),
    Achievement(
      id: 'ach_region_003',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Hoenn',
      description: 'Registra aciertos de todos los Pokémon de Hoenn (ID 252-386).',
      targetValue: 135,
      type: AchievementType.collectionRegionHoenn,
    ),
    Achievement(
      id: 'ach_region_004',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Sinnoh',
      description: 'Registra aciertos de todos los Pokémon de Sinnoh (ID 387-493).',
      targetValue: 107,
      type: AchievementType.collectionRegionSinnoh,
    ),
    Achievement(
      id: 'ach_region_005',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Unova',
      description: 'Registra aciertos de todos los Pokémon de Unova (ID 494-649).',
      targetValue: 156,
      type: AchievementType.collectionRegionUnova,
    ),
    Achievement(
      id: 'ach_region_006',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Kalos',
      description: 'Registra aciertos de todos los Pokémon de Kalos (ID 650-721).',
      targetValue: 72,
      type: AchievementType.collectionRegionKalos,
    ),
    Achievement(
      id: 'ach_region_007',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Alola',
      description: 'Registra aciertos de todos los Pokémon de Alola (ID 722-809).',
      targetValue: 88,
      type: AchievementType.collectionRegionAlola,
    ),
    Achievement(
      id: 'ach_region_008',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Galar',
      description: 'Registra aciertos de todos los Pokémon de Galar (ID 810-905).',
      targetValue: 96,
      type: AchievementType.collectionRegionGalar,
    ),
    Achievement(
      id: 'ach_region_009',
      difficulty: AchievementDifficulty.maestro,
      name: 'Campeón de Paldea',
      description: 'Registra aciertos de todos los Pokémon de Paldea (ID 906-1025).',
      targetValue: 120,
      type: AchievementType.collectionRegionPaldea,
    ),

    // ========== INTERMEDIO ==========
    Achievement(
      id: 'ach_inter_001',
      difficulty: AchievementDifficulty.intermedio,
      name: 'Te elijo a ti!!!',
      description: 'Acierta todos los Pokémon iniciales de todas las generaciones.',
      targetValue: 27,
      type: AchievementType.collectionStarters,
    ),
    Achievement(
      id: 'ach_inter_002',
      difficulty: AchievementDifficulty.intermedio,
      name: 'Cazador de Leyendas',
      description: 'Encuentra y acierta 20 Pokémon Legendarios diferentes.',
      targetValue: 20,
      type: AchievementType.collectionLegendary,
    ),
    Achievement(
      id: 'ach_inter_003',
      difficulty: AchievementDifficulty.intermedio,
      name: 'Buscador de Mitos',
      description: 'Encuentra y acierta 10 Pokémon Míticos diferentes.',
      targetValue: 10,
      type: AchievementType.collectionMythical,
    ),
    Achievement(
      id: 'ach_inter_004',
      difficulty: AchievementDifficulty.intermedio,
      name: 'Racha Imparable',
      description: 'Consigue una racha de 50 respuestas correctas consecutivas.',
      targetValue: 50,
      type: AchievementType.cumulativeStreakRecord,
    ),

    // ========== FÁCIL ==========
    Achievement(
      id: 'ach_facil_001',
      difficulty: AchievementDifficulty.facil,
      name: 'Amistad Base',
      description: 'Juega un total de 10 partidas.',
      targetValue: 10,
      type: AchievementType.cumulativeGamesPlayed,
    ),
    Achievement(
      id: 'ach_facil_002',
      difficulty: AchievementDifficulty.facil,
      name: 'Entrenador Novato',
      description: 'Acierta un total de 100 respuestas correctas.',
      targetValue: 100,
      type: AchievementType.cumulativeTotalCorrect,
    ),
    Achievement(
      id: 'ach_facil_003',
      difficulty: AchievementDifficulty.facil,
      name: 'Primer Paso',
      description: 'Completa tu primera partida.',
      targetValue: 1,
      type: AchievementType.cumulativeGamesPlayed,
    ),
    Achievement(
      id: 'ach_facil_004',
      difficulty: AchievementDifficulty.facil,
      name: 'Coleccionista Principiante',
      description: 'Descubre 50 Pokémon diferentes.',
      targetValue: 50,
      type: AchievementType.collectionRegionKanto, // Reutilizamos el tipo para cualquier colección
    ),
  ];

  /// Inicializa el servicio cargando datos guardados
  Future<void> initialize() async {
    await _loadStats();
    await _loadUnlockedPokemon();
    await _loadAchievements();
    debugPrint('AchievementService initialized');
  }

  /// Obtiene todos los logros con su progreso actualizado
  Future<List<Achievement>> getAllAchievements() async {
    return _allAchievements.map((achievement) {
      final progress = _calculateProgress(achievement);
      return achievement.copyWith(currentProgress: progress);
    }).toList();
  }

  /// Actualiza estadísticas después de una partida
  Future<void> updateAfterGame({
    required int correctAnswers,
    required int totalTime,
    required int maxStreak,
    required String mode,
    required List<int> correctPokemonIds,
  }) async {
    _totalGamesPlayed++;
    _totalCorrectAnswers += correctAnswers;

    if (maxStreak > _bestStreak) {
      _bestStreak = maxStreak;
    }

    // Actualizar estadísticas por modo
    switch (mode.toLowerCase()) {
      case 'silueta':
        _correctInModeSilhouette += correctAnswers;
        break;
      case 'sonido':
        _correctInModeSound += correctAnswers;
        break;
      case 'número':
      case 'numero':
        _correctInModeNumber += correctAnswers;
        break;
      case 'descripción':
      case 'descripcion':
        _correctInModeDescription += correctAnswers;
        break;
    }

    // Agregar Pokémon descubiertos
    _unlockedPokemonIds.addAll(correctPokemonIds);

    // Guardar todo
    await _saveStats();
    await _saveUnlockedPokemon();

    debugPrint('Achievement stats updated: Games=$_totalGamesPlayed, Correct=$_totalCorrectAnswers, Unlocked=${_unlockedPokemonIds.length}');
  }

  /// Calcula el progreso de un logro específico
  int _calculateProgress(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.cumulativeGamesPlayed:
        return _totalGamesPlayed;

      case AchievementType.cumulativeTotalCorrect:
        return _totalCorrectAnswers;

      case AchievementType.cumulativeStreakRecord:
        return _bestStreak;

      case AchievementType.cumulativeModeSilhouette:
        return _correctInModeSilhouette;

      case AchievementType.cumulativeModeSound:
        return _correctInModeSound;

      case AchievementType.cumulativeModeNumber:
        return _correctInModeNumber;

      case AchievementType.cumulativeModeDesc:
        return _correctInModeDescription;

      case AchievementType.collectionStarters:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isStarter(id)).length;

      case AchievementType.collectionLegendary:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isLegendary(id)).length;

      case AchievementType.collectionMythical:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isMythical(id)).length;

      case AchievementType.collectionRegionKanto:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isKanto(id)).length;

      case AchievementType.collectionRegionJohto:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isJohto(id)).length;

      case AchievementType.collectionRegionHoenn:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isHoenn(id)).length;

      case AchievementType.collectionRegionSinnoh:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isSinnoh(id)).length;

      case AchievementType.collectionRegionUnova:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isUnova(id)).length;

      case AchievementType.collectionRegionKalos:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isKalos(id)).length;

      case AchievementType.collectionRegionAlola:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isAlola(id)).length;

      case AchievementType.collectionRegionGalar:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isGalar(id)).length;

      case AchievementType.collectionRegionPaldea:
        return _unlockedPokemonIds.where((id) => PokemonUtils.isPaldea(id)).length;

      case AchievementType.singleSession:
        // Los logros de sesión única no se calculan aquí
        return 0;
    }
  }

  /// Carga estadísticas guardadas
  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statsJson = prefs.getString(_statsKey);

      if (statsJson != null) {
        final stats = jsonDecode(statsJson) as Map<String, dynamic>;
        _totalGamesPlayed = stats['totalGamesPlayed'] as int? ?? 0;
        _totalCorrectAnswers = stats['totalCorrectAnswers'] as int? ?? 0;
        _bestStreak = stats['bestStreak'] as int? ?? 0;
        _correctInModeSilhouette = stats['correctInModeSilhouette'] as int? ?? 0;
        _correctInModeSound = stats['correctInModeSound'] as int? ?? 0;
        _correctInModeNumber = stats['correctInModeNumber'] as int? ?? 0;
        _correctInModeDescription = stats['correctInModeDescription'] as int? ?? 0;
      }
    } catch (e) {
      debugPrint('Error loading achievement stats: $e');
    }
  }

  /// Guarda estadísticas
  Future<void> _saveStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final stats = {
        'totalGamesPlayed': _totalGamesPlayed,
        'totalCorrectAnswers': _totalCorrectAnswers,
        'bestStreak': _bestStreak,
        'correctInModeSilhouette': _correctInModeSilhouette,
        'correctInModeSound': _correctInModeSound,
        'correctInModeNumber': _correctInModeNumber,
        'correctInModeDescription': _correctInModeDescription,
      };
      await prefs.setString(_statsKey, jsonEncode(stats));
    } catch (e) {
      debugPrint('Error saving achievement stats: $e');
    }
  }

  /// Carga Pokémon descubiertos
  Future<void> _loadUnlockedPokemon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idsJson = prefs.getString(_unlockedPokemonKey);

      if (idsJson != null) {
        final ids = (jsonDecode(idsJson) as List<dynamic>).map((e) => e as int).toSet();
        _unlockedPokemonIds = ids;
      }
    } catch (e) {
      debugPrint('Error loading unlocked pokemon: $e');
    }
  }

  /// Guarda Pokémon descubiertos
  Future<void> _saveUnlockedPokemon() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_unlockedPokemonKey, jsonEncode(_unlockedPokemonIds.toList()));
    } catch (e) {
      debugPrint('Error saving unlocked pokemon: $e');
    }
  }

  /// Carga logros (para futuras personalizaciones)
  Future<void> _loadAchievements() async {
    // Por ahora, los logros son estáticos
  }

  /// Resetea todos los logros (para testing)
  Future<void> resetAllAchievements() async {
    _totalGamesPlayed = 0;
    _totalCorrectAnswers = 0;
    _bestStreak = 0;
    _correctInModeSilhouette = 0;
    _correctInModeSound = 0;
    _correctInModeNumber = 0;
    _correctInModeDescription = 0;
    _unlockedPokemonIds.clear();

    await _saveStats();
    await _saveUnlockedPokemon();

    debugPrint('All achievements reset');
  }

  /// Obtiene estadísticas generales
  Map<String, int> getStats() {
    return {
      'totalGamesPlayed': _totalGamesPlayed,
      'totalCorrectAnswers': _totalCorrectAnswers,
      'bestStreak': _bestStreak,
      'unlockedPokemon': _unlockedPokemonIds.length,
    };
  }
}

