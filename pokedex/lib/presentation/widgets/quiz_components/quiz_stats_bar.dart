import 'package:flutter/material.dart';

/// Barra superior que muestra las estadísticas del juego
class QuizStatsBar extends StatelessWidget {
  final int score;
  final double multiplier;
  final int remainingTime;
  final int consecutiveCorrect;
  final VoidCallback onExitPressed;

  const QuizStatsBar({
    super.key,
    required this.score,
    required this.multiplier,
    required this.remainingTime,
    required this.consecutiveCorrect,
    required this.onExitPressed,
  });

  String get _formattedScore {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String get _formattedTime {
    final minutes = remainingTime ~/ 60;
    final seconds = remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timeColor {
    if (remainingTime <= 5) return Colors.red;
    if (remainingTime <= 10) return Colors.orange;
    return const Color(0xFF4FC43C);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF4FC43C).withOpacity(0.3),
            width: 2,
          ),
        ),
      ),
      child: Column(
        children: [
          // Primera fila: Exit, Timer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Exit
              IconButton(
                onPressed: onExitPressed,
                icon: const Icon(Icons.close),
                color: Colors.red,
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // Timer
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _timeColor, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.timer,
                      color: _timeColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formattedTime,
                      style: TextStyle(
                        fontFamily: 'Pixelated',
                        fontSize: 18,
                        color: _timeColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Placeholder para balance
              const SizedBox(width: 28),
            ],
          ),

          const SizedBox(height: 12),

          // Segunda fila: Score y Multiplicador
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Score
              Expanded(
                child: _buildStatBox(
                  icon: Icons.star,
                  label: 'PUNTOS',
                  value: _formattedScore,
                  color: const Color(0xFFFFD700),
                ),
              ),

              const SizedBox(width: 12),

              // Multiplicador
              Expanded(
                child: _buildStatBox(
                  icon: Icons.trending_up,
                  label: 'x${multiplier.toStringAsFixed(1)}',
                  value: '$consecutiveCorrect racha',
                  color: const Color(0xFF4FC43C),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 12,
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 14,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

