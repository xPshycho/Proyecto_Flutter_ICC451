class EvolutionDetail {
  final int? minLevel;
  final String? trigger;
  final String? item;
  final String? condition;
  final int evolvesFromSpeciesId;
  final int evolvesToSpeciesId;

  const EvolutionDetail({
    this.minLevel,
    this.trigger,
    this.item,
    this.condition,
    required this.evolvesFromSpeciesId,
    required this.evolvesToSpeciesId,
  });

  factory EvolutionDetail.fromGraphQL(Map<String, dynamic> json) {
    final minLevel = json['min_level'] as int?;
    final triggerData = json['pokemon_v2_evolutiontrigger'] as Map<String, dynamic>?;
    final itemData = json['pokemon_v2_item'] as Map<String, dynamic>?;

    String? trigger;
    if (triggerData != null) {
      final triggerName = triggerData['name'] as String?;
      trigger = _translateTrigger(triggerName);
    }

    String? item;
    if (itemData != null) {
      final itemNames = itemData['pokemon_v2_itemnames'] as List<dynamic>?;
      if (itemNames != null && itemNames.isNotEmpty) {
        item = itemNames[0]['name'] as String?;
      }
    }

    return EvolutionDetail(
      minLevel: minLevel,
      trigger: trigger,
      item: item,
      condition: _buildCondition(json),
      evolvesFromSpeciesId: json['evolves_from_species_id'] as int? ?? 0,
      evolvesToSpeciesId: json['evolved_species_id'] as int? ?? 0,
    );
  }

  static String? _translateTrigger(String? triggerName) {
    if (triggerName == null) return null;

    const triggers = {
      'level-up': 'Nivel',
      'trade': 'Intercambio',
      'use-item': 'Objeto',
      'shed': 'Espacio libre',
      'spin': 'Girar',
      'tower-of-darkness': 'Torre oscuridad',
      'tower-of-waters': 'Torre aguas',
      'three-critical-hits': '3 golpes críticos',
      'take-damage': 'Recibir daño',
      'other': 'Especial',
    };

    return triggers[triggerName] ?? 'Especial';
  }

  static String? _buildCondition(Map<String, dynamic> json) {
    final conditions = <String>[];

    final minHappiness = json['min_happiness'] as int?;
    if (minHappiness != null) {
      conditions.add('Amistad $minHappiness+');
    }

    final minBeauty = json['min_beauty'] as int?;
    if (minBeauty != null) {
      conditions.add('Belleza $minBeauty+');
    }

    final minAffection = json['min_affection'] as int?;
    if (minAffection != null) {
      conditions.add('Afecto $minAffection+');
    }

    final timeOfDay = json['time_of_day'] as String?;
    if (timeOfDay != null && timeOfDay.isNotEmpty) {
      final timeMap = {'day': 'Día', 'night': 'Noche', 'dusk': 'Atardecer'};
      conditions.add(timeMap[timeOfDay] ?? timeOfDay);
    }

    final location = json['pokemon_v2_location']?['pokemon_v2_locationnames'] as List<dynamic>?;
    if (location != null && location.isNotEmpty) {
      final locationName = location[0]['name'] as String?;
      if (locationName != null) conditions.add(locationName);
    }

    final needsRain = json['needs_overworld_rain'] as bool?;
    if (needsRain == true) {
      conditions.add('Lluvia');
    }

    final turnUpsideDown = json['turn_upside_down'] as bool?;
    if (turnUpsideDown == true) {
      conditions.add('Girar consola');
    }

    return conditions.isEmpty ? null : conditions.join(', ');
  }

  String getDisplayText() {
    if (minLevel != null) {
      return 'Nvl. $minLevel';
    }

    if (item != null) {
      return item!;
    }

    if (trigger != null && trigger != 'Nivel') {
      return trigger!;
    }

    if (condition != null) {
      return condition!;
    }

    return '';
  }
}

