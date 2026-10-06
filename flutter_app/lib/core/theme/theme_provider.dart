import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Notifier que gestiona de forma reactiva el modo de tema (Claro / Oscuro) de la app.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  /// Alterna entre el tema claro y oscuro.
  void toggleTheme() {
    state = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
  }

  /// Establece explícitamente un modo de tema.
  void setThemeMode(ThemeMode mode) {
    state = mode;
  }
}

/// Provider reactivo para el ThemeMode de la aplicación.
final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
