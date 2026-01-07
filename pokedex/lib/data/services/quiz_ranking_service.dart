import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quiz_ranking.dart';

/// Servicio para gestionar la persistencia del ranking del quiz
class QuizRankingService {
  static const String _rankingKey = 'quiz_ranking_top5';
  static const int _maxEntries = 5;

  /// Obtiene el top 5 del ranking
  Future<List<QuizRankingEntry>> getTop5() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? rankingJson = prefs.getString(_rankingKey);

      if (rankingJson == null || rankingJson.isEmpty) {
        return [];
      }

      final List<dynamic> decoded = jsonDecode(rankingJson);
      final entries = decoded
          .map((item) => QuizRankingEntry.fromJson(item as Map<String, dynamic>))
          .toList();

      // Ordenar por score descendente, y en caso de empate por tiempo ascendente
      entries.sort((a, b) {
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;
        return a.time.compareTo(b.time);
      });

      return entries.take(_maxEntries).toList();
    } catch (e) {
      debugPrint('Error loading quiz ranking: $e');
      return [];
    }
  }

  /// Agrega una nueva entrada al ranking y mantiene solo el top 5
  Future<bool> addEntry(QuizRankingEntry entry) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentRanking = await getTop5();

      // Agregar nueva entrada
      currentRanking.add(entry);

      // Ordenar
      currentRanking.sort((a, b) {
        final scoreComparison = b.score.compareTo(a.score);
        if (scoreComparison != 0) return scoreComparison;
        return a.time.compareTo(b.time);
      });

      // Mantener solo top 5
      final top5 = currentRanking.take(_maxEntries).toList();

      // Guardar
      final encoded = jsonEncode(top5.map((e) => e.toJson()).toList());
      await prefs.setString(_rankingKey, encoded);

      debugPrint('Quiz ranking updated: ${top5.length} entries');
      return true;
    } catch (e) {
      debugPrint('Error saving quiz ranking: $e');
      return false;
    }
  }

  /// Limpia todo el ranking
  Future<void> clearRanking() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_rankingKey);
      debugPrint('Quiz ranking cleared');
    } catch (e) {
      debugPrint('Error clearing quiz ranking: $e');
    }
  }

  /// Verifica si un score entraría en el top 5
  Future<bool> wouldEnterTop5(int score, Duration time) async {
    final top5 = await getTop5();

    if (top5.length < _maxEntries) return true;

    final lastEntry = top5.last;
    if (score > lastEntry.score) return true;
    if (score == lastEntry.score && time < lastEntry.time) return true;

    return false;
  }
}

