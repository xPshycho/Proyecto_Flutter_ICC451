import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../../data/favorites_service.dart';
import '../widgets/detail_components/pokemon_header.dart';
import '../widgets/detail_components/pokemon_info_card.dart';
import '../widgets/detail_components/pokemon_abilities_section.dart';
import '../widgets/detail_components/pokemon_stats_section.dart';
import '../widgets/detail_components/pokemon_weaknesses_section.dart';
import '../widgets/detail_components/pokemon_evolution_section.dart';

class PokemonDetailPage extends StatefulWidget {
  final int id;
  final PokemonRepository repository;
  const PokemonDetailPage({super.key, required this.id, required this.repository});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<Pokemon> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchPokemonDetail(widget.id);
  }

  void _navigateToEvolution(int evolutionId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PokemonDetailPage(
          id: evolutionId,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _handleBackNavigation() {
    Navigator.of(context).pop();
  }

  void _handleFavoriteToggle(FavoritesService favService, Pokemon pokemon) {
    favService.toggleFavorite(pokemon);

    // Mostrar un SnackBar con feedback visual
    final isFavorite = favService.isFavorite(pokemon.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isFavorite ? Icons.favorite : Icons.heart_broken,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isFavorite
                  ? '${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)} agregado a favoritos'
                  : '${pokemon.name[0].toUpperCase()}${pokemon.name.substring(1)} removido de favoritos',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        backgroundColor: isFavorite ? Colors.red : Colors.grey[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Pokemon>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }

          final pokemon = snapshot.data!;
          return _buildDetailView(pokemon);
        },
      ),
    );
  }

  Widget _buildDetailView(Pokemon pokemon) {
    final favService = Provider.of<FavoritesService>(context, listen: true);

    return CustomScrollView(
      slivers: [
        // Header con imagen y fondo de tipo
        SliverToBoxAdapter(
          child: PokemonHeader(
            pokemon: pokemon,
            onBack: _handleBackNavigation,
            onFavoriteToggle: () => _handleFavoriteToggle(favService, pokemon),
            isFavorite: favService.isFavorite(pokemon.id),
          ),
        ),

        // Contenido principal
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Column(
              children: [
                // Información básica
                PokemonInfoCard(pokemon: pokemon),

                // Secciones adicionales
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),

                      // Habilidades
                      PokemonAbilitiesSection(pokemon: pokemon),
                      const SizedBox(height: 24),

                      // Debilidades
                      PokemonWeaknessesSection(pokemon: pokemon),
                      const SizedBox(height: 24),

                      // Estadísticas
                      PokemonStatsSection(pokemon: pokemon),
                      const SizedBox(height: 24),

                      // Evoluciones
                      PokemonEvolutionSection(
                        pokemon: pokemon,
                        onEvolutionTap: _navigateToEvolution,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Error al cargar el Pokémon',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Regresar'),
            ),
          ],
        ),
      ),
    );
  }
}
