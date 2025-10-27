import 'package:flutter/material.dart';

import '../widgets/search_box.dart';
import '../widgets/bottom_filter_menu.dart';
import '../widgets/floating_sort_menu.dart';
import '../widgets/bottom_menu.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  static const double _bottomSpacerHeight = 300.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pokedex button
              Align(
                alignment: Alignment.center,
                child: TextButton.icon(
                  onPressed: () {
                    showBottomMenu(
                      context,
                      onPokedexPressed: () {
                        debugPrint('Pokedex Nacional presionado');
                        Navigator.pop(context);
                      },
                      onMapaPressed: () {
                        debugPrint('Mapa presionado');
                        Navigator.pop(context);
                      },
                      onHelpPressed: () {
                        debugPrint('Ayuda presionado');
                        Navigator.pop(context);
                      },
                    );
                  },
                  icon: const Icon(Icons.menu_book_outlined, size: 32),
                  label: const Text('Pokedex', style: TextStyle(fontSize: 20)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  ),
                ),
              ),

              // Search box and filter icons row
              Row(
                children: [
                  // Search box
                  Expanded(
                    child: SearchBox(
                      hintText: 'Buscar Pokemon',
                      height: 32.0,
                      onChanged: (value) {
                        debugPrint('Searching for: $value');
                      },

                    ),
                  ),
                  const SizedBox(width: 8),

                  // Sort button
                  IconButton(
                    onPressed: () {
                      showSortMenu(
                        context,
                        onApplySort: (option, order) {
                          debugPrint('Ordenar por: $option, orden: $order');
                        },
                      );
                    },
                    icon: const Icon(Icons.sort, size: 32),
                    tooltip: 'Sort',
                    color: colorScheme.onSurface,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),


                  // Filter icon button
                  IconButton(
                    onPressed: () {
                      showFilterMenu(
                        context,
                        onApplyFilters: (filters) {
                          debugPrint('Filtros aplicados: $filters');
                        },
                      );
                    },
                    icon: const Icon(Icons.filter_alt, size: 32),
                    tooltip: 'Filter',
                    color: colorScheme.onSurface,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              SizedBox(height: _bottomSpacerHeight),
            ],
          ),
        ),
      ),
    );
  }
}
