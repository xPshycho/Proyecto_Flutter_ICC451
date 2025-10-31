/// Utilidades para diseño responsive
class ResponsiveUtils {
  ResponsiveUtils._();

  /// Calcula el número de columnas basado en el ancho
  static int calculateCrossAxisCount(double width) {
    if (width >= 1200) return 5;
    if (width >= 1000) return 4;
    if (width >= 700) return 3;
    if (width >= 480) return 2;
    return 1;
  }

  /// Calcula el aspect ratio basado en el ancho
  static double calculateChildAspectRatio(double width) {
    if (width >= 1200) return 3.28 / 1.02;
    if (width >= 1000) return 3.28 / 1.12;
    if (width >= 700) return 3.28 / 1.22;
    if (width >= 480) return 3.28 / 1.32;
    return 3.28 / 1.02;
  }
}
