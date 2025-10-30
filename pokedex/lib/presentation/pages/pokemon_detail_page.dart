import 'package:flutter/material.dart';
import '../../data/models/pokemon.dart';
import '../../data/repositories/pokemon_repository.dart';

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
                if (p.spriteUrl != null) Center(child: Image.network(p.spriteUrl!, width: 200, height: 200)),
                const SizedBox(height: 12),
                Text('#${p.id.toString().padLeft(3, '0')}', style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 8),
                Text(p.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: p.types.map((t) => Chip(label: Text(t))).toList()),
                const SizedBox(height: 12),
                if (p.height != null || p.weight != null) Row(children: [
                  if (p.height != null) Text('Altura: ${p.height}'),
                  const SizedBox(width: 16),
                  if (p.weight != null) Text('Peso: ${p.weight}'),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }
}

