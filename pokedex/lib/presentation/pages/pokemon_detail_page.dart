import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../../data/services/audio_service.dart';
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
import '../../data/services/pokemon_card_share_service.dart';
import '../widgets/error_view.dart';

class PokemonDetailPage extends StatefulWidget {
  final int id;
  final PokemonRepository repository;
  final bool initialShinyState;

  const PokemonDetailPage({
    super.key,
    required this.id,
    required this.repository,
    this.initialShinyState = false,
  });

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late final AudioService _audioService;
  late bool _isShiny;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
    _isShiny = widget.initialShinyState; // Inicializar con el estado recibido
  }

  @override
  void dispose() {
    _audioService.stopCry();
    super.dispose();
  }

  void _navigateToEvolution(BuildContext context, int evolutionId) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PokemonDetailBloc(repository: widget.repository)
            ..add(LoadPokemonDetail(evolutionId)),
          child: PokemonDetailPage(
            id: evolutionId,
            repository: widget.repository,
            initialShinyState: _isShiny, // Mantener estado shiny
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

  void _handleSoundTap(Pokemon pokemon) {
    _audioService.playCry(pokemon.id);
  }

  void _handleShinyToggle(Pokemon pokemon) {
    // Check if shiny sprite is available
    if (pokemon.shinySpriteUrl == null && !_isShiny) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'No hay sprite shiny disponible para ${pokemon.name}',
                style: const TextStyle(fontSize: 11),
              ),
            ],
          ),
          backgroundColor: Colors.orange[700],
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }

    setState(() {
      _isShiny = !_isShiny;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _isShiny ? Icons.auto_awesome : Icons.catching_pokemon,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isShiny ? 'Modo Shiny activado ✨' : 'Modo Normal activado',
              style: const TextStyle(fontSize: 11),
            ),
          ],
        ),
        backgroundColor: _isShiny ? Colors.amber : Colors.grey[700],
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
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
      body: BlocConsumer<PokemonDetailBloc, PokemonDetailState>(
        listener: (context, state) {
          // Reproducir cry automáticamente cuando se carga el Pokemon
          if (state is PokemonDetailLoaded) {
            _audioService.playCry(state.pokemon.id);
          }
        },
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
                onSpriteTap: () => _audioService.playCry(pokemon.id),
                onSoundTap: () => _handleSoundTap(pokemon),
                onShinyToggle: () => _handleShinyToggle(pokemon),
                isShiny: _isShiny,
                onShareTap: () async {
                  final shareService = PokemonCardShareService();
                  await shareService.sharePokemonCard(context, pokemon);
                },
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
          Builder(
            builder: (context) => PokemonEvolutionSection(
              pokemon: pokemon,
              onEvolutionTap: (evolutionId) => _navigateToEvolution(context, evolutionId),
              isShiny: _isShiny,
            ),
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
    final title = state.isRegionalForm;
    return ErrorView(
      onRetry: () {
        context.read<PokemonDetailBloc>().add(
          RetryLoadPokemonDetail(state.pokemonId),
        );
      },
      onBack: () => Navigator.of(context).pop(),
    );
  }
}








