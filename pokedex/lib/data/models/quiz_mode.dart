/// Enumeración de las modalidades de juego del quiz
enum QuizMode {
  silhouette,
  description,
  number,
  sound;

  String get displayName {
    switch (this) {
      case QuizMode.silhouette:
        return 'Silueta';
      case QuizMode.description:
        return 'Descripción';
      case QuizMode.number:
        return 'Número';
      case QuizMode.sound:
        return 'Sonido';
    }
  }

  double get baseMultiplier {
    switch (this) {
      case QuizMode.silhouette:
        return 1.0;
      case QuizMode.description:
        return 1.5;
      case QuizMode.number:
        return 2.0;
      case QuizMode.sound:
        return 3.0;
    }
  }

  static QuizMode fromString(String mode) {
    switch (mode.toLowerCase()) {
      case 'silueta':
        return QuizMode.silhouette;
      case 'descripción':
      case 'descripcion':
        return QuizMode.description;
      case 'número':
      case 'numero':
        return QuizMode.number;
      case 'sonido':
        return QuizMode.sound;
      default:
        return QuizMode.silhouette;
    }
  }
}

