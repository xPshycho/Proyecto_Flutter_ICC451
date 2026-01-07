import 'package:flutter/material.dart';
import '../../presentation/pages/pokemon_card_preview_page.dart';
import '../../data/models/pokemon.dart';

/// Servicio para generar y compartir cartas Pokémon
class PokemonCardShareService {
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
}
