import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' show Vector3, Matrix4;

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
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _focusAreaIfRequested(constraints, scale, scaledWidth, scaledHeight);
          });
        }

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
          ),
        );
      },
    );
  }

  void _focusAreaIfRequested(BoxConstraints constraints, double scale, double scaledWidth, double scaledHeight) async {
    if (_hasFocused) return;
    final id = widget.initialAreaIdentifier!.toLowerCase().trim();

    // First, if a manual map exists, try to map `id` -> explicit identifier
    String? manualTargetId;
    if (widget.manualAreaIdMap != null) {
      final key = _normalizeKey(id);
      manualTargetId = widget.manualAreaIdMap![key];
      if (manualTargetId != null) manualTargetId = manualTargetId.toLowerCase().trim();
    }

    // Buscar un área cuyo identificador candidato o nombre coincida
    MapArea? match;

    if (manualTargetId != null) {
      for (final area in widget.areas) {
        final candidates = area.candidateIdentifiers.map((e) => e.toLowerCase().trim());
        if (candidates.contains(manualTargetId) || (area.identifier?.toLowerCase().trim() == manualTargetId)) {
          match = area;
          break;
        }
      }
    }

    // Si no hay match todavía, buscar por identifiers y name como antes
    if (match == null) {
      for (final area in widget.areas) {
        final candidates = area.candidateIdentifiers.map((e) => e.toLowerCase().trim()).toList();
        if (candidates.contains(id) || area.name.toLowerCase().trim() == id) {
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

    // Guardar el highlight (en coordenadas del widget) para dibujar overlay
    setState(() {
      _highlightRect = scaledRect;
      // Iniciar animación de pulso
      _pulseController.repeat(reverse: true);
    });

    // Centro del viewport
    final viewportCenter = Offset(constraints.maxWidth / 2, constraints.maxHeight / 2);
    // Top-left del child (porque el child está centrado dentro del InteractiveViewer)
    final childTopLeft = Offset((constraints.maxWidth - scaledWidth) / 2, (constraints.maxHeight - scaledHeight) / 2);
    // Centro del área en coordenadas del viewport
    final areaCenterInViewport = childTopLeft + Offset(scaledRect.center.dx, scaledRect.center.dy);

    // Determinar zoom deseado. Si el usuario pidió un initialZoom, usarlo.
    double desiredScale = widget.initialZoom ?? 2.0;
    // Ajustar desiredScale para que el área ocupe una fracción razonable del viewport
    final areaPortionWidth = scaledRect.width / constraints.maxWidth;
    final areaPortionHeight = scaledRect.height / constraints.maxHeight;
    // Si el área ya es grande, usar un zoom menor
    final autoScaleCandidate = 1 / ((areaPortionWidth + areaPortionHeight) / 2 + 0.0001);
    desiredScale = (widget.initialZoom ?? autoScaleCandidate).clamp(0.8, 4.0);

    // Calcular la traducción necesaria para que el centro del área quede en el centro del viewport
    final tx = viewportCenter.dx - areaCenterInViewport.dx * desiredScale;
    final ty = viewportCenter.dy - areaCenterInViewport.dy * desiredScale;

    // Obtener transform actual
    final currentMatrix = _transformationController.value.clone();
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    final currentTranslationVec = currentMatrix.getTranslation();
    final startTx = currentTranslationVec.x;
    final startTy = currentTranslationVec.y;
    final startScale = currentScale;

    final targetTx = tx;
    final targetTy = ty;
    final targetScale = desiredScale;

    // Si la diferencia es muy pequeña, aplicar directamente
    const epsilon = 0.01;
    if ((startScale - targetScale).abs() < epsilon && (startTx - targetTx).abs() < 1.0 && (startTy - targetTy).abs() < 1.0) {
      final matrix = Matrix4.identity();
      matrix.translateByVector3(Vector3(targetTx, targetTy, 0));
      matrix.scaleByVector3(Vector3(targetScale, targetScale, targetScale));
      _transformationController.value = matrix;
      _hasFocused = true;
      return;
    }

    // Animar la transición entre transforms (interpolando scale y translate por separado)
    _animController.stop();
    _animController.reset();
    final curved = CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic);

    void listener() {
      final t = curved.value;
      final curScale = startScale + (targetScale - startScale) * t;
      final curTx = startTx + (targetTx - startTx) * t;
      final curTy = startTy + (targetTy - startTy) * t;

      final matrix = Matrix4.identity();
      matrix.translateByVector3(Vector3(curTx, curTy, 0));
      matrix.scaleByVector3(Vector3(curScale, curScale, curScale));
      _transformationController.value = matrix;

      // Opcional: actualizar highlight si se quisiera moverlo (no necesario si highlight está en coordenadas child)
    }

    curved.addListener(listener);
    await _animController.forward();
    curved.removeListener(listener);

    // Mantener el highlight visible unos instantes, luego retirarlo
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() {
      _highlightRect = null;
      _pulseController.stop();
      _pulseController.reset();
    });

    _hasFocused = true;
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
