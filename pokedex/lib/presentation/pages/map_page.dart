import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../widgets/map_components/interactive_map_widget.dart';
import '../widgets/map_components/kanto_map_areas.dart';
import '../../../data/services/map_repository.dart';
import '../../../data/models/location.dart';
import '../widgets/map_components/route_pokemon_modal.dart';

/// Página para explorar mapas interactivos de regiones de Pokémon.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? selectedArea;
  List<Location> _locations = [];
  bool _isLoadingEncounters = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapas Interactivos'),
      ),
      body: Column(
        children: [
          // Selector de región (placeholder)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: 'Kanto',
              items: const [
                DropdownMenuItem(value: 'Kanto', child: Text('Kanto')),
                // Agregar más regiones
              ],
              onChanged: (value) {
                // Cambiar mapa
              },
            ),
          ),
          Expanded(
            child: InteractiveMapWidget(
              mapImagePath: KantoMapAreas.mapImagePath,
              areas: KantoMapAreas.areas,
              onAreaTap: (areaName) {
                setState(() {
                  selectedArea = areaName;
                });
                _showRouteModal(areaName);
              },
            ),
          ),
          if (selectedArea != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Área seleccionada: $selectedArea'),
            ),
        ],
      ),
    );
  }

  Future<void> _showRouteModal(String areaName) async {
    setState(() {
      _isLoadingEncounters = true;
    });

    int? locationId;
    try {
      final client = GraphQLProvider.of(context).value;
      final repository = MapRepository(client);
      locationId = await repository.getLocationAreaIdByName(areaName);
    } catch (_) {
      locationId = null;
    }

    setState(() {
      _isLoadingEncounters = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutePokemonModal(
        routeName: areaName,
        locationId: locationId,
      ),
    );
  }
}
