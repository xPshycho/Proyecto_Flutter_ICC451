import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;
import 'dart:math' as math;

/// Widget para mostrar un mapa interactivo con áreas clicables.
class InteractiveMapWidget extends StatefulWidget {
  final String mapImagePath;
  final List<MapArea> areas;
  final double imageWidth;
  final double imageHeight;
  // Ahora onAreaTap recibe el objeto MapArea para permitir pasar un `identifier` PokeAPI
  final Function(MapArea area)? onAreaTap;

  // Identificador (o nombre) de área que se desea enfocar al abrir
  final String? initialAreaIdentifier;
  // Zoom deseado al enfocar (opcional). Si null, se calcula automáticamente.
  final double? initialZoom;

  // Mapeo manual opcional: normalizado locationName -> areaIdentifier
  final Map<String, String>? manualAreaIdMap;
  final bool debugImmediateFocus;

  const InteractiveMapWidget({
    super.key,
    required this.mapImagePath,
    required this.areas,
    required this.imageWidth,
    required this.imageHeight,
    this.onAreaTap,
    this.initialAreaIdentifier,
    this.initialZoom,
    this.manualAreaIdMap,
    this.debugImmediateFocus = false,
  });

  @override
  State<InteractiveMapWidget> createState() => _InteractiveMapWidgetState();
}

class _InteractiveMapWidgetState extends State<InteractiveMapWidget> with TickerProviderStateMixin {
  final TransformationController _transformationController = TransformationController();
  late final AnimationController _animController;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnim;
  bool _hasFocused = false; // para que el enfoque ocurra solo una vez

  // Rect en coordenadas de pantalla para resaltar el área (scaled)
  Rect? _highlightRect;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 420));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.06).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
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

        // Si se pide enfocar una área, programar el cálculo pos-frame
        if (!_hasFocused && widget.initialAreaIdentifier != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Esperar un poco para asegurar que InteractiveViewer esté completamente montado
            await Future.delayed(const Duration(milliseconds: 80));
            debugPrint('InteractiveMapWidget: requesting focus for identifier=${widget.initialAreaIdentifier}');
            await _focusAreaIfRequested(constraints, scale, scaledWidth, scaledHeight);
          });
        }

        return InteractiveViewer(
          transformationController: _transformationController,
          minScale: 0.5,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          boundaryMargin: const EdgeInsets.all(2000),
          clipBehavior: Clip.none,
          constrained: false,
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

                  // Áreas clicables (invisibles)
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
                          color: Colors.transparent, // Invisible, pero clickable
                        ),
                      ),
                    );
                  }),

                  // Highlight overlay (si existe) con animación de pulso
                  if (_highlightRect != null)
                    Positioned(
                      left: _highlightRect!.left,
                      top: _highlightRect!.top,
                      width: _highlightRect!.width,
                      height: _highlightRect!.height,
                      child: IgnorePointer(
                        child: AnimatedBuilder(
                          animation: _pulseAnim,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnim.value,
                              alignment: Alignment.center,
                              child: child,
                            );
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.yellow.withOpacity(0.12),
                              border: Border.all(color: Colors.yellowAccent.withOpacity(0.9), width: 2),
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
          ),
        );
      },
    );
  }

  Future<void> _focusAreaIfRequested(BoxConstraints constraints, double scale, double scaledWidth, double scaledHeight) async {
    if (_hasFocused) return;
    final id = widget.initialAreaIdentifier!.toLowerCase().trim();

    // First, if a manual map exists, try to map `id` -> explicit identifier
    String? manualTargetId;
    if (widget.manualAreaIdMap != null) {
      // Buscar la entrada manual más cercana comparando la clave con _looselyMatches
      for (final entry in widget.manualAreaIdMap!.entries) {
        final k = entry.key.toLowerCase().trim();
        if (_looselyMatches(_normalizeKey(k), id) || _looselyMatches(k, id)) {
          manualTargetId = entry.value.toLowerCase().trim();
          debugPrint('InteractiveMapWidget: manualAreaIdMap hit -> key=${entry.key} value=${entry.value} for id=$id');
          break;
        }
      }
      if (manualTargetId == null) {
        debugPrint('InteractiveMapWidget: manualAreaIdMap had no tolerant match for id=$id; keys=${widget.manualAreaIdMap!.keys.toList()}');
      }
    }

    // Buscar un área cuyo identificador candidato o nombre coincida (heurística tolerante)
    MapArea? match;

    if (manualTargetId != null) {
      for (final area in widget.areas) {
        // probar todos los candidateIdentifiers con comparación laxa
        final candidates = area.candidateIdentifiers.map((e) => e.toLowerCase().trim());
        bool found = false;
        for (final c in candidates) {
          if (_looselyMatches(c, manualTargetId)) {
            debugPrint('InteractiveMapWidget: manual match candidate $c matches manualTargetId=$manualTargetId for area=${area.name}');
            found = true;
            break;
          }
        }
        if (found || (area.identifier != null && _looselyMatches(area.identifier!, manualTargetId)) || _looselyMatches(_normalizeKey(area.name), manualTargetId)) {
          match = area;
          break;
        }
      }
    }

    // Si no hay match todavía, buscar por identifiers y name como antes
    if (match == null) {
      for (final area in widget.areas) {
        final candidates = area.candidateIdentifiers.map((e) => e.toLowerCase().trim()).toList();
        // intentar con la comparación laxa también
        bool any = false;
        for (final c in candidates) {
          if (_looselyMatches(c, id)) {
            debugPrint('InteractiveMapWidget: candidate $c matches id=$id for area=${area.name}');
            any = true;
            break;
          }
        }
        if (any || _looselyMatches(_normalizeKey(area.name), id) || (area.identifier != null && _looselyMatches(area.identifier!, id))) {
          match = area;
          break;
        }
      }
    }

    if (match == null) {
      // Intentar encontrar por coincidencia parcial palabra a palabra
      for (final area in widget.areas) {
        final name = area.name.toLowerCase();
        if (name.contains(id) || id.contains(name)) {
          match = area;
          break;
        }
      }
    }

    if (match == null) {
      debugPrint('InteractiveMapWidget: no match found for id=$id manualTarget=$manualTargetId');
      _hasFocused = true;
      return;
    }

    // Calcular scaledRect en las mismas coordenadas que en el build
    final scaledRect = Rect.fromLTRB(
      match.rect.left * scale,
      match.rect.top * scale,
      match.rect.right * scale,
      match.rect.bottom * scale,
    );

    // Determinar el zoom deseado para centrar el área.
    // Por defecto, intentar que el área ocupe ~60% de la dimensión menor del viewport.
    final areaMaxDim = math.max(scaledRect.width, scaledRect.height);
    final viewportMinDim = math.min(constraints.maxWidth, constraints.maxHeight);
    double computedScale = (viewportMinDim * 0.6) / (areaMaxDim == 0 ? 1.0 : areaMaxDim);
    // Asegurar escala mínima igual al 'scale' base para no alejar más de lo que cabe la imagen
    computedScale = math.max(computedScale, scale);
    // Clamp al rango permitido por InteractiveViewer en este widget
    final minScale = 0.5;
    final maxScale = 5.0;
    final double desiredScale = (widget.initialZoom != null)
        ? widget.initialZoom!.clamp(minScale, maxScale)
        : computedScale.clamp(minScale, maxScale);

    // Guardar el highlight (en coordenadas del widget) para dibujar overlay
    setState(() {
      _highlightRect = scaledRect;
      // Iniciar animación de pulso
      _pulseController.repeat(reverse: true);
    });
    debugPrint('InteractiveMapWidget: match found -> ${match.name} identifier=${match.identifier} scaledRect=$scaledRect desiredScale=$desiredScale');

    // Centro del viewport
    final viewportCenter = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    // scaledRect.center está en coordenadas del child (ya escaladas por `scale`)
    // Usamos esas coordenadas directamente para calcular la traducción t tal que
    // s * childPoint + t = viewportCenter => t = viewportCenter - s * childPoint

    // Top-left del child: ahora el child está alineado al topleft dentro del InteractiveViewer
    final childTopLeft = Offset.zero;
    // Centro del área en coordenadas del viewport
    final areaCenterInViewport = childTopLeft + Offset(scaledRect.center.dx, scaledRect.center.dy);

    // Calcular la traducción necesaria para que el centro del área quede en el centro del viewport
    // t = viewportCenter - childTopLeft - s * childCenter
    final tx = viewportCenter.dx - childTopLeft.dx - desiredScale * scaledRect.center.dx;
    final ty = viewportCenter.dy - childTopLeft.dy - desiredScale * scaledRect.center.dy;

    debugPrint('InteractiveMapWidget: tx=$tx ty=$ty desiredScale=$desiredScale areaCenterInViewport=$areaCenterInViewport scaledRect.center=${scaledRect.center}');

    final currentMatrix = _transformationController.value.clone();
    // Compose as Translate * Scale so that: M * childPoint = viewportCenter
    final translateM = Matrix4.identity()..setTranslation(Vector3(tx, ty, 0));
    final scaleM = Matrix4.identity()..scale(desiredScale, desiredScale, 1.0);
    final targetMatrix = translateM * scaleM;

    // Si la diferencia es muy pequeña, aplicar directamente
    const epsilon = 0.01;
    final curScale = currentMatrix.getMaxScaleOnAxis();
    final currentTranslation = currentMatrix.getTranslation();
    if ((curScale - desiredScale).abs() < epsilon && (currentTranslation.x - tx).abs() < 1.0 && (currentTranslation.y - ty).abs() < 1.0) {
      _transformationController.value = targetMatrix;
      _hasFocused = true;
      return;
    }

    // Si estamos en modo de diagnóstico/depuración, aplicar inmediatamente sin animación
    if (widget.debugImmediateFocus) {
      debugPrint('InteractiveMapWidget: debugImmediateFocus active — applying targetMatrix immediately');
      _transformationController.value = targetMatrix;
      _hasFocused = true;
      return;
    }

    // Animar usando Matrix4Tween
    _animController.stop();
    _animController.reset();
    final curved = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);
    final tween = Matrix4Tween(begin: currentMatrix, end: targetMatrix);
    final animation = tween.animate(curved);

    void animListener() {
      _transformationController.value = animation.value;
    }

    animation.addListener(animListener);
    await _animController.forward();
    animation.removeListener(animListener);

    // Mantener el highlight visible unos instantes, luego retirarlo
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() {
      _highlightRect = null;
      _pulseController.stop();
      _pulseController.reset();
    });

    _hasFocused = true;
  }

  bool _looselyMatches(String candidate, String target) {
    candidate = candidate.toLowerCase().trim();
    target = target.toLowerCase().trim();
    if (candidate == target) return true;
    if (candidate.endsWith(target)) return true;
    if (target.endsWith(candidate)) return true;
    if (candidate.contains(target)) return true;
    if (target.contains(candidate)) return true;
    // compare last two segments (to ignore region prefix como 'kanto-')
    String tail(String s) {
      final parts = s.split('-');
      if (parts.length >= 2) return '${parts[parts.length - 2]}-${parts.last}';
      return s;
    }
    if (tail(candidate) == tail(target)) return true;
    return false;
  }

  String _normalizeKey(String s) {
    var id = s.toLowerCase();
    id = id.replaceAll(RegExp('[^a-z0-9\-]'), '-');
    id = id.replaceAll(RegExp('-+'), '-');
    id = id.trim();
    if (id.endsWith('-')) id = id.substring(0, id.length - 1);
    if (id.startsWith('-')) id = id.substring(1);
    return id;
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

  /// Devuelve una lista de identificadores candidatos para probar.
  ///
  /// Dado que no siempre sabemos cuáles son rutas marinas o terrestres, esta
  /// lista incluye el identificador original (si existe), una variante con
  /// el prefijo "sea-" y variantes donde "route" se transforma a
  /// "sea-route" cuando procede. También se incluye el `name` como fallback.
  List<String> get candidateIdentifiers {
    final Set<String> ids = {};

    if (identifier != null && identifier!.trim().isNotEmpty) {
      final id = identifier!.trim();
      ids.add(id);

      // Variante con prefijo sea-
      ids.add('sea-$id');

      // Reemplazo de -route- por -sea-route- (ej: kanto-route-1 -> kanto-sea-route-1)
      if (id.contains('-route-')) {
        ids.add(id.replaceAll('-route-', '-sea-route-'));
      }

      // Reemplazo de route- por sea-route- (caso sin guión previo)
      if (id.contains('route-') && !id.contains('-route-')) {
        ids.add(id.replaceAll('route-', 'sea-route-'));
      }

      // Si ya tiene sea-route, también agregar la versión sin sea-
      if (id.contains('sea-route')) {
        ids.add(id.replaceAll('sea-route', 'route'));
        ids.add(id.replaceAll('sea-', ''));
      }
    }

    // Siempre añadir el name como última opción para compatibilidad
    ids.add(name);

    return ids.toList(growable: false);
  }
}
