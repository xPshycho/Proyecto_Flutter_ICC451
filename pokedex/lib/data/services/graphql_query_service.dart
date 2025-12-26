class GraphQLQueryService {
  GraphQLQueryService._();

  // Query básica para obtener pokémon por IDs
  static const String byIds = r'''
    query getByIds($ids: [Int!]) {
      pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { 
          id 
          is_legendary 
          is_mythical 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';

  // Query para detalles completos
  static const String detailsByIds = r'''
    query getDetailsByIds($ids: [Int!]) {
      pokemon_v2_pokemon(where: {id: {_in: $ids}}) {
        id
        name
        height
        weight
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonabilities { pokemon_v2_ability { name } }
        pokemon_v2_pokemonstats { base_stat pokemon_v2_stat { name } }
        pokemon_v2_pokemonspecy { 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';

  // Query para formas por IDs de pokémon
  static const String formsByPokemonIds = r'''
    query getFormsByPokemonIds($ids: [Int!]) {
      pokemon_v2_pokemonform(where: {pokemon_id: {_in: $ids}}) {
        id
        pokemon_id
        name
        form_name
        is_default
        is_battle_only
        is_mega
        pokemon_v2_pokemonformsprites {
          sprites
        }
      }
    }
  ''';

  /// NUEVO: formas de toda una cadena evolutiva.
  ///
  /// Importante: muchas megas/variantes viven en otros `pokemon_id` dentro de la misma
  /// especie/cadena, por lo que consultarlas solo por `pokemon_id` del actual suele
  /// devolver vacío.
  static const String formsByEvolutionChainId = r'''
    query getFormsByEvolutionChainId($chainId: Int!) {
      pokemon_v2_pokemonform(
        where: {
          pokemon_v2_pokemon: {
            pokemon_v2_pokemonspecy: {evolution_chain_id: {_eq: $chainId}}
          }
        }
      ) {
        id
        pokemon_id
        name
        form_name
        is_default
        is_battle_only
        is_mega
        pokemon_v2_pokemonformsprites {
          sprites
        }
      }
    }
  ''';

  // Query para mega evoluciones
  static const String megaEvolutions = r'''
    query getMegaEvolutions($pokemonId: Int!) {
      pokemon_v2_pokemonform(where: {pokemon_id: {_eq: $pokemonId}, is_mega: {_eq: true}}) {
        id
        pokemon_id
        name
        form_name
        is_default
        is_battle_only
        is_mega
      }
    }
  ''';

  // Query para lista paginada
  static const String list = r'''
    query getPokemons($limit: Int!, $offset: Int!, $orderBy: [pokemon_v2_pokemon_order_by!]!, $where: pokemon_v2_pokemon_bool_exp) {
      pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: $orderBy, where: $where) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      }
    }
  ''';

  // Query para lista con información de especies (para filtros de Legendario/Mítico)
  static const String listWithSpecies = r'''
    query getPokemonsWithSpecies($limit: Int!, $offset: Int!, $orderBy: [pokemon_v2_pokemon_order_by!]!) {
      pokemon_v2_pokemon(limit: $limit, offset: $offset, order_by: $orderBy) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { 
          id 
          is_legendary 
          is_mythical 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';

  // Query para detalle individual
  static const String detail = r'''
    query getPokemon($id: Int!) {
      pokemon_v2_pokemon_by_pk(id: $id) {
        id
        name
        height
        weight
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonabilities { 
          pokemon_v2_ability { 
            name 
            pokemon_v2_abilitynames(where: {language_id: {_eq: 7}}, limit: 1) {
              name
            }
          } 
        }
        pokemon_v2_pokemonstats { base_stat pokemon_v2_stat { name } }
        pokemon_v2_pokemonspecy {
          evolution_chain_id
          generation_id
          pokemon_v2_pokemonspeciesflavortexts(where: {language_id: {_eq: 7}}, limit: 1) {
            flavor_text
          }
        }
      }
    }
  ''';

  // Query para cadena evolutiva
  static const String evolutionChain = r'''
    query getEvolutionChain($id: Int!) {
      pokemon_v2_evolutionchain_by_pk(id: $id) {
        id
        baby_trigger_item_id
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          evolves_from_species_id
          evolution_chain_id
          pokemon_v2_pokemonevolutions {
            evolved_species_id
            evolution_trigger_id
            min_level
            min_happiness
            min_beauty
            min_affection
            time_of_day
            needs_overworld_rain
            turn_upside_down
            evolution_item_id
            pokemon_v2_evolutiontrigger {
              name
            }
            pokemon_v2_item {
              pokemon_v2_itemnames(where: {language_id: {_eq: 7}}, limit: 1) {
                name
              }
            }
            pokemon_v2_location {
              pokemon_v2_locationnames(where: {language_id: {_eq: 7}}, limit: 1) {
                name
              }
            }
          }
          pokemon_v2_pokemons(order_by: {id: asc}) {
            id
            name
            pokemon_v2_pokemonsprites { sprites }
            pokemon_v2_pokemontypes { pokemon_v2_type { name } }
          }
        }
      }
    }
  ''';

  // Query para pokémon por especie
  static const String pokemonsBySpecies = r'''
    query getPokemonsBySpecies($speciesId: Int!) {
      pokemon_v2_pokemon(where: {pokemon_v2_pokemonspecy: {id: {_eq: $speciesId}}}, order_by: {id: asc}) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
      }
    }
  ''';

  // Query para búsqueda por nombre
  static const String searchByName = r'''
    query searchPokemonByName($name: String!, $limit: Int!, $offset: Int!) {
      pokemon_v2_pokemon(
        where: {name: {_ilike: $name}}, 
        limit: $limit, 
        offset: $offset,
        order_by: {id: asc}
      ) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { 
          id 
          is_legendary 
          is_mythical 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';


  // Query para lista con filtro por tipos
  static const String listByTypes = r'''
    query getPokemonsByTypes($limit: Int!, $offset: Int!, $orderBy: [pokemon_v2_pokemon_order_by!]!, $typeNames: [String!]!) {
      pokemon_v2_pokemon(
        limit: $limit, 
        offset: $offset, 
        order_by: $orderBy,
        where: {pokemon_v2_pokemontypes: {pokemon_v2_type: {name: {_in: $typeNames}}}}
      ) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { 
          id 
          is_legendary 
          is_mythical 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';

  // Query para lista con filtro por tipos y generaciones
  static const String listByTypesAndGenerations = r'''
    query getPokemonsByTypesAndGenerations($limit: Int!, $offset: Int!, $orderBy: [pokemon_v2_pokemon_order_by!]!, $typeNames: [String!]!, $generationIds: [Int!]!) {
      pokemon_v2_pokemon(
        limit: $limit, 
        offset: $offset, 
        order_by: $orderBy,
        where: {
          _and: [
            {pokemon_v2_pokemontypes: {pokemon_v2_type: {name: {_in: $typeNames}}}},
            {pokemon_v2_pokemonspecy: {generation_id: {_in: $generationIds}}}
          ]
        }
      ) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { 
          id 
          is_legendary 
          is_mythical 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';

  // Query para lista con filtro por generation_id
  static const String listByGenerationIds = r'''
    query getPokemonsByGenerations($limit: Int!, $offset: Int!, $orderBy: [pokemon_v2_pokemon_order_by!]!, $generationIds: [Int!]!) {
      pokemon_v2_pokemon(
        limit: $limit, 
        offset: $offset, 
        order_by: $orderBy,
        where: {pokemon_v2_pokemonspecy: {generation_id: {_in: $generationIds}}}
      ) {
        id
        name
        pokemon_v2_pokemonsprites { sprites }
        pokemon_v2_pokemontypes { pokemon_v2_type { name } }
        pokemon_v2_pokemonspecy { 
          id 
          is_legendary 
          is_mythical 
          evolution_chain_id 
          generation_id
        }
      }
    }
  ''';

  // Query para detalle de movimientos
  static const String movesByPokemonId = r'''
    query getMovesByPokemonId($pokemonId: Int!) {
      pokemon_v2_pokemonmove(where: {pokemon_id: {_eq: $pokemonId}}) {
        move_id
        level
        pokemon_v2_movelearnmethod {
          name
        }
        pokemon_v2_versiongroup {
          name
        }
        pokemon_v2_move {
          name
          power
          accuracy
          pp
          pokemon_v2_type { name }
          pokemon_v2_movedamageclass { name }
          pokemon_v2_movenames(where: {language_id: {_eq: 7}}, limit: 1) {
            name
          }
        }
      }
    }
  ''';

    // Query para encuentros de Pokémon por ubicación
    static const String encountersByLocation = r'''
    query getEncountersByLocation($locationId: Int!) {
      pokemon_v2_encounter(where: {pokemon_v2_locationarea: {location_id: {_eq: $locationId}}}) {
        pokemon_v2_pokemon {
          id
          name
        }
        pokemon_v2_encounterslot {
          rarity
          pokemon_v2_encountermethod {
            name
          }
        }
        min_level
        max_level
        pokemon_v2_version {
          name
        }
      }
    }
    ''';

    // Query para encuentros de un Pokémon específico
    static const String encountersByPokemon = r'''
    query getEncountersByPokemon($pokemonId: Int!) {
      pokemon_v2_encounter(where: {pokemon_id: {_eq: $pokemonId}}) {
        pokemon_v2_locationarea {
          id
          name
          pokemon_v2_location {
            name
            pokemon_v2_region {
              name
            }
          }
        }
        pokemon_v2_encounterslot {
          rarity
          pokemon_v2_encountermethod {
            name
          }
        }
        min_level
        max_level
        pokemon_v2_version {
          name
        }
        pokemon_v2_pokemon {
          id
        }
      }
    }
    ''';

    // Query para encuentros de Pokémon por área de ubicación
    static const String encountersByLocationArea = r'''
    query getEncountersByLocationArea($locationAreaId: Int!) {
      pokemon_v2_encounter(where: {location_area_id: {_eq: $locationAreaId}}) {
        pokemon_v2_pokemon {
          id
          name
        }
        pokemon_v2_encounterslot {
          rarity
          pokemon_v2_encountermethod {
            name
          }
        }
        min_level
        max_level
        pokemon_v2_version {
          name
        }
      }
    }
    ''';

  // Nueva query: obtener location area por nombre (busca coincidencias exactas)
  static const String locationAreaByName = r'''
    query getLocationAreaByName($name: String!) {
      pokemon_v2_locationarea(
        where: {
          _or: [
            {name: {_eq: $name}},
            {pokemon_v2_location: {name: {_eq: $name}}}
          ]
        }
      ) {
        id
        name
        pokemon_v2_location {
          id
          name
        }
      }
    }
  ''';

  // Nueva query: obtener location por nombre (coincidencia exacta)
  static const String locationByName = r'''
    query getLocationByName($name: String!) {
      pokemon_v2_location(
        where: { name: {_eq: $name} }
      ) {
        id
        name
        pokemon_v2_region {
          id
          name
        }
      }
    }
  ''';

  // Query que busca coincidencias parciales usando ILIKE (case-insensitive, pattern)
  static const String locationAreaByNameLike = r'''
    query getLocationAreaByNameLike($name: String!) {
      pokemon_v2_locationarea(
        where: {
          _or: [
            {name: {_ilike: $name}},
            {pokemon_v2_location: {name: {_ilike: $name}}}
          ]
        }
      ) {
        id
        name
        pokemon_v2_location {
          id
          name
          pokemon_v2_region {
            id
            name
          }
        }
      }
    }
  ''';

  // Query para location (tabla pokemon_v2_location) con ILIKE
  static const String locationByNameLike = r'''
    query getLocationByNameLike($name: String!) {
      pokemon_v2_location(
        where: { name: {_ilike: $name} }
      ) {
        id
        name
        pokemon_v2_region {
          id
          name
        }
      }
    }
  ''';
}
