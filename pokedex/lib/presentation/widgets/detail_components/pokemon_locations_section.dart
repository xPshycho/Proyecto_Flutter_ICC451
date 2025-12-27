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
  bool _didLoadLocations = false; // bandera para didChangeDependencies

  @override
  void initState() {
    super.initState();
    // NO llamar a _loadLocations() aquí porque usa GraphQLProvider.of(context)
    // que depende de un InheritedWidget; en su lugar llamaremos en didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadLocations) {
      _didLoadLocations = true;
      _loadLocations();
    }
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
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
          _buildGroupedLocations(),
      ],
    );
  }

  Widget _buildGroupedLocations() {
    // Agrupar por región
    final Map<String, List<Location>> grouped = {};
    for (final loc in _locations) {
      grouped.putIfAbsent(loc.region, () => []).add(loc);
    }

    final sortedRegions = grouped.keys.toList()..sort();

    return Column(
      children: sortedRegions.map((region) {
        final locations = grouped[region]!..sort((a, b) => a.name.compareTo(b.name));
        return ExpansionTile(
          title: Text(region, style: Theme.of(context).textTheme.titleMedium),
          children: locations.map((loc) => _buildLocationTile(loc)).toList(),
        );
      }).toList(),
    );
  }

  Widget _buildLocationTile(Location location) {
    return ListTile(
      title: Text(location.name),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...location.encounters.map((enc) => Text('${enc.method}: Niv. ${enc.minLevel}-${enc.maxLevel} · ${(enc.rate * 100).toStringAsFixed(1)}%')),
        ],
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _openMapAtLocation(location),
    );
  }

  void _navigateToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPage()),
    );
  }

  void _openMapAtLocation(Location location) {
    // Intent: abrir MapPage con la región y un identificador de ruta/área.
    // Suponemos que el nombre de la ubicación o su id pueden usarse como identifier.
    final identifier = _normalizeIdentifier(location.name);
    final manualMap = _buildManualAreaMap(location);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapPage(
          initialRegion: location.region,
          initialRouteIdentifier: identifier,
          manualAreaIdMap: manualMap,
        ),
      ),
    );
  }

  Map<String, String> _buildManualAreaMap(Location location) {
    final key = _normalizeIdentifier(location.name);
    final region = location.region.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '-');

    // Candidates: region + '-' + id, region + '-route-' + num (if route), 'sea-' variants, id alone
    final id = key;
    final candidates = <String>[];

    if (id.startsWith('route-') || id.startsWith('route')) {
      // route-1 -> region-route-1
      final routeNum = id.replaceFirst(RegExp(r'^route-?'), '');
      candidates.add('$region-route-$routeNum');
      candidates.add('$region-sea-route-$routeNum');
      candidates.add('sea-$region-route-$routeNum');
    }

    candidates.add('$region-$id');
    candidates.add('sea-$region-$id');
    candidates.add(id); // fallback

    // Elegimos el primer candidato como valor aproximado; InteractiveMapWidget probará
    // manualTargetId contra los candidateIdentifiers de cada MapArea.
    return {key: candidates.first};
  }

  String _normalizeIdentifier(String name) {
    // Normalizar el nombre para intentar coincidir con los identifiers usados en MapArea
    var id = name.toLowerCase();
    // Reemplazar espacios y caracteres comunes
    id = id.replaceAll(RegExp('[^a-z0-9\-]'), '-');
    id = id.replaceAll(RegExp('-+'), '-');
    id = id.trim();
    if (id.endsWith('-')) id = id.substring(0, id.length - 1);
    if (id.startsWith('-')) id = id.substring(1);
    return id;
  }
}
