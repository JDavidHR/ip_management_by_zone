import 'package:flutter/material.dart';

class MCPaletteColors {
  static const Color primary = Color(0xFF007BFF); // Azul cian brillante
  static const Color secondary = Color(0xFF00C6FF); // Cian más claro
  static const Color background = Color(0xFFE3F8FF); // Azul muy claro
  static const Color surface = Color(0xFFFFFFFF); // Blanco puro
  static const Color textPrimary =
      Color(0xFF004C8C); // Azul oscuro para texto principal
  static const Color textSecondary =
      Color(0xFF0074A6); // Azul medio para texto secundario

  static const mcBlue = Color(0xFF0054A6);
  static const mcYellow = Color(0xFFF4C32F);

  // Colores principales corporativos
  static const Color primaryMC = Color(0xFF0054A6); // Azul MC
  static const Color secondaryMC = Color(0xFFF2B315); // Amarillo MC

  // Variantes del azul (MaterialColor)
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0054A6,
    <int, Color>{
      50: Color(0xFFE1ECF7),
      100: Color(0xFFB3CFEB),
      200: Color(0xFF80B0DE),
      300: Color(0xFF4D90D1),
      400: Color(0xFF2678C7),
      500: Color(0xFF005FC0),
      600: Color(0xFF0057BA),
      700: Color(0xFF004DAF),
      800: Color(0xFF0043A6),
      900: Color(0xFF003292),
    },
  );

  // Variantes del amarillo
  static const MaterialColor secondarySwatch = MaterialColor(
    0xFFF2B315,
    <int, Color>{
      50: Color(0xFFFFF3DD),
      100: Color(0xFFFFE3AA),
      200: Color(0xFFFFD477),
      300: Color(0xFFFFC444),
      400: Color(0xFFFFB71F),
      500: Color(0xFFF2B315),
      600: Color(0xFFD99F12),
      700: Color(0xFFBF8B0F),
      800: Color(0xFFA6760C),
      900: Color(0xFF7A5407),
    },
  );

  // Colores adicionales derivados (útiles para UI)
  static const Color primaryLight = Color(0xFF4D90D1);
  static const Color primaryDark = Color(0xFF003B79);

  static const Color secondaryLight = Color(0xFFFFD477);
  static const Color secondaryDark = Color(0xFFBF8B0F);

  // Grises para la interfaz
  static const Color gray = Color(0xFFEEEEEE);
  static const Color darkGray = Color(0xFF333333);
}
