import 'package:flutter/material.dart';

/// Barra superior que muestra las estadísticas del juego
class QuizStatsBar extends StatefulWidget {
  final int score;
  final double multiplier;
  final int remainingTime;
  final int consecutiveCorrect;
  final VoidCallback onExitPressed;
  final int? timeChange; // +5 o -5

  const QuizStatsBar({
    super.key,
    required this.score,
    required this.multiplier,
    required this.remainingTime,
    required this.consecutiveCorrect,
    required this.onExitPressed,
    this.timeChange,
  });

  @override
  State<QuizStatsBar> createState() => _QuizStatsBarState();
}

class _QuizStatsBarState extends State<QuizStatsBar> with SingleTickerProviderStateMixin {
  AnimationController? _animationController;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimation();
  }

  @override
  void didUpdateWidget(QuizStatsBar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Si cambió el timeChange, reiniciar la animación
    if (oldWidget.timeChange != widget.timeChange && widget.timeChange != null) {
      _animationController?.reset();
      _animationController?.forward();
    }
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(_animationController!);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.5),
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOut,
    ));

    if (widget.timeChange != null) {
      _animationController!.forward();
    }
  }

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  String get _formattedScore {
    return widget.score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  String get _formattedTime {
    final minutes = widget.remainingTime ~/ 60;
    final seconds = widget.remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Color get _timeColor {
    if (widget.remainingTime <= 5) return Colors.red;
    if (widget.remainingTime <= 10) return Colors.orange;
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
          // Primera fila: Exit, Timer con animación
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Botón Exit
              IconButton(
                onPressed: widget.onExitPressed,
                icon: const Icon(Icons.close),
                color: Colors.red,
                iconSize: 28,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),

              // Timer con animación de cambio
              Stack(
                clipBehavior: Clip.none,
                children: [
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

                  // Animación de +5 o -5
                  if (widget.timeChange != null && _fadeAnimation != null && _slideAnimation != null)
                    Positioned(
                      right: -40,
                      top: 0,
                      child: FadeTransition(
                        opacity: _fadeAnimation!,
                        child: SlideTransition(
                          position: _slideAnimation!,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: widget.timeChange! > 0
                                  ? Colors.green.withOpacity(0.9)
                                  : Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: widget.timeChange! > 0
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                width: 2,
                              ),
                            ),
                            child: Text(
                              widget.timeChange! > 0 ? '+5s' : '-5s',
                              style: const TextStyle(
                                fontFamily: 'Pixelated',
                                fontSize: 14,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
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
                  label: 'x${widget.multiplier.toStringAsFixed(1)}',
                  value: '${widget.consecutiveCorrect} racha',
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
