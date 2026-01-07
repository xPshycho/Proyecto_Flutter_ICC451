import 'package:equatable/equatable.dart';

/// Eventos para el PokemonDetailBloc
abstract class PokemonDetailEvent extends Equatable {
  const PokemonDetailEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar los detalles de un Pokémon
class LoadPokemonDetail extends PokemonDetailEvent {
  final int pokemonId;

  const LoadPokemonDetail(this.pokemonId);

  @override
  List<Object?> get props => [pokemonId];
}

/// Evento para navegar a otro Pokémon (evolución)
class NavigateToEvolution extends PokemonDetailEvent {
  final int evolutionId;

  const NavigateToEvolution(this.evolutionId);

  @override
  List<Object?> get props => [evolutionId];
}

/// Evento para reintentar la carga con limpieza de caché
class RetryLoadPokemonDetail extends PokemonDetailEvent {
  final int pokemonId;

  const RetryLoadPokemonDetail(this.pokemonId);

  @override
  List<Object?> get props => [pokemonId];
}

