import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Johto.
class JohtoMapAreas {
  static const String mapImagePath = 'assets/images/maps/johto.png';
  static const double imageWidth = 166.0;
  static const double imageHeight = 144.0;

  static List<MapArea> get areas => [
    // Towns
    MapArea(name: 'New Bark Town', rect: Rect.fromLTRB(144, 109, 152, 117)),
    MapArea(name: 'Cherrygrove City', rect: Rect.fromLTRB(105, 109, 113, 117)),
    MapArea(name: 'Violet City', rect: Rect.fromLTRB(90, 60, 97, 68)),
    MapArea(name: 'Azalea Town', rect: Rect.fromLTRB(71, 129, 79, 137)),
    MapArea(name: 'Goldenrod City', rect: Rect.fromLTRB(49, 88, 63, 103)),
    MapArea(name: 'Ecruteak City', rect: Rect.fromLTRB(66, 40, 81, 48)),
    MapArea(name: 'Olivine City', rect: Rect.fromLTRB(18, 53, 33, 61)),
    MapArea(name: 'Cianwood City', rect: Rect.fromLTRB(8, 96, 16, 104)),
    MapArea(name: 'Mahogany Town', rect: Rect.fromLTRB(109, 40, 117, 48)),
    MapArea(name: 'Blackthorn City', rect: Rect.fromLTRB(137, 40, 145, 48)),

    // Caves and Forests
    MapArea(name: 'Dark Cave', rect: Rect.fromLTRB(116, 60, 136, 69)),
    MapArea(name: 'Ruins of Alph', rect: Rect.fromLTRB(81, 76, 89, 84)),
    MapArea(name: 'Union Cave', rect: Rect.fromLTRB(90, 129, 98, 137)),
    MapArea(name: 'Ilex Forest', rect: Rect.fromLTRB(53, 129, 61, 137)),
    MapArea(name: 'National Park', rect: Rect.fromLTRB(53, 60, 61, 68)),
    MapArea(name: 'Whirl Islands', rect: Rect.fromLTRB(18, 88, 26, 96)),
    MapArea(name: 'Mt. Mortar', rect: Rect.fromLTRB(86, 40, 94, 48)),
    MapArea(name: 'Lake of Rage', rect: Rect.fromLTRB(109, 7, 117, 15)),
    MapArea(name: 'Ice Path', rect: Rect.fromLTRB(129, 40, 137, 48)),
    MapArea(name: 'Dragon\'s Den', rect: Rect.fromLTRB(137, 30, 145, 38)),
    MapArea(name: 'Mt. Silver', rect: Rect.fromLTRB(158, 80, 166, 88)),
    MapArea(name: 'Safari Zone', rect: Rect.fromLTRB(0, 93, 5, 101)),

    // Routes
    MapArea(name: 'Route 29', rect: Rect.fromLTRB(113, 108, 143, 118)),
    MapArea(name: 'Route 30', rect: Rect.fromLTRB(105, 108, 116, 68)),
    MapArea(name: 'Route 31', rect: Rect.fromLTRB(98, 59, 115, 68)),
    MapArea(name: 'Route 32', rect: Rect.fromLTRB(89, 68, 99, 128)),
    MapArea(name: 'Route 33', rect: Rect.fromLTRB(79, 128, 90, 137)),
    MapArea(name: 'Route 34', rect: Rect.fromLTRB(52, 103, 62, 128)),
    MapArea(name: 'Route 35', rect: Rect.fromLTRB(52, 68, 62, 88)),
    MapArea(name: 'Route 36', rect: Rect.fromLTRB(60, 59, 89, 69)),
    MapArea(name: 'Route 37', rect: Rect.fromLTRB(71, 55, 82, 58)),
    MapArea(name: 'Route 38', rect: Rect.fromLTRB(25, 39, 66, 49)),
    MapArea(name: 'Route 39', rect: Rect.fromLTRB(25, 48, 34, 53)),
    MapArea(name: 'Route 40', rect: Rect.fromLTRB(17, 61, 27, 82)),
    MapArea(name: 'Route 41', rect: Rect.fromLTRB(17, 82, 27, 105)),
    MapArea(name: 'Route 42', rect: Rect.fromLTRB(81, 39, 109, 49)),
    MapArea(name: 'Route 43', rect: Rect.fromLTRB(108, 15, 118, 40)),
    MapArea(name: 'Route 44', rect: Rect.fromLTRB(117, 39, 128, 49)),
    MapArea(name: 'Route 45', rect: Rect.fromLTRB(136, 48, 146, 89)),
    MapArea(name: 'Route 46', rect: Rect.fromLTRB(130, 78, 140, 108)),
    MapArea(name: 'Route 47', rect: Rect.fromLTRB(0, 104, 8, 111)),
    MapArea(name: 'Route 48', rect: Rect.fromLTRB(0, 100, 6, 105)),

    // Other
    MapArea(name: 'Battle Frontier', rect: Rect.fromLTRB(10, 51, 18, 59)),
  ];
}
