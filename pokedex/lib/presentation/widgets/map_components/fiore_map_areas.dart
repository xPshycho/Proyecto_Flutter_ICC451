import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Fiore.
class FioreMapAreas {
  static const String mapImagePath = 'assets/images/maps/fiore.png';
  // Tamaño de la imagen según el HTML (width / height)
  static const double imageWidth = 257.0;
  static const double imageHeight = 191.0;

  static List<MapArea> get areas => [
    // Coordenadas extraídas del mapa HTML (coords -> Rect.fromLTRB)
    MapArea(name: 'Ring Town', rect: Rect.fromLTRB(40, 117, 48, 132), identifier: 'ring-town'),
    MapArea(name: 'Kisara Plains', rect: Rect.fromLTRB(57, 125, 65, 131), identifier: 'fiore-kisara-plains'),
    MapArea(name: 'Lyra Forest', rect: Rect.fromLTRB(41, 97, 47, 105), identifier: 'fiore-lyra-forest'),
    MapArea(name: 'Krokka Tunnel', rect: Rect.fromLTRB(89, 86, 97, 92), identifier: 'fiore-krokka-tunnel'),
    MapArea(name: 'East Road', rect: Rect.fromLTRB(136, 86, 144, 92), identifier: 'fiore-east-road'),
    MapArea(name: 'Fall City', rect: Rect.fromLTRB(162, 85, 177, 100), identifier: 'fall-city'),
    MapArea(name: 'Underground Waterways', rect: Rect.fromLTRB(194, 79, 202, 85), identifier: 'fiore-underground-waterways'),
    MapArea(name: 'Dusk Factory', rect: Rect.fromLTRB(193, 93, 202, 99), identifier: 'fiore-dusk-factory'),
    MapArea(name: 'Safra Sea', rect: Rect.fromLTRB(170, 175, 176, 183), identifier: 'safra-sea'),
    // Summerland aparece duplicado en el HTML; usar un rect que cubra ambas variantes
    MapArea(name: 'Summerland', rect: Rect.fromLTRB(103, 154, 118, 169), identifier: 'fiore-summerland'),
    MapArea(name: 'Olive Jungle', rect: Rect.fromLTRB(130, 153, 136, 161), identifier: 'fiore-olive-jungle'),
    MapArea(name: 'Jungle Relic', rect: Rect.fromLTRB(130, 145, 136, 153), identifier: 'fiore-jungle-relic'),
    MapArea(name: 'Panula Cave', rect: Rect.fromLTRB(97, 106, 103, 114), identifier: 'panula-cave'),
    MapArea(name: 'North Road', rect: Rect.fromLTRB(97, 70, 103, 78), identifier: 'fiore-north-road'),
    // Wintown tiene dos rects en el HTML; usamos el que cubre ambos
    MapArea(name: 'Wintown', rect: Rect.fromLTRB(96, 55, 111, 70), identifier: 'wintown'),
    MapArea(name: 'Sekra Range', rect: Rect.fromLTRB(103, 38, 111, 46), identifier: 'fiore-sekra-range'),
    MapArea(name: 'Go-Rock Squad Base', rect: Rect.fromLTRB(95, 22, 101, 30), identifier: 'fiore-go-rock-squad-base'),
    MapArea(name: 'Fiore Temple', rect: Rect.fromLTRB(114, 22, 120, 30), identifier: 'fiore-temple'),
  ];
}

