import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Hoenn.
class HoennMapAreas {
  static const String mapImagePath = 'assets/images/maps/hoenn.png';
  static const double imageWidth = 306.0;
  static const double imageHeight = 221.0;

  static List<MapArea> get areas => [
    // Pueblos / Ciudades
    MapArea(name: 'Littleroot Town', rect: Rect.fromLTRB(57, 147, 65, 155), identifier: 'littleroot-town'),
    MapArea(name: 'Oldale Town', rect: Rect.fromLTRB(57, 122, 65, 129), identifier: 'oldale-town'),
    MapArea(name: 'Petalburg City', rect: Rect.fromLTRB(30, 122, 45, 130), identifier: 'petalburg-city'),
    MapArea(name: 'Rustboro City', rect: Rect.fromLTRB(11, 82, 26, 90), identifier: 'rustboro-city'),
    // segunda área superpuesta para Rustboro (aparece también en el HTML)
    MapArea(name: 'Rustboro City', rect: Rect.fromLTRB(11, 82, 19, 97), identifier: 'rustboro-city-alt'),
    MapArea(name: 'Dewford Town', rect: Rect.fromLTRB(38, 185, 46, 193), identifier: 'dewford-town'),
    MapArea(name: 'Slateport City', rect: Rect.fromLTRB(85, 140, 100, 155), identifier: 'slateport-city'),
    MapArea(name: 'Mauville City', rect: Rect.fromLTRB(85, 89, 99, 96), identifier: 'mauville-city'),
    // segunda área superpuesta para Mauville
    MapArea(name: 'Mauville City', rect: Rect.fromLTRB(85, 89, 93, 104), identifier: 'mauville-city-alt'),
    MapArea(name: 'Verdanturf Town', rect: Rect.fromLTRB(57, 89, 65, 97), identifier: 'verdanturf-town'),
    MapArea(name: 'Lavaridge Town', rect: Rect.fromLTRB(64, 64, 72, 72), identifier: 'lavaridge-town'),
    MapArea(name: 'Fallarbor Town', rect: Rect.fromLTRB(44, 43, 59, 51), identifier: 'fallarbor-town'),
    MapArea(name: 'Fortree City', rect: Rect.fromLTRB(109, 43, 117, 51), identifier: 'fortree-city'),
    MapArea(name: 'Lilycove City', rect: Rect.fromLTRB(156, 61, 171, 76), identifier: 'lilycove-city'),
    MapArea(name: 'Pacifidlog Town', rect: Rect.fromLTRB(172, 147, 180, 155), identifier: 'pacifidlog-town'),
    MapArea(name: 'Sootopolis City', rect: Rect.fromLTRB(199, 109, 207, 117), identifier: 'sootopolis-city'),
    MapArea(name: 'Mossdeep City', rect: Rect.fromLTRB(227, 79, 242, 87), identifier: 'mossdeep-city'),
    MapArea(name: 'Evergrande City', rect: Rect.fromLTRB(268, 130, 276, 144), identifier: 'evergrande-city'),
    MapArea(name: 'Battle Frontier', rect: Rect.fromLTRB(221, 174, 237, 191), identifier: 'battle-frontier'),
    MapArea(name: 'Southern Island', rect: Rect.fromLTRB(268, 196, 280, 208), identifier: 'southern-island'),

    // Rutas
    MapArea(name: 'Route 101', rect: Rect.fromLTRB(57, 130, 65, 147), identifier: 'hoenn-route-101'),
    MapArea(name: 'Route 102', rect: Rect.fromLTRB(45, 122, 57, 130), identifier: 'hoenn-route-102'),
    MapArea(name: 'Route 103', rect: Rect.fromLTRB(57, 115, 85, 123), identifier: 'hoenn-route-103'),
    MapArea(name: 'Route 104', rect: Rect.fromLTRB(11, 122, 29, 129), identifier: 'hoenn-route-104'),
    // entry adicional repetido en el HTML
    MapArea(name: 'Route 104', rect: Rect.fromLTRB(11, 122, 19, 97), identifier: 'hoenn-route-104-alt'),
    MapArea(name: 'Route 105', rect: Rect.fromLTRB(11, 129, 19, 177), identifier: 'hoenn-route-105'),
    MapArea(name: 'Route 106', rect: Rect.fromLTRB(11, 177, 46, 185), identifier: 'hoenn-route-106'),
    MapArea(name: 'Route 107', rect: Rect.fromLTRB(46, 186, 61, 192), identifier: 'hoenn-route-107'),
    MapArea(name: 'Route 108', rect: Rect.fromLTRB(61, 186, 85, 192), identifier: 'hoenn-route-108'),
    MapArea(name: 'Route 109', rect: Rect.fromLTRB(85, 155, 93, 193), identifier: 'hoenn-route-109'),
    MapArea(name: 'Route 110', rect: Rect.fromLTRB(85, 104, 93, 140), identifier: 'hoenn-route-110'),
    MapArea(name: 'Route 111', rect: Rect.fromLTRB(85, 43, 93, 89), identifier: 'hoenn-route-111'),
    MapArea(name: 'Route 112', rect: Rect.fromLTRB(72, 64, 85, 72), identifier: 'hoenn-route-112'),
    MapArea(name: 'Route 113', rect: Rect.fromLTRB(59, 43, 85, 51), identifier: 'hoenn-route-113'),
    MapArea(name: 'Route 114', rect: Rect.fromLTRB(27, 43, 44, 51), identifier: 'hoenn-route-114'),
    // entrada adicional para Route 114 (área mayor)
    MapArea(name: 'Route 114', rect: Rect.fromLTRB(27, 43, 35, 63), identifier: 'hoenn-route-114-alt'),
    MapArea(name: 'Meteor Falls', rect: Rect.fromLTRB(18, 55, 27, 63), identifier: 'meteor-falls'),
    MapArea(name: 'Route 115', rect: Rect.fromLTRB(11, 55, 19, 82), identifier: 'hoenn-route-115'),
    MapArea(name: 'Route 116', rect: Rect.fromLTRB(26, 82, 65, 90), identifier: 'hoenn-route-116'),
    MapArea(name: 'Route 117', rect: Rect.fromLTRB(65, 89, 85, 97), identifier: 'hoenn-route-117'),
    MapArea(name: 'Route 118', rect: Rect.fromLTRB(99, 89, 112, 97), identifier: 'hoenn-route-118'),
    MapArea(name: 'Route 119', rect: Rect.fromLTRB(100, 43, 108, 89), identifier: 'hoenn-route-119'),
    MapArea(name: 'Route 120', rect: Rect.fromLTRB(118, 43, 125, 69), identifier: 'hoenn-route-120'),
    MapArea(name: 'Route 121', rect: Rect.fromLTRB(126, 61, 156, 70), identifier: 'hoenn-route-121'),
    MapArea(name: 'Route 122', rect: Rect.fromLTRB(142, 69, 149, 89), identifier: 'hoenn-route-122'),
    MapArea(name: 'Route 123', rect: Rect.fromLTRB(112, 89, 150, 97), identifier: 'hoenn-route-123'),
    MapArea(name: 'Route 124', rect: Rect.fromLTRB(171, 61, 227, 69), identifier: 'hoenn-route-124'),
    // segunda área para Route 124 en HTML
    MapArea(name: 'Route 124', rect: Rect.fromLTRB(183, 69, 227, 86), identifier: 'hoenn-route-124-alt'),
    MapArea(name: 'Route 125', rect: Rect.fromLTRB(227, 61, 242, 79), identifier: 'hoenn-route-125'),
    MapArea(name: 'Route 126', rect: Rect.fromLTRB(183, 86, 223, 134), identifier: 'hoenn-route-126'),
    MapArea(name: 'Route 127', rect: Rect.fromLTRB(223, 86, 241, 136), identifier: 'hoenn-route-127'),
    MapArea(name: 'Route 128', rect: Rect.fromLTRB(223, 136, 268, 144), identifier: 'hoenn-route-128'),
    MapArea(name: 'Route 129', rect: Rect.fromLTRB(222, 144, 242, 155), identifier: 'hoenn-route-129'),
    MapArea(name: 'Route 130', rect: Rect.fromLTRB(204, 147, 222, 155), identifier: 'hoenn-route-130'),
    MapArea(name: 'Route 131', rect: Rect.fromLTRB(180, 147, 204, 155), identifier: 'hoenn-route-131'),
    MapArea(name: 'Route 132', rect: Rect.fromLTRB(153, 147, 172, 155), identifier: 'hoenn-route-132'),
    MapArea(name: 'Route 133', rect: Rect.fromLTRB(131, 147, 153, 155), identifier: 'hoenn-route-133'),
    MapArea(name: 'Route 134', rect: Rect.fromLTRB(100, 147, 131, 155), identifier: 'hoenn-route-134'),
  ];
}
