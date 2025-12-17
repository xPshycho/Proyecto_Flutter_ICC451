import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../data/models/quiz_mode.dart';

/// Diálogo que se muestra al finalizar el quiz
class QuizGameOverDialog extends StatelessWidget {
  final QuizMode mode;
  final int finalScore;
  final Duration totalTime;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final bool enteredTop5;
  final Function(String) onSaveResult;
  final VoidCallback onClose;

  const QuizGameOverDialog({
    super.key,
    required this.mode,
    required this.finalScore,
    required this.totalTime,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.enteredTop5,
    required this.onSaveResult,
    required this.onClose,
  });

  String get _formattedScore {
    return finalScore.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String get _formattedTime {
    final hours = totalTime.inHours;
    final minutes = totalTime.inMinutes.remainder(60);
    final seconds = totalTime.inSeconds.remainder(60);
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _accuracy {
    if (totalQuestions == 0) return 0;
    return (correctAnswers / totalQuestions) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFF4FC43C),
              width: 3,
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  const Text(
                    '¡PARTIDA TERMINADA!',
                    style: TextStyle(
                      fontFamily: 'Pixelated',
                      fontSize: 22,
                      color: Color(0xFF4FC43C),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Modo: ${mode.displayName}',
                    style: const TextStyle(
                      fontFamily: 'Pixelated',
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Puntuación principal
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFD700),
                          size: 40,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'PUNTUACIÓN FINAL',
                          style: TextStyle(
                            fontFamily: 'Pixelated',
                            fontSize: 14,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formattedScore,
                          style: const TextStyle(
                            fontFamily: 'Pixelated',
                            fontSize: 36,
                            color: Color(0xFFFFD700),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Estadísticas
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.timer,
                          label: 'TIEMPO',
                          value: _formattedTime,
                          color: const Color(0xFF4FC43C),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.check_circle,
                          label: 'PRECISIÓN',
                          value: '${_accuracy.toStringAsFixed(0)}%',
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.quiz,
                          label: 'PREGUNTAS',
                          value: '$totalQuestions',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.done_all,
                          label: 'CORRECTAS',
                          value: '$correctAnswers',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Mensaje de Top 5 si aplica
                  if (enteredTop5) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC43C).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFFFFD700),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFFFD700),
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            '¡ENTRASTE AL TOP 5!',
                            style: TextStyle(
                              fontFamily: 'Pixelated',
                              fontSize: 18,
                              color: Color(0xFFFFD700),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Tu puntuación ha sido guardada',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Pixelated',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Botón cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FC43C),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'CERRAR',
                        style: TextStyle(
                          fontFamily: 'Pixelated',
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 10,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

