/// Modelo que representa un logro del quiz
class Achievement {
  final String id;
  final AchievementDifficulty difficulty;
  final String name;
  final String description;
  final int targetValue;
  final int currentProgress;
  final AchievementType type;

  Achievement({
    required this.id,
    required this.difficulty,
    required this.name,
    required this.description,
    required this.targetValue,
    this.currentProgress = 0,
    required this.type,
  });

  bool get isUnlocked => currentProgress >= targetValue;

  double get progress => currentProgress / targetValue;

  String get progressText => '$currentProgress / $targetValue';

  Achievement copyWith({
    int? currentProgress,
  }) {
    return Achievement(
      id: id,
      difficulty: difficulty,
      name: name,
      description: description,
      targetValue: targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      type: type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'difficulty': difficulty.name,
      'achievement': name,
      'description': description,
      'target_value': targetValue,
      'progress': currentProgress,
      'type': type.name,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      difficulty: AchievementDifficulty.fromString(json['difficulty'] as String),
      name: json['achievement'] as String,
      description: json['description'] as String,
      targetValue: json['target_value'] as int,
      currentProgress: (json['progress'] as num?)?.toInt() ?? 0,
      type: AchievementType.fromString(json['type'] as String),
    );
  }
}

enum AchievementDifficulty {
  facil,
  intermedio,
  maestro,
  arceus;

  String get displayName {
    switch (this) {
      case AchievementDifficulty.facil:
        return 'Fácil';
      case AchievementDifficulty.intermedio:
        return 'Intermedio';
      case AchievementDifficulty.maestro:
        return 'Maestro Pokémon';
      case AchievementDifficulty.arceus:
        return 'Arceus';
    }
  }

  static AchievementDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'facil':
      case 'fácil':
        return AchievementDifficulty.facil;
      case 'intermedio':
        return AchievementDifficulty.intermedio;
      case 'maestro pokemon':
      case 'maestro pokémon':
        return AchievementDifficulty.maestro;
      case 'arceus':
        return AchievementDifficulty.arceus;
      default:
        return AchievementDifficulty.facil;
    }
  }
}

enum AchievementType {
  singleSession,
  cumulativeModeSound,
  cumulativeModeNumber,
  cumulativeModeDesc,
  cumulativeModeSilhouette,
  collectionStarters,
  collectionLegendary,
  collectionMythical,
  collectionRegionKanto,
  collectionRegionJohto,
  collectionRegionHoenn,
  collectionRegionSinnoh,
  collectionRegionUnova,
  collectionRegionKalos,
  collectionRegionAlola,
  collectionRegionGalar,
  collectionRegionPaldea,
  cumulativeGamesPlayed,
  cumulativeTotalCorrect,
  cumulativeStreakRecord;

  static AchievementType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'single_session':
        return AchievementType.singleSession;
      case 'cumulative_mode_sound':
        return AchievementType.cumulativeModeSound;
      case 'cumulative_mode_number':
        return AchievementType.cumulativeModeNumber;
      case 'cumulative_mode_desc':
        return AchievementType.cumulativeModeDesc;
      case 'cumulative_mode_silhouette':
        return AchievementType.cumulativeModeSilhouette;
      case 'collection_starters':
        return AchievementType.collectionStarters;
      case 'collection_legendary':
        return AchievementType.collectionLegendary;
      case 'collection_mythical':
        return AchievementType.collectionMythical;
      case 'collection_region_kanto':
        return AchievementType.collectionRegionKanto;
      case 'collection_region_johto':
        return AchievementType.collectionRegionJohto;
      case 'collection_region_hoenn':
        return AchievementType.collectionRegionHoenn;
      case 'collection_region_sinnoh':
        return AchievementType.collectionRegionSinnoh;
      case 'collection_region_unova':
        return AchievementType.collectionRegionUnova;
      case 'collection_region_kalos':
        return AchievementType.collectionRegionKalos;
      case 'collection_region_alola':
        return AchievementType.collectionRegionAlola;
      case 'collection_region_galar':
        return AchievementType.collectionRegionGalar;
      case 'collection_region_paldea':
        return AchievementType.collectionRegionPaldea;
      case 'cumulative_games_played':
        return AchievementType.cumulativeGamesPlayed;
      case 'cumulative_total_correct':
        return AchievementType.cumulativeTotalCorrect;
      case 'cumulative_streak_record':
        return AchievementType.cumulativeStreakRecord;
      default:
        return AchievementType.cumulativeGamesPlayed;
    }
  }
}

