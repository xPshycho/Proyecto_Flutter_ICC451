/// Clase que contiene todas las traducciones del Quiz
/// Soporta español (es) e inglés (en)
class QuizTranslations {
  final String language;

  const QuizTranslations._(this.language);

  /// Factory para obtener las traducciones según el idioma
  factory QuizTranslations.forLanguage(String lang) {
    return QuizTranslations._(lang);
  }

  bool get _isSpanish => language == 'es';

  // ============ Quiz Home Page ============

  String get quizTitle => _isSpanish ? 'Poke Quiz' : 'Poke Quiz';
  String get hallOfFame => _isSpanish ? 'Salón de la Fama' : 'Hall of Fame';
  String get noRecordsYet => _isSpanish
      ? 'No hay registros aún.\n¡Sé el primero en jugar!'
      : 'No records yet.\nBe the first to play!';
  String get achievements => _isSpanish ? 'Logros' : 'Achievements';
  String get mode => _isSpanish ? 'Modalidad' : 'Mode';
  String get play => _isSpanish ? 'JUGAR' : 'PLAY';

  // Modos de juego
  String get silhouette => _isSpanish ? 'Silueta' : 'Silhouette';
  String get description => _isSpanish ? 'Descripción' : 'Description';
  String get number => _isSpanish ? 'Número' : 'Number';
  String get sound => _isSpanish ? 'Sonido' : 'Sound';

  // Modal de nombre
  String get enterTrainerName => _isSpanish ? 'Ingresa tu nombre de entrenador' : 'Enter your trainer name';
  String get cancel => _isSpanish ? 'CANCELAR' : 'CANCEL';
  String get start => _isSpanish ? 'COMENZAR' : 'START';

  // ============ Quiz Page ============

  String get exitQuiz => _isSpanish ? '¿Salir del Quiz?' : 'Exit Quiz?';
  String get loseProgress => _isSpanish
      ? 'Perderás todo tu progreso'
      : 'You will lose all your progress';
  String get exit => _isSpanish ? 'Salir' : 'Exit';

  String get loadingPokemon => _isSpanish ? 'Cargando Pokémon...' : 'Loading Pokémon...';
  String get preparingQuiz => _isSpanish ? 'Preparando el quiz...' : 'Preparing the quiz...';
  String get pleaseWait => _isSpanish ? 'Por favor espera' : 'Please wait';

  String get errorOccurred => _isSpanish ? 'Error' : 'Error';
  String get retry => _isSpanish ? 'Reintentar' : 'Retry';
  String get back => _isSpanish ? 'Volver' : 'Back';

  // Stats bar
  String get points => _isSpanish ? 'PUNTOS' : 'POINTS';
  String get streak => _isSpanish ? 'Racha' : 'Streak';

  // Display area (Sound mode)
  String get listenToSound => _isSpanish ? 'Escucha el sonido' : 'Listen to the sound';
  String get tapToPlay => _isSpanish ? 'Toca para reproducir' : 'Tap to play';

  // ============ Game Over Dialog ============

  String get gameFinished => _isSpanish ? 'PARTIDA TERMINADA' : 'GAME FINISHED';
  String get modeLabel => _isSpanish ? 'Modo' : 'Mode';
  String get results => _isSpanish ? 'RESULTADOS' : 'RESULTS';
  String get finalScore => _isSpanish ? 'PUNTUACIÓN' : 'SCORE';
  String get time => _isSpanish ? 'TIEMPO' : 'TIME';
  String get accuracy => _isSpanish ? 'PRECISIÓN' : 'ACCURACY';
  String get questions => _isSpanish ? 'PREGUNTAS' : 'QUESTIONS';
  String get correct => _isSpanish ? 'CORRECTAS' : 'CORRECT';
  String get enteredTop5 => _isSpanish ? 'ENTRASTE AL TOP 5' : 'YOU MADE THE TOP 5';
  String get scoreSaved => _isSpanish ? 'Tu puntuación ha sido guardada' : 'Your score has been saved';
  String get close => _isSpanish ? 'CERRAR' : 'CLOSE';

  // ============ Achievements Page ============

  String get achievementsTitle => _isSpanish ? 'Logros' : 'Achievements';
  String get all => _isSpanish ? 'Todos' : 'All';
  String get bronze => _isSpanish ? 'Bronce' : 'Bronze';
  String get silver => _isSpanish ? 'Plata' : 'Silver';
  String get gold => _isSpanish ? 'Oro' : 'Gold';
  String get locked => _isSpanish ? 'Bloqueado' : 'Locked';
  String get unlocked => _isSpanish ? 'Desbloqueado' : 'Unlocked';

  // ============ Language Settings ============

  String get languageLabel => _isSpanish ? 'Idioma' : 'Language';
  String get spanish => _isSpanish ? 'Español' : 'Spanish';
  String get english => _isSpanish ? 'Inglés' : 'English';
  String get changeLanguage => _isSpanish ? 'Cambiar idioma' : 'Change language';

  // ============ Misc ============

  String get mysteriousPokemon => _isSpanish
      ? 'Un misterioso Pokémon del que se sabe muy poco...'
      : 'A mysterious Pokémon that is known for very little...';

  /// Obtiene el nombre del modo de juego traducido
  String getModeDisplayName(String mode) {
    switch (mode.toLowerCase()) {
      case 'silueta':
      case 'silhouette':
        return silhouette;
      case 'descripción':
      case 'descripcion':
      case 'description':
        return description;
      case 'número':
      case 'numero':
      case 'number':
        return number;
      case 'sonido':
      case 'sound':
        return sound;
      default:
        return mode;
    }
  }

  /// Traduce el nombre interno del modo al idioma actual
  String translateMode(String internalMode) {
    switch (internalMode) {
      case 'Silueta':
        return silhouette;
      case 'Descripción':
        return description;
      case 'Número':
        return number;
      case 'Sonido':
        return sound;
      default:
        return internalMode;
    }
  }
}

/// Extensión para facilitar el acceso a las traducciones
extension QuizTranslationsExtension on String {
  QuizTranslations get tr => QuizTranslations.forLanguage(this);
}
