/// Modelo para una entrada del ranking del quiz
class QuizRankingEntry {
  final String playerName;
  final int score;
  final Duration time;
  final DateTime date;

  QuizRankingEntry({
    required this.playerName,
    required this.score,
    required this.time,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
      'playerName': playerName,
      'score': score,
      'timeInSeconds': time.inSeconds,
      'date': date.toIso8601String(),
    };
  }

  factory QuizRankingEntry.fromJson(Map<String, dynamic> json) {
    return QuizRankingEntry(
      playerName: json['playerName'] as String,
      score: json['score'] as int,
      time: Duration(seconds: json['timeInSeconds'] as int),
      date: DateTime.parse(json['date'] as String),
    );
  }

  String get formattedTime {
    final hours = time.inHours;
    final minutes = time.inMinutes.remainder(60);
    final seconds = time.inSeconds.remainder(60);
    return '${hours.toString().padLeft(1, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedScore {
    return score.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
