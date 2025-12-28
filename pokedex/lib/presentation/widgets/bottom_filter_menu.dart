import 'package:flutter/material.dart';
import 'FilterBoxes/single_select_filter_box.dart';
import 'FilterBoxes/type_filter_box.dart';

class FilterOptions {
  static const categorias = [
    'Starter',
    'Mega',
    'Gigantamax',
    'Legendario',
    'Mítico',
  ];

  static const tipos = [
    'Fuego', 'Agua', 'Planta', 'Eléctrico',
    'Hielo', 'Lucha', 'Veneno', 'Tierra',
    'Volador', 'Psíquico', 'Dragón', 'Hada',
    'Acero', 'Bicho', 'Roca', 'Fantasma',
    'Siniestro', 'Normal'
  ];

  static const regiones = [
    'Kanto', 'Johto', 'Hoenn', 'Sinnoh',
    'Teselia', 'Kalos', 'Alola', 'Galar', 'Paldea'
  ];
}

class BottomFilterMenu extends StatefulWidget {
  final Function(Map<String, dynamic>)? onApplyFilters;
  final Map<String, dynamic>? initialFilters;

  const BottomFilterMenu({
    super.key,
    this.onApplyFilters,
    this.initialFilters,
  });

  @override
  State<BottomFilterMenu> createState() => _BottomFilterMenuState();
}

class _BottomFilterMenuState extends State<BottomFilterMenu> {
  bool _favoritos = false;
  bool _noFavoritos = false;
  String? _categoriaSeleccionada;
  List<String> _tiposSeleccionados = [];
  String? _regionSeleccionada;

  @override
  void initState() {
    super.initState();
    _initializeFilters();
  }

  void _initializeFilters() {
    if (widget.initialFilters != null) {
      final filters = widget.initialFilters!;
      setState(() {
        _favoritos = filters['favoritos'] ?? false;
        _noFavoritos = filters['noFavoritos'] ?? false;

        // Para categorías: tomar solo la primera si hay múltiples
        final categorias = filters['categorias'] as List<dynamic>?;
        _categoriaSeleccionada = (categorias != null && categorias.isNotEmpty)
            ? categorias.first.toString()
            : null;

        // Para tipos: máximo 2
        final tipos = filters['tipos'] as List<dynamic>?;
        _tiposSeleccionados = tipos != null
            ? tipos.take(2).map((e) => e.toString()).toList()
            : [];

        // Para regiones: tomar solo la primera si hay múltiples
        final regiones = filters['regiones'] as List<dynamic>?;
        _regionSeleccionada = (regiones != null && regiones.isNotEmpty)
            ? regiones.first.toString()
            : null;
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _favoritos = false;
      _noFavoritos = false;
      _categoriaSeleccionada = null;
      _tiposSeleccionados = [];
      _regionSeleccionada = null;
    });
  }

  void _applyFilters() {
    final filters = {
      'favoritos': _favoritos,
      'noFavoritos': _noFavoritos,
      'categorias': _categoriaSeleccionada != null ? [_categoriaSeleccionada] : [],
      'tipos': _tiposSeleccionados,
      'regiones': _regionSeleccionada != null ? [_regionSeleccionada] : [],
    };

    widget.onApplyFilters?.call(filters);
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
              color: colorScheme.onSurface.withAlpha(76),
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

                  // Categoría - SELECCIÓN ÚNICA
                  SingleSelectFilterBox(
                    title: 'Categoría',
                    options: FilterOptions.categorias,
                    selectedOption: _categoriaSeleccionada,
                    onSelectionChanged: (selected) {
                      setState(() => _categoriaSeleccionada = selected);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Tipo - Máximo 2 selecciones con TypeFilterBox
                  TypeFilterBox(
                    title: 'Tipo',
                    options: FilterOptions.tipos,
                    selectedOptions: _tiposSeleccionados,
                    onSelectionChanged: (selected) {
                      setState(() => _tiposSeleccionados = selected);
                    },
                  ),

                  const SizedBox(height: 8),

                  // Region - SELECCIÓN ÚNICA
                  SingleSelectFilterBox(
                    title: 'Region',
                    options: FilterOptions.regiones,
                    selectedOption: _regionSeleccionada,
                    onSelectionChanged: (selected) {
                      setState(() => _regionSeleccionada = selected);
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
    final backgroundColor = isSelected
        ? colorScheme.primary
        : colorScheme.onSurface.withAlpha(20);
    final foregroundColor = isSelected
        ? Colors.white
        : colorScheme.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(25),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: foregroundColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: foregroundColor,
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
void showFilterMenu(BuildContext context, {Function(Map<String, dynamic>)? onApplyFilters, Map<String, dynamic>? initialFilters}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BottomFilterMenu(onApplyFilters: onApplyFilters, initialFilters: initialFilters),
  );
}
