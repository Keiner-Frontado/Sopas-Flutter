import 'package:flutter/material.dart';
import 'colors.dart' as app_colors;

/// Estilos reutilizables para la app basados en la clase `Colors` (lib/core/colors.dart).
class Styles {
  // AppBar
  static final appBarTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: app_colors.Colors.onPrimary,
  );

  static final titleText = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    color: app_colors.Colors.textPrimary,
  );
  
  // Texto principal
  static final text = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: app_colors.Colors.textPrimary,
  );

  // Botones (texto)
  static final buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: app_colors.Colors.onPrimary,
  );

  // Hint/placeholder
  static final hintText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: app_colors.Colors.textHint,
  );

  // Labels
  static final labelText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: app_colors.Colors.primary,
  );

  // Inputs
  static final inputText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: app_colors.Colors.textPrimary,
  );

  static final inputHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w300,
    color: app_colors.Colors.textHint,
  );

  static final inputLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: app_colors.Colors.textSecondary,
  );

  static final Color inputBorderColor = app_colors.Colors.outline;
  static final Color inputBackground = app_colors.Colors.surface;

  // Buttons (variantes)
  static final buttonPrimaryText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: app_colors.Colors.onPrimary,
  );

  static final buttonSecondaryText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: app_colors.Colors.primary,
  );

  static final Color buttonPrimaryBg = app_colors.Colors.buttonPrimary;
  static final Color buttonSecondaryBg = app_colors.Colors.buttonSecondary;

  // Misc
  static final caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w300,
    color: app_colors.Colors.textSecondary,
  );

  static final errorText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: app_colors.Colors.error,
  );

  static final dividerColor = app_colors.Colors.divider;
}

/// Tema global que aplica los colores y estilos a widgets básicos.
class AppTheme {
  static ThemeData get light {
    final seed = app_colors.Colors.primary;

    return ThemeData(
      useMaterial3: false,
      colorScheme: ColorScheme.fromSeed(seedColor: seed).copyWith(
        primary: app_colors.Colors.primary,
        onPrimary: app_colors.Colors.onPrimary,
        secondary: app_colors.Colors.secondary,
        surface: app_colors.Colors.surface,
        error: app_colors.Colors.error,
      ),
      primaryColor: app_colors.Colors.primary,
      scaffoldBackgroundColor: app_colors.Colors.scaffoldBackground,

      // AppBar
      appBarTheme: AppBarTheme(
        toolbarHeight: 40,
        backgroundColor: app_colors.Colors.primaryLight,
        titleTextStyle: Styles.appBarTitle,
        shape: ShapeBorder .lerp(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          null,
          0,
        ),
        iconTheme: IconThemeData(size: 24, color: app_colors.Colors.onPrimary),
        actionsPadding: EdgeInsetsGeometry.only(right: 8),
        elevation: 0,
      ),

      popupMenuTheme: PopupMenuThemeData(
        color: app_colors.Colors.primaryLight,
        textStyle: Styles.buttonText,
      ),

      // Text theme (nombres modernos para compatibilidad con versiones recientes)
      textTheme: TextTheme(
        titleLarge: Styles.appBarTitle,
        bodyLarge: Styles.text,
        bodyMedium: Styles.text,
        titleMedium: Styles.labelText,
        labelSmall: Styles.caption,
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: app_colors.Colors.buttonPrimary,
          foregroundColor: app_colors.Colors.buttonText,
          textStyle: Styles.buttonPrimaryText,
          fixedSize: Size.fromHeight(38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),

      // Text buttons
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: app_colors.Colors.primary,
          textStyle: Styles.buttonSecondaryText,
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: app_colors.Colors.primary,
          side: BorderSide(color: app_colors.Colors.outline),
          textStyle: Styles.buttonSecondaryText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Inputs
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: app_colors.Colors.surface,
        hintStyle: Styles.inputHint,
        labelStyle: Styles.inputLabel,
        helperStyle: Styles.inputLabel,
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: app_colors.Colors.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: app_colors.Colors.primary, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: app_colors.Colors.error),
          borderRadius: BorderRadius.circular(12),
        ),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: app_colors.Colors.divider, thickness: 1),

      // FloatingActionButton
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: app_colors.Colors.primary,
        foregroundColor: app_colors.Colors.onPrimary,
      ),

  // Nota: la colorScheme ya define primary/error y los widgets modernos la usan.
    );
  }
}