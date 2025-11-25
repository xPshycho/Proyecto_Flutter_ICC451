import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../data/models/pokemon.dart';
import '../widgets/pokemon_card_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Página de previsualización de la carta Pokémon antes de compartir
class PokemonCardPreviewPage extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonCardPreviewPage({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonCardPreviewPage> createState() => _PokemonCardPreviewPageState();
}

class _PokemonCardPreviewPageState extends State<PokemonCardPreviewPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSharing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final capitalizedName = '${widget.pokemon.name[0].toUpperCase()}${widget.pokemon.name.substring(1)}';

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.grey[200],
      appBar: AppBar(
        title: Text('Carta de $capitalizedName'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Vista previa de la carta
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: PokemonCardWidget(pokemon: widget.pokemon),
                  ),
                ),
              ),
            ),
          ),

          // Botones de acción
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Botón de cancelar
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isSharing ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Botón de compartir
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: _isSharing ? null : _handleShare,
                      icon: _isSharing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.share),
                      label: Text(_isSharing ? 'Generando...' : 'Compartir'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: isDark ? Colors.blue[700] : Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Maneja el proceso de compartir la carta
  Future<void> _handleShare() async {
    setState(() => _isSharing = true);

    try {
      // Generar la imagen de la carta
      final imageBytes = await _generateCardImage();

      if (!mounted) return;

      if (imageBytes == null) {
        _showError('No se pudo generar la imagen');
        setState(() => _isSharing = false);
        return;
      }

      // Guardar la imagen temporalmente
      final tempFile = await _saveImageToTemp(imageBytes);

      // Compartir la imagen
      final capitalizedName = '${widget.pokemon.name[0].toUpperCase()}${widget.pokemon.name.substring(1)}';
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: '¡Mira la carta de $capitalizedName! 🎴\n\n'
            'Generada desde Pokédex',
        subject: 'Carta Pokémon - $capitalizedName',
      );

      // Limpiar archivo temporal después de un delay
      Future.delayed(const Duration(seconds: 5), () {
        tempFile.delete().catchError((_) => tempFile);
      });

      if (mounted) {
        setState(() => _isSharing = false);
        // Cerrar la pantalla de previsualización después de compartir
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error sharing pokemon card: $e');
      if (mounted) {
        setState(() => _isSharing = false);
        _showError('Error al compartir: $e');
      }
    }
  }

  /// Genera la imagen de la carta
  Future<Uint8List?> _generateCardImage() async {
    try {
      final imageBytes = await _screenshotController.capture(
        pixelRatio: 3.0, // Alta calidad
      );
      return imageBytes;
    } catch (e) {
      debugPrint('Error generating card image: $e');
      return null;
    }
  }

  /// Guarda la imagen en un archivo temporal
  Future<File> _saveImageToTemp(Uint8List imageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final fileName = 'pokemon_card_${widget.pokemon.name}_$timestamp.png';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    return file;
  }

  /// Muestra un mensaje de error
  void _showError(String message) {
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

