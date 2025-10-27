import 'package:flutter/material.dart';
import 'FilterBoxes/expandable_filter_box.dart';
import 'FilterBoxes/type_filter_box.dart';

class BottomFilterMenu extends StatefulWidget {
  final Function(Map<String, dynamic>)? onApplyFilters;

  const BottomFilterMenu({
    super.key,
    this.onApplyFilters,
  });

  @override
  State<BottomFilterMenu> createState() => _BottomFilterMenuState();
}

class _BottomFilterMenuState extends State<BottomFilterMenu> {
  // Estado de los filtros
  bool _favoritos = false;
  bool _noFavoritos = false;
  List<String> _categoriasSeleccionadas = [];
  List<String> _tiposSeleccionados = [];
  List<String> _regionesSeleccionadas = [];
  List<String> _filtro4Seleccionados = [];
  List<String> _filtro5Seleccionados = [];

  // Opciones disponibles para cada categoría
  final List<String> _categoriaOptions = [
    'Starter',
    'Mega',
    'Gigantamax',
    'Ultra Bestia',
    'Legendario',
    'Mítico',
  ];

  final List<String> _tipoOptions = [
    'Fuego',
    'Agua',
    'Planta',
    'Eléctrico',
    'Hielo',
    'Lucha',
    'Veneno',
    'Tierra',
    'Volador',
    'Psíquico',
    'Dragón',
    'Hada',
    'Acero',
    'Bicho',
    'Roca',
    'Fantasma',
    'Siniestro',
    'Normal'
  ];

  final List<String> _regionOptions = [
    'Kanto',
    'Johto',
    'Hoenn',
    'Sinnoh',
    'Teselia',
    'Kalos',
    'Alola',
    'Galar',
    'Paldea'
  ];

  final List<String> _filtro4Options = [
    'Opción 1',
    'Opción 2',
    'Opción 3',
    'Opción 4',
  ];

  final List<String> _filtro5Options = [
    'Opción A',
    'Opción B',
    'Opción C',
    'Opción D',
  ];

  void _resetFilters() {
    setState(() {
      _favoritos = false;
      _noFavoritos = false;
      _categoriasSeleccionadas = [];
      _tiposSeleccionados = [];
      _regionesSeleccionadas = [];
      _filtro4Seleccionados = [];
      _filtro5Seleccionados = [];
    });
  }

  void _applyFilters() {
    final filters = {
      'favoritos': _favoritos,
      'noFavoritos': _noFavoritos,
      'categorias': _categoriasSeleccionadas,
      'tipos': _tiposSeleccionados,
      'regiones': _regionesSeleccionadas,
      'filtro4': _filtro4Seleccionados,
      'filtro5': _filtro5Seleccionados,
    };

    if (widget.onApplyFilters != null) {
      widget.onApplyFilters!(filters);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título con línea roja debajo
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Text(
                  'Filtros',
                  style: textTheme.headlineLarge?.copyWith(fontSize: 18),
                ),
              ),
              Container(
                width: 160,
                height: 3,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Contenido de filtros con scroll
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Botones de Favoritos y No Favoritos
                  Row(
                    children: [
                      Expanded(
                        child: _buildChipButton(
                          label: 'Favoritos',
                          icon: Icons.favorite,
                          isSelected: _favoritos,
                          onTap: () => setState(() {
                            _favoritos = !_favoritos;
                            if (_favoritos) _noFavoritos = false;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildChipButton(
                          label: 'Los otros',
                          icon: Icons.heart_broken,
                          isSelected: _noFavoritos,
                          onTap: () => setState(() {
                            _noFavoritos = !_noFavoritos;
                            if (_noFavoritos) _favoritos = false;
                          }),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Categoría
                  ExpandableFilterBox(
                    title: 'Categoría',
                    options: _categoriaOptions,
                    selectedOptions: _categoriasSeleccionadas,
                    onSelectionChanged: (selected) {
                      setState(() => _categoriasSeleccionadas = selected);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Tipo - Usando TypeFilterBox con íconos
                  TypeFilterBox(
                    title: 'Tipo',
                    options: _tipoOptions,
                    selectedOptions: _tiposSeleccionados,
                    onSelectionChanged: (selected) {
                      setState(() => _tiposSeleccionados = selected);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Region
                  ExpandableFilterBox(
                    title: 'Region',
                    options: _regionOptions,
                    selectedOptions: _regionesSeleccionadas,
                    onSelectionChanged: (selected) {
                      setState(() => _regionesSeleccionadas = selected);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Filtro 4
                  ExpandableFilterBox(
                    title: '...',
                    options: _filtro4Options,
                    selectedOptions: _filtro4Seleccionados,
                    onSelectionChanged: (selected) {
                      setState(() => _filtro4Seleccionados = selected);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Filtro 5
                  ExpandableFilterBox(
                    title: '...',
                    options: _filtro5Options,
                    selectedOptions: _filtro5Seleccionados,
                    onSelectionChanged: (selected) {
                      setState(() => _filtro5Seleccionados = selected);
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Botones de acción en la parte inferior
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Botón Restablecer (rojo)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _resetFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFFFF6B6B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Restablecer',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Botón Aplicar (verde)
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Aplicar',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : colorScheme.onSurface.withOpacity(0.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.white : colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Función helper para mostrar el menú desde cualquier parte
void showFilterMenu(BuildContext context, {Function(Map<String, dynamic>)? onApplyFilters}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BottomFilterMenu(onApplyFilters: onApplyFilters),
  );
}
