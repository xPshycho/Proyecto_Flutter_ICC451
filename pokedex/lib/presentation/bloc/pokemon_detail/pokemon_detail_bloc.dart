import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../../core/utils/pokemon_validation_utils.dart';
import '../../../core/exceptions/invalid_pokemon_id_exception.dart';
import 'pokemon_detail_event.dart';
import 'pokemon_detail_state.dart';

/// BLoC para gestionar el estado de detalle de un Pokémon
class PokemonDetailBloc extends Bloc<PokemonDetailEvent, PokemonDetailState> {
  final PokemonRepository repository;

  PokemonDetailBloc({required this.repository})
      : super(const PokemonDetailInitial()) {
    on<LoadPokemonDetail>(_onLoadPokemonDetail);
    on<NavigateToEvolution>(_onNavigateToEvolution);
    on<RetryLoadPokemonDetail>(_onRetryLoadPokemonDetail);
  }

  /// Carga los detalles de un Pokémon
  Future<void> _onLoadPokemonDetail(
    LoadPokemonDetail event,
    Emitter<PokemonDetailState> emit,
  ) async {
    try {
      emit(const PokemonDetailLoading());

      // Validar que el ID sea un Pokémon por defecto
      PokemonValidationUtils.validateDefaultPokemon(event.pokemonId);

      final pokemon = await repository.fetchPokemonDetail(event.pokemonId);

      emit(PokemonDetailLoaded(pokemon));
    } on InvalidPokemonIdException catch (e) {
      debugPrint('Invalid Pokemon ID: ${e.toString()}');

      emit(PokemonDetailError(
        message: e.reason,
        pokemonId: event.pokemonId,
        isRegionalForm: e.isRegionalForm,
        isInvalidId: true,
      ));
    } catch (e) {
      debugPrint('Error loading pokemon detail: $e');

      final isRegionalForm = event.pokemonId > 10000;

      emit(PokemonDetailError(
        message: e.toString(),
        pokemonId: event.pokemonId,
        isRegionalForm: isRegionalForm,
      ));
    }
  }

  /// Navega a un Pokémon de evolución
  Future<void> _onNavigateToEvolution(
    NavigateToEvolution event,
    Emitter<PokemonDetailState> emit,
  ) async {
    add(LoadPokemonDetail(event.evolutionId));
  }

  /// Reintenta la carga limpiando el caché
  Future<void> _onRetryLoadPokemonDetail(
    RetryLoadPokemonDetail event,
    Emitter<PokemonDetailState> emit,
  ) async {
    try {
      emit(const PokemonDetailLoading());

      // Validar que el ID sea un Pokémon por defecto antes de limpiar caché
      PokemonValidationUtils.validateDefaultPokemon(event.pokemonId);

      // Limpiar caché antes de reintentar
      await repository.clearGraphQLCache();

      final pokemon = await repository.fetchPokemonDetail(event.pokemonId);

      emit(PokemonDetailLoaded(pokemon));
    } on InvalidPokemonIdException catch (e) {
      debugPrint('Invalid Pokemon ID on retry: ${e.toString()}');

      emit(PokemonDetailError(
        message: e.reason,
        pokemonId: event.pokemonId,
        isRegionalForm: e.isRegionalForm,
        isInvalidId: true,
      ));
    } catch (e) {
      debugPrint('Error retrying pokemon detail: $e');

      final isRegionalForm = event.pokemonId > 10000;

      emit(PokemonDetailError(
        message: e.toString(),
        pokemonId: event.pokemonId,
        isRegionalForm: isRegionalForm,
      ));
    }
  }
}

