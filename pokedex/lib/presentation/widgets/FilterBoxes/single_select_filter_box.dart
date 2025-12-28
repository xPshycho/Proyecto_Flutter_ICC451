import 'package:flutter/material.dart';

/// Componente de filtro que permite seleccionar solo una opción a la vez
class SingleSelectFilterBox extends StatefulWidget {
  final String title;
  final List<String> options;
  final String? selectedOption;
  final ValueChanged<String?> onSelectionChanged;

  const SingleSelectFilterBox({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOption,
    required this.onSelectionChanged,
  });

  @override
  State<SingleSelectFilterBox> createState() => _SingleSelectFilterBoxState();
}

class _SingleSelectFilterBoxState extends State<SingleSelectFilterBox> {
  bool _isExpanded = false;

  void _toggleOption(String option) {
    // Si la opción ya está seleccionada, deseleccionarla
    if (widget.selectedOption == option) {
      widget.onSelectionChanged(null);
    } else {
      // Seleccionar la nueva opción (reemplaza la anterior)
      widget.onSelectionChanged(option);
    }
  }

  void _clearSelection() {
    widget.onSelectionChanged(null);
  }

  List<String> _getOrderedOptions() {
    if (widget.selectedOption == null) return widget.options;

    final selected = widget.options.where((opt) => opt == widget.selectedOption).toList();
    final unselected = widget.options.where((opt) => opt != widget.selectedOption).toList();
    return [...selected, ...unselected];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = widget.selectedOption != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con título, botón clear y flecha
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasSelection) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: _clearSelection,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.red.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.red.withAlpha(76),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.close,
                          size: 8,
                          color: Colors.red[700],
                        ),
                        const SizedBox(width: 1),
                        Text(
                          'Clear',
                          style: TextStyle(
                            fontSize: 7,
                            color: Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(width: 4),
              InkWell(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: colorScheme.onSurface.withAlpha(153),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Solo mostrar cuando está expandido
          if (_isExpanded) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _getOrderedOptions().map((option) {
                final isSelected = widget.selectedOption == option;
                return _buildOptionChip(
                  label: option,
                  isSelected: isSelected,
                  onTap: () => _toggleOption(option),
                );
              }).toList(),
            ),
          ] else if (hasSelection) ...[
            // Mostrar la opción seleccionada cuando está colapsado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.selectedOption!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionChip({
    required String label,
    required bool isSelected,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16),
          border: isSelected
              ? Border.all(color: colorScheme.primary.withAlpha(180), width: 1.5)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

