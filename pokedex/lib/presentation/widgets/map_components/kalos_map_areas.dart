import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Kalos.
class KalosMapAreas {
  static const String mapImagePath = 'assets/images/maps/kalos.png';
  // Estimación del tamaño de la imagen según coordenadas en el mapa HTML
  static const double imageWidth = 320.0;
  static const double imageHeight = 220.0;

  static List<MapArea> get areas => [
    // Routes (se approximan polígonos como bounding rects)
    MapArea(name: 'Route 1', rect: Rect.fromLTRB(210, 163, 213, 173)),
    MapArea(name: 'Route 2', rect: Rect.fromLTRB(209, 140, 214, 150)),
    MapArea(name: 'Route 3', rect: Rect.fromLTRB(200, 124, 209, 132)), // poly -> bbox
    MapArea(name: 'Route 4', rect: Rect.fromLTRB(173, 90, 193, 114)), // poly -> bbox
    MapArea(name: 'Route 5', rect: Rect.fromLTRB(133, 89, 157, 115)), // poly -> bbox
    MapArea(name: 'Route 6', rect: Rect.fromLTRB(97, 95, 127, 117)), // poly -> bbox
    MapArea(name: 'Route 7', rect: Rect.fromLTRB(76, 118, 124, 123)),
    MapArea(name: 'Route 8', rect: Rect.fromLTRB(55, 126, 70, 155)), // poly -> bbox
    MapArea(name: 'Route 9', rect: Rect.fromLTRB(78, 156, 109, 162)),
    MapArea(name: 'Route 10', rect: Rect.fromLTRB(32, 103, 51, 118)), // poly -> bbox
    MapArea(name: 'Route 11', rect: Rect.fromLTRB(30, 87, 34, 95)), // poly -> bbox
    MapArea(name: 'Route 12', rect: Rect.fromLTRB(53, 61, 103, 76)), // poly -> bbox
    MapArea(name: 'Route 13', rect: Rect.fromLTRB(115, 62, 152, 76)), // poly -> bbox
    MapArea(name: 'Route 14', rect: Rect.fromLTRB(162, 30, 168, 63)),
    MapArea(name: 'Route 15', rect: Rect.fromLTRB(169, 25, 215, 60)), // poly -> bbox
    MapArea(name: 'Route 16', rect: Rect.fromLTRB(179, 63, 213, 77)), // poly -> bbox
    MapArea(name: 'Route 17', rect: Rect.fromLTRB(224, 62, 275, 81)), // poly -> bbox
    MapArea(name: 'Route 18', rect: Rect.fromLTRB(285, 83, 294, 92)), // poly -> bbox
    MapArea(name: 'Route 19', rect: Rect.fromLTRB(275, 98, 294, 115)), // poly -> bbox
    MapArea(name: 'Route 20', rect: Rect.fromLTRB(258, 123, 266, 154)), // poly -> bbox
    MapArea(name: 'Route 21', rect: Rect.fromLTRB(241, 114, 264, 119)),
    MapArea(name: 'Route 22', rect: Rect.fromLTRB(202, 113, 229, 121)), // poly -> bbox

    // Towns / Cities / POIs
    MapArea(name: 'Ambrette Town', rect: Rect.fromLTRB(65, 152, 79, 166)),
    MapArea(name: 'Anistar City', rect: Rect.fromLTRB(274, 73, 288, 87)),
    MapArea(name: 'Aquacorde Town', rect: Rect.fromLTRB(205, 150, 219, 164)),
    MapArea(name: 'Azure Bay', rect: Rect.fromLTRB(84, 41, 105, 58)), // poly -> bbox
    MapArea(name: 'Camphrier Town', rect: Rect.fromLTRB(124, 114, 138, 128)),
    MapArea(name: 'Chamber of Emptiness', rect: Rect.fromLTRB(216, 120, 227, 131)),
    MapArea(name: 'Connecting Cave', rect: Rect.fromLTRB(65, 115, 76, 126)),
    MapArea(name: 'Couriway Town', rect: Rect.fromLTRB(291, 89, 305, 103)),
    MapArea(name: 'Coumarine City', rect: Rect.fromLTRB(103, 56, 117, 70)),
    MapArea(name: 'Cyllage City', rect: Rect.fromLTRB(49, 113, 63, 127)),
    MapArea(name: 'Dendemille Town', rect: Rect.fromLTRB(212, 56, 226, 70)),
    MapArea(name: 'Frost Cavern', rect: Rect.fromLTRB(226, 62, 238, 74)),
    MapArea(name: 'Geosenge Town', rect: Rect.fromLTRB(22, 93, 36, 107)),
    MapArea(name: 'Glittering Cave', rect: Rect.fromLTRB(111, 153, 122, 164)),
    MapArea(name: 'Kalos Power Plant', rect: Rect.fromLTRB(116, 79, 128, 91)),
    MapArea(name: 'Kiloude City', rect: Rect.fromLTRB(233, 187, 247, 201)),
    MapArea(name: 'Laverre City', rect: Rect.fromLTRB(158, 17, 172, 31)),
    MapArea(name: 'Lost Hotel', rect: Rect.fromLTRB(185, 49, 197, 61)),
    MapArea(name: 'Lumiose City', rect: Rect.fromLTRB(150, 63, 182, 93)),
    MapArea(name: 'Parfum Palace', rect: Rect.fromLTRB(89, 88, 101, 100)),
    MapArea(name: 'Poke Ball Factory', rect: Rect.fromLTRB(159, 6, 170, 17)),
    MapArea(name: 'Pokemon League', rect: Rect.fromLTRB(228, 84, 240, 96)),
    MapArea(name: 'Pokemon Village', rect: Rect.fromLTRB(253, 153, 264, 164)),
    MapArea(name: 'Reflection Cave', rect: Rect.fromLTRB(35, 78, 47, 90)),
    MapArea(name: 'Santalune City', rect: Rect.fromLTRB(192, 112, 204, 124)),
    MapArea(name: 'Santalune Forest', rect: Rect.fromLTRB(206, 130, 217, 141)),
    MapArea(name: "Sea Spirit's Den", rect: Rect.fromLTRB(75, 33, 86, 44)),
    MapArea(name: 'Shalour City', rect: Rect.fromLTRB(41, 69, 54, 83)),
    MapArea(name: 'Snowbelle City', rect: Rect.fromLTRB(264, 110, 278, 124)),
    MapArea(name: 'Terminus Cave', rect: Rect.fromLTRB(302, 73, 313, 84)),
    MapArea(name: 'Vaniville Town', rect: Rect.fromLTRB(205, 174, 219, 188)),
    MapArea(name: 'Victory Road', rect: Rect.fromLTRB(229, 98, 241, 121)),

    // Other notable locations
    MapArea(name: 'Chamber of Emptiness (alt)', rect: Rect.fromLTRB(216, 120, 227, 131)),
    MapArea(name: 'Parfum Palace (alt)', rect: Rect.fromLTRB(89, 88, 101, 100)),
  ];
}

