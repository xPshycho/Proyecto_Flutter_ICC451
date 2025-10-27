import 'package:flutter/material.dart';

// Colores personalizables para los botones del menú
class BottomMenuColors {
  final Color pokedexButtonColor;
  final Color mapaButtonColor;
  final Color helpButtonColor;
  final Color buttonTextColor;

  const BottomMenuColors({
    this.pokedexButtonColor = const Color(0xFFBBBBBB),
    this.mapaButtonColor = const Color(0xFFBBBBBB),
    this.helpButtonColor = const Color(0xFFBBBBBB),
    this.buttonTextColor = Colors.black,
  });
}

class BottomMenu extends StatelessWidget {
  final VoidCallback? onPokedexPressed;
  final VoidCallback? onMapaPressed;
  final VoidCallback? onHelpPressed;
  final BottomMenuColors colors;

  const BottomMenu({
    super.key,
    this.onPokedexPressed,
    this.onMapaPressed,
    this.onHelpPressed,
    this.colors = const BottomMenuColors(),
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título "Menú" con línea roja
          Column(
            children: [
              Text(
                'Menú',
                style: textTheme.headlineLarge?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Container(
                width: 180,
                height: 3,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Botón Pokedex Nacional (ancho completo)
          _buildMenuButton(
            label: 'Pokedex Nacional',
            color: colors.pokedexButtonColor,
            textColor: colors.buttonTextColor,
            onPressed: onPokedexPressed,
          ),

          const SizedBox(height: 12),

          // Fila con botones Mapa y ?
          Row(
            children: [
              // Botón Mapa
              Expanded(
                child: _buildMenuButton(
                  label: 'Mapa',
                  color: colors.mapaButtonColor,
                  textColor: colors.buttonTextColor,
                  onPressed: onMapaPressed,
                ),
              ),

              const SizedBox(width: 12),

              // Botón ?
              Expanded(
                child: _buildMenuButton(
                  label: '?',
                  color: colors.helpButtonColor,
                  textColor: colors.buttonTextColor,
                  onPressed: onHelpPressed,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required Color color,
    required Color textColor,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed ?? () => debugPrint('$label pressed'),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Función helper para mostrar el menú desde cualquier parte
void showBottomMenu(
  BuildContext context, {
  VoidCallback? onPokedexPressed,
  VoidCallback? onMapaPressed,
  VoidCallback? onHelpPressed,
  BottomMenuColors? colors,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => BottomMenu(
      onPokedexPressed: onPokedexPressed,
      onMapaPressed: onMapaPressed,
      onHelpPressed: onHelpPressed,
      colors: colors ?? const BottomMenuColors(),
    ),
  );
}

