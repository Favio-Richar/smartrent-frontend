import 'package:flutter/material.dart';

class Validators {
  // ---------- Requeridos ----------
  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null;

  static String? requiredNumber(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final n = num.tryParse(v.trim());
    if (n == null) return 'Debe ser numérico';
    if (n < 0) return 'No puede ser negativo';
    return null;
  }

  static FormFieldValidator<String> minLen(int min) {
    return (v) =>
        (v == null || v.trim().length < min) ? 'Mínimo $min caracteres' : null;
  }

  // ---------- Email ----------
  /// Email opcional: si está vacío, no marca error; si trae valor, debe ser válido.
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim());
    return ok ? null : 'Email inválido';
  }

  /// Email requerido: obliga a que exista y sea válido.
  static String? requiredEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
    final ok = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim());
    return ok ? null : 'Email inválido';
  }

  // ---------- Números y rangos ----------
  /// Acepta vacío; si trae valor, debe ser número.
  static String? number(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    return num.tryParse(v.trim()) == null ? 'Debe ser numérico' : null;
  }

  /// Requerido numérico en rango [min, max].
  static FormFieldValidator<String> numberBetween(num min, num max) {
    return (v) {
      if (v == null || v.trim().isEmpty) return 'Campo obligatorio';
      final n = num.tryParse(v.trim());
      if (n == null) return 'Debe ser numérico';
      if (n < min || n > max) return 'Debe estar entre $min y $max';
      return null;
    };
  }

  // ---------- URL / Teléfono (opcionales) ----------
  static String? url(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final ok = RegExp(
      r'^(https?:\/\/)?([^\s.]+\.[^\s]{2,}|localhost)(\/\S*)?$',
    ).hasMatch(v.trim());
    return ok ? null : 'URL inválida';
  }

  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) return null;
    final ok = RegExp(r'^\+?\d{7,15}$').hasMatch(v.trim());
    return ok ? null : 'Teléfono inválido';
  }

  // ---------- Varios ----------
  /// Asegura que una lista tenga al menos un elemento (por ejemplo, imágenes).
  static String? notEmptyList<T>(List<T>? list) =>
      (list == null || list.isEmpty) ? 'Debe agregar al menos uno' : null;

  /// Coincidencia contra un patrón (útil para placas, códigos, etc.)
  static FormFieldValidator<String> pattern(RegExp regex, String msg) {
    return (v) {
      if (v == null || v.trim().isEmpty) return null;
      return regex.hasMatch(v.trim()) ? null : msg;
    };
  }
}
