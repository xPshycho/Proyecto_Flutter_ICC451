import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Kanto.
class KantoMapAreas {
  static const String mapImagePath = 'assets/images/maps/kanto.png';

  static List<MapArea> get areas => [
    MapArea(name: 'Pallet Town', rect: Rect.fromLTRB(47, 103, 56, 112)),
    MapArea(name: 'Viridian City', rect: Rect.fromLTRB(47, 76, 56, 92)),
    MapArea(name: 'Viridian Forest', rect: Rect.fromLTRB(47, 64, 56, 71)),
    MapArea(name: 'Pewter City', rect: Rect.fromLTRB(47, 46, 62, 62)),
    MapArea(name: 'Mt. Moon', rect: Rect.fromLTRB(88, 39, 96, 48)),
    MapArea(name: 'Cerulean City', rect: Rect.fromLTRB(127, 39, 137, 48)),
    MapArea(name: 'Rock Tunnel', rect: Rect.fromLTRB(160, 40, 168, 47)),
    MapArea(name: 'Power Plant', rect: Rect.fromLTRB(160, 50, 168, 57)),
    MapArea(name: 'Lavender Town', rect: Rect.fromLTRB(160, 64, 168, 71)),
    MapArea(name: 'Pokémon Tower', rect: Rect.fromLTRB(168, 74, 176, 82)),
    MapArea(name: 'Saffron City', rect: Rect.fromLTRB(124, 62, 138, 76)),
    MapArea(name: 'Celadon City', rect: Rect.fromLTRB(104, 64, 111, 72)),
    MapArea(name: 'Vermilion City', rect: Rect.fromLTRB(128, 88, 136, 96)),
    MapArea(name: 'Diglett\'s Cave', rect: Rect.fromLTRB(136, 88, 144, 96)),
    MapArea(name: 'Fuchsia City', rect: Rect.fromLTRB(112, 112, 120, 120)),
    MapArea(name: 'Seafoam Islands', rect: Rect.fromLTRB(75, 128, 88, 135)),
    MapArea(name: 'Cinnabar Island', rect: Rect.fromLTRB(47, 128, 55, 136)),
    MapArea(name: 'Victory Road', rect: Rect.fromLTRB(23, 48, 31, 55)),
    MapArea(name: 'Indigo Plateau', rect: Rect.fromLTRB(23, 39, 31, 47)),
    MapArea(name: 'Tohjo Falls', rect: Rect.fromLTRB(2, 109, 10, 116)),
    MapArea(name: 'Route 1', rect: Rect.fromLTRB(47, 92, 56, 103)),
    MapArea(name: 'Route 2', rect: Rect.fromLTRB(47, 71, 56, 76)),
    MapArea(name: 'Route 3', rect: Rect.fromLTRB(63, 47, 88, 56)),
    MapArea(name: 'Route 4', rect: Rect.fromLTRB(79, 39, 127, 48)),
    MapArea(name: 'Route 5', rect: Rect.fromLTRB(127, 48, 137, 61)),
    MapArea(name: 'Route 6', rect: Rect.fromLTRB(127, 77, 137, 88)),
    MapArea(name: 'Route 7', rect: Rect.fromLTRB(139, 63, 159, 72)),
    MapArea(name: 'Route 8', rect: Rect.fromLTRB(112, 63, 123, 72)),
    MapArea(name: 'Route 9', rect: Rect.fromLTRB(136, 39, 159, 48)),
    MapArea(name: 'Route 10', rect: Rect.fromLTRB(159, 39, 168, 64)),
    MapArea(name: 'Route 11', rect: Rect.fromLTRB(144, 87, 159, 96)),
    MapArea(name: 'Route 12', rect: Rect.fromLTRB(159, 72, 168, 104)),
    MapArea(name: 'Route 13', rect: Rect.fromLTRB(143, 103, 168, 112)),
    MapArea(name: 'Route 14', rect: Rect.fromLTRB(135, 103, 145, 120)),
    MapArea(name: 'Route 15', rect: Rect.fromLTRB(120, 111, 135, 120)),
    MapArea(name: 'Route 16', rect: Rect.fromLTRB(71, 63, 103, 72)),
    MapArea(name: 'Route 17', rect: Rect.fromLTRB(71, 72, 80, 112)),
    MapArea(name: 'Route 18', rect: Rect.fromLTRB(71, 111, 112, 120)),
    MapArea(name: 'Route 19', rect: Rect.fromLTRB(111, 120, 121, 136)),
    MapArea(name: 'Route 20', rect: Rect.fromLTRB(55, 127, 111, 137)),
    MapArea(name: 'Route 21', rect: Rect.fromLTRB(47, 127, 56, 112)),
    MapArea(name: 'Route 22', rect: Rect.fromLTRB(31, 79, 48, 88)),
    MapArea(name: 'Route 23', rect: Rect.fromLTRB(22, 55, 32, 79)),
    MapArea(name: 'Route 24', rect: Rect.fromLTRB(127, 23, 136, 40)),
    MapArea(name: 'Route 25', rect: Rect.fromLTRB(136, 23, 152, 33)),
    MapArea(name: 'Route 27', rect: Rect.fromLTRB(0, 103, 32, 118)),
    MapArea(name: 'Route 26', rect: Rect.fromLTRB(22, 88, 32, 108)),
    MapArea(name: 'Route 28', rect: Rect.fromLTRB(8, 79, 23, 88)),
    // Agregar más áreas de Sevii Islands si es necesario
  ];
}
