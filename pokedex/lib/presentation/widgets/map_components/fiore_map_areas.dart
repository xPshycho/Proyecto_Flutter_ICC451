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
    MapArea(name: 'Ring Town', rect: Rect.fromLTRB(40, 117, 48, 132)),
    MapArea(name: 'Kisara Plains', rect: Rect.fromLTRB(57, 125, 65, 131)),
    MapArea(name: 'Lyra Forest', rect: Rect.fromLTRB(41, 97, 47, 105)),
    MapArea(name: 'Krokka Tunnel', rect: Rect.fromLTRB(89, 86, 97, 92)),
    MapArea(name: 'East Road', rect: Rect.fromLTRB(136, 86, 144, 92)),
    MapArea(name: 'Fall City', rect: Rect.fromLTRB(162, 85, 177, 100)),
    MapArea(name: 'Underground Waterways', rect: Rect.fromLTRB(194, 79, 202, 85)),
    MapArea(name: 'Dusk Factory', rect: Rect.fromLTRB(193, 93, 202, 99)),
    MapArea(name: 'Safra Sea', rect: Rect.fromLTRB(170, 175, 176, 183)),
    // Summerland aparece duplicado en el HTML; usar un rect que cubra ambas variantes
    MapArea(name: 'Summerland', rect: Rect.fromLTRB(103, 154, 118, 169)),
    MapArea(name: 'Olive Jungle', rect: Rect.fromLTRB(130, 153, 136, 161)),
    MapArea(name: 'Jungle Relic', rect: Rect.fromLTRB(130, 145, 136, 153)),
    MapArea(name: 'Panula Cave', rect: Rect.fromLTRB(97, 106, 103, 114)),
    MapArea(name: 'North Road', rect: Rect.fromLTRB(97, 70, 103, 78)),
    // Wintown tiene dos rects en el HTML; usamos el que cubre ambos
    MapArea(name: 'Wintown', rect: Rect.fromLTRB(96, 55, 111, 70)),
    MapArea(name: 'Sekra Range', rect: Rect.fromLTRB(103, 38, 111, 46)),
    MapArea(name: 'Go-Rock Squad Base', rect: Rect.fromLTRB(95, 22, 101, 30)),
    MapArea(name: 'Fiore Temple', rect: Rect.fromLTRB(114, 22, 120, 30)),
  ];
}

