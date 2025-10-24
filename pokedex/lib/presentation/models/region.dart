class Region {
  final String name;
  final int generation;

  const Region({required this.name, required this.generation});

  // Devuelve la ruta de la imagen asociada a esta región.
  String get imagePath => 'assets/images/starters/gen_$generation.png';
}

// Lista completa de regiones de Pokémon ordenadas por generación.
const List<Region> allRegions = [
  Region(name: 'Kanto', generation: 1),
  Region(name: 'Johto', generation: 2),
  Region(name: 'Hoenn', generation: 3),
  Region(name: 'Sinnoh', generation: 4),
  Region(name: 'Unova', generation: 5),
  Region(name: 'Kalos', generation: 6),
  Region(name: 'Alola', generation: 7),
  Region(name: 'Galar', generation: 8),
  Region(name: 'Paldea', generation: 9),
];

