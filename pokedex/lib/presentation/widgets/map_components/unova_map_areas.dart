import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Unova.
class UnovaMapAreas {
  static const String mapImagePath = 'assets/images/maps/unova.png';
  static const double imageWidth = 256.0;
  static const double imageHeight = 168.0;

  static List<MapArea> get areas => [
    // Routes (rects and approximated polys as bounding rects)
    MapArea(name: 'Route 1', rect: Rect.fromLTRB(231, 144, 233, 152)),
    MapArea(name: 'Route 2', rect: Rect.fromLTRB(229, 124, 232, 132)),
    MapArea(name: 'Route 3', rect: Rect.fromLTRB(209, 117, 222, 121)),
    MapArea(name: 'Route 4', rect: Rect.fromLTRB(130, 96, 134, 124)),
    MapArea(name: 'Route 5', rect: Rect.fromLTRB(115, 89, 126, 94)),
    // Route 6 poly -> bbox
    MapArea(name: 'Route 6', rect: Rect.fromLTRB(44, 68, 69, 89)),
    // Route 7 poly -> bbox
    MapArea(name: 'Route 7', rect: Rect.fromLTRB(44, 45, 70, 64)),
    MapArea(name: 'Route 8', rect: Rect.fromLTRB(80, 41, 94, 47)),
    MapArea(name: 'Route 9', rect: Rect.fromLTRB(113, 41, 127, 47)),
    MapArea(name: 'Route 10', rect: Rect.fromLTRB(134, 29, 158, 34)),
    MapArea(name: 'Route 11', rect: Rect.fromLTRB(138, 41, 151, 47)),
    MapArea(name: 'Route 12', rect: Rect.fromLTRB(170, 41, 184, 47)),
    // Route 13 poly -> bbox
    MapArea(name: 'Route 13', rect: Rect.fromLTRB(195, 46, 220, 67)),
    // Route 14 poly -> bbox
    MapArea(name: 'Route 14', rect: Rect.fromLTRB(194, 69, 220, 90)),
    MapArea(name: 'Route 15', rect: Rect.fromLTRB(169, 89, 184, 94)),
    MapArea(name: 'Route 16', rect: Rect.fromLTRB(138, 89, 150, 94)),
    MapArea(name: 'Route 17', rect: Rect.fromLTRB(213, 156, 226, 161)),
    MapArea(name: 'Route 18', rect: Rect.fromLTRB(202, 156, 213, 161)),
    // Route 19 has two entries: rect and small poly bbox
    MapArea(name: 'Route 19', rect: Rect.fromLTRB(13, 131, 15, 147)),
    MapArea(name: 'Route 19 (alt)', rect: Rect.fromLTRB(12, 126, 27, 132)),
    MapArea(name: 'Route 20', rect: Rect.fromLTRB(39, 126, 63, 130)),
    MapArea(name: 'Route 21', rect: Rect.fromLTRB(233, 41, 237, 50)),
    MapArea(name: 'Route 22', rect: Rect.fromLTRB(211, 35, 229, 39)),
    // Route 23 multiple rects
    MapArea(name: 'Route 23', rect: Rect.fromLTRB(195, 35, 205, 39)),
    MapArea(name: 'Route 23 (alt1)', rect: Rect.fromLTRB(195, 15, 197, 39)),
    MapArea(name: 'Route 23 (alt2)', rect: Rect.fromLTRB(188, 15, 197, 19)),

    // Marine Tube appears multiple times -> add all rects
    MapArea(name: 'Marine Tube', rect: Rect.fromLTRB(229, 66, 253, 71)),
    MapArea(name: 'Marine Tube (alt1)', rect: Rect.fromLTRB(251, 31, 253, 71)),
    MapArea(name: 'Marine Tube (alt2)', rect: Rect.fromLTRB(241, 35, 253, 40)),

    // Bridges and special locations
    // Skyarrow Bridge poly bbox (approx)
    MapArea(name: 'Skyarrow Bridge', rect: Rect.fromLTRB(138, 117, 187, 130)),
    MapArea(name: 'Desert Resort', rect: Rect.fromLTRB(118, 102, 131, 107)),
    MapArea(name: 'Tubeline Bridge', rect: Rect.fromLTRB(93, 40, 114, 46)),
    MapArea(name: 'Village Bridge', rect: Rect.fromLTRB(150, 40, 171, 46)),
    MapArea(name: 'Marvelous Bridge', rect: Rect.fromLTRB(149, 88, 170, 94)),
    MapArea(name: 'Driftveil Drawbridge', rect: Rect.fromLTRB(80, 88, 114, 94)),

    // Towns / Cities / Points of Interest
    MapArea(name: 'Nuvema Town', rect: Rect.fromLTRB(226, 152, 238, 164)),
    MapArea(name: 'Plasma Frigate', rect: Rect.fromLTRB(219, 148, 225, 154)),
    MapArea(name: 'Accumula Town', rect: Rect.fromLTRB(226, 132, 238, 144)),
    MapArea(name: 'Striaton City', rect: Rect.fromLTRB(222, 112, 234, 124)),
    MapArea(name: 'Nacrene City', rect: Rect.fromLTRB(197, 112, 209, 124)),
    MapArea(name: 'Castelia City', rect: Rect.fromLTRB(126, 124, 138, 136)),
    MapArea(name: 'Nimbasa City', rect: Rect.fromLTRB(126, 85, 138, 97)),
    MapArea(name: 'Driftveil City', rect: Rect.fromLTRB(68, 85, 80, 97)),
    MapArea(name: 'Mistralton City', rect: Rect.fromLTRB(34, 61, 46, 73)),
    MapArea(name: 'Icirrus City', rect: Rect.fromLTRB(68, 37, 80, 49)),
    MapArea(name: 'Opelucid City', rect: Rect.fromLTRB(126, 37, 138, 49)),
    MapArea(name: 'Pokémon League', rect: Rect.fromLTRB(164, 9, 176, 21)),
    MapArea(name: 'Lacunosa Town', rect: Rect.fromLTRB(184, 37, 196, 49)),
    MapArea(name: 'Undella Town', rect: Rect.fromLTRB(218, 61, 230, 73)),
    MapArea(name: 'Black City', rect: Rect.fromLTRB(184, 85, 190, 97)),
    MapArea(name: 'White Forest', rect: Rect.fromLTRB(190, 85, 196, 97)),
    MapArea(name: 'Aspertia City', rect: Rect.fromLTRB(8, 147, 20, 161)),
    MapArea(name: 'Floccesy Town', rect: Rect.fromLTRB(26, 121, 39, 135)),
    MapArea(name: 'Virbank City', rect: Rect.fromLTRB(63, 121, 76, 135)),

    MapArea(name: 'Pokéwood (PokéStar Studios)', rect: Rect.fromLTRB(60, 111, 68, 121)),
    MapArea(name: 'Floccesy Ranch', rect: Rect.fromLTRB(38, 115, 44, 121)),
    MapArea(name: 'Cave of Being', rect: Rect.fromLTRB(38, 135, 44, 143)),
    MapArea(name: 'Virbank Complex', rect: Rect.fromLTRB(61, 135, 67, 143)),
    MapArea(name: 'Castelia Sewers', rect: Rect.fromLTRB(153, 140, 159, 148)),
    MapArea(name: 'P2 Laboratory', rect: Rect.fromLTRB(211, 148, 217, 156)),
    MapArea(name: 'Relic Passage', rect: Rect.fromLTRB(102, 115, 108, 123)),
    MapArea(name: 'PWT', rect: Rect.fromLTRB(73, 99, 81, 109)),
    MapArea(name: 'Clay Tunnel', rect: Rect.fromLTRB(69, 74, 81, 109)),
    MapArea(name: 'Lentimas Town', rect: Rect.fromLTRB(181, 61, 193, 75)),
    MapArea(name: 'Strange House', rect: Rect.fromLTRB(195, 56, 201, 64)),
    MapArea(name: 'Reversal Mountain', rect: Rect.fromLTRB(203, 64, 209, 72)),
    MapArea(name: 'Seaside Cave', rect: Rect.fromLTRB(232, 50, 238, 56)),
    MapArea(name: 'Humilau City', rect: Rect.fromLTRB(229, 30, 241, 41)),
    MapArea(name: "N's Castle", rect: Rect.fromLTRB(179, 3, 185, 11)),
    MapArea(name: 'Victory Road (B2W2)', rect: Rect.fromLTRB(180, 12, 188, 21)),

    MapArea(name: 'Dreamyard', rect: Rect.fromLTRB(236, 115, 242, 121)),
    MapArea(name: 'Wellspring Cave', rect: Rect.fromLTRB(212, 107, 218, 113)),
    MapArea(name: 'Pinwheel Forest', rect: Rect.fromLTRB(191, 122, 197, 128)),
    MapArea(name: 'Relic Castle', rect: Rect.fromLTRB(112, 101, 118, 107)),
    MapArea(name: 'Mistralton Cave', rect: Rect.fromLTRB(66, 71, 72, 77)),
    MapArea(name: 'Chargestone Cave', rect: Rect.fromLTRB(39, 77, 45, 83)),
    MapArea(name: 'Celestial Tower', rect: Rect.fromLTRB(51, 47, 57, 53)),
    MapArea(name: 'Twist Mountain', rect: Rect.fromLTRB(69, 52, 75, 58)),
    MapArea(name: 'Dragonspiral Tower', rect: Rect.fromLTRB(63, 28, 69, 34)),
    MapArea(name: 'Moor of Icirrus', rect: Rect.fromLTRB(85, 33, 91, 39)),
    MapArea(name: 'Anville Town', rect: Rect.fromLTRB(4, 27, 10, 33)),
    MapArea(name: "Challenger's Cave", rect: Rect.fromLTRB(114, 46, 120, 52)),
    MapArea(name: 'Victory Road', rect: Rect.fromLTRB(159, 20, 167, 28)),
    MapArea(name: 'Giant Chasm', rect: Rect.fromLTRB(205, 33, 211, 41)),
    MapArea(name: 'Undella Bay', rect: Rect.fromLTRB(239, 60, 245, 68)),
    MapArea(name: 'Abundant Shrine', rect: Rect.fromLTRB(194, 74, 200, 80)),
    MapArea(name: 'Lostlorn Forest', rect: Rect.fromLTRB(143, 81, 149, 87)),
    MapArea(name: 'EntraLink', rect: Rect.fromLTRB(129, 64, 135, 70)),
    MapArea(name: 'Liberty Island', rect: Rect.fromLTRB(71, 142, 77, 148)),
    MapArea(name: 'Unity Tower', rect: Rect.fromLTRB(95, 153, 103, 161)),
  ];
}

