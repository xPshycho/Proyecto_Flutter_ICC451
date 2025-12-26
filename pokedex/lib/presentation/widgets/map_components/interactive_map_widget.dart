import 'package:flutter/material.dart';

/// Widget para mostrar un mapa interactivo con áreas clicables.
class InteractiveMapWidget extends StatefulWidget {
  final String mapImagePath;
  final List<MapArea> areas;
  final double imageWidth;
  final double imageHeight;
  // Ahora onAreaTap recibe el objeto MapArea para permitir pasar un `identifier` PokeAPI
  final Function(MapArea area)? onAreaTap;

  const InteractiveMapWidget({
    super.key,
    required this.mapImagePath,
    required this.areas,
    required this.imageWidth,
    required this.imageHeight,
    this.onAreaTap,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> {
  final TransformationController _transformationController = TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate scale to fit the image in the container
        final scaleX = constraints.maxWidth / widget.imageWidth;
        final scaleY = constraints.maxHeight / widget.imageHeight;
        final scale = scaleX < scaleY ? scaleX : scaleY;

        final scaledWidth = widget.imageWidth * scale;
        final scaledHeight = widget.imageHeight * scale;

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          child: Center(
            child: SizedBox(
              width: scaledWidth,
              height: scaledHeight,
              child: Stack(
                children: [
                  Image.asset(
                    widget.mapImagePath,
                    fit: BoxFit.fill,
                    width: scaledWidth,
                    height: scaledHeight,
                  ),
                  ...widget.areas.map((area) {
                    final scaledRect = Rect.fromLTRB(
                      area.rect.left * scale,
                      area.rect.top * scale,
                      area.rect.right * scale,
                      area.rect.bottom * scale,
                    );
                    return Positioned(
                      left: scaledRect.left,
                      top: scaledRect.top,
                      width: scaledRect.width,
                      height: scaledRect.height,
                      child: GestureDetector(
                        onTap: () => widget.onAreaTap?.call(area),
                        child: Container(
                          color: Colors.transparent, // Invisible, but clickable
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Modelo para representar un área clicable en el mapa.
class MapArea {
  final String name; // nombre amigable para mostrar
  final Rect rect;
  final String? identifier; // identificador PokeAPI (ej. 'kanto-route-1' o 'pallet-town')

  MapArea({
    required this.name,
    required this.rect,
    this.identifier,
  });
}
