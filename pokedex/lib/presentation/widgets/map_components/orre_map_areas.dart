import 'dart:ui';
import 'interactive_map_widget.dart';

/// Definiciones de áreas clicables para el mapa de Orre.
class OrreMapAreas {
  static const String mapImagePath = 'assets/images/maps/orre.png';
  // Tamaño estimado de la imagen según el HTML (width/height)
  static const double imageWidth = 216.0;
  static const double imageHeight = 168.0;

  static List<MapArea> get areas => [
    // Puntos extraídos del mapa HTML (coords -> Rect.fromLTRB)
    MapArea(name: 'Pokémon HQ Laboratory', rect: Rect.fromLTRB(19, 67, 27, 74), identifier: 'pokemon-hq-laboratory'),
    MapArea(name: 'Gateon Port', rect: Rect.fromLTRB(25, 102, 40, 116), identifier: 'gateon-port'),
    MapArea(name: 'Citadark Isle', rect: Rect.fromLTRB(7, 151, 15, 159), identifier: 'citadark-isle'),
    MapArea(name: 'Agate Village', rect: Rect.fromLTRB(66, 66, 74, 82), identifier: 'agate-village'),
    MapArea(name: "Kaminko's Laboratory", rect: Rect.fromLTRB(52, 96, 60, 104), identifier: 'orre-kaminkos-laboratory'),
    MapArea(name: 'Orre Colosseum', rect: Rect.fromLTRB(57, 122, 65, 130), identifier: 'orre-orre-colosseum'),
    MapArea(name: 'Oasis PokéSpot', rect: Rect.fromLTRB(73, 90, 81, 96), identifier: 'orre-oasis-pokespot'),
    MapArea(name: 'Pyrite City', rect: Rect.fromLTRB(78, 124, 93, 139), identifier: 'pyrite-city'),
    MapArea(name: 'Mt. Battle', rect: Rect.fromLTRB(98, 55, 106, 63), identifier: 'mt-battle'),
    MapArea(name: 'Cave PokéSpot', rect: Rect.fromLTRB(114, 70, 122, 76), identifier: 'orre-cave-pokespot'),
    MapArea(name: 'Cipher Lab', rect: Rect.fromLTRB(117, 90, 125, 98), identifier: 'orre-cipher-lab'),
    MapArea(name: 'Realgam Tower', rect: Rect.fromLTRB(118, 110, 126, 118), identifier: 'orre-realgam-tower'),
    MapArea(name: 'Cipher Key Lair', rect: Rect.fromLTRB(130, 34, 138, 42), identifier: 'orre-cipher-key-lair'),
    MapArea(name: 'S.S. Libra', rect: Rect.fromLTRB(151, 74, 159, 82), identifier: 'orre-ss-libra'),
    MapArea(name: 'Rock/Ground PokéSpot', rect: Rect.fromLTRB(180, 79, 188, 85), identifier: 'orre-rock-ground-pokespot'),
    // Phenac City aparece con dos rects en el HTML; usamos uno que cubre ambos
    MapArea(name: 'Phenac City', rect: Rect.fromLTRB(144, 109, 159, 124), identifier: 'phenac-city'),
    MapArea(name: 'Outskirt Stand', rect: Rect.fromLTRB(177, 104, 185, 112), identifier: 'orre-outskirt-stand'),
    MapArea(name: 'Snagem Hideout', rect: Rect.fromLTRB(179, 52, 187, 60), identifier: 'orre-snagem-hideout'),

    // entradas duplicadas/artísticas del HTML (mantener referencia)
    MapArea(name: 'Pokémon HQ Laboratory (alt)', rect: Rect.fromLTRB(19, 67, 27, 74), identifier: 'pokemon-hq-laboratory-alt'),
  ];
}
