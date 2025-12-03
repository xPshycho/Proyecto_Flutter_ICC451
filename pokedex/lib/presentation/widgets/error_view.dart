import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar errores de carga con Pikachu buscando
class ErrorView extends StatelessWidget {
  final String? title;
  final String? message;
  final VoidCallback onRetry;
  final VoidCallback? onBack;
  final bool showAppBar;
  final bool hideRetry;

  const ErrorView({
    super.key,
    this.title,
    this.message,
    required this.onRetry,
    this.onBack,
    this.showAppBar = true,
    this.hideRetry = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagen de Pikachu buscando
            Image.asset(
              'assets/icons/pikachu_search.png',
              width: 300,
              height: 300,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.search_off,
                  size: 120,
                  color: Colors.grey[400],
                );
              },
            ),
            const SizedBox(height: 32),

            // Mensaje de error principal
            Text(
              title ?? 'Parece que Rotom se ha dormido',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            // Mensaje secundario
            Text(
              message ?? 'Verifica tu conexión a internet y presiona el botón de reintentar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Botón de reintentar (condicional)
            if (!hideRetry)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 20),
                label: const Text(
                  'Reintentar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
          ],
        ),
      ),
    );

    if (!showAppBar) {
      return content;
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        leading: onBack != null
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: onBack,
        ) : null,
        title: const Text(
          'Error de conexión',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: content,
    );
  }
}

