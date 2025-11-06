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
import '../widgets/detail_components/pokemon_forms_section.dart';
import '../widgets/detail_components/pokemon_moveset_section.dart';

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

  void _handleFavoriteToggle(FavoritesService favService, Pokemon pokemon) {
    favService.toggleFavorite(pokemon);
    _showFavoriteSnackBar(favService.isFavorite(pokemon.id), pokemon.name);
  }

  void _showFavoriteSnackBar(bool isFavorite, String pokemonName) {
    final capitalizedName = '${pokemonName[0].toUpperCase()}${pokemonName.substring(1)}';
    final message = isFavorite
        ? '$capitalizedName agregado a favoritos'
        : '$capitalizedName removido de favoritos';

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
            Text(message, style: const TextStyle(fontSize: 11)),
          ],
        ),
        backgroundColor: isFavorite ? Colors.red : Colors.grey[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        SliverToBoxAdapter(
          child: PokemonHeader(
            pokemon: pokemon,
            onBack: () => Navigator.of(context).pop(),
            onFavoriteToggle: () => _handleFavoriteToggle(favService, pokemon),
            isFavorite: favService.isFavorite(pokemon.id),
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Column(
              children: [
                PokemonInfoCard(
                  pokemon: pokemon,
                  onEvolutionTap: _navigateToEvolution,
                ),
                _buildDetailSections(pokemon),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailSections(Pokemon pokemon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          PokemonAbilitiesSection(pokemon: pokemon),
          const SizedBox(height: 24),
          PokemonWeaknessesSection(pokemon: pokemon),
          const SizedBox(height: 24),
          PokemonStatsSection(pokemon: pokemon),
          const SizedBox(height: 24),
          PokemonMovesetSection(
            pokemon: pokemon,
            repository: widget.repository,
          ),
          const SizedBox(height: 24),
          PokemonFormsSection(pokemon: pokemon),
          const SizedBox(height: 24),
          PokemonEvolutionSection(
            pokemon: pokemon,
            onEvolutionTap: _navigateToEvolution,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorView(String error) {
    final isRegionalForm = widget.id > 10000;
    final title = isRegionalForm
        ? 'Error al cargar la forma regional'
        : 'Error al cargar el Pokémon';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
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
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              if (isRegionalForm)
                const Text(
                  'Las formas regionales pueden tener problemas de caché.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
              const SizedBox(height: 8),
              Text(
                error.length > 100 ? '${error.substring(0, 100)}...' : error,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildErrorButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Regresar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[600],
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: _retryWithCacheClear,
          icon: const Icon(Icons.refresh),
          label: const Text('Reintentar'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }

  void _retryWithCacheClear() async {
    try {
      // Limpiar caché antes de reintentar
      await widget.repository.clearGraphQLCache();

      // Recrear el future
      setState(() {
        _future = widget.repository.fetchPokemonDetail(widget.id);
      });
    } catch (e) {
      debugPrint('Error during retry: $e');
    }
  }
}
