import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Hoenn.
class HoennMapAreas {
  static const String mapImagePath = 'assets/images/maps/hoenn.png';
  static const double imageWidth = 306.0;
  static const double imageHeight = 221.0;

  static List<MapArea> get areas => [
    // Towns / Cities
    MapArea(name: 'Littleroot Town', rect: Rect.fromLTRB(57, 147, 65, 155)),
    MapArea(name: 'Oldale Town', rect: Rect.fromLTRB(57, 122, 65, 129)),
    MapArea(name: 'Petalburg City', rect: Rect.fromLTRB(30, 122, 45, 130)),
    MapArea(name: 'Rustboro City', rect: Rect.fromLTRB(11, 82, 26, 90)),
    // segunda área superpuesta para Rustboro (aparece también en el HTML)
    MapArea(name: 'Rustboro City', rect: Rect.fromLTRB(11, 82, 19, 97)),
    MapArea(name: 'Dewford Town', rect: Rect.fromLTRB(38, 185, 46, 193)),
    MapArea(name: 'Slateport City', rect: Rect.fromLTRB(85, 140, 100, 155)),
    MapArea(name: 'Mauville City', rect: Rect.fromLTRB(85, 89, 99, 96)),
    // segunda área superpuesta para Mauville
    MapArea(name: 'Mauville City', rect: Rect.fromLTRB(85, 89, 93, 104)),
    MapArea(name: 'Verdanturf Town', rect: Rect.fromLTRB(57, 89, 65, 97)),
    MapArea(name: 'Lavaridge Town', rect: Rect.fromLTRB(64, 64, 72, 72)),
    MapArea(name: 'Fallarbor Town', rect: Rect.fromLTRB(44, 43, 59, 51)),
    MapArea(name: 'Fortree City', rect: Rect.fromLTRB(109, 43, 117, 51)),
    MapArea(name: 'Lilycove City', rect: Rect.fromLTRB(156, 61, 171, 76)),
    MapArea(name: 'Pacifidlog Town', rect: Rect.fromLTRB(172, 147, 180, 155)),
    MapArea(name: 'Sootopolis City', rect: Rect.fromLTRB(199, 109, 207, 117)),
    MapArea(name: 'Mossdeep City', rect: Rect.fromLTRB(227, 79, 242, 87)),
    MapArea(name: 'Evergrande City', rect: Rect.fromLTRB(268, 130, 276, 144)),
    MapArea(name: 'Battle Frontier', rect: Rect.fromLTRB(221, 174, 237, 191)),
    MapArea(name: 'Southern Island', rect: Rect.fromLTRB(268, 196, 280, 208)),

    // Routes
    MapArea(name: 'Route 101', rect: Rect.fromLTRB(57, 130, 65, 147)),
    MapArea(name: 'Route 102', rect: Rect.fromLTRB(45, 122, 57, 130)),
    MapArea(name: 'Route 103', rect: Rect.fromLTRB(57, 115, 85, 123)),
    MapArea(name: 'Route 104', rect: Rect.fromLTRB(11, 122, 29, 129)),
    // entry adicional repetido en el HTML
    MapArea(name: 'Route 104', rect: Rect.fromLTRB(11, 122, 19, 97)),
    MapArea(name: 'Route 105', rect: Rect.fromLTRB(11, 129, 19, 177)),
    MapArea(name: 'Route 106', rect: Rect.fromLTRB(11, 177, 46, 185)),
    MapArea(name: 'Route 107', rect: Rect.fromLTRB(46, 186, 61, 192)),
    MapArea(name: 'Route 108', rect: Rect.fromLTRB(61, 186, 85, 192)),
    MapArea(name: 'Route 109', rect: Rect.fromLTRB(85, 155, 93, 193)),
    MapArea(name: 'Route 110', rect: Rect.fromLTRB(85, 104, 93, 140)),
    MapArea(name: 'Route 111', rect: Rect.fromLTRB(85, 43, 93, 89)),
    MapArea(name: 'Route 112', rect: Rect.fromLTRB(72, 64, 85, 72)),
    MapArea(name: 'Route 113', rect: Rect.fromLTRB(59, 43, 85, 51)),
    MapArea(name: 'Route 114', rect: Rect.fromLTRB(27, 43, 44, 51)),
    // entrada adicional para Route 114 (área mayor)
    MapArea(name: 'Route 114', rect: Rect.fromLTRB(27, 43, 35, 63)),
    MapArea(name: 'Meteor Falls', rect: Rect.fromLTRB(18, 55, 27, 63)),
    MapArea(name: 'Route 115', rect: Rect.fromLTRB(11, 55, 19, 82)),
    MapArea(name: 'Route 116', rect: Rect.fromLTRB(26, 82, 65, 90)),
    MapArea(name: 'Route 117', rect: Rect.fromLTRB(65, 89, 85, 97)),
    MapArea(name: 'Route 118', rect: Rect.fromLTRB(99, 89, 112, 97)),
    MapArea(name: 'Route 119', rect: Rect.fromLTRB(100, 43, 108, 89)),
    MapArea(name: 'Route 120', rect: Rect.fromLTRB(118, 43, 125, 69)),
    MapArea(name: 'Route 121', rect: Rect.fromLTRB(126, 61, 156, 70)),
    MapArea(name: 'Route 122', rect: Rect.fromLTRB(142, 69, 149, 89)),
    MapArea(name: 'Route 123', rect: Rect.fromLTRB(112, 89, 150, 97)),
    MapArea(name: 'Route 124', rect: Rect.fromLTRB(171, 61, 227, 69)),
    // segunda área para Route 124 en HTML
    MapArea(name: 'Route 124', rect: Rect.fromLTRB(183, 69, 227, 86)),
    MapArea(name: 'Route 125', rect: Rect.fromLTRB(227, 61, 242, 79)),
    MapArea(name: 'Route 126', rect: Rect.fromLTRB(183, 86, 223, 134)),
    MapArea(name: 'Route 127', rect: Rect.fromLTRB(223, 86, 241, 136)),
    MapArea(name: 'Route 128', rect: Rect.fromLTRB(223, 136, 268, 144)),
    MapArea(name: 'Route 129', rect: Rect.fromLTRB(222, 144, 242, 155)),
    MapArea(name: 'Route 130', rect: Rect.fromLTRB(204, 147, 222, 155)),
    MapArea(name: 'Route 131', rect: Rect.fromLTRB(180, 147, 204, 155)),
    MapArea(name: 'Route 132', rect: Rect.fromLTRB(153, 147, 172, 155)),
    MapArea(name: 'Route 133', rect: Rect.fromLTRB(131, 147, 153, 155)),
    MapArea(name: 'Route 134', rect: Rect.fromLTRB(100, 147, 131, 155)),
  ];
}

