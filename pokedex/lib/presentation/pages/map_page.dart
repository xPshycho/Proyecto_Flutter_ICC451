import 'package:flutter/material.dart';
import '../widgets/map_components/interactive_map_widget.dart';
import '../widgets/map_components/kanto_map_areas.dart';
import '../widgets/map_components/route_pokemon_modal.dart';
import '../widgets/map_components/johto_map_areas.dart';
import '../widgets/map_components/oblivia_map_areas.dart';
import '../widgets/map_components/hoenn_map_areas.dart';
import '../widgets/map_components/sinnoh_map_areas.dart';
import '../widgets/map_components/unova_map_areas.dart';
import '../widgets/map_components/kalos_map_areas.dart';
import '../widgets/map_components/orre_map_areas.dart';
import '../widgets/map_components/fiore_map_areas.dart';
import '../widgets/map_components/almia_map_areas.dart';

/// Página para explorar mapas interactivos de regiones de Pokémon.
class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  String? selectedArea;
  String selectedRegion = 'Kanto';
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
                DropdownMenuItem(value: 'Johto', child: Text('Johto')),
                DropdownMenuItem(value: 'Hoenn', child: Text('Hoenn')),
                DropdownMenuItem(value: 'Sinnoh', child: Text('Sinnoh')),
                DropdownMenuItem(value: 'Unova', child: Text('Unova')),
                DropdownMenuItem(value: 'Kalos', child: Text('Kalos')),
                DropdownMenuItem(value: 'Alola', child: Text('Alola')),
                DropdownMenuItem(value: 'Galar', child: Text('Galar')),
                DropdownMenuItem(value: 'Orre', child: Text('Orre')),
                DropdownMenuItem(value: 'Fiore', child: Text('Fiore')),
                DropdownMenuItem(value: 'Almia', child: Text('Almia')),
                DropdownMenuItem(value: 'Oblivia', child: Text('Oblivia')),
                DropdownMenuItem(value: 'Unova (BW)', child: Text('Unova (BW)')),
                // Nota: 'Unova (BW)' no tiene por qué ser diferente si ya hay 'Unova' — mantenido solo si se necesita
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    // Normalize value if we added variants
                    selectedRegion = value;
                  });
                }
              },
            ),
          ),
          Expanded(
            child: InteractiveMapWidget(
              mapImagePath: _mapImagePath,
              areas: _areas,
              imageWidth: _imageWidth,
              imageHeight: _imageHeight,
              // Ahora recibimos un MapArea y extraemos su identifier
              onAreaTap: (area) async {
                if (_isOpeningModal) return;
                _isOpeningModal = true;
                // area es MapArea
                final MapArea mapArea = area;
                final identifier = mapArea.identifier ?? mapArea.name;
                setState(() {
                  selectedArea = mapArea.name; // nombre amigable para mostrar
                });
                debugPrint('MapPage: area tapped -> ${mapArea.name} (identifier: $identifier, region: $selectedRegion)');
                await _showRouteModal(identifier);
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

  String get _mapImagePath {
    switch (selectedRegion) {
      case 'Kanto':
        return KantoMapAreas.mapImagePath;
      case 'Johto':
        return JohtoMapAreas.mapImagePath;
      case 'Hoenn':
        return HoennMapAreas.mapImagePath;
      case 'Sinnoh':
        return SinnohMapAreas.mapImagePath;
      case 'Unova':
      case 'Unova (BW)':
        return UnovaMapAreas.mapImagePath;
      case 'Kalos':
        return KalosMapAreas.mapImagePath;
      case 'Orre':
        return OrreMapAreas.mapImagePath;
      case 'Fiore':
        return FioreMapAreas.mapImagePath;
      case 'Almia':
        return AlmiaMapAreas.mapImagePath;
      case 'Oblivia':
        return ObliviaMapAreas.mapImagePath;
      default:
        return KantoMapAreas.mapImagePath;
    }
  }

  List<MapArea> get _areas {
    switch (selectedRegion) {
      case 'Kanto':
        return KantoMapAreas.areas;
      case 'Johto':
        return JohtoMapAreas.areas;
      case 'Hoenn':
        return HoennMapAreas.areas;
      case 'Sinnoh':
        return SinnohMapAreas.areas;
      case 'Unova':
      case 'Unova (BW)':
        return UnovaMapAreas.areas;
      case 'Kalos':
        return KalosMapAreas.areas;
      case 'Orre':
        return OrreMapAreas.areas;
      case 'Fiore':
        return FioreMapAreas.areas;
      case 'Almia':
        return AlmiaMapAreas.areas;
      case 'Oblivia':
        return ObliviaMapAreas.areas;
      default:
        return KantoMapAreas.areas;
    }
  }

  double get _imageWidth {
    switch (selectedRegion) {
      case 'Kanto':
        return KantoMapAreas.imageWidth;
      case 'Johto':
        return JohtoMapAreas.imageWidth;
      case 'Hoenn':
        return HoennMapAreas.imageWidth;
      case 'Sinnoh':
        return SinnohMapAreas.imageWidth;
      case 'Unova':
      case 'Unova (BW)':
        return UnovaMapAreas.imageWidth;
      case 'Kalos':
        return KalosMapAreas.imageWidth;
      case 'Orre':
        return OrreMapAreas.imageWidth;
      case 'Fiore':
        return FioreMapAreas.imageWidth;
      case 'Almia':
        return AlmiaMapAreas.imageWidth;
      case 'Oblivia':
        return ObliviaMapAreas.imageWidth;
      default:
        return KantoMapAreas.imageWidth;
    }
  }

  double get _imageHeight {
    switch (selectedRegion) {
      case 'Kanto':
        return KantoMapAreas.imageHeight;
      case 'Johto':
        return JohtoMapAreas.imageHeight;
      case 'Hoenn':
        return HoennMapAreas.imageHeight;
      case 'Sinnoh':
        return SinnohMapAreas.imageHeight;
      case 'Unova':
      case 'Unova (BW)':
        return UnovaMapAreas.imageHeight;
      case 'Kalos':
        return KalosMapAreas.imageHeight;
      case 'Orre':
        return OrreMapAreas.imageHeight;
      case 'Fiore':
        return FioreMapAreas.imageHeight;
      case 'Almia':
        return AlmiaMapAreas.imageHeight;
      case 'Oblivia':
        return ObliviaMapAreas.imageHeight;
      default:
        return KantoMapAreas.imageHeight;
    }
  }

  Future<void> _showRouteModal(String routeIdentifier) async {
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
        routeName: routeIdentifier,
        locationId: null,
        regionName: selectedRegion,
      ),
    );
    // When modal Future completes, it's closed.
    _isModalOpen = false;
  }
}
