import 'dart:ui';
import 'dart:math';
import 'dart:async';
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
  bool _showLabels = false;
  Timer? _toggleTimer;
  late String _randomTrainerImage;

  @override
  void initState() {
    super.initState();
    // Seleccionar imagen aleatoria de entrenador (1.png a 9.png)
    final random = Random();
    final trainerNumber = random.nextInt(9) + 1;
    _randomTrainerImage = 'assets/images/trainers/$trainerNumber.png';

    // Alternar entre valores y labels cada 5 segundos
    _toggleTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          _showLabels = !_showLabels;
        });
      }
    });
  }

  @override
  void dispose() {
    _toggleTimer?.cancel();
    super.dispose();
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
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get _accuracy {
    if (widget.totalQuestions == 0) return 0;
    return (widget.correctAnswers / widget.totalQuestions) * 100;
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            color: const Color(0xFF1F1F1F),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF4FC43C),
              width: 4,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4FC43C).withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 0,
              ),
              // Inner shadow effect (simulado con otro contenedor)
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 32),

              // Título y modo
              _buildHeader(),

              const SizedBox(height: 24),

              // Card de Top 5 (solo si aplica)
              if (widget.enteredTop5) ...[
                _buildTop5Card(),
                const SizedBox(height: 24),
              ],

              // Card de estadísticas sin Top 5 o con Top 5
              if (!widget.enteredTop5) ...[
                _buildStatsCardWithoutTop5(),
                const SizedBox(height: 24),
              ],

              // Botón cerrar
              _buildCloseButton(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          tr.gameFinished,
          style: const TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 24,
            color: Color(0xFFB2FC74),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${tr.modeLabel}: ${tr.getModeDisplayName(widget.mode.displayName)}',
          style: const TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 18,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  Widget _buildTop5Card() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFFFD700),
            width: 3,
          ),
        ),
        child: Column(
          children: [
            // Título Top 5
            Text(
              tr.enteredTop5,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 20,
                color: Color(0xFFFFD700),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Contenedor con imagen y estadísticas
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Imagen del entrenador
                Image.asset(
                  _randomTrainerImage,
                  width: 100,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 100,
                      color: Colors.white54,
                    );
                  },
                ),
                const SizedBox(width: 16),

                // Estadísticas en columna
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatRow(
                        icon: Icons.star,
                        color: const Color(0xFFFFD700),
                        value: _formattedScore,
                        label: tr.finalScore,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.timer,
                        color: const Color(0xFF4FC43C),
                        value: _formattedTime,
                        label: tr.time,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.check_circle,
                        color: Colors.blue,
                        value: '${_accuracy.toStringAsFixed(0)}%',
                        label: tr.accuracy,
                      ),
                      const SizedBox(height: 12),
                      _buildStatRow(
                        icon: Icons.local_fire_department,
                        color: Colors.orange,
                        value: '${widget.maxStreak}',
                        label: tr.streak,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCardWithoutTop5() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF262626),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4FC43C),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            _buildStatRow(
              icon: Icons.star,
              color: const Color(0xFFFFD700),
              value: _formattedScore,
              label: tr.finalScore,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.timer,
              color: const Color(0xFF4FC43C),
              value: _formattedTime,
              label: tr.time,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.check_circle,
              color: Colors.blue,
              value: '${_accuracy.toStringAsFixed(0)}%',
              label: tr.accuracy,
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              icon: Icons.local_fire_department,
              color: Colors.orange,
              value: '${widget.maxStreak}',
              label: tr.streak,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: Text(
              _showLabels ? label : value,
              key: ValueKey(_showLabels ? 'label' : 'value'),
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 12,
                color: _showLabels ? color : Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCloseButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        height: 64,
        child: ElevatedButton(
          onPressed: widget.onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF25B435),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: Text(
            tr.close,
            style: const TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
