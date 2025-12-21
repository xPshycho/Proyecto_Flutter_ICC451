import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/models/location.dart';
import '../../../data/services/map_repository.dart';
import '../../pages/map_page.dart';

/// Sección que muestra las ubicaciones donde aparece un Pokémon.
class PokemonLocationsSection extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonLocationsSection({super.key, required this.pokemon});

  @override
  State<PokemonLocationsSection> createState() => _PokemonLocationsSectionState();
}

class _PokemonLocationsSectionState extends State<PokemonLocationsSection> {
  List<Location> _locations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = GraphQLProvider.of(context).value;
      final repository = MapRepository(client);
      _locations = await repository.getLocationsWithEncountersByPokemon(widget.pokemon.id);
    } catch (e) {
      _error = 'Error al cargar ubicaciones: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ubicaciones',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => _navigateToMap(),
              tooltip: 'Ver en mapa',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red))
        else if (_locations.isEmpty)
          const Text('No hay ubicaciones disponibles')
        else
          _buildLocationsList(),
      ],
    );
  }

  Widget _buildLocationsList() {
    return Column(
      children: _locations.map((location) => _buildLocationCard(location)).toList(),
    );
  }

  Widget _buildLocationCard(Location location) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              location.name,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Región: ${location.region}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...location.encounters.map((encounter) => _buildEncounterInfo(encounter)),
          ],
        ),
      ),
    );
  }

  Widget _buildEncounterInfo(Encounter encounter) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text(
            '${encounter.method}: Niv. ${encounter.minLevel}-${encounter.maxLevel}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(width: 8),
          Text(
            '${(encounter.rate * 100).toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  void _navigateToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPage()),
    );
  }
}
