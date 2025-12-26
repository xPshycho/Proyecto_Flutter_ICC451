import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Oblivia.
class ObliviaMapAreas {
  static const String mapImagePath = 'assets/images/maps/oblivia.png';
  // Tamaño aproximado de la imagen según los coords del HTML
  static const double imageWidth = 270.0;
  static const double imageHeight = 245.0;

  static List<MapArea> get areas => [
    // Dolce Island
    MapArea(name: 'Dolce Island - Southern Beach', rect: Rect.fromLTRB(61, 238, 69, 245), identifier: 'oblivia-dolce-southern-beach'),
    MapArea(name: 'Dolce Island - Hill', rect: Rect.fromLTRB(61, 230, 69, 236), identifier: 'oblivia-dolce-hill'),
    MapArea(name: 'Dolce Island - Eastern Beach', rect: Rect.fromLTRB(69, 230, 77, 236), identifier: 'oblivia-dolce-eastern-beach'),

    // Renbow Island
    MapArea(name: 'Renbow Island - Cocona Village', rect: Rect.fromLTRB(93, 189, 102, 205), identifier: 'oblivia-renbow-cocona-village'),
    MapArea(name: 'Renbow Island - Teakwood Forest', rect: Rect.fromLTRB(61, 189, 93, 197), identifier: 'oblivia-renbow-teakwood-forest'),
    MapArea(name: 'Renbow Island - Rasp Cavern', rect: Rect.fromLTRB(61, 181, 69, 189), identifier: 'oblivia-renbow-rasp-cavern'),
    MapArea(name: 'Renbow Island - Lapras Beach', rect: Rect.fromLTRB(100, 197, 133, 205), identifier: 'oblivia-renbow-lapras-beach'),
    MapArea(name: 'Renbow Island - Curl Bay', rect: Rect.fromLTRB(125, 181, 133, 197), identifier: 'oblivia-renbow-curl-bay'),
    MapArea(name: "Renbow Island - Rand's House", rect: Rect.fromLTRB(125, 173, 133, 181), identifier: 'oblivia-renbow-rands-house'),
    // Latolato Trail (varias entradas -> usar un rect que cubre ambas)
    MapArea(name: 'Renbow Island - Latolato Trail', rect: Rect.fromLTRB(109, 156, 125, 181), identifier: 'oblivia-renbow-latolato-trail'),
    MapArea(name: 'Renbow Island - Mt. Latolato', rect: Rect.fromLTRB(77, 149, 117, 157), identifier: 'oblivia-renbow-mt-latolato'),
    MapArea(name: 'Renbow Island - Wireless Tower', rect: Rect.fromLTRB(69, 149, 77, 157), identifier: 'oblivia-renbow-wireless-tower'),
    // Hinder Cape (varias entradas -> combinar)
    MapArea(name: 'Renbow Island - Hinder Cape', rect: Rect.fromLTRB(117, 141, 133, 165), identifier: 'oblivia-renbow-hinder-cape'),
    MapArea(name: 'Renbow Island - Big Booker Bridge', rect: Rect.fromLTRB(133, 141, 197, 149), identifier: 'oblivia-renbow-big-booker-bridge'),
    MapArea(name: 'Offshore Renbow Island - Coral Sea', rect: Rect.fromLTRB(109, 205, 117, 221), identifier: 'oblivia-renbow-coral-sea'),

    // Mitonga Island
    MapArea(name: 'Mitonga Island - Tilt Village', rect: Rect.fromLTRB(197, 141, 205, 149), identifier: 'oblivia-mitonga-tilt-village'),
    // Mitonga Road (varias entradas -> combinar en un rect amplio)
    MapArea(name: 'Mitonga Island - Mitonga Road', rect: Rect.fromLTRB(205, 117, 245, 149), identifier: 'oblivia-mitonga-road'),
    MapArea(name: 'Mitonga Island - Noir Forest', rect: Rect.fromLTRB(213, 109, 221, 117), identifier: 'oblivia-mitonga-noir-forest'),
    MapArea(name: 'Mitonga Island - Old Mansion', rect: Rect.fromLTRB(205, 109, 213, 125), identifier: 'oblivia-mitonga-old-mansion'),
    MapArea(name: 'Mitonga Island - Daybreak Ruins', rect: Rect.fromLTRB(229, 135, 237, 143), identifier: 'oblivia-mitonga-daybreak-ruins'),
    MapArea(name: 'Mitonga Island - Dangerous Cliff', rect: Rect.fromLTRB(213, 141, 269, 149), identifier: 'oblivia-mitonga-dangerous-cliff'),

    // Faldera Island
    MapArea(name: 'Faldera Island - Faldera Volcano', rect: Rect.fromLTRB(200, 207, 208, 215), identifier: 'oblivia-faldera-volcano'),

    // Sophian Island
    MapArea(name: 'Sophian Island - Aqua Resort', rect: Rect.fromLTRB(165, 69, 173, 77), identifier: 'oblivia-sophian-aqua-resort'),
    // Sophian Road (varias entradas -> combinar)
    MapArea(name: 'Sophian Island - Sophian Road', rect: Rect.fromLTRB(117, 45, 173, 77), identifier: 'oblivia-sophian-road'),
    MapArea(name: 'Sophian Island - Canal Ruins', rect: Rect.fromLTRB(125, 77, 133, 85), identifier: 'oblivia-sophian-canal-ruins'),
    MapArea(name: 'Sophian Island - Mt. Sorbet', rect: Rect.fromLTRB(165, 37, 173, 45), identifier: 'oblivia-sophian-mt-sorbet'),
    MapArea(name: 'Sophian Island - Silver Falls', rect: Rect.fromLTRB(109, 52, 117, 77), identifier: 'oblivia-sophian-silver-falls'),
    MapArea(name: 'Sophian Island - Oblivia Ruins', rect: Rect.fromLTRB(109, 45, 117, 53), identifier: 'oblivia-sophian-oblivia-ruins'),

    // Tilikule / Layuda / other small islands
    MapArea(name: 'Tilikule Island - Tilikule Monument', rect: Rect.fromLTRB(41, 64, 49, 72), identifier: 'oblivia-tilikule-monument'),
    MapArea(name: 'Layuda Island - Mt. Layuda', rect: Rect.fromLTRB(37, 98, 45, 106), identifier: 'oblivia-layuda-mt-layuda'),

    // Eastern / Western Seas
    MapArea(name: 'Eastern Sea - Undersea Cavern', rect: Rect.fromLTRB(251, 45, 259, 53), identifier: 'oblivia-eastern-undersea-cavern'),
    MapArea(name: 'Western Sea - Rainbow Dais', rect: Rect.fromLTRB(5, 157, 13, 165), identifier: 'oblivia-western-rainbow-dais'),

    // Región general
    MapArea(name: 'Oblivia Region - Sky Fortress', rect: Rect.fromLTRB(131, 114, 139, 122), identifier: 'oblivia-sky-fortress'),
  ];
}
