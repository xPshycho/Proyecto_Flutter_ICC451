import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/constants/pokemon_constants.dart';

class TypeFilterBox extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onSelectionChanged;

  const TypeFilterBox({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
  });

  @override
  State<TypeFilterBox> createState() => _TypeFilterBoxState();
}

class _TypeFilterBoxState extends State<TypeFilterBox> {
  bool _isExpanded = false;

  void _toggleOption(String option) {
    final List<String> newSelection = List.from(widget.selectedOptions);
    if (newSelection.contains(option)) {
      newSelection.remove(option);
    } else {
      newSelection.add(option);
    }
    widget.onSelectionChanged(newSelection);
  }

  void _clearSelection() {
    widget.onSelectionChanged([]);
  }

  List<String> _getOrderedOptions() {
    final selected = widget.options.where((opt) => widget.selectedOptions.contains(opt)).toList();
    final unselected = widget.options.where((opt) => !widget.selectedOptions.contains(opt)).toList();
    return [...selected, ...unselected];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelection = widget.selectedOptions.isNotEmpty;

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
                final isSelected = widget.selectedOptions.contains(option);
                return _buildTypeTag(
                  label: option,
                  isSelected: isSelected,
                  isCompact: false,
                  onTap: () => _toggleOption(option),
                );
              }).toList(),
            ),
          ] else if (hasSelection) ...[
            // Solo mostrar count cuando está colapsado y hay selección
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${widget.selectedOptions.length} seleccionado${widget.selectedOptions.length > 1 ? 's' : ''}',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypeTag({
    required String label,
    required bool isSelected,
    required bool isCompact,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final typeColor = PokemonConstants.getTypeColor(label);
    final typeIcon = PokemonConstants.getTypeIcon(label);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? typeColor
              : colorScheme.onSurface.withAlpha(38),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: typeColor.withAlpha(204),
                  width: 1.5,
                )
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (typeIcon != null) ...[
              SvgPicture.asset(
                typeIcon,
                width: 14,
                height: 14,
                colorFilter: ColorFilter.mode(
                  isSelected ? Colors.white : colorScheme.onSurface,
                  BlendMode.srcIn,
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
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
