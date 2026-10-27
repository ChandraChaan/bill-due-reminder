import 'package:flutter/material.dart';

const Color _seed = Color(0xFF16705B);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  return ThemeData(
    colorScheme: scheme,
    useMaterial3: true,
    cardTheme: const CardThemeData(margin: EdgeInsets.zero),
    listTileTheme: const ListTileThemeData(minVerticalPadding: 10),
  );
}
