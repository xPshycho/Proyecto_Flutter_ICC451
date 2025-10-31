import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';
import '../../data/favorites_service.dart';
import '../../core/constants/pokemon_constants.dart';

class PokemonDetailPage extends StatefulWidget {
  final int id;
  final PokemonRepository repository;
  const PokemonDetailPage({super.key, required this.id, required this.repository});

  @override
  State<PokemonDetailPage> createState() => _PokemonDetailPageState();
}

class _PokemonDetailPageState extends State<PokemonDetailPage> {
  late Future<Pokemon> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.repository.fetchPokemonDetail(widget.id);
  }

  @override
  Widget build(BuildContext context) {
    final favService = Provider.of<FavoritesService>(context, listen: true);
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle')),
      body: FutureBuilder<Pokemon>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final p = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (p.spriteUrl != null) Image.network(p.spriteUrl!, width: 160, height: 160),
                    IconButton(
                      icon: Icon(favService.isFavorite(p.id) ? Icons.favorite : Icons.favorite_border, color: favService.isFavorite(p.id) ? Colors.red : null),
                      onPressed: () => favService.toggleFavorite(p),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('#${p.id.toString().padLeft(3, '0')}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(p.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: p.types.map((t) {
                  final typeColor = PokemonConstants.getTypeColor(t);
                  final icon = PokemonConstants.getTypeIcon(t);
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Image.asset(icon, width: 14, height: 14),
                          const SizedBox(width: 6),
                        ],
                        Text(t, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  );
                }).toList()),
                const SizedBox(height: 12),
                if (p.height != null || p.weight != null) Row(children: [
                  if (p.height != null) Text('Altura: ${p.height}'),
                  const SizedBox(width: 16),
                  if (p.weight != null) Text('Peso: ${p.weight}'),
                ]),
                const SizedBox(height: 12),
                if (p.abilities.isNotEmpty) ...[
                  const Text('Habilidades', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Wrap(spacing: 6, children: p.abilities.map((a) => Chip(label: Text(a))).toList()),
                  const SizedBox(height: 12),
                ],
                if (p.stats.isNotEmpty) ...[
                  const Text('Stats', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    children: p.stats.entries.map((e) => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [Text(e.key), Text(e.value.toString())],
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                ],
                if (p.evolutions != null && p.evolutions!.isNotEmpty) ...[
                  const Text('Evoluciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Column(
                    children: p.evolutions!.map((ev) => ListTile(
                      leading: ev.spriteUrl != null ? Image.network(ev.spriteUrl!, width: 56, height: 56) : null,
                      title: Text(ev.name),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PokemonDetailPage(id: ev.id, repository: widget.repository)));
                      },
                    )).toList(),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
