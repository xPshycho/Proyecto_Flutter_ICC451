import 'package:flutter/material.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../widgets/pokemon_card.dart';
import 'pokemon_detail_page.dart';
import '../widgets/bottom_filter_menu.dart';
import '../widgets/FilterBoxes/pokemon_type_colors.dart';

class PokedexListPage extends StatefulWidget {
  final PokemonRepository repository;
  const PokedexListPage({super.key, required this.repository});

  @override
  State<PokedexListPage> createState() => _PokedexListPageState();
}

class _PokedexListPageState extends State<PokedexListPage> {
  final ScrollController _scrollController = ScrollController();
  List<Pokemon> _pokemons = [];
  bool _loading = false;
  bool _error = false;
  String _errorMessage = '';
  int _offset = 0;
  final int _limit = 24;
  String _query = '';
  List<String> _typeFilters = [];

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

  Future<void> _refresh() async {
    setState(() {
      _pokemons = [];
      _offset = 0;
    });
    await _loadMore();
  }

  Future<void> _applyFilterMap(Map<String, dynamic> filters) async {
    final tiposSpanish = (filters['tipos'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final tiposApi = PokemonTypeColors.toApiTypes(tiposSpanish);
    setState(() {
      _typeFilters = tiposApi; // ahora _typeFilters guarda nombres en esquema API
      _pokemons = [];
      _offset = 0;
    });
    await _loadMore();
  }

  Future<void> _loadMore() async {
    setState(() {
      _loading = true;
      _error = false;
      _errorMessage = '';
    });
    try {
      final list = await widget.repository.fetchPokemons(limit: _limit, offset: _offset, types: _typeFilters);
      final filtered = list.where((p) {
        final matchesQuery = _query.isEmpty || p.name.toLowerCase().contains(_query.toLowerCase());
        // Aquí p.types pueden venir en inglés (from REST) o en español según origen;
        // Normalizamos a lowercase inglés para comparar con _typeFilters (que están en api names)
        final pTypesApi = p.types.map((t) => t.toLowerCase()).toList();
        final matchesTypes = _typeFilters.isEmpty || pTypesApi.any((t) => _typeFilters.contains(t));
        return matchesQuery && matchesTypes;
      }).toList();

      setState(() {
        _pokemons.addAll(filtered);
        _offset += _limit;
      });
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
          onChanged: (v) {
            _query = v;
            _pokemons = [];
            _offset = 0;
            _loadMore();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              showFilterMenu(context, onApplyFilters: (filters) => _applyFilterMap(filters));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: _buildBody(),
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

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 3 / 1.2,
      ),
      itemCount: _pokemons.length + (_loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _pokemons.length) return const Padding(
          padding: EdgeInsets.symmetric(vertical: 24.0),
          child: Center(child: CircularProgressIndicator()),
        );

        final p = _pokemons[index];
        return PokemonCard(
          pokemon: p,
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => PokemonDetailPage(id: p.id, repository: widget.repository)));
          },
        );
      },
    );
  }
}
