import 'package:equatable/equatable.dart';
import '../../../data/models/pokemon.dart';

/// Estados del PokemonDetailBloc
abstract class PokemonDetailState extends Equatable {
  const PokemonDetailState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class PokemonDetailInitial extends PokemonDetailState {
  const PokemonDetailInitial();
}

/// Estado de carga
class PokemonDetailLoading extends PokemonDetailState {
  const PokemonDetailLoading();
}

/// Estado con datos cargados
class PokemonDetailLoaded extends PokemonDetailState {
  final Pokemon pokemon;

  const PokemonDetailLoaded(this.pokemon);

  @override
  List<Object?> get props => [pokemon];
}

/// Estado de error
class PokemonDetailError extends PokemonDetailState {
  final String message;
  final int pokemonId;
  final bool isRegionalForm;

  const PokemonDetailError({
    required this.message,
    required this.pokemonId,
    this.isRegionalForm = false,
  });

  @override
  List<Object?> get props => [message, pokemonId, isRegionalForm];
}

