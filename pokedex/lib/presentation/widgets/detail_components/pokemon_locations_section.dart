import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../../../data/models/pokemon.dart';
import '../../../data/models/location.dart';
import '../../../data/services/map_repository.dart';
import '../../pages/map_page.dart';

/// Sección que muestra las ubicaciones donde aparece un Pokémon.
class PokemonLocationsSection extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonLocationsSection({super.key, required this.pokemon});

  @override
  State<PokemonLocationsSection> createState() => _PokemonLocationsSectionState();
}

class _PokemonLocationsSectionState extends State<PokemonLocationsSection> {
  List<Location> _locations = [];
  bool _isLoading = true;
  String? _error;
  bool _didLoadLocations = false; // bandera para didChangeDependencies

  @override
  void initState() {
    super.initState();
    // NO llamar a _loadLocations() aquí porque usa GraphQLProvider.of(context)
    // que depende de un InheritedWidget; en su lugar llamaremos en didChangeDependencies.
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didLoadLocations) {
      _didLoadLocations = true;
      _loadLocations();
    }
  }

  Future<void> _loadLocations() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final client = GraphQLProvider.of(context).value;
      final repository = MapRepository(client);
      _locations = await repository.getLocationsWithEncountersByPokemon(widget.pokemon.id);
    } catch (e) {
      _error = 'Error al cargar ubicaciones: $e';
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Ubicaciones',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            IconButton(
              icon: const Icon(Icons.map),
              onPressed: () => _navigateToMap(),
              tooltip: 'Ver en mapa',
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red))
        else if (_locations.isEmpty)
          const Text('No hay ubicaciones disponibles')
        else
          _buildGroupedLocations(),
      ],
    );
  }

  Widget _buildGroupedLocations() {
    // Agrupar por región
    final Map<String, List<Location>> grouped = {};
    for (final loc in _locations) {
      grouped.putIfAbsent(loc.region, () => []).add(loc);
    }

    final sortedRegions = grouped.keys.toList()..sort();

    return Column(
      children: sortedRegions.map((region) {
        final locations = grouped[region]!..sort((a, b) => a.name.compareTo(b.name));
        return ExpansionTile(
          title: Text(region, style: Theme.of(context).textTheme.titleMedium),
          children: locations.map((loc) => _buildLocationTile(loc)).toList(),
        );
      }).toList(),
    );
  }

  // --- UI: tarjeta por ubicación más legible y cómodo ---
  Widget _buildLocationTile(Location location) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
      child: Card(
        color: (() {
          final base = Theme.of(context).cardColor;
          final a = (0.9 * 255).round() & 0xFF;
          final r = (base.r * 255.0).round() & 0xFF;
          final g = (base.g * 255.0).round() & 0xFF;
          final b = (base.b * 255.0).round() & 0xFF;
          return Color.fromARGB(a, r, g, b);
        })(),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _openMapAtLocation(location),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono de mapa a la izquierda
                Padding(
                  padding: const EdgeInsets.only(right: 12.0, top: 4.0),
                  child: Icon(Icons.location_on_outlined, size: 28, color: Theme.of(context).colorScheme.primary),
                ),

                // Texto principal y encuentros
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _prettyName(location.name),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),

                      // Resumen compacto de encuentros (líneas con método y niveles)
                      ..._buildEncounterLines(location),

                      const SizedBox(height: 8),

                      // Pequeño hint de región
                      Text(location.region, style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),

                // Botón claro 'Ir al mapa'
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.map_outlined),
                      tooltip: 'Ir al mapa',
                      onPressed: () => _openMapAtLocation(location),
                    ),
                    TextButton(
                      onPressed: () => _openMapAtLocation(location),
                      style: TextButton.styleFrom(minimumSize: const Size(80, 36)),
                      child: const Text('Ir al mapa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildEncounterLines(Location location) {
    if (location.encounters.isEmpty) {
      return [Text('Encuentros: desconocidos', style: Theme.of(context).textTheme.bodySmall)];
    }

    // Agrupar encuentros por (method, min-max, rate) y contar duplicados
    final Map<String, List<dynamic>> groups = {}; // key -> list of encounters
    for (final enc in location.encounters) {
      final key = '${enc.method}::${enc.minLevel}-${enc.maxLevel}::${(enc.rate * 100).toStringAsFixed(4)}';
      groups.putIfAbsent(key, () => []).add(enc);
    }

    // Convertir a líneas ordenadas por prioridad del método (gift/island-scan primero)
    final entries = groups.entries.toList();
    entries.sort((a, b) {
      int score(String method) {
        final low = method.split('::').first.toLowerCase();
        if (low.contains('gift')) return 100;
        if (low.contains('island') || low.contains('island-scan')) return 90;
        if (low.contains('surf') || low.contains('water')) return 80;
        if (low.contains('walking') || low.contains('grass')) return 70;
        return 50;
      }
      final sa = score(a.key);
      final sb = score(b.key);
      return sa.compareTo(sb);
    });
    final sortedEntries = entries.reversed.toList();

    final lines = <Widget>[];
    final maxShow = 3;

    for (var i = 0; i < sortedEntries.length && i < maxShow; i++) {
      final key = sortedEntries[i].key;
      final parts = key.split('::');
      final method = parts[0];
      final range = parts[1];
      final rateStr = parts[2];
      final count = sortedEntries[i].value.length;

      final rate = double.tryParse(rateStr) ?? 0.0;

      final baseChipBg = (() {
        final base = Theme.of(context).colorScheme.surfaceContainerHighest;
        final a = (0.5 * 255).round() & 0xFF;
        final r = (base.r * 255.0).round() & 0xFF;
        final g = (base.g * 255.0).round() & 0xFF;
        final b = (base.b * 255.0).round() & 0xFF;
        return Color.fromARGB(a, r, g, b);
      })();

      lines.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Small method chip
          Container(
            margin: const EdgeInsets.only(right: 8.0, top: 2.0),
            child: Chip(
              backgroundColor: baseChipBg,
              label: Text(_prettyMethod(method), style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
              avatar: _methodIcon(method),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
            ),
          ),

          // Details
          Expanded(
            child: Text('Niv. $range · ${rate.toStringAsFixed(1)}%${count > 1 ? ' · x$count' : ''}',
                style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ));
    }

    if (entries.length > maxShow) {
      lines.add(Text('+${entries.length - maxShow} más', style: Theme.of(context).textTheme.bodySmall));
    }

    return lines;
  }

  Widget? _methodIcon(String method) {
    final m = method.toLowerCase();
    if (m.contains('gift')) return const Icon(Icons.card_giftcard, size: 16, color: Colors.white);
    if (m.contains('island')) return const Icon(Icons.beach_access, size: 16, color: Colors.white);
    if (m.contains('surf') || m.contains('water')) return const Icon(Icons.waves, size: 16, color: Colors.white);
    if (m.contains('walk') || m.contains('grass')) return const Icon(Icons.directions_walk, size: 16, color: Colors.white);
    if (m.contains('fish')) return const Icon(Icons.pool, size: 16, color: Colors.white);
    return const Icon(Icons.circle, size: 12, color: Colors.white70);
  }

  String _prettyMethod(String method) {
    final m = method.toLowerCase();
    if (m.contains('gift')) return 'Regalo';
    if (m.contains('island') || m.contains('island-scan')) return 'Island scan';
    if (m.contains('surf') || m.contains('water')) return 'Surf';
    if (m.contains('walk') || m.contains('grass')) return 'Hierba';
    if (m.contains('fish')) return 'Pesca';
    if (m.contains('headbutt')) return 'Golpe';
    if (m.contains('static') || m.contains('encounter')) return 'Encuentro';
    // Fallback: limpiar y capitalizar
    var s = method.replaceAll('-', ' ').replaceAll('_', ' ').trim();
    if (s.isEmpty) return method;
    return s.split(' ').map((w) => w.isEmpty ? w : (w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : ''))).join(' ');
  }

  void _navigateToMap() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MapPage()),
    );
  }

  void _openMapAtLocation(Location location) {
    // Construir identificador aproximado y manualMap con mejor candidato (manteniendo la API actual Map<String,String>)
    final key = _normalizeIdentifier(location.name);
    final manualMap = _buildManualAreaMap(location);
    final identifier = manualMap[key] ?? _normalizeIdentifier(location.name);

    // Feedback inmediato al usuario
    final msg = 'Abriendo mapa — centrando en ${_prettyName(location.name)}';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MapPage(
          initialRegion: location.region,
          initialRouteIdentifier: identifier,
          manualAreaIdMap: manualMap,
          debugImmediateFocus: true,
        ),
      ),
    );
  }

  /// Genera un mapa manual simple: key normalizada -> candidato escogido.
  /// Mejora la heurística generando varios candidatos y devolviendo el más probable
  /// sin cambiar la firma original (para compatibilidad con MapPage/InteractiveMapWidget).
  Map<String, String> _buildManualAreaMap(Location location) {
    final key = _normalizeIdentifier(location.name);
    final region = location.region.toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '-').replaceAll(RegExp('-+'), '-');

    final id = key;
    final Set<String> candidates = {};

    // Candidate: raw id
    candidates.add(id);

    // region-prefix variants
    candidates.add('$region-$id');
    candidates.add('sea-$region-$id');
    candidates.add('sea-$id');

    // Variantes para rutas (route-1, route1, etc.)
    final routeMatch = RegExp(r'route[-_ ]?(\d+)', caseSensitive: false).firstMatch(id);
    if (routeMatch != null) {
      final routeNum = routeMatch.group(1);
      if (routeNum != null) {
        candidates.add('$region-route-$routeNum');
        candidates.add('$region-sea-route-$routeNum');
        candidates.add('sea-$region-route-$routeNum');
        candidates.add('$region-route-$routeNum-main');
      }
    }

    // Si el id tiene 'area' o 'city', añadir variantes intercambiando palabras comunes
    if (id.contains('area')) {
      candidates.add(id.replaceAll('area', 'city-area'));
      candidates.add(id.replaceAll('area', 'area-main'));
    }
    if (id.contains('city')) {
      candidates.add(id.replaceAll('city', 'city-area'));
    }

    // Priorizar candidatos con region y route
    final prioritized = candidates.toList()
      ..sort((a, b) {
        int score(String s) {
          var sc = 0;
          if (s.contains(region)) sc += 4;
          if (s.contains('route')) sc += 3;
          if (s.startsWith('sea-') || s.contains('sea-route')) sc += 1;
          return -sc; // ordenar descending por score
        }
        return score(a).compareTo(score(b));
      });

    final chosen = prioritized.isNotEmpty ? prioritized.first : id;

    return {key: chosen};
  }

  String _normalizeIdentifier(String name) {
    // Normalizar el nombre para intentar coincidir con los identifiers usados en MapArea
    var id = name.toLowerCase();
    // Reemplazar espacios y caracteres comunes
    id = id.replaceAll(RegExp('[^a-z0-9\-]'), '-');
    id = id.replaceAll(RegExp('-+'), '-');
    id = id.trim();
    if (id.endsWith('-')) id = id.substring(0, id.length - 1);
    if (id.startsWith('-')) id = id.substring(1);
    return id;
  }

  String _prettyName(String raw) {
    // Intentar devolver algo más legible para el usuario: reemplazar '-' por espacios y capitalizar
    final s = raw.replaceAll('-', ' ').trim();
    return s.splitMapJoin(RegExp(r"\b"), onMatch: (m) => m.group(0)!, onNonMatch: (n) => n).split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + (w.length > 1 ? w.substring(1) : '');
    }).join(' ');
  }
}
