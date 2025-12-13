import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../data/models/quiz_mode.dart';

/// Diálogo que se muestra al finalizar el quiz
class QuizGameOverDialog extends StatefulWidget {
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

  @override
  State<QuizGameOverDialog> createState() => _QuizGameOverDialogState();
}

class _QuizGameOverDialogState extends State<QuizGameOverDialog> {
  final TextEditingController _nameController = TextEditingController();
  bool _nameSaved = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

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

  void _saveName() {
    if (_nameSaved) return;

    String name = _nameController.text.trim().toUpperCase();
    if (name.isEmpty) {
      name = 'ASH';
    } else if (name.length > 3) {
      name = name.substring(0, 3);
    }

    widget.onSaveResult(name);
    setState(() {
      _nameSaved = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡Resultado guardado como $name!',
          style: const TextStyle(fontFamily: 'Pixelated'),
        ),
        backgroundColor: const Color(0xFF4FC43C),
        duration: const Duration(seconds: 2),
      ),
    );
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
                    'Modo: ${widget.mode.displayName}',
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
                          value: '${widget.totalQuestions}',
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.done_all,
                          label: 'CORRECTAS',
                          value: '${widget.correctAnswers}',
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Entrada de nombre si entró al top 5
                  if (widget.enteredTop5 && !_nameSaved) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4FC43C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4FC43C),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Color(0xFFFFD700),
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            '¡ENTRASTE AL TOP 5!',
                            style: TextStyle(
                              fontFamily: 'Pixelated',
                              fontSize: 16,
                              color: Color(0xFF4FC43C),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Ingresa tu nombre (máx 3 letras)',
                            style: TextStyle(
                              fontFamily: 'Pixelated',
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _nameController,
                            textAlign: TextAlign.center,
                            maxLength: 3,
                            textCapitalization: TextCapitalization.characters,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[A-Za-z]'),
                              ),
                              UpperCaseTextFormatter(),
                            ],
                            style: const TextStyle(
                              fontFamily: 'Pixelated',
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 8,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              hintText: 'ASH',
                              hintStyle: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                              filled: true,
                              fillColor: const Color(0xFF2A2A2A),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4FC43C),
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4FC43C),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                  color: Color(0xFF4FC43C),
                                  width: 3,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _saveName,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4FC43C),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'GUARDAR',
                              style: TextStyle(
                                fontFamily: 'Pixelated',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
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
                      onPressed: widget.onClose,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2A2A2A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                            color: Color(0xFF4FC43C),
                            width: 2,
                          ),
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

/// Formateador para convertir el texto a mayúsculas automáticamente
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

