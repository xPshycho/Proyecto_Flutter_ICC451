import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/location.dart';
import '../../../data/services/map_repository.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/repositories/pokemon_repository.dart';
import '../../pages/pokemon_detail_page.dart';
import '../../bloc/pokemon_detail/pokemon_detail_bloc.dart';
import '../../bloc/pokemon_detail/pokemon_detail_event.dart';

/// Modal que muestra todos los Pokémon de una ruta específica.
class RoutePokemonModal extends StatefulWidget {
  final String routeName;
  final String? routeIdentifier; // nuevo
  final List<String>? candidateIdentifiers;
  final int? locationId;
  final String? regionName;

  const RoutePokemonModal({
    super.key,
    required this.routeName,
    this.routeIdentifier,
    this.candidateIdentifiers,
    this.locationId,
    this.regionName,
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

  String? _resolvedType;

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
      _encounters = [];
    });

    try {
      final client = GraphQLProvider.of(context).value;
      final repository = MapRepository(client);

      int? idToUse = widget.locationId;

      // Si no tenemos un id válido, intentar resolverlo por nombre
      if (idToUse == null) {
        // Si el MapPage nos pasó un routeIdentifier explícito úsalo directamente.
        String? identifier = widget.routeIdentifier;
        if (identifier == null) {
          // Construir identificador en inglés con sintaxis PokeAPI (fallback)
          final lowerRoute = widget.routeName.toLowerCase();
          if (lowerRoute.contains('route') || lowerRoute.contains('ruta')) {
            // Es ruta
            final routeNum = lowerRoute.replaceAll('route', '').replaceAll('ruta', '').replaceAll(' ', '').replaceAll('-', '');
            if (widget.regionName?.toLowerCase() == 'johto') {
              identifier = 'route$routeNum';
            } else {
              final regionSlug = (widget.regionName ?? 'kanto').toLowerCase().replaceAll(' ', '-');
              identifier = '$regionSlug-route-$routeNum';
            }
          } else {
            // Es ciudad o lugar
            identifier = lowerRoute.replaceAll(' ', '-');
          }
        }
        debugPrint('RoutePokemonModal: construido identifier: $identifier');

        // Intentar buscar location con el identifier (si existe)
        // Primero intentar con la lista de candidatos si viene desde MapArea
        int? locId;
        if (widget.candidateIdentifiers != null && widget.candidateIdentifiers!.isNotEmpty) {
          for (final cand in widget.candidateIdentifiers!) {
            final tryId = await repository.getLocationIdByIdentifier(cand);
            if (tryId != null) {
              locId = tryId;
              identifier = cand;
              break;
            }
          }
        }
        // Si no encontramos nada con candidatos, intentar con el identifier construido
        if (locId == null) {
          locId = identifier != null ? await repository.getLocationIdByIdentifier(identifier) : null;
        }
        if (locId != null) {
          idToUse = locId;
          _resolvedType = 'location';
        } else {
          // Fallback: intentar resolver con la lógica anterior (location-area)
          final resolvedMap = await repository.resolveLocationOrArea(widget.routeName, regionName: widget.regionName);
          debugPrint('RoutePokemonModal: fallback resolveLocationOrArea result -> $resolvedMap');
          final resolved = resolvedMap['id'] as int?;
          if (resolved == null) {
            // Intentar obtener coincidencias y mostrarlas como opción al usuario
            // Hacemos varios intentos con variantes para mejorar la tasa de acierto
            final List<Map<String, dynamic>> combined = [];
            void addMatches(List<Map<String, dynamic>> list) {
              for (final m in list) {
                final id = m['id'] as int?;
                if (id == null) continue;
                final exists = combined.any((c) => (c['id'] as int?) == id);
                if (!exists) combined.add(m);
              }
            }

            List<Map<String, dynamic>> matches = await repository.getLocationAreaMatches(widget.routeName);
            debugPrint('RoutePokemonModal: matches iniciales para "${widget.routeName}" -> ${matches.length}');
            addMatches(matches);

            // Variantes: hyphenated, last numeric token, compacted
            final norm = widget.routeName.trim().toLowerCase();
            final hyphenated = norm.replaceAll(RegExp(r"\s+"), '-');
            if (hyphenated != norm) {
              final more = await repository.getLocationAreaMatches(hyphenated);
              debugPrint('RoutePokemonModal: matches hyphenated "$hyphenated" -> ${more.length}');
              addMatches(more);
            }

            final parts = norm.split(RegExp(r"\s+"));
            if (parts.isNotEmpty) {
              final last = parts.last;
              if (RegExp(r"^\d+").hasMatch(last)) {
                final more = await repository.getLocationAreaMatches(last);
                debugPrint('RoutePokemonModal: matches numeric "$last" -> ${more.length}');
                addMatches(more);
              }
            }

            final compact = norm.replaceAll(' ', '');
            if (compact != norm) {
              final more = await repository.getLocationAreaMatches(compact);
              debugPrint('RoutePokemonModal: matches compact "$compact" -> ${more.length}');
              addMatches(more);
            }

            // También intentar combinar con el nombre de la región si está disponible
            if ((widget.regionName ?? '').isNotEmpty) {
              final regionNorm = widget.regionName!.trim().toLowerCase();
              final combined1 = '$norm $regionNorm';
              final more1 = await repository.getLocationAreaMatches(combined1);
              debugPrint('RoutePokemonModal: matches "$combined1" -> ${more1.length}');
              addMatches(more1);

              final combined2 = '$regionNorm $norm';
              final more2 = await repository.getLocationAreaMatches(combined2);
              debugPrint('RoutePokemonModal: matches "$combined2" -> ${more2.length}');
              addMatches(more2);

              final hyphenRegion = '$hyphenated-$regionNorm';
              final more3 = await repository.getLocationAreaMatches(hyphenRegion);
              debugPrint('RoutePokemonModal: matches "$hyphenRegion" -> ${more3.length}');
              addMatches(more3);
            }

            // Intentos adicionales: buscar por tokens sueltos y combinaciones para cubrir casos como 'route 1', 'route-1', '1 route'
            final tokens = norm.split(RegExp(r"\s+"));
            // always try the first token (often 'route') and last token (often number)
            if (tokens.isNotEmpty) {
              final firstToken = tokens.first;
              if (firstToken.length > 1) {
                final more = await repository.getLocationAreaMatches(firstToken);
                debugPrint('RoutePokemonModal: matches token first "$firstToken" -> ${more.length}');
                addMatches(more);
              }
              final lastToken = tokens.last;
              if (lastToken.isNotEmpty) {
                final more = await repository.getLocationAreaMatches(lastToken);
                debugPrint('RoutePokemonModal: matches token last "$lastToken" -> ${more.length}');
                addMatches(more);
              }
              if (tokens.length >= 2) {
                final alt1 = '${tokens.first}-${tokens.last}';
                final more = await repository.getLocationAreaMatches(alt1);
                debugPrint('RoutePokemonModal: matches alt1 "$alt1" -> ${more.length}');
                addMatches(more);
                final alt2 = '${tokens.last} ${tokens.first}';
                final more2 = await repository.getLocationAreaMatches(alt2);
                debugPrint('RoutePokemonModal: matches alt2 "$alt2" -> ${more2.length}');
                addMatches(more2);
              }
            }

             // Si aún está vacío, intentar resolver sin filtro de región
             if (combined.isEmpty) {
               // intentar resolver usando resolveLocationOrArea sin region
               final resolvedAny = await repository.resolveLocationOrArea(widget.routeName, regionName: null);
               debugPrint('RoutePokemonModal: intento sin region (resolveLocationOrArea) para "${widget.routeName}" -> $resolvedAny');
               final resolvedAnyId = resolvedAny['id'] as int?;
               if (resolvedAnyId != null) {
                 idToUse = resolvedAnyId;
                 _resolvedType = resolvedAny['type'] as String?;
               }
             }

            if (idToUse == null && combined.isNotEmpty) {
              setState(() {
                _isLoading = false;
                _showMatches = true;
                _matches = combined.toList();
              });
              return;
            }

            if (idToUse == null) {
              setState(() {
                _isLoading = false;
                _error = 'No se encontró la ubicación para "${widget.routeName}" (nombre -> id).';
              });
              return;
            }
          } else {
            idToUse = resolved;
            _resolvedType = resolvedMap['type'] as String?;
          }
        }
       }

       await _loadEncountersForId(idToUse, _resolvedType ?? 'location');
     } catch (e) {
       setState(() {
         _isLoading = false;
         _error = 'Error al cargar encuentros: $e';
       });
     }
   }

    Future<void> _loadEncountersForId(int id, [String type = 'location']) async {
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

      _encounters = await repository.getEncountersByLocationOrArea(id, type);

      // Log: mostrar encuentros crudos obtenidos
      try {
        debugPrint('RoutePokemonModal: encuentros crudos (id $id) -> ${_encounters.map((e) => {'pokemonId': e.pokemonId, 'pokemonName': e.pokemonName, 'method': e.method, 'games': e.games, 'min': e.minLevel, 'max': e.maxLevel, 'rate': e.rate}).toList()}');
      } catch (e) {
        debugPrint('RoutePokemonModal: fallo al imprimir encuentros: $e');
      }

      // Filtrar encuentros para mostrar solo encuentros 'salvajes' usando una lista blanca de métodos.
      // Métodos comunes salvajes: walk, surf, grass, cave, old-rod, good-rod, super-rod, fishing, rock-smash, headbutt
      bool isMethodWild(String method) {
        final m = method.toLowerCase();
        final whitelist = ['walk', 'surf', 'grass', 'cave', 'old-rod', 'good-rod', 'super-rod', 'fishing', 'fish', 'rock-smash', 'headbutt', 'hidden'];
        for (final w in whitelist) {
          if (m.contains(w)) return true;
        }
        return false;
      }

      final beforeFilterCount = _encounters.length;
      _encounters = _encounters.where((e) {
        final methods = e.method.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
        for (final m in methods) {
          if (isMethodWild(m)) return true;
        }
        return false;
      }).toList();
      debugPrint('RoutePokemonModal: encuentros filtrados (salvajes) para id $id -> ${_encounters.length} (antes: $beforeFilterCount)');

      if (_encounters.isEmpty) {
        setState(() {
          _error = 'No hay encuentros registrados para ${widget.routeName} (id $id).';
        });
      } else {
        // Obtener IDs únicos de pokémon de los encuentros
        final ids = _encounters.map((e) => e.pokemonId).toSet().toList();
        debugPrint('RoutePokemonModal: ids de pokémon a cargar para id $id -> ${ids.toString()}');
        // Cargar datos de pokémon para mostrar tarjetas
        final pokes = await repository.getPokemonsByIds(ids);
        // Reconstruir `Pokemon` simples para evitar referencias inesperadas a objetos complejos
        final safePokes = pokes.map((p) => Pokemon(id: p.id, name: p.name, spriteUrl: p.spriteUrl, types: List<String>.from(p.types))).toList();

        // Log: mostrar pokémon cargados
        try {
          debugPrint('RoutePokemonModal: pokémon cargados para id $id -> ${safePokes.map((p) => {'id': p.id, 'name': p.name}).toList()}');
        } catch (e) {
          debugPrint('RoutePokemonModal: fallo al imprimir pokémon cargados: $e');
        }

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
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: _loadEncounters,
                                          icon: const Icon(Icons.refresh),
                                          label: const Text('Refrescar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      itemCount: _pokemons.length,
                                      itemBuilder: (context, index) {
                                        final pokemon = _pokemons[index];
                                        // Encontrar el encounter correspondiente (por id)
                                        final encounter = _encounters.firstWhere((e) => e.pokemonId == pokemon.id, orElse: () => Encounter(pokemonId: pokemon.id, pokemonName: pokemon.name, method: 'walk', minLevel: 0, maxLevel: 0, rate: 0.0, games: []));
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          child: _DetailedPokemonCard(
                                            pokemon: pokemon,
                                            encounter: encounter,
                                            onTap: () => _navigateToPokemonDetail(pokemon),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
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
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final m = _matches[index];
              final id = m['id'] as int?;
              final name = m['name'] as String? ?? 'Desconocido';
              final locationName = m['locationName'] as String? ?? '';
              return ListTile(
                title: Text(name),
                subtitle: locationName.isNotEmpty ? Text(locationName) : null,
                trailing: id != null ? Text('id $id') : null,
                onTap: id != null ? () => _loadEncountersForId(id, 'location-area') : null,
              );
            },
          ),
        ),
      ],
    );
  }

  void _navigateToPokemonDetail(Pokemon pokemon) async {
    final repo = RepositoryProvider.of<PokemonRepository>(context);

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => PokemonDetailBloc(repository: repo)
            ..add(LoadPokemonDetail(pokemon.id)),
          child: PokemonDetailPage(
            id: pokemon.id,
            repository: repo,
          ),
        ),
      ),
    );
  }
}

// Tarjeta más detallada que incluye info de encuentro (games, method, rate)
class _DetailedPokemonCard extends StatelessWidget {
  final Pokemon pokemon;
  final Encounter encounter;
  final VoidCallback? onTap;

  const _DetailedPokemonCard({required this.pokemon, required this.encounter, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determinar si el encuentro es considerado 'salvaje'
    bool isWildEncounter(Encounter e) {
      final methods = e.method.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
      final whitelist = ['walk', 'surf', 'grass', 'cave', 'old-rod', 'good-rod', 'super-rod', 'fishing', 'fish', 'rock-smash', 'headbutt', 'hidden'];
      for (final m in methods) {
        final low = m.toLowerCase();
        for (final w in whitelist) {
          if (low.contains(w)) return true;
        }
      }
      return false;
    }

    final wild = isWildEncounter(encounter);

    return InkWell(
      onTap: () {
        // Log para depuración: quién hizo tap y qué acción se va a ejecutar
        try {
          debugPrint('RoutePokemonModal: tarjeta pulsada -> pokemon id=${pokemon.id}, name=${pokemon.name}');
        } catch (e) {
          debugPrint('RoutePokemonModal: fallo al imprimir log de tap -> $e');
        }
        onTap?.call();
      },
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
                    Row(
                      children: [
                        Expanded(child: Text('#${pokemon.id.toString().padLeft(3, '0')}', style: TextStyle(color: colorScheme.onSurface.withAlpha(140), fontSize: 11, fontWeight: FontWeight.w600))),
                        if (wild)
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.green.withAlpha(40), borderRadius: BorderRadius.circular(12)),
                            child: const Text('Salvaje', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                          ),
                      ],
                    ),
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
                    const SizedBox(height: 8),
                    // Mostrar info del encuentro: métodos y juegos
                    Row(
                      children: [
                        // métodos como chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: encounter.method.split(',').map((m) => m.trim()).where((m) => m.isNotEmpty).map((m) {
                              return Container(
                                margin: const EdgeInsets.only(right: 6),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: colorScheme.secondary.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                                child: Text(m, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Rate: ${(encounter.rate * 100).toStringAsFixed(0)}%', style: TextStyle(color: colorScheme.onSurface.withAlpha(140), fontSize: 12)),
                        const SizedBox(width: 8),
                        // Mostrar juegos como chips
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: encounter.games.map((g) {
                                return Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: colorScheme.primary.withAlpha(20), borderRadius: BorderRadius.circular(12)),
                                  child: Text(g, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
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
