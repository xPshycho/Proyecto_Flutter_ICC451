import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

/// Servicio singleton para gestionar la reproducción de Pokemon cries
class AudioService {
  static final AudioService _instance = AudioService._internal();

  factory AudioService() => _instance;

  AudioService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isDisposed = false;

  /// Reproduce el cry de un Pokémon basado en su ID
  /// La URL sigue el formato: https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/{id}.ogg
  Future<void> playCry(int pokemonId) async {
    if (_isDisposed) {
      debugPrint('AudioService: Cannot play, service is disposed');
      return;
    }

    try {
      // Detener cualquier reproducción actual
      await stopCry();

      final cryUrl = _generateCryUrl(pokemonId);
      debugPrint('AudioService: Playing cry for Pokemon #$pokemonId from $cryUrl');

      await _audioPlayer.play(UrlSource(cryUrl));
    } catch (e) {
      // Manejo silencioso de errores - el cry es una característica opcional
      debugPrint('AudioService: Error playing cry for Pokemon #$pokemonId: $e');
    }
  }

  /// Detiene la reproducción actual del cry
  Future<void> stopCry() async {
    if (_isDisposed) return;

    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('AudioService: Error stopping cry: $e');
    }
  }

  /// Pausa la reproducción actual del cry
  Future<void> pauseCry() async {
    if (_isDisposed) return;

    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('AudioService: Error pausing cry: $e');
    }
  }

  /// Reanuda la reproducción pausada del cry
  Future<void> resumeCry() async {
    if (_isDisposed) return;

    try {
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('AudioService: Error resuming cry: $e');
    }
  }

  /// Libera los recursos del reproductor de audio
  Future<void> dispose() async {
    if (_isDisposed) return;

    try {
      await _audioPlayer.stop();
      await _audioPlayer.dispose();
      _isDisposed = true;
      debugPrint('AudioService: Disposed');
    } catch (e) {
      debugPrint('AudioService: Error disposing: $e');
    }
  }

  /// Genera la URL del cry basada en el ID del Pokémon
  String _generateCryUrl(int pokemonId) {
    return 'https://raw.githubusercontent.com/PokeAPI/cries/main/cries/pokemon/latest/$pokemonId.ogg';
  }

  /// Verifica si el servicio ha sido liberado
  bool get isDisposed => _isDisposed;
}

