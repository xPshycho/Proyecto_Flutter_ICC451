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
        pokemon_v2_pokemonspecy { id is_legendary is_mythical evolution_chain_id }
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
        pokemon_v2_pokemonspecy { evolution_chain_id }
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
        pokemon_v2_pokemonspecy { id is_legendary is_mythical evolution_chain_id }
      }
    }
  ''';

  // Query para detalle de movimientos
  static const String movesByPokemonId = r'''
    query getMovesByPokemonId($pokemonId: Int!) {
      pokemon_v2_pokemonmove(where: {pokemon_id: {_eq: $pokemonId}}) {
        move_id
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
}

