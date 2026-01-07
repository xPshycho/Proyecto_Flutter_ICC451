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

    return Scaffold(
      // Usar el fondo universal del tema
      backgroundColor: Theme.of(context).cardColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header con título y botón de volver
            _buildHeader(context, isDark),

            // Contenido con la carta centrada
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Screenshot(
                    controller: _screenshotController,
                    child: PokemonCardWidget(
                      pokemon: widget.pokemon,
                    ),
                  ),
                ),
              ),
            ),

            // Botones de acción en la parte inferior
            _buildActionButtons(context, isDark),
          ],
        ),
      ),
    );
  }

  /// Construye el header con título y botón de volver
  Widget _buildHeader(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final Color blurBgColor = isDark
        ? Colors.white.withAlpha(25)
        : Colors.black.withAlpha(15);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          // Botón de volver
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: blurBgColor,
            ),
            child: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: isDark ? Colors.white : Colors.black87,
              ),
              padding: EdgeInsets.zero,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),

          const SizedBox(width: 16),

          // Título
          Expanded(
            child: Text(
              'Compartir Carta',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : Colors.black87,
                fontFamily: 'Pixelated',
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye los botones de acción (Cancelar y Compartir)
  Widget _buildActionButtons(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFFE8E8E8),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Botón Cancelar (Rojo) - más pequeño
            Expanded(
              child: _buildCancelButton(isDark),
            ),

            const SizedBox(width: 8),

            // Botón Compartir (Verde) - más pequeño
            Expanded(
              child: _buildShareButton(isDark),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de cancelar con estilo gaming
  Widget _buildCancelButton(bool isDark) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFC54747),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC54747).withAlpha(76),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSharing ? null : () => Navigator.of(context).pop(),
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 6), // Reducir de 8 a 6
              Text(
                'Cancelar',
                style: TextStyle(
                  fontSize: 14, // Reducir de 18 a 16
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Pixelated',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el botón de compartir con estilo gaming
  Widget _buildShareButton(bool isDark) {
    return Container(
      height: double.infinity,
      decoration: BoxDecoration(
        color: _isSharing ? const Color(0xFF9E9E9E) : const Color(0xFF55C547),
        borderRadius: BorderRadius.circular(12),
        boxShadow: _isSharing
            ? []
            : [
                BoxShadow(
                  color: const Color(0xFF55C547).withAlpha(76),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isSharing ? null : _handleShare,
          borderRadius: BorderRadius.circular(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isSharing) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.ios_share_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 6),
              if (_isSharing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else
                const Text(
                  'Compartir',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontFamily: 'Pixelated',
                  ),
                ),
              ],
            ],
          ),
        ),
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
        text: '¡Mira la carta de $capitalizedName! 🎴\n\nGenerada desde Pokédex',
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
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFC54747),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
