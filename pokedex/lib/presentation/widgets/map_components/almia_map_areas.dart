import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Almia.
class AlmiaMapAreas {
  static const String mapImagePath = 'assets/images/maps/almia.png';
  // Tamaño de la imagen según el HTML (width / height)
  static const double imageWidth = 256.0;
  static const double imageHeight = 192.0;

  static List<MapArea> get areas => [
    // Coordenadas extraídas del mapa HTML (coords -> Rect.fromLTRB)
    MapArea(name: 'Chicole Village', rect: Rect.fromLTRB(92, 151, 107, 159)),
    MapArea(name: 'Veintown', rect: Rect.fromLTRB(92, 117, 100, 132)),
    // Ranger School aparece con dos rects; usar uno que cubra ambas variantes
    MapArea(name: 'Ranger School', rect: Rect.fromLTRB(120, 117, 135, 132)),
    MapArea(name: 'Pueltown', rect: Rect.fromLTRB(85, 78, 100, 86)),
    MapArea(name: 'Altru Park', rect: Rect.fromLTRB(85, 70, 100, 78)),
    MapArea(name: 'Altru Building', rect: Rect.fromLTRB(85, 62, 100, 70)),
    MapArea(name: 'Altru Tower', rect: Rect.fromLTRB(92, 34, 100, 43)),
    MapArea(name: 'Peril Cliffs', rect: Rect.fromLTRB(68, 44, 76, 71)),
    MapArea(name: 'Marine Cave', rect: Rect.fromLTRB(75, 125, 83, 131)),
    MapArea(name: 'Cargo Ship', rect: Rect.fromLTRB(135, 125, 143, 131)),
    MapArea(name: 'Ranger Union', rect: Rect.fromLTRB(44, 70, 52, 78)),
    // Shiver Camp tiene dos rects; usamos uno que cubre ambas variantes
    MapArea(name: 'Shiver Camp', rect: Rect.fromLTRB(38, 39, 53, 54)),
    MapArea(name: 'Almia Castle', rect: Rect.fromLTRB(15, 30, 23, 39)),
    MapArea(name: 'Chroma Ruins', rect: Rect.fromLTRB(171, 27, 177, 35)),
    MapArea(name: 'Chroma Highlands', rect: Rect.fromLTRB(171, 36, 177, 44)),
    MapArea(name: 'Boyleland', rect: Rect.fromLTRB(217, 85, 232, 93)),
    MapArea(name: 'Volcano Cave', rect: Rect.fromLTRB(224, 68, 232, 85)),
    MapArea(name: 'Haruba Village', rect: Rect.fromLTRB(224, 166, 239, 181)),
    MapArea(name: 'Hippowdon Temple', rect: Rect.fromLTRB(232, 150, 238, 158)),
    MapArea(name: 'Oil Field Hideout', rect: Rect.fromLTRB(163, 154, 171, 160)),
    MapArea(name: 'Sea of Wailord', rect: Rect.fromLTRB(191, 125, 197, 133)),
    MapArea(name: 'Puel Sea', rect: Rect.fromLTRB(175, 111, 181, 119)),
    MapArea(name: 'Capture Arena', rect: Rect.fromLTRB(40, 160, 48, 168)),
    MapArea(name: 'Chicole Path', rect: Rect.fromLTRB(92, 132, 100, 151)),
    MapArea(name: 'School Road', rect: Rect.fromLTRB(100, 124, 120, 132)),
    MapArea(name: 'Nabiki Beach', rect: Rect.fromLTRB(83, 124, 92, 132)),
    MapArea(name: 'Vein Forest', rect: Rect.fromLTRB(92, 86, 100, 117)),
    MapArea(name: 'Union Road', rect: Rect.fromLTRB(52, 70, 85, 78)),
    MapArea(name: 'Crysta Cave', rect: Rect.fromLTRB(15, 70, 44, 78)),
    MapArea(name: 'Hia Field', rect: Rect.fromLTRB(15, 39, 23, 70)),
    // Chroma Road aparece varias veces; usar un rect que cubra las variantes
    MapArea(name: 'Chroma Road', rect: Rect.fromLTRB(100, 47, 178, 78)),
    MapArea(name: 'Haruba Desert', rect: Rect.fromLTRB(231, 158, 239, 166)),
  ];
}

