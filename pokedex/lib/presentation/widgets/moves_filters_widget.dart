import 'package:flutter/material.dart';
import 'FilterBoxes/expandable_filter_box.dart';

class MovesFiltersWidget extends StatefulWidget {
  final List<String>? selectedTypes;
  final List<String>? selectedLearnMethods;
  final List<String>? selectedVersionGroups;
  final String? searchQuery;
  final Function(List<String>? types, List<String>? methods, List<String>? versions)? onFiltersChanged;
  final Function(String query)? onSearchChanged;
  final VoidCallback? onClearFilters;

  const MovesFiltersWidget({
    super.key,
    this.selectedTypes,
    this.selectedLearnMethods,
    this.selectedVersionGroups,
    this.searchQuery,
    this.onFiltersChanged,
    this.onSearchChanged,
    this.onClearFilters,
  });

  @override
  State<MovesFiltersWidget> createState() => _MovesFiltersWidgetState();
}

class _MovesFiltersWidgetState extends State<MovesFiltersWidget> {
  late List<String> _selectedTypes;
  late List<String> _selectedMethods;
  late List<String> _selectedVersions;
  late TextEditingController _searchController;

  static const List<String> _availableTypes = [
    'Normal', 'Fuego', 'Agua', 'Planta', 'Eléctrico', 'Hielo', 'Lucha', 'Veneno',
    'Tierra', 'Volador', 'Psíquico', 'Bicho', 'Roca', 'Fantasma', 'Dragón',
    'Siniestro', 'Acero', 'Hada'
  ];

  static const List<String> _availableMethods = [
    'Por nivel', 'MT/MO', 'Tutor', 'Por herencia', 'Herencia especial'
  ];

  static const List<String> _availableVersions = [
    'Rojo/Azul', 'Oro/Plata', 'Rubí/Zafiro', 'Diamante/Perla', 'Negro/Blanco',
    'X/Y', 'Sol/Luna', 'Espada/Escudo', 'Escarlata/Púrpura'
  ];

  @override
  void initState() {
    super.initState();
    _selectedTypes = List.from(widget.selectedTypes ?? []);
    _selectedMethods = List.from(widget.selectedLearnMethods ?? []);
    _selectedVersions = List.from(widget.selectedVersionGroups ?? []);
    _searchController = TextEditingController(text: widget.searchQuery ?? '');
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters() {
    widget.onFiltersChanged?.call(
      _selectedTypes.isEmpty ? null : _selectedTypes,
      _selectedMethods.isEmpty ? null : _selectedMethods,
      _selectedVersions.isEmpty ? null : _selectedVersions,
    );
  }

  void _clearAllFilters() {
    setState(() {
      _selectedTypes.clear();
      _selectedMethods.clear();
      _selectedVersions.clear();
      _searchController.clear();
    });
    widget.onClearFilters?.call();
  }

  bool get _hasActiveFilters =>
      _selectedTypes.isNotEmpty ||
      _selectedMethods.isNotEmpty ||
      _selectedVersions.isNotEmpty ||
      _searchController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header con título y botón limpiar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros de movimientos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_hasActiveFilters)
                TextButton.icon(
                  onPressed: _clearAllFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Limpiar'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Barra de búsqueda
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              labelText: 'Buscar movimiento',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        widget.onSearchChanged?.call('');
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onChanged: (value) {
              widget.onSearchChanged?.call(value);
            },
          ),

          const SizedBox(height: 16),

          // Filtros expandibles
          ExpandableFilterBox(
            title: 'Tipos',
            options: _availableTypes,
            selectedOptions: _selectedTypes,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedTypes = selected;
              });
              _updateFilters();
            },
          ),

          const SizedBox(height: 12),

          ExpandableFilterBox(
            title: 'Método de aprendizaje',
            options: _availableMethods,
            selectedOptions: _selectedMethods,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedMethods = selected;
              });
              _updateFilters();
            },
          ),

          const SizedBox(height: 12),

          ExpandableFilterBox(
            title: 'Versión del juego',
            options: _availableVersions,
            selectedOptions: _selectedVersions,
            onSelectionChanged: (selected) {
              setState(() {
                _selectedVersions = selected;
              });
              _updateFilters();
            },
          ),
        ],
      ),
    );
  }
}
