import 'package:flutter/material.dart';

class MovesSortWidget extends StatelessWidget {
  final String? currentSortBy;
  final bool currentAscending;
  final Function(String sortBy, bool ascending)? onSortChanged;

  const MovesSortWidget({
    super.key,
    this.currentSortBy,
    this.currentAscending = true,
    this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Text(
            'Ordenar por:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSortChip('Nombre', 'name'),
                  const SizedBox(width: 8),
                  _buildSortChip('Nivel', 'level'),
                  const SizedBox(width: 8),
                  _buildSortChip('Poder', 'power'),
                  const SizedBox(width: 8),
                  _buildSortChip('Tipo', 'type'),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Botón para cambiar orden ascendente/descendente
          if (currentSortBy != null)
            IconButton(
              onPressed: () {
                onSortChanged?.call(currentSortBy!, !currentAscending);
              },
              icon: Icon(
                currentAscending ? Icons.arrow_upward : Icons.arrow_downward,
                color: Theme.of(context).primaryColor,
              ),
              tooltip: currentAscending ? 'Orden descendente' : 'Orden ascendente',
            ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String sortKey) {
    final isSelected = currentSortBy == sortKey;

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : null,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onSortChanged?.call(sortKey, currentAscending);
        } else {
          onSortChanged?.call('name', true);
        }
      },
      selectedColor: Colors.blue,
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? Colors.blue : Colors.grey.shade300,
      ),
    );
  }
}
