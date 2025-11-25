import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import '../../presentation/widgets/pokemon_card_widget.dart';
import '../../presentation/pages/pokemon_card_preview_page.dart';
import '../../data/models/pokemon.dart';

/// Servicio para generar y compartir cartas Pokémon
class PokemonCardShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Muestra la pantalla de previsualización de la carta Pokémon
  Future<void> sharePokemonCard(
    BuildContext context,
    Pokemon pokemon,
  ) async {
    // Navegar a la pantalla de previsualización
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PokemonCardPreviewPage(pokemon: pokemon),
        fullscreenDialog: true,
      ),
    );
  }

  /// Genera la imagen de la carta Pokémon
  Future<Uint8List?> _generateCardImage(Pokemon pokemon) async {
    try {
      // Crear el widget de la carta
      final cardWidget = MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: PokemonCardWidget(pokemon: pokemon),
          ),
        ),
      );

      // Capturar el screenshot
      final imageBytes = await _screenshotController.captureFromWidget(
        cardWidget,
        delay: const Duration(milliseconds: 100),
        context: null,
        pixelRatio: 3.0, // Alta calidad
      );

      return imageBytes;
    } catch (e) {
      debugPrint('Error generating card image: $e');
      return null;
    }
  }

  /// Guarda la imagen en un archivo temporal
  Future<File> _saveImageToTemp(Uint8List imageBytes, String pokemonName) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'pokemon_card_${pokemonName}_$timestamp.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Muestra un mensaje de error
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 11),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[700],
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

