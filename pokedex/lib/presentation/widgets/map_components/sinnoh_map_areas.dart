import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Sinnoh.
class SinnohMapAreas {
  static const String mapImagePath = 'assets/images/maps/sinnoh.png';
  static const double imageWidth = 216.0;
  static const double imageHeight = 168.0;

  static List<MapArea> get areas => [
    // Towns / Key locations
    MapArea(name: 'Twinleaf Town', rect: Rect.fromLTRB(22, 150, 30, 158)),
    MapArea(name: 'Lake Verity', rect: Rect.fromLTRB(8, 136, 23, 151)),
    MapArea(name: 'Sandgem Town', rect: Rect.fromLTRB(36, 143, 44, 151)),
    MapArea(name: 'Jubilife City', rect: Rect.fromLTRB(29, 122, 44, 137)),
    MapArea(name: 'Canalave City', rect: Rect.fromLTRB(8, 115, 16, 130)),
    MapArea(name: 'Iron Island', rect: Rect.fromLTRB(22, 66, 30, 74)),
    MapArea(name: 'Full Moon Island', rect: Rect.fromLTRB(16, 17, 24, 25)),
    MapArea(name: 'New Moon Island', rect: Rect.fromLTRB(29, 17, 37, 25)),
    MapArea(name: 'Floaroma Town', rect: Rect.fromLTRB(36, 94, 44, 109)),
    MapArea(name: 'Eterna City', rect: Rect.fromLTRB(64, 73, 79, 81)),
    // segunda area para Eterna City (según HTML)
    MapArea(name: 'Eterna City', rect: Rect.fromLTRB(64, 73, 72, 88)),
    MapArea(name: 'Oreburgh City', rect: Rect.fromLTRB(57, 122, 72, 130)),
    // otra entrada para Oreburgh (superpuesta en HTML)
    MapArea(name: 'Oreburgh City', rect: Rect.fromLTRB(64, 136, 72, 122)),
    MapArea(name: 'Pal Park', rect: Rect.fromLTRB(64, 158, 72, 164)),
    MapArea(name: 'Snowpoint City', rect: Rect.fromLTRB(78, 3, 86, 18)),
    MapArea(name: 'Lake Acuity', rect: Rect.fromLTRB(64, 6, 76, 18)),
    MapArea(name: 'Acuity Lakefront', rect: Rect.fromLTRB(64, 3, 77, 18)),
    MapArea(name: 'Celestic Town', rect: Rect.fromLTRB(100, 73, 108, 81)),
    MapArea(name: 'Hearthome City', rect: Rect.fromLTRB(99, 108, 114, 123)),
    MapArea(name: 'Solaceon Town', rect: Rect.fromLTRB(120, 101, 135, 109)),
    MapArea(name: 'Veilstone City', rect: Rect.fromLTRB(148, 87, 163, 102)),
    MapArea(name: 'Sendoff Spring', rect: Rect.fromLTRB(162, 108, 177, 118)),
    MapArea(name: 'Spring Path', rect: Rect.fromLTRB(162, 118, 177, 123)),
    MapArea(name: 'Lake Valor', rect: Rect.fromLTRB(148, 122, 159, 136)),
    MapArea(name: 'Valor Lakefront', rect: Rect.fromLTRB(159, 122, 163, 136)),
    MapArea(name: 'Sunyshore City', rect: Rect.fromLTRB(183, 122, 198, 137)),
    MapArea(name: 'Victory Road', rect: Rect.fromLTRB(183, 88, 191, 94)),
    MapArea(name: 'Pokémon League', rect: Rect.fromLTRB(183, 80, 191, 88)),
    MapArea(name: 'Fight Area', rect: Rect.fromLTRB(134, 52, 149, 60)),
    MapArea(name: 'Survival Area', rect: Rect.fromLTRB(141, 31, 149, 39)),
    MapArea(name: 'Resort Area', rect: Rect.fromLTRB(22, 150, 30, 158)),
    MapArea(name: 'Battle Tower / Battle Park', rect: Rect.fromLTRB(141, 45, 149, 52)),
    MapArea(name: 'Battle Frontier', rect: Rect.fromLTRB(145, 45, 149, 52)),
    MapArea(name: 'Mt. Coronet', rect: Rect.fromLTRB(85, 45, 93, 102)),
    MapArea(name: 'Mt. Coronet (lower)', rect: Rect.fromLTRB(78, 94, 86, 123)),
    MapArea(name: 'Valley Windworks', rect: Rect.fromLTRB(50, 101, 58, 109)),
    MapArea(name: 'Fuego Ironworks', rect: Rect.fromLTRB(36, 87, 44, 95)),
    MapArea(name: 'Eterna Forest', rect: Rect.fromLTRB(43, 73, 58, 88)),
    MapArea(name: 'Seabreak Path', rect: Rect.fromLTRB(197, 10, 205, 68)),
    MapArea(name: 'Flower Paradise', rect: Rect.fromLTRB(197, 2, 205, 10)),
    MapArea(name: 'Stark Mountain', rect: Rect.fromLTRB(162, 10, 170, 16)),

    // Routes
    MapArea(name: 'Route 201', rect: Rect.fromLTRB(23, 143, 36, 151)),
    MapArea(name: 'Route 202', rect: Rect.fromLTRB(36, 137, 44, 143)),
    MapArea(name: 'Route 203', rect: Rect.fromLTRB(44, 122, 57, 130)),
    MapArea(name: 'Route 204', rect: Rect.fromLTRB(36, 109, 44, 122)),
    MapArea(name: 'Route 205', rect: Rect.fromLTRB(44, 87, 52, 109)),
    MapArea(name: 'Route 205 (north)', rect: Rect.fromLTRB(57, 73, 64, 81)),
    MapArea(name: 'Route 206', rect: Rect.fromLTRB(64, 88, 72, 115)),
    MapArea(name: 'Route 207', rect: Rect.fromLTRB(64, 115, 79, 123)),
    MapArea(name: 'Route 208', rect: Rect.fromLTRB(85, 115, 99, 123)),
    MapArea(name: 'Route 209', rect: Rect.fromLTRB(114, 115, 128, 123)),
    // entry adicional para Route 209
    MapArea(name: 'Route 209 (alt)', rect: Rect.fromLTRB(120, 109, 128, 123)),
    MapArea(name: 'Route 210', rect: Rect.fromLTRB(120, 73, 128, 101)),
    MapArea(name: 'Route 210 (alt)', rect: Rect.fromLTRB(108, 73, 128, 81)),
    MapArea(name: 'Route 211', rect: Rect.fromLTRB(79, 73, 101, 81)),
    MapArea(name: 'Route 212', rect: Rect.fromLTRB(99, 123, 107, 151)),
    // otra área para Route 212
    MapArea(name: 'Route 212 (alt)', rect: Rect.fromLTRB(99, 143, 127, 151)),
    MapArea(name: 'Route 213', rect: Rect.fromLTRB(142, 136, 163, 151)),
    MapArea(name: 'Route 214', rect: Rect.fromLTRB(155, 102, 163, 123)),
    MapArea(name: 'Route 215', rect: Rect.fromLTRB(127, 87, 148, 95)),
    MapArea(name: 'Route 216', rect: Rect.fromLTRB(64, 45, 86, 53)),
    MapArea(name: 'Route 217', rect: Rect.fromLTRB(64, 17, 72, 45)),
    MapArea(name: 'Route 218', rect: Rect.fromLTRB(16, 122, 29, 130)),
    MapArea(name: 'Route 219', rect: Rect.fromLTRB(36, 151, 44, 158)),
    MapArea(name: 'Route 220', rect: Rect.fromLTRB(36, 157, 52, 165)),
    MapArea(name: 'Route 221', rect: Rect.fromLTRB(52, 157, 72, 165)),
    MapArea(name: 'Route 222', rect: Rect.fromLTRB(162, 129, 183, 137)),
    MapArea(name: 'Route 223', rect: Rect.fromLTRB(183, 94, 191, 122)),
    MapArea(name: 'Route 224', rect: Rect.fromLTRB(190, 73, 198, 88)),
    // otra area para Route 224
    MapArea(name: 'Route 224 (alt)', rect: Rect.fromLTRB(197, 68, 205, 81)),
    MapArea(name: 'Route 225', rect: Rect.fromLTRB(134, 31, 142, 52)),
    MapArea(name: 'Route 226', rect: Rect.fromLTRB(149, 31, 170, 39)),
    MapArea(name: 'Route 227', rect: Rect.fromLTRB(162, 16, 170, 32)),
    MapArea(name: 'Route 228', rect: Rect.fromLTRB(169, 31, 177, 53)),
    MapArea(name: 'Route 229', rect: Rect.fromLTRB(169, 52, 184, 60)),
    MapArea(name: 'Route 230', rect: Rect.fromLTRB(149, 52, 169, 60)),
  ];
}

