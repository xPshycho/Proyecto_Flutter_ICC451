class PokemonType {
  final String name;
  final String iconPath;
  final int color;

  const PokemonType({
    required this.name,
    required this.iconPath,
    required this.color,
  });
}

// Mapa de tipos de Pokémon con sus iconos y colores
const Map<String, PokemonType> pokemonTypes = {
  'Fuego': PokemonType(
    name: 'Fuego',
    iconPath: 'assets/icons/types/icons/fire.svg',
    color: 0xFFFBA54C,
  ),
  'Agua': PokemonType(
    name: 'Agua',
    iconPath: 'assets/icons/types/icons/water.svg',
    color: 0xFF539DDF,
  ),
  'Planta': PokemonType(
    name: 'Planta',
    iconPath: 'assets/icons/types/icons/grass.svg',
    color: 0xFF5FBD58,
  ),
  'Electrico': PokemonType(
    name: 'Electrico',
    iconPath: 'assets/icons/types/icons/electric.svg',
    color: 0xFFF2D94E,
  ),
  'Hielo': PokemonType(
    name: 'Hielo',
    iconPath: 'assets/icons/types/icons/ice.svg',
    color: 0xFF75D0C1,
  ),
  'Lucha': PokemonType(
    name: 'Lucha',
    iconPath: 'assets/icons/types/icons/fighting.svg',
    color: 0xFFD3425F,
  ),
  'Veneno': PokemonType(
    name: 'Veneno',
    iconPath: 'assets/icons/types/icons/poison.svg',
    color: 0xFFB763CF,
  ),
  'Tierra': PokemonType(
    name: 'Tierra',
    iconPath: 'assets/icons/types/icons/ground.svg',
    color: 0xFFDA7C4D,
  ),
  'Volador': PokemonType(
    name: 'Volador',
    iconPath: 'assets/icons/types/icons/flying.svg',
    color: 0xFFA1BBEC,
  ),
  'Psíquico': PokemonType(
    name: 'Psíquico',
    iconPath: 'assets/icons/types/icons/psychic.svg',
    color: 0xFFFA8581,
  ),
  'Bicho': PokemonType(
    name: 'Bicho',
    iconPath: 'assets/icons/types/icons/bug.svg',
    color: 0xFF92BC2C,
  ),
  'Roca': PokemonType(
    name: 'Roca',
    iconPath: 'assets/icons/types/icons/rock.svg',
    color: 0xFFC9BB8A,
  ),
  'Fantasma': PokemonType(
    name: 'Fantasma',
    iconPath: 'assets/icons/types/icons/ghost.svg',
    color: 0xFF5F6DBC,
  ),
  'Dragón': PokemonType(
    name: 'Dragón',
    iconPath: 'assets/icons/types/icons/dragon.svg',
    color: 0xFF0C69C8,
  ),
  'Siniestro': PokemonType(
    name: 'Siniestro',
    iconPath: 'assets/icons/types/icons/dark.svg',
    color: 0xFF595761,
  ),
  'Acero': PokemonType(
    name: 'Acero',
    iconPath: 'assets/icons/types/icons/steel.svg',
    color: 0xFF5695A3,
  ),
  'Hada': PokemonType(
    name: 'Hada',
    iconPath: 'assets/icons/types/icons/fairy.svg',
    color: 0xFFEE90E6,
  ),
  'Normal': PokemonType(
    name: 'Normal',
    iconPath: 'assets/icons/types/icons/normal.svg',
    color: 0xFFA0A29F,
  ),
};

