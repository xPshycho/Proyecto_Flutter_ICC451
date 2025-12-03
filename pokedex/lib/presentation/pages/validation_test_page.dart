import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pokedex/data/repositories/pokemon_repository.dart';
import 'package:pokedex/presentation/bloc/pokemon_detail/pokemon_detail_bloc.dart';
import 'package:pokedex/presentation/bloc/pokemon_detail/pokemon_detail_event.dart';
import 'package:pokedex/presentation/bloc/pokemon_detail/pokemon_detail_state.dart';

/// Página de prueba para validar que la validación de ID funciona correctamente
class ValidationTestPage extends StatelessWidget {
  final PokemonRepository repository;

  const ValidationTestPage({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test de Validación')),
      body: BlocProvider(
        create: (_) => PokemonDetailBloc(repository: repository),
        child: const _TestBody(),
      ),
    );
  }
}

class _TestBody extends StatelessWidget {
  const _TestBody();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PokemonDetailBloc, PokemonDetailState>(
      listener: (context, state) {
        if (state is PokemonDetailError && state.isInvalidId) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Validación exitosa: ${state.message}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Pruebas de Validación de ID de Pokémon',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Test ID válido
              ElevatedButton(
                onPressed: () {
                  context.read<PokemonDetailBloc>().add(
                    const LoadPokemonDetail(25), // Pikachu - ID válido
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Probar ID válido (25 - Pikachu)'),
              ),
              const SizedBox(height: 10),

              // Test ID fuera de rango
              ElevatedButton(
                onPressed: () {
                  context.read<PokemonDetailBloc>().add(
                    const LoadPokemonDetail(1026), // ID fuera de rango 1025
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Probar ID fuera de rango (1026)'),
              ),
              const SizedBox(height: 10),

              // Test ID de forma regional
              ElevatedButton(
                onPressed: () {
                  context.read<PokemonDetailBloc>().add(
                    const LoadPokemonDetail(10001), // ID forma regional
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Probar ID forma regional (10001)'),
              ),
              const SizedBox(height: 10),

              // Test ID menor a 1
              ElevatedButton(
                onPressed: () {
                  context.read<PokemonDetailBloc>().add(
                    const LoadPokemonDetail(0), // ID inválido
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                child: const Text('Probar ID inválido (0)'),
              ),
              const SizedBox(height: 20),

              // Estado actual
              if (state is PokemonDetailLoading)
                const Center(child: CircularProgressIndicator()),

              if (state is PokemonDetailLoaded)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '✅ Pokémon cargado exitosamente: ${state.pokemon.name} (ID: ${state.pokemon.id})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),

              if (state is PokemonDetailError)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: state.isInvalidId ? Colors.orange[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isInvalidId ? '⚠️ Error de Validación:' : '❌ Error de Conexión:',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Mensaje: ${state.message}'),
                      const SizedBox(height: 4),
                      Text('ID: ${state.pokemonId}'),
                      const SizedBox(height: 4),
                      Text('Es forma regional: ${state.isRegionalForm}'),
                      const SizedBox(height: 4),
                      Text('Es ID inválido: ${state.isInvalidId}'),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
