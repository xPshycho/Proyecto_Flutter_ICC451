import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../data/services/achievement_service.dart';

/// Página de logros del quiz - Rediseñada con estética del quiz
class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final AchievementService _achievementService = AchievementService();
  List<Achievement> _achievements = [];
  bool _isLoading = true;
  AchievementDifficulty? _selectedDifficulty;

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);

    await _achievementService.initialize();
    final achievements = await _achievementService.getAllAchievements();

    setState(() {
      _achievements = achievements;
      _isLoading = false;
    });
  }

  List<Achievement> get _filteredAchievements {
    if (_selectedDifficulty == null) {
      return _achievements;
    }
    return _achievements.where((a) => a.difficulty == _selectedDifficulty).toList();
  }

  int get _totalUnlocked => _achievements.where((a) => a.isUnlocked).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC43C)),
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildDifficultyFilter(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _buildAchievementsList(),
                  ),
                ],
              ),
            ),
    );
  }

  /// Header con botón home, título "Logros" y contador
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Botón home (blanco)
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.home_rounded),
            iconSize: 28,
            color: Colors.white,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),

          const SizedBox(width: 16),

          // Título "Logros" (verde) centrado
          Expanded(
            child: Center(
              child: Text(
                'Logros',
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 20,
                  color: Color(0xFF4FC43C),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Contador de logros
          Text(
            '$_totalUnlocked/${_achievements.length}',
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Filtro de dificultad horizontal
  Widget _buildDifficultyFilter() {
    return SizedBox(
      height: 32,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildDifficultyChip(null, 'Todos', isSelected: _selectedDifficulty == null),
          const SizedBox(width: 8),
          _buildDifficultyChip(AchievementDifficulty.facil, 'Fácil'),
          const SizedBox(width: 8),
          _buildDifficultyChip(AchievementDifficulty.intermedio, 'Intermedio'),
          const SizedBox(width: 8),
          _buildDifficultyChip(AchievementDifficulty.maestro, 'Maestro'),
          const SizedBox(width: 8),
          _buildDifficultyChip(AchievementDifficulty.arceus, 'Arceus'),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(AchievementDifficulty? difficulty, String label, {bool? isSelected}) {
    final selected = isSelected ?? _selectedDifficulty == difficulty;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDifficulty = selected ? null : difficulty;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected ? const Color(0xFF4FC43C) : const Color(0xFF434343),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 12,
              color: selected ? Colors.black : Colors.white,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  /// Lista de logros
  Widget _buildAchievementsList() {
    if (_filteredAchievements.isEmpty) {
      return const Center(
        child: Text(
          'No hay logros en esta categoría',
          style: TextStyle(
            fontFamily: 'Pixelated',
            color: Colors.white70,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _filteredAchievements.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildAchievementCard(_filteredAchievements[index]);
      },
    );
  }

  /// Tarjeta de logro individual
  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final progress = achievement.progress.clamp(0.0, 1.0);
    final borderColor = _getDifficultyColor(achievement.difficulty);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: const Color(0xFF262626),
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icono de lock grande arriba a la izquierda y nombre
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono de lock grande
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isUnlocked ? const Color(0xFF4FC43C) : const Color(0xFF434343),
                ),
                child: Icon(
                  isUnlocked ? Icons.emoji_events : Icons.lock,
                  color: isUnlocked ? Colors.black : Colors.white54,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              // Nombre y tag de dificultad
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center, // Alinea verticalmente el texto y el tag
                  spacing: 8.0,
                  runSpacing: 4,
                  children: [
                    Text(
                      achievement.name,
                      style: TextStyle(
                        fontFamily: 'Pixelated',
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: isUnlocked ? Colors.white : Colors.white70,
                      ),
                    ),
                    // _buildDifficultyTag(achievement.difficulty),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Descripción
          Text(
            achievement.description,
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 12,
              color: isUnlocked ? Colors.white70 : Colors.white54,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 12),

          // Barra de progreso y fracción (sin porcentaje)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: const Color(0xFF434343),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: isUnlocked ? const Color(0xFF4FC43C) : const Color(0xFF888888),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Solo mostrar la fracción, sin porcentaje
              Text(
                achievement.progressText,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 10,
                  color: isUnlocked ? const Color(0xFF4FC43C) : Colors.white70,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Tag de dificultad con color según categoría
  Widget _buildDifficultyTag(AchievementDifficulty difficulty) {
    Color backgroundColor;
    String label;

    switch (difficulty) {
      case AchievementDifficulty.facil:
        backgroundColor = const Color(0x3F25B435); // Verde con transparencia
        label = 'Fácil';
        break;
      case AchievementDifficulty.intermedio:
        backgroundColor = const Color(0x3FFF9800); // Naranja con transparencia
        label = 'Intermedio';
        break;
      case AchievementDifficulty.maestro:
        backgroundColor = const Color(0x3F9C27B0); // Púrpura con transparencia
        label = 'Maestro';
        break;
      case AchievementDifficulty.arceus:
        backgroundColor = const Color(0x3FF44336); // Rojo con transparencia
        label = 'Arceus';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: backgroundColor,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Pixelated',
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  /// Obtiene el color del borde según la dificultad
  Color _getDifficultyColor(AchievementDifficulty difficulty) {
    switch (difficulty) {
      case AchievementDifficulty.facil:
        return const Color(0xFF25B435); // Verde
      case AchievementDifficulty.intermedio:
        return const Color(0xFFFF9800); // Naranja
      case AchievementDifficulty.maestro:
        return const Color(0xFF9C27B0); // Púrpura
      case AchievementDifficulty.arceus:
        return const Color(0xFFF44336); // Rojo
    }
  }
}
