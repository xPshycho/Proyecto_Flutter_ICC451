import 'package:flutter/material.dart';

enum SortOption {
  numero,
  tipo,
  nombre,
}

enum SortOrder {
  asc,
  desc,
}

class FloatingSortMenu extends StatefulWidget {
  final Function(SortOption, SortOrder)? onApplySort;

  const FloatingSortMenu({
    super.key,
    this.onApplySort,
  });

  @override
  State<FloatingSortMenu> createState() => _FloatingSortMenuState();
}

class _FloatingSortMenuState extends State<FloatingSortMenu> {
  SortOption _selectedOption = SortOption.numero; // Numero seleccionado por defecto
  SortOrder _sortOrder = SortOrder.asc;

  void _selectOption(SortOption option) {
    setState(() {
      _selectedOption = option;
    });
  }

  void _resetSelection() {
    setState(() {
      _selectedOption = SortOption.numero;
      _sortOrder = SortOrder.asc;
    });
    Navigator.pop(context);
  }

  void _applySort() {
    if (_selectedOption != null && widget.onApplySort != null) {
      widget.onApplySort!(_selectedOption!, _sortOrder);
    }
    Navigator.pop(context);
  }

  String _getOptionLabel(SortOption option) {
    switch (option) {
      case SortOption.numero:
        return 'Numero';
      case SortOption.tipo:
        return 'Tipo';
      case SortOption.nombre:
        return 'Nombre';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título "Ordenar" con línea roja
            Column(
              children: [
                Text(
                  'Ordenar',
                  style: textTheme.headlineLarge?.copyWith(fontSize: 20),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 200,
                  height: 3,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Opciones de ordenamiento y botones ASC/DESC
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Columna de opciones
                Expanded(
                  child: Column(
                    children: [
                      _buildSortButton(
                        label: _getOptionLabel(SortOption.numero),
                        isSelected: _selectedOption == SortOption.numero,
                        onTap: () => _selectOption(SortOption.numero),
                      ),
                      const SizedBox(height: 12),
                      _buildSortButton(
                        label: _getOptionLabel(SortOption.tipo),
                        isSelected: _selectedOption == SortOption.tipo,
                        onTap: () => _selectOption(SortOption.tipo),
                      ),
                      const SizedBox(height: 12),
                      _buildSortButton(
                        label: _getOptionLabel(SortOption.nombre),
                        isSelected: _selectedOption == SortOption.nombre,
                        onTap: () => _selectOption(SortOption.nombre),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Botones ASC/DESC
                Column(
                  children: [
                    const SizedBox(height: 16),
                    _buildOrderButton(
                      label: 'ASC',
                      icon: Icons.arrow_upward,
                      isSelected: _sortOrder == SortOrder.asc,
                      onTap: () => setState(() => _sortOrder = SortOrder.asc),
                    ),
                    const SizedBox(height: 12),
                    _buildOrderButton(
                      label: 'DSC',
                      icon: Icons.arrow_downward,
                      isSelected: _sortOrder == SortOrder.desc,
                      onTap: () => setState(() => _sortOrder = SortOrder.desc),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Botones de acción circulares
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Botón Cancelar circular (rojo con X)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _resetSelection,
                    backgroundColor: const Color(0xFFFF6B6B),
                    heroTag: 'cancel_sort_button',
                    elevation: 0,
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Botón Aplicar circular (verde con checkmark)
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    onPressed: _applySort,
                    backgroundColor: const Color(0xFF4CAF50),
                    heroTag: 'apply_sort_button',
                    elevation: 0,
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSortButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5A5A72)
              : colorScheme.onSurface.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : colorScheme.onSurface,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF5A5A72)
              : colorScheme.onSurface.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? Colors.white : colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Icon(
              icon,
              size: 24,
              color: isSelected ? Colors.white : colorScheme.onSurface,
            ),
          ],
        ),
      ),
    );
  }
}

// Función helper para mostrar el menú desde cualquier parte
void showSortMenu(BuildContext context, {Function(SortOption, SortOrder)? onApplySort}) {
  showDialog(
    context: context,
    builder: (context) => FloatingSortMenu(onApplySort: onApplySort),
  );
}
