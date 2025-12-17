/// Utilidades para identificar categorías de Pokémon por ID
class PokemonUtils {
  PokemonUtils._();

  // ========== REGIONES ==========

  static bool isKanto(int id) => id >= 1 && id <= 151;
  static bool isJohto(int id) => id >= 152 && id <= 251;
  static bool isHoenn(int id) => id >= 252 && id <= 386;
  static bool isSinnoh(int id) => id >= 387 && id <= 493;
  static bool isUnova(int id) => id >= 494 && id <= 649;
  static bool isKalos(int id) => id >= 650 && id <= 721;
  static bool isAlola(int id) => id >= 722 && id <= 809;
  static bool isGalar(int id) => id >= 810 && id <= 905;
  static bool isPaldea(int id) => id >= 906 && id <= 1025;

  // ========== STARTERS ==========

  static final Set<int> starterIds = {
    // Kanto
    1, 4, 7,        // Bulbasaur, Charmander, Squirtle
    // Johto
    152, 155, 158,  // Chikorita, Cyndaquil, Totodile
    // Hoenn
    252, 255, 258,  // Treecko, Torchic, Mudkip
    // Sinnoh
    387, 390, 393,  // Turtwig, Chimchar, Piplup
    // Unova
    495, 498, 501,  // Snivy, Tepig, Oshawott
    // Kalos
    650, 653, 656,  // Chespin, Fennekin, Froakie
    // Alola
    722, 725, 728,  // Rowlet, Litten, Popplio
    // Galar
    810, 813, 816,  // Grookey, Scorbunny, Sobble
    // Paldea
    906, 909, 912,  // Sprigatito, Fuecoco, Quaxly
  };

  static bool isStarter(int id) => starterIds.contains(id);

  // ========== LEGENDARIOS ==========

  static final Set<int> legendaryIds = {
    // Kanto
    144, 145, 146, 150,  // Articuno, Zapdos, Moltres, Mewtwo
    // Johto
    243, 244, 245, 249, 250,  // Raikou, Entei, Suicune, Lugia, Ho-Oh
    // Hoenn
    377, 378, 379, 380, 381, 382, 383, 384,  // Regirock, Regice, Registeel, Latias, Latios, Kyogre, Groudon, Rayquaza
    // Sinnoh
    480, 481, 482, 483, 484, 485, 486, 487, 488,  // Uxie, Mesprit, Azelf, Dialga, Palkia, Heatran, Regigigas, Giratina, Cresselia
    // Unova
    638, 639, 640, 641, 642, 643, 644, 645, 646,  // Cobalion, Terrakion, Virizion, Tornadus, Thundurus, Reshiram, Zekrom, Kyurem, Landorus
    // Kalos
    716, 717, 718,  // Xerneas, Yveltal, Zygarde
    // Alola
    785, 786, 787, 788, 789, 790, 791, 792,  // Tapu Koko, Tapu Lele, Tapu Bulu, Tapu Fini, Cosmog, Cosmoem, Solgaleo, Lunala
    // Galar
    888, 889, 890, 891, 892, 894, 895, 896, 897, 898,  // Zacian, Zamazenta, Eternatus, Kubfu, Urshifu, Regieleki, Regidrago, Glastrier, Spectrier, Calyrex
    // Paldea
    1001, 1002, 1003, 1004, 1007, 1008, 1014, 1015, 1016, 1017, 1024,  // Wo-Chien, Chien-Pao, Ting-Lu, Chi-Yu, Koraidon, Miraidon, Okidogi, Munkidori, Fezandipiti, Ogerpon, Terapagos
  };

  static bool isLegendary(int id) => legendaryIds.contains(id);

  // ========== MÍTICOS ==========

  static final Set<int> mythicalIds = {
    // Kanto
    151,  // Mew
    // Johto
    251,  // Celebi
    // Hoenn
    385,  // Jirachi
    386,  // Deoxys
    // Sinnoh
    489, 490, 491, 492, 493,  // Phione, Manaphy, Darkrai, Shaymin, Arceus
    // Unova
    494, 647, 648, 649,  // Victini, Keldeo, Meloetta, Genesect
    // Kalos
    719, 720, 721,  // Diancie, Hoopa, Volcanion
    // Alola
    801, 802, 807, 808, 809,  // Magearna, Marshadow, Zeraora, Meltan, Melmetal
    // Galar
    893,  // Zarude
    // Paldea
    1025,  // Pecharunt
  };

  static bool isMythical(int id) => mythicalIds.contains(id);

  // ========== PSEUDO-LEGENDARIOS ==========

  static final Set<int> pseudoLegendaryIds = {
    // Kanto
    149,  // Dragonite
    // Johto
    248,  // Tyranitar
    // Hoenn
    376,  // Metagross
    373,  // Salamence
    // Sinnoh
    445,  // Garchomp
    // Unova
    635, 637,  // Hydreigon, Volcarona
    // Kalos
    706,  // Goodra
    // Alola
    784,  // Kommo-o
    // Galar
    887,  // Dragapult
    // Paldea
    1007,  // Baxcalibur
  };

  static bool isPseudoLegendary(int id) => pseudoLegendaryIds.contains(id);

  // ========== ULTRA BEASTS ==========

  static final Set<int> ultraBeastIds = {
    793, 794, 795, 796, 797, 798, 799, 805, 806,  // Nihilego, Buzzwole, Pheromosa, Xurkitree, Celesteela, Kartana, Guzzlord, Stakataka, Blacephalon
  };

  static bool isUltraBeast(int id) => ultraBeastIds.contains(id);

  // ========== EEVEE Y EVOLUCIONES ==========

  static final Set<int> eeveelutionIds = {
    133, 134, 135, 136, 196, 197, 470, 471, 700,  // Eevee, Vaporeon, Jolteon, Flareon, Espeon, Umbreon, Leafeon, Glaceon, Sylveon
  };

  static bool isEeveelution(int id) => eeveelutionIds.contains(id);

  // ========== POKÉMON BEBÉ ==========

  static final Set<int> babyPokemonIds = {
    172, 173, 174, 175, 236, 238, 239, 240, 298, 360, 406, 433, 438, 439, 440, 446, 447, 458,
  };

  static bool isBaby(int id) => babyPokemonIds.contains(id);

  // ========== FÓSILES ==========

  static final Set<int> fossilPokemonIds = {
    138, 139, 140, 141, 142, 345, 346, 347, 348, 408, 409, 410, 411, 564, 565, 566, 567, 696, 697, 698, 699, 880, 881, 882, 883,
  };

  static bool isFossil(int id) => fossilPokemonIds.contains(id);
}

