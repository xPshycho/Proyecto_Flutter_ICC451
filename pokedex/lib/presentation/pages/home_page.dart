import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../widgets/bottom_filter_menu.dart';
import '../widgets/floating_sort_menu.dart';
import '../widgets/bottom_menu.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/pokemon_card.dart';
import '../../data/models/pokemon.dart';
import '../../data/favorites_service.dart';
import 'pokemon_detail_page.dart';
import '../widgets/FilterBoxes/pokemon_type_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  List<Pokemon> _pokemons = [];
  bool _loading = false;
  bool _error = false;
  String _errorMessage = '';
  int _offset = 0;
  final int _limit = 24;
  String _query = '';
  List<String> _typeFilters = [];
  List<String> _categoryFilters = [];
  bool _favorites = false;
  bool _noFavoritos = false;
  List<String> _generations = [];
  String _sortBy = 'id';
  bool _ascending = true;

  // Nuevas variables para filtros seleccionados
  List<String> _selectedTypesSpanish = [];
  List<String> _selectedRegions = [];
  List<String> _selectedGenerations = [];
  List<String> _selectedCategories = [];

  @override
  void initState() {
    super.initState();
    _loadMore();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200 && !_loading && !_error) {
        _loadMore();
      }
    });
  }

  /// Refresca la lista de Pokémon
  Future<void> _refresh() async {
    setState(() {
      _pokemons = [];
      _offset = 0;
    });
    await _loadMore();
  }

  /// Aplica filtros desde el menú
  Future<void> _applyFilterMap(Map<String, dynamic> filters) async {
    final favoritos = filters['favoritos'] as bool? ?? false;
    final noFavoritos = filters['noFavoritos'] as bool? ?? false;
    final tiposSpanish = (filters['tipos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final tiposApi = PokemonTypeColors.toApiTypes(tiposSpanish);
    final regiones = (filters['regiones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final generacionesFromRegions = regiones.map((r) {
      switch (r) {
        case 'Kanto': return '1';
        case 'Johto': return '2';
        case 'Hoenn': return '3';
        case 'Sinnoh': return '4';
        case 'Teselia': return '5';
        case 'Kalos': return '6';
        case 'Alola': return '7';
        case 'Galar': return '8';
        case 'Paldea': return '9';
        default: return '1';
      }
    }).toList();

    // Generaciones seleccionadas explícitamente en el menú
    final generacionesSeleccionadas = (filters['generaciones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    // Categorías seleccionadas
    final categorias = (filters['categorias'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    setState(() {
      _favorites = favoritos;
      _noFavoritos = noFavoritos;
      _typeFilters = tiposApi;
      // Combinar generaciones derivadas de regiones + generaciones explícitas
      _generations = List.from({...generacionesFromRegions, ...generacionesSeleccionadas});
      _categoryFilters = categorias;
      _pokemons = [];
      _offset = 0;

      // Guardar filtros seleccionados para persistencia
      _selectedTypesSpanish = tiposSpanish;
      _selectedRegions = regiones;
      _selectedGenerations = generacionesSeleccionadas;
      _selectedCategories = categorias;
    });

    await _loadMore();
  }

  /// Aplica ordenamiento desde el menú
  Future<void> _applySort(SortOption option, SortOrder order) async {
    String sortBy;
    switch (option) {
      case SortOption.numero:
        sortBy = 'id';
        break;
      case SortOption.nombre:
        sortBy = 'name';
        break;
      case SortOption.tipo:
        sortBy = 'name'; // Placeholder, sorting by type not implemented
        break;
    }
    bool ascending = order == SortOrder.asc;
    setState(() {
      _sortBy = sortBy;
      _ascending = ascending;
      _pokemons = [];
      _offset = 0;
    });
    await _loadMore();
  }

  /// Carga más Pokémon desde el repositorio aplicando filtros
  Future<void> _loadMore() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = '';
    });
    try {
      final repo = Provider.of<PokemonRepository>(context, listen: false);
      final favService = Provider.of<FavoritesService>(context, listen: false);
      final list = await repo.fetchPokemons(
        limit: _limit,
        offset: _offset,
        types: _typeFilters,
        generations: _generations,
        categories: _categoryFilters,
        sortBy: _sortBy,
        ascending: _ascending,
      );
      final filtered = list.where((p) {
        final matchesQuery = _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
        final pTypesApi = p.types.map((t) => t.toLowerCase()).toList();
        final matchesTypes = _typeFilters.isEmpty || pTypesApi.any((t) => _typeFilters.contains(t));
        return matchesQuery && matchesTypes;
      }).toList();

      setState(() {
        _pokemons.addAll(filtered);
        _offset += _limit;
      });

      // Aplicar filtros adicionales
      if (_favorites) {
        setState(() {
          _pokemons = _pokemons.where((p) => favService.isFavorite(p.id)).toList();
        });
      }

      if (_noFavoritos) {
        setState(() {
          _pokemons = _pokemons.where((p) => !favService.isFavorite(p.id)).toList();
        });
      }

      if (_generations.isNotEmpty) {
        final ranges = _generations.map((g) {
          switch (g) {
            case '1': return [1,151];
            case '2': return [152,251];
            case '3': return [252,386];
            case '4': return [387,493];
            case '5': return [494,649];
            case '6': return [650,721];
            case '7': return [722,809];
            case '8': return [810,905];
            case '9': return [906,1000];
          }
          return [0,9999];
        }).toList();
        setState(() {
          _pokemons = _pokemons.where((p) {
            return ranges.any((r) => p.id >= r[0] && p.id <= r[1]);
          }).toList();
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching pokemons: $e');
      debugPrint('$st');
      setState(() {
        _error = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  void _clearAllFilters() {
    setState(() {
      _favorites = false;
      _noFavoritos = false;
      _typeFilters = [];
      _generations = [];
      _categoryFilters = [];
      _selectedTypesSpanish = [];
      _selectedRegions = [];
      _selectedGenerations = [];
      _selectedCategories = [];
      _pokemons = [];
      _offset = 0;
    });
    _loadMore();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          decoration: const InputDecoration(
            hintText: 'Buscar Pokémon...',
            border: InputBorder.none,
            isDense: true,
          ),
          onChanged: (value) {
            _query = value;
            _pokemons = [];
            _offset = 0;
            _loadMore();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterMenu(context, onApplyFilters: (filters) => _applyFilterMap(filters), initialFilters: {
                'favoritos': _favorites,
                'noFavoritos': _noFavoritos,
                'tipos': _selectedTypesSpanish,
                'regiones': _selectedRegions,
                'generaciones': _selectedGenerations,
                'categorias': _selectedCategories,
                'filtro4': [],
                'filtro5': [],
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              showSortMenu(context, onApplySort: (option, order) => _applySort(option, order));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showMenu,
        child: const Icon(Icons.menu),
      ),
    );
  }

  Widget _buildBody() {
    if (_error && _pokemons.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
              const SizedBox(height: 12),
              Text('No se pudieron cargar los Pokémon', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _loadMore, child: const Text('Reintentar')),
            ],
          ),
        ),
      );
    }

    if (_pokemons.isEmpty && _loading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Recopilar filtros activos
    List<String> activeFilters = [];
    if (_favorites) activeFilters.add('Favoritos');
    if (_noFavoritos) activeFilters.add('No Favoritos');
    activeFilters.addAll(_selectedTypesSpanish);
    activeFilters.addAll(_selectedRegions);
    activeFilters.addAll(_selectedGenerations.map((g) => 'Gen $g'));
    activeFilters.addAll(_selectedCategories);

    return Column(
      children: [
        if (activeFilters.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8),
            color: Colors.grey[200],
            child: Row(
              children: [
                const Text('Filtros activos: ', style: TextStyle(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: activeFilters.map((filter) {
                      if (_selectedTypesSpanish.contains(filter)) {
                        return _buildActiveTypeChip(filter);
                      } else {
                        return Chip(
                          label: Text(filter, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.blue[100],
                        );
                      }
                    }).toList(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearAllFilters,
                  tooltip: 'Limpiar filtros',
                ),
              ],
            ),
          ),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              int crossAxisCount = 2;
              double childAspectRatio = 3 / 2.2;
              if (width >= 1200) {
                crossAxisCount = 5;
                childAspectRatio = 3 / 1.8;
              } else if (width >= 1000) {
                crossAxisCount = 4;
                childAspectRatio = 3 / 1.9;
              } else if (width >= 700) {
                crossAxisCount = 3;
                childAspectRatio = 3 / 2.0;
              } else if (width >= 480) {
                crossAxisCount = 2;
                childAspectRatio = 3 / 2.2;
              } else {
                crossAxisCount = 1;
                childAspectRatio = 3 / 1.2;
              }

              return GridView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: childAspectRatio,
                ),
                itemCount: _pokemons.length + (_loading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= _pokemons.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final p = _pokemons[index];
                  return PokemonCard(
                    pokemon: p,
                    onTap: () {
                      final repo = Provider.of<PokemonRepository>(context, listen: false);
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => PokemonDetailPage(id: p.id, repository: repo)));
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  void _showMenu() async {
    await showBottomMenu(
      context,
      onPokedexPressed: () => Navigator.pop(context), // Ya estás aquí
      onMapaPressed: () => debugPrint('Mapa'),
      onHelpPressed: () => debugPrint('Ayuda'),
    );
  }

  Widget _buildActiveTypeChip(String type) {
    final typeColor = PokemonTypeColors.getTypeColor(type);
    final icon = PokemonTypeColors.getTypeIcon(type);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Image.asset(icon, width: 14, height: 14),
            const SizedBox(width: 4),
          ],
          Text(type, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
