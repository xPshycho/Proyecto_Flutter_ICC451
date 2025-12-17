import 'package:flutter/material.dart';
import '../../data/models/achievement.dart';
import '../../data/services/achievement_service.dart';

/// Página de logros del quiz
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('LOGROS'),
        centerTitle: true,
        actions: [
          // Mostrar progreso total
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '$_totalUnlocked/${_achievements.length}',
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4FC43C)),
              ),
            )
          : Column(
              children: [
                _buildDifficultyFilter(),
                _buildStatsBar(),
                Expanded(
                  child: _filteredAchievements.isEmpty
                      ? const Center(
                          child: Text(
                            'No hay logros en esta categoría',
                            style: TextStyle(
                              fontFamily: 'Pixelated',
                              color: Colors.white70,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredAchievements.length,
                          itemBuilder: (context, index) {
                            return _buildAchievementCard(_filteredAchievements[index]);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  /// Filtro de dificultad
  Widget _buildDifficultyFilter() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _buildDifficultyChip(null, 'Todos'),
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

  Widget _buildDifficultyChip(AchievementDifficulty? difficulty, String label) {
    final isSelected = _selectedDifficulty == difficulty;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontFamily: 'Pixelated',
          fontSize: 12,
          color: isSelected ? Colors.black : Colors.white,
        ),
      ),
      selected: isSelected,
      selectedColor: const Color(0xFF4FC43C),
      backgroundColor: const Color(0xFF2A2A2A),
      checkmarkColor: Colors.black,
      onSelected: (selected) {
        setState(() {
          _selectedDifficulty = selected ? difficulty : null;
        });
      },
    );
  }

  /// Barra de estadísticas
  Widget _buildStatsBar() {
    final stats = _achievementService.getStats();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF4FC43C), width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(Icons.sports_esports, 'Partidas', stats['totalGamesPlayed']!),
          _buildStatItem(Icons.check_circle, 'Correctas', stats['totalCorrectAnswers']!),
          _buildStatItem(Icons.catching_pokemon, 'Descubiertos', stats['unlockedPokemon']!),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, int value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4FC43C), size: 20),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 10,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  /// Tarjeta de logro
  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isUnlocked
            ? const Color(0xFF2A2A2A)
            : const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked
              ? const Color(0xFF4FC43C)
              : const Color(0xFF444444),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono del logro
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isUnlocked
                        ? const Color(0xFF4FC43C)
                        : const Color(0xFF444444),
                  ),
                  child: Icon(
                    isUnlocked ? Icons.emoji_events : Icons.lock,
                    color: isUnlocked ? Colors.black : Colors.white54,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 12),

                // Contenido
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nombre del logro
                      Text(
                        achievement.name,
                        style: TextStyle(
                          fontFamily: 'Pixelated',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked ? Colors.white : Colors.white70,
                        ),
                      ),

                      const SizedBox(height: 4),

                      // Descripción
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontFamily: 'Pixelated',
                          fontSize: 11,
                          color: isUnlocked ? Colors.white70 : Colors.white54,
                          height: 1.3,
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Tag de dificultad
                      _buildDifficultyTag(achievement.difficulty),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Barra de progreso
          _buildProgressBar(achievement),
        ],
      ),
    );
  }

  /// Tag de dificultad
  Widget _buildDifficultyTag(AchievementDifficulty difficulty) {
    Color color;

    switch (difficulty) {
      case AchievementDifficulty.facil:
        color = Colors.green;
        break;
      case AchievementDifficulty.intermedio:
        color = Colors.orange;
        break;
      case AchievementDifficulty.maestro:
        color = Colors.purple;
        break;
      case AchievementDifficulty.arceus:
        color = Colors.red;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        difficulty.displayName.toUpperCase(),
        style: TextStyle(
          fontFamily: 'Pixelated',
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Barra de progreso
  Widget _buildProgressBar(Achievement achievement) {
    final progress = achievement.progress.clamp(0.0, 1.0);
    final isUnlocked = achievement.isUnlocked;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Texto de progreso
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                achievement.progressText,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 11,
                  color: isUnlocked ? const Color(0xFF4FC43C) : Colors.white70,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 11,
                  color: isUnlocked ? const Color(0xFF4FC43C) : Colors.white70,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Barra
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF444444),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUnlocked ? const Color(0xFF4FC43C) : const Color(0xFF888888),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

