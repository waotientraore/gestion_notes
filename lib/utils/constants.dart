import 'package:flutter/material.dart';

// Couleurs et styles réutilisés dans toute l'application.
class AppConstants {
  static const Color primaryColor = Colors.blue;
  static const Color errorColor = Colors.red;
  static const String appTitle = 'Mes Notes';

  static const EdgeInsets screenPadding = EdgeInsets.all(16.0);

  static InputDecoration inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
