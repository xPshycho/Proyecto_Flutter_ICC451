import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/quiz_translations.dart';
import '../../../data/models/quiz_mode.dart';
import '../../../data/services/language_service.dart';

/// Diálogo que se muestra al finalizar el quiz
class QuizGameOverDialog extends StatefulWidget {
  final QuizMode mode;
  final int finalScore;
  final Duration totalTime;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final int maxStreak;
  final bool enteredTop5;
  final LanguageService languageService;
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
    required this.maxStreak,
    required this.enteredTop5,
    required this.languageService,
    required this.onSaveResult,
    required this.onClose,
  });

  @override
  State<QuizGameOverDialog> createState() => _QuizGameOverDialogState();
}

class _QuizGameOverDialogState extends State<QuizGameOverDialog> {
  late String _randomTrainerImage;

  @override
  void initState() {
    super.initState();
    // Seleccionar imagen aleatoria de entrenador (1.png a 9.png)
    final random = Random();
    final trainerNumber = random.nextInt(9) + 1;
    _randomTrainerImage = 'assets/images/trainers/$trainerNumber.png';
  }

  // Traducciones
  QuizTranslations get tr => QuizTranslations.forLanguage(widget.languageService.currentLanguage);

  String get _formattedScore {
    return widget.finalScore.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String get _formattedTime {
    final hours = widget.totalTime.inHours;
    final minutes = widget.totalTime.inMinutes.remainder(60);
    final seconds = widget.totalTime.inSeconds.remainder(60);
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _accuracy {
    if (widget.totalQuestions == 0) return 0;
    return (widget.correctAnswers / widget.totalQuestions) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Colores que se adaptan al tema
    final kTitleGreen = isDark ? const Color(0xFF65E868) : const Color(0xFF4CAF50);
    final kBorderYellow = isDark ? const Color(0xFFFFD600) : const Color(0xFFFFC107);
    final kCardBg = isDark ? const Color(0xFF252525) : const Color(0xFFF5F5F5);
    final kButtonGreen = isDark ? const Color(0xFF2CAC39) : const Color(0xFF4CAF50);
    final kModeTextColor = isDark ? Colors.grey : Colors.grey.shade700;
    final kResultTextColor = isDark ? const Color(0xFFFFF5C4) : const Color(0xFF795548);

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tr.gameFinished,
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 20,
                color: kTitleGreen,
                fontWeight: FontWeight.bold,
                shadows: const [
                  Shadow(color: Colors.black, offset: Offset(2, 2), blurRadius: 0),
                ],
              ),
            ),
            const SizedBox(height: 4),

            Text(
              '${tr.modeLabel}: ${tr.getModeDisplayName(widget.mode.displayName)}',
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 16,
                color: kModeTextColor,
              ),
            ),

            const SizedBox(height: 20),

            // Tarjeta Principal con Borde Amarillo
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: kCardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: kBorderYellow,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Título dentro de la caja (Top 5 o Resultado)
                  Text(
                    widget.enteredTop5 ? tr.enteredTop5.toUpperCase() : tr.results.toUpperCase(),
                    style: TextStyle(
                      fontFamily: 'Pixelated',
                      fontSize: 18,
                      color: kResultTextColor,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Fila con Avatar e Stats
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lado Izquierdo: Avatar / Personaje
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage(_randomTrainerImage),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 10),

                      // Lado Derecho: Lista de estadísticas
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildStatRow(
                              icon: Icons.star,
                              color: kBorderYellow,
                              text: _formattedScore,
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              icon: Icons.timer_outlined,
                              color: kTitleGreen,
                              text: _formattedTime,
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              icon: Icons.check_circle_outline,
                              color: isDark ? Colors.lightBlueAccent : Colors.blue,
                              text: '${_accuracy.toStringAsFixed(0)}%',
                            ),
                            const SizedBox(height: 12),
                            _buildStatRow(
                              icon: Icons.local_fire_department,
                              color: isDark ? Colors.redAccent : Colors.red,
                              text: widget.maxStreak.toString(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 4. Botón Cerrar
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: widget.onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kButtonGreen,
                  foregroundColor: Colors.black,
                  elevation: 5,
                  shadowColor: Colors.black54,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: Text(
                  tr.close.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: 'Pixelated',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper para las filas de estadísticas
  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    const pixelShadow = [
      Shadow(
        color: Color(0xFF000000),
        offset: Offset(2, 4),
        blurRadius: 0,
      ),
    ];

    return Row(
      children: [
        Text(
          String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontFamily: icon.fontFamily,
            package: icon.fontPackage,
            fontSize: 24,
            color: color,
            shadows: pixelShadow,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 20,
            color: color,
            fontWeight: FontWeight.bold,
            shadows: pixelShadow,
          ),
        ),
      ],
    );
  }
}
