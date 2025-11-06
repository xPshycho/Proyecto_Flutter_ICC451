import 'package:flutter/material.dart';

class ExpandableFilterBox extends StatefulWidget {
  final String title;
  final List<String> options;
  final List<String> selectedOptions;
  final ValueChanged<List<String>> onSelectionChanged;

  const ExpandableFilterBox({
    super.key,
    required this.title,
    required this.options,
    required this.selectedOptions,
    required this.onSelectionChanged,
  });

  @override
  State<ExpandableFilterBox> createState() => _ExpandableFilterBoxState();
}

class _ExpandableFilterBoxState extends State<ExpandableFilterBox> {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    if (hasSelection) ...[
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: _clearSelection,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
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
                                size: 10,
                                color: Colors.red[700],
                              ),
                              const SizedBox(width: 2),
                              Text(
                                'Clear',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
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

          // Preview de selección o N/A
          if (!_isExpanded) ...[
            if (hasSelection)
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: widget.selectedOptions.map((option) {
                  return _buildTag(
                    label: option,
                    isSelected: true,
                    isCompact: true,
                  );
                }).toList(),
              )
            else
              _buildNATag(),
          ],

          // Lista expandida de opciones
          if (_isExpanded) ...[
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _getOrderedOptions().map((option) {
                final isSelected = widget.selectedOptions.contains(option);
                return _buildTag(
                  label: option,
                  isSelected: isSelected,
                  isCompact: false,
                  onTap: () => _toggleOption(option),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNATag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'N/A',
        style: TextStyle(
          fontSize: 10,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTag({
    required String label,
    required bool isSelected,
    required bool isCompact,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isCompact ? 10 : 12,
          vertical: isCompact ? 5 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF4CAF50)
              : colorScheme.onSurface.withAlpha(38),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF388E3C),
                  width: 1.5,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: isCompact ? 9 : 10,
            color: isSelected ? Colors.black : colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
