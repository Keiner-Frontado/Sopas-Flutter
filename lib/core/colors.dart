import 'dart:ui';

class Colors {
  // Base tone (monocromatic - alrededor de #3F3AE6)
  static const Color primary = Color(0xFF6964F5);
  static const Color primaryDark = Color(0xFF7270CC);
  static const Color primaryLight = Color(0xFFC1BFF3);
  static const Color secondary = Color(0xFFD4D4EE);

  // Text colors (variaciones sobre el mismo tono)
  static const Color textPrimary = Color(0xFF0B0927); // muy oscuro con matiz violeta
  static const Color textSecondary = Color(0xFF181635);
  static const Color textHint = Color(0xFF9E9CE9);

  // Fondos y superficies (tonos muy claros del mismo color)
  static const Color background = Color(0xFFF2F3FF);
  static const Color scaffoldBackground = Color(0xFFEFEFFF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5FF);

  // Bordes, divisores y sombras
  static const Color outline = Color(0xFFDBD9FF);
  static const Color divider = Color(0xFFDDDBFF);
  static const Color shadow = Color(0x1F3F3AE6); // same hue with low alpha

  // Semánticos (se dejan recognoscibles; pueden ajustarse si se desea 100% monocromático)
  static const Color error = Color(0xFFC00426);
  static const Color success = Color(0xFF389E3D);
  static const Color warning = Color(0xFFF59E0B);
  static const Color disabled = Color(0xFFBDBDBD);

  // Botones y estados (variaciones del primario)
  static const Color buttonPrimary = Color(0xFF726FC5);
  static const Color buttonSecondary = Color(0xFFB5B3EE);
  static const Color buttonText = Color(0xFFFFFFFF);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color onSecondary = Color(0xFF0F0D2B);

  // Selección
  static const Color selected = Color(0xFF7371EE);
  static const Color unselected = Color(0xFF9B98DA);
}