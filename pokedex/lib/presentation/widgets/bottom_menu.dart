// dart

import 'package:flutter/material.dart';
import '../models/menu_source.dart';

typedef OnItemSelected = void Function(String item);

class BottomMenu extends StatelessWidget {
  final MenuSource source;
  final OnItemSelected? onItemSelected;

  const BottomMenu({super.key, required this.source, this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    final title = titleForSource(source);
    final items = itemsForSource(source);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.4,
      minChildSize: 0.2,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: ListView(
            controller: scrollController,
            children: [
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
              ...items.map((t) => ListTile(
                    title: Text(t),
                    onTap: () {
                      Navigator.of(context).pop();
                      if (onItemSelected != null) onItemSelected!(t);
                    },
                  )),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }
}

