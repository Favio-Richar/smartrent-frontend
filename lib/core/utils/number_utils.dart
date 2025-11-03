// lib/core/utils/number_utils.dart
class NumberUtils {
  /// Convierte texto a double de forma segura. Acepta coma (,) y punto (.).
  static double? toDoubleSafe(String? s) {
    if (s == null) return null;
    final t = s.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    return double.tryParse(t);
  }

  /// Convierte texto a int de forma segura. Acepta valores tipo "12.0".
  static int? toIntSafe(String? s) {
    if (s == null) return null;
    final t = s.trim().replaceAll(',', '.');
    if (t.isEmpty) return null;
    final d = double.tryParse(t);
    if (d != null) return d.round();
    return int.tryParse(t);
  }
}
