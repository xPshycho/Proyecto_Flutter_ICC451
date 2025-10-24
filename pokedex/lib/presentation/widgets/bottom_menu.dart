import 'package:flutter/material.dart';
import '../models/menu_source.dart';
import '../models/region.dart';
import 'regional_grid_view.dart';

typedef OnItemSelected = void Function(String item);
typedef OnRegionSelected = void Function(Region region);

class BottomMenu extends StatelessWidget {
  final MenuSource source;
  final OnItemSelected? onItemSelected;
  final OnRegionSelected? onRegionSelected;

  const BottomMenu({
    super.key,
    required this.source,
    this.onItemSelected,
    this.onRegionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final title = titleForSource(source);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(title, style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 8),
              const Divider(),

              Expanded(
                child: source == MenuSource.regional
                    ? _buildRegionalContent(context, scrollController)
                    : _buildDefaultContent(context, scrollController),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRegionalContent(BuildContext context, ScrollController scrollController) {
    return SingleChildScrollView(
      controller: scrollController,
      child: RegionalGridView(
        onRegionSelected: (region) {
          Navigator.of(context).pop();
          if (onRegionSelected != null) {
            onRegionSelected!(region);
          }
          if (onItemSelected != null) {
            onItemSelected!(region.name);
          }
        },
      ),
    );
  }

  Widget _buildDefaultContent(BuildContext context, ScrollController scrollController) {
    final items = itemsForSource(source);

    return ListView(
      controller: scrollController,
      children: [
        ...items.map((t) => ListTile(
              title: Text(t),
              onTap: () {
                Navigator.of(context).pop();
                if (onItemSelected != null) onItemSelected!(t);
              },
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}
