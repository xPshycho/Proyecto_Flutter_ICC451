import 'package:flutter/material.dart';

// Colores personalizables para los botones del menú
class BottomMenuColors {
  final Color pokedexButtonColor;
  final Color mapaButtonColor;
  final Color helpButtonColor;
  final Color homeButtonColor;
  final Color buttonTextColor;

  const BottomMenuColors({
    this.pokedexButtonColor = const Color(0xFFBBBBBB),
    this.mapaButtonColor = const Color(0xFFBBBBBB),
    this.helpButtonColor = const Color(0xFFBBBBBB),
    this.homeButtonColor = const Color(0xFFBBBBBB),
    this.buttonTextColor = Colors.black,
  });
}

class BottomMenu extends StatelessWidget {
  final VoidCallback? onPokedexPressed;
  final VoidCallback? onMapaPressed;
  final VoidCallback? onHelpPressed;
  final VoidCallback? onHomePressed;
  final BottomMenuColors colors;

  const BottomMenu({
    super.key,
    this.onPokedexPressed,
    this.onMapaPressed,
    this.onHelpPressed,
    this.onHomePressed,
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
              color: colorScheme.onSurface.withAlpha(76),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título "Menú" con línea
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

          // Botones
          _buildFullWidthButton(
            label: 'Pokedex',
            color: colors.pokedexButtonColor,
            textColor: colors.buttonTextColor,
            onPressed: onPokedexPressed,
          ),

          const SizedBox(height: 12),

          _buildFullWidthButton(
            label: 'Mapa',
            color: colors.mapaButtonColor,
            textColor: colors.buttonTextColor,
            onPressed: onMapaPressed,
          ),

          const SizedBox(height: 12),

          _buildFullWidthButton(
            label: 'Adivina el pokemon',
            color: colors.helpButtonColor,
            textColor: colors.buttonTextColor,
            onPressed: onHelpPressed,
          ),

          const SizedBox(height: 12),

          _buildFullWidthButton(
            label: 'Home',
            color: colors.homeButtonColor,
            textColor: colors.buttonTextColor,
            onPressed: onHomePressed,
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildFullWidthButton({
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
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
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

// Helper to show the bottom menu from anywhere
Future<void> showBottomMenu(
  BuildContext context, {
  VoidCallback? onPokedexPressed,
  VoidCallback? onMapaPressed,
  VoidCallback? onHelpPressed,
  VoidCallback? onHomePressed,
  BottomMenuColors? colors,
}) {
  return showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) => BottomMenu(
      onPokedexPressed: onPokedexPressed,
      onMapaPressed: onMapaPressed,
      onHelpPressed: onHelpPressed,
      onHomePressed: onHomePressed,
      colors: colors ?? const BottomMenuColors(),
    ),
  );
}

