import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../widgets/map_components/interactive_map_widget.dart';
import '../widgets/map_components/kanto_map_areas.dart';
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
  String selectedRegion = 'Kanto';
  List<Location> _locations = [];
  bool _isLoadingEncounters = false;
  bool _isOpeningModal = false; // evita abrir múltiples modales por taps rápidos
  bool _isModalOpen = false;

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
              value: selectedRegion,
              items: const [
                DropdownMenuItem(value: 'Kanto', child: Text('Kanto')),
                // Agregar más regiones
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRegion = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: InteractiveMapWidget(
              mapImagePath: KantoMapAreas.mapImagePath,
              areas: KantoMapAreas.areas,
              onAreaTap: (areaName) async {
                // Protegemos contra taps rápidos
                if (_isOpeningModal) return;
                _isOpeningModal = true;
                setState(() {
                  selectedArea = areaName;
                });
                await _showRouteModal(areaName);
                _isOpeningModal = false;
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

    setState(() {
      _isLoadingEncounters = false;
    });

    // Instead of popping arbitrary routes, keep track of modal state and await its closing.
    if (_isModalOpen) {
      // If modal is open, don't open another; you could also close it explicitly if needed.
      return;
    }

    _isModalOpen = true;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => RoutePokemonModal(
        routeName: areaName,
        locationId: null,
        regionName: selectedRegion,
      ),
    );
    // When modal Future completes, it's closed.
    _isModalOpen = false;
  }
}
