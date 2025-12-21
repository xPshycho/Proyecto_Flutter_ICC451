import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/location.dart';
import '../../../data/services/map_repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../data/models/pokemon.dart';

/// Modal que muestra todos los Pokémon de una ruta específica.
class RoutePokemonModal extends StatefulWidget {
  final String routeName;
  final int? locationId;

  const RoutePokemonModal({
    super.key,
    required this.routeName,
    this.locationId,
  });

  @override
  State<RoutePokemonModal> createState() => _RoutePokemonModalState();
}

class _RoutePokemonModalState extends State<RoutePokemonModal> {
  List<Encounter> _encounters = [];
  List<Pokemon> _pokemons = [];
  bool _isLoading = true;
  String? _error;
  bool _hasLoaded = false;

  // Nuevos estados para coincidencias
  List<Map<String, dynamic>> _matches = [];
  bool _showMatches = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      _loadEncounters();
    }
  }

  Future<void> _loadEncounters() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _showMatches = false;
      _matches = [];
      _pokemons = [];
    });

    try {
      final client = GraphQLProvider.of(context).value;
      final repository = MapRepository(client);

      int? idToUse = widget.locationId;

      // Si no tenemos un id válido, intentar resolverlo por nombre
      if (idToUse == null) {
        final resolved = await repository.getLocationAreaIdByName(widget.routeName);
        if (resolved == null) {
          // Intentar obtener coincidencias y mostrarlas como opción al usuario
          final matches = await repository.getLocationAreaMatches(widget.routeName);
          if (matches.isNotEmpty) {
            setState(() {
              _isLoading = false;
              _showMatches = true;
              _matches = matches;
            });
            return;
          }

          setState(() {
            _isLoading = false;
            _error = 'No se encontró la ubicación para "${widget.routeName}" (nombre -> id).';
          });
          return;
        }
        idToUse = resolved;
      }

      await _loadEncountersForId(idToUse);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Error al cargar encuentros: $e';
      });
    }
  }

  Future<void> _loadEncountersForId(int id) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _showMatches = false;
      _matches = [];
      _encounters = [];
      _pokemons = [];
    });

    try {
      final client = GraphQLProvider.of(context).value;
      final repository = MapRepository(client);

      _encounters = await repository.getEncountersByLocation(id);

      if (_encounters.isEmpty) {
        setState(() {
          _error = 'No hay encuentros registrados para ${widget.routeName} (id $id).';
        });
      } else {
        // Obtener IDs únicos de pokémon de los encuentros
        final ids = _encounters.map((e) => e.pokemonId).toSet().toList();
        // Cargar datos de pokémon para mostrar tarjetas
        final pokes = await repository.getPokemonsByIds(ids);
        // Reconstruir `Pokemon` simples para evitar referencias inesperadas a objetos complejos
        final safePokes = pokes.map((p) => Pokemon(id: p.id, name: p.name, spriteUrl: p.spriteUrl, types: List<String>.from(p.types))).toList();
        setState(() {
          _pokemons = safePokes;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error al cargar encuentros: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.routeName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showMatches
                    ? _buildMatchesView()
                    : _error != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_error!),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadEncounters,
                                  child: const Text('Reintentar'),
                                ),
                              ],
                            ),
                          )
                        : _pokemons.isEmpty
                            ? const Center(child: Text('No hay encuentros disponibles'))
                            : ListView.builder(
                                itemCount: _pokemons.length,
                                itemBuilder: (context, index) {
                                  final pokemon = _pokemons[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    child: _SimplePokemonCard(
                                      pokemon: pokemon,
                                      onTap: () => Navigator.of(context).pop(),
                                    ),
                                  );
                                },
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchesView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text('Se encontraron varias coincidencias. Selecciona la correcta:'),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: _matches.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = _matches[index];
              final id = m['id'] as int?;
              final name = m['name'] as String? ?? 'Desconocido';
              final locationName = m['locationName'] as String? ?? '';
              return ListTile(
                title: Text(name),
                subtitle: locationName.isNotEmpty ? Text(locationName) : null,
                trailing: id != null ? Text('id $id') : null,
                onTap: id != null ? () => _loadEncountersForId(id) : null,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Tarjeta simple local que muestra sprite, id, nombre y tipos (sin blocs ni dependencias externas)
class _SimplePokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final VoidCallback? onTap;

  const _SimplePokemonCard({required this.pokemon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              SizedBox(
                width: 72,
                height: 72,
                child: pokemon.spriteUrl != null
                    ? Image.network(pokemon.spriteUrl!, fit: BoxFit.contain, errorBuilder: (c, e, st) => Icon(Icons.catching_pokemon, size: 36, color: colorScheme.onSurface.withAlpha(120)))
                    : Icon(Icons.catching_pokemon, size: 36, color: colorScheme.onSurface.withAlpha(120)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('#${pokemon.id.toString().padLeft(3, '0')}', style: TextStyle(color: colorScheme.onSurface.withAlpha(140), fontSize: 11, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(pokemon.name[0].toUpperCase() + (pokemon.name.length > 1 ? pokemon.name.substring(1) : ''), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: pokemon.types.map((t) {
                          final spanishType = t; // asume ya está en inglés; PokemonConstants mapping not needed here
                          return Container(
                            margin: const EdgeInsets.only(right: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: colorScheme.primary.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                            child: Text(spanishType, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
