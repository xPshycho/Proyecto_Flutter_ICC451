import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/detail_components/pokemon_header.dart';
import '../widgets/detail_components/pokemon_info_card.dart';
import '../widgets/detail_components/pokemon_abilities_section.dart';
import '../widgets/detail_components/pokemon_stats_section.dart';
import '../widgets/detail_components/pokemon_weaknesses_section.dart';
import '../widgets/detail_components/pokemon_evolution_section.dart';
import '../widgets/detail_components/pokemon_forms_section.dart';
import '../widgets/detail_components/pokemon_moveset_section.dart';
import '../bloc/pokemon_detail/pokemon_detail_bloc.dart';
import '../bloc/pokemon_detail/pokemon_detail_event.dart';
import '../bloc/pokemon_detail/pokemon_detail_state.dart';
import '../bloc/favorites/favorites_bloc.dart';
import '../bloc/favorites/favorites_event.dart';
import '../bloc/favorites/favorites_state.dart';

class PokemonDetailPage extends StatelessWidget {
  final int id;
  final PokemonRepository repository;

  const PokemonDetailPage({
    super.key,
    required this.id,
    required this.repository,
  });

  void _navigateToEvolution(BuildContext context, int evolutionId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PokemonDetailBloc(repository: repository)
            ..add(LoadPokemonDetail(evolutionId)),
          child: PokemonDetailPage(
            id: evolutionId,
            repository: repository,
          ),
        ),
      ),
    );
  }

  void _handleFavoriteToggle(BuildContext context, Pokemon pokemon) {
    context.read<FavoritesBloc>().add(ToggleFavorite(pokemon));
    _showFavoriteSnackBar(
      context,
      context.read<FavoritesBloc>().state is FavoritesLoaded &&
          (context.read<FavoritesBloc>().state as FavoritesLoaded).isFavorite(pokemon.id),
      pokemon.name,
    );
  }

  void _showFavoriteSnackBar(BuildContext context, bool isFavorite, String pokemonName) {
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
      body: BlocBuilder<PokemonDetailBloc, PokemonDetailState>(
        builder: (context, state) {
          if (state is PokemonDetailLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PokemonDetailError) {
            return _buildErrorView(context, state);
          }

          if (state is PokemonDetailLoaded) {
            return _buildDetailView(context, state.pokemon);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildDetailView(BuildContext context, Pokemon pokemon) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: BlocBuilder<FavoritesBloc, FavoritesState>(
            builder: (context, favState) {
              final isFavorite = favState is FavoritesLoaded &&
                  favState.isFavorite(pokemon.id);

              return PokemonHeader(
                pokemon: pokemon,
                onBack: () => Navigator.of(context).pop(),
                onFavoriteToggle: () => _handleFavoriteToggle(context, pokemon),
                isFavorite: isFavorite,
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -30),
            child: Column(
              children: [
                PokemonInfoCard(
                  pokemon: pokemon,
                  onEvolutionTap: (evolutionId) => _navigateToEvolution(context, evolutionId),
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
            repository: repository,
          ),
          const SizedBox(height: 24),
          PokemonFormsSection(pokemon: pokemon),
          const SizedBox(height: 24),
          Builder(
            builder: (context) => PokemonEvolutionSection(
              pokemon: pokemon,
              onEvolutionTap: (evolutionId) => _navigateToEvolution(context, evolutionId),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, PokemonDetailError state) {
    final title = state.isRegionalForm
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
              if (state.isRegionalForm)
                const Text(
                  'Las formas regionales pueden tener problemas de caché.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.orange),
                ),
              const SizedBox(height: 8),
              Text(
                state.message.length > 100
                    ? '${state.message.substring(0, 100)}...'
                    : state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              _buildErrorButtons(context, state),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorButtons(BuildContext context, PokemonDetailError state) {
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
          onPressed: () {
            context.read<PokemonDetailBloc>().add(
              RetryLoadPokemonDetail(state.pokemonId),
            );
          },
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
}
