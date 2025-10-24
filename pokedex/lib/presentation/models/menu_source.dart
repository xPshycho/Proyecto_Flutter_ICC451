// dart

enum MenuSource { pokedexNacional, regional, tipos }

String titleForSource(MenuSource source) {
  switch (source) {
    case MenuSource.pokedexNacional:
      return 'Pokedex Nacional';
    case MenuSource.regional:
      return 'Regional';
    case MenuSource.tipos:
      return 'Tipos';
  }
}

List<String> itemsForSource(MenuSource source) {
  switch (source) {
    case MenuSource.pokedexNacional:
      return ['All Pokemon', 'By Generation', 'Search', 'Favorites'];
    case MenuSource.regional:
      return ['Kanto', 'Johto', 'Hoenn', 'Sinnoh', 'Unova', 'Kalos', 'Alola',
        'Galar', 'Paldea'];
    case MenuSource.tipos:
      return ['Fuego', 'Agua', 'Planta', 'Electrico', 'Hielo', 'Lucha', 'Veneno',
        'Tierra', 'Volador', 'Psíquico', 'Bicho', 'Roca', 'Fantasma', 'Dragón',
        'Siniestro', 'Acero', 'Hada', 'Normal' ];
  }
}

