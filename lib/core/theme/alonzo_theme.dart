import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tema visual ALONZO — Minimalismo high-end inspirado en Zara y Farfetch.
///
/// Filosofía: fondo blanco puro, tipografía negra con peso visual,
/// cero sombras, cero elevaciones, bordes sutiles cuando es necesario.
class AlonzoTheme {
  AlonzoTheme._();

  // ── Paleta ──────────────────────────────────────────────
  static const Color _black = Color(0xFF000000);
  static const Color _white = Color(0xFFFFFFFF);
  static const Color _grey50 = Color(0xFFF5F5F5);
  static const Color _grey100 = Color(0xFFEEEEEE);
  static const Color _grey300 = Color(0xFFE0E0E0);
  static const Color _grey500 = Color(0xFF9E9E9E);
  static const Color _grey700 = Color(0xFF616161);
  static const Color _grey900 = Color(0xFF212121);
  static const Color _error = Color(0xFFB00020);

  // ── Tipografía ──────────────────────────────────────────
  // Instrument Sans: moderna, geométrica, perfecta para moda premium.
  // Fallback a la familia del sistema si no carga.
  static TextTheme get _textTheme {
    final base = GoogleFonts.instrumentSansTextTheme();
    return base.copyWith(
      // Logo / Branding — tracking ancho estilo Zara
      displayLarge: base.displayLarge?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: 6,
        color: _black,
      ),
      // Títulos de sección: "En tendencia", "Novedades"
      headlineLarge: base.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _black,
      ),
      headlineMedium: base.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.3,
        color: _black,
      ),
      // Nombre de producto
      titleLarge: base.titleLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: _black,
      ),
      // Marca del producto
      titleMedium: base.titleMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: _grey700,
      ),
      // Precio
      titleSmall: base.titleSmall?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.2,
        color: _black,
      ),
      // Cuerpo principal
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: _grey900,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: _grey700,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.5,
        color: _grey500,
      ),
      // Labels (tabs, botones)
      labelLarge: base.labelLarge?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.5,
        color: _black,
      ),
      labelMedium: base.labelMedium?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.2,
        color: _grey700,
      ),
    );
  }

  // ── Tema principal ──────────────────────────────────────
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _white,
      colorScheme: const ColorScheme.light(
        primary: _black,
        onPrimary: _white,
        secondary: _grey700,
        onSecondary: _white,
        surface: _white,
        onSurface: _black,
        error: _error,
        onError: _white,
        outline: _grey300,
        surfaceContainerHighest: _grey50,
      ),
      textTheme: _textTheme,

      // ── AppBar: totalmente plano, sin sombra ─────────────
      appBarTheme: AppBarTheme(
        backgroundColor: _white,
        foregroundColor: _black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: _textTheme.labelLarge?.copyWith(
          fontSize: 15,
          letterSpacing: 3,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: const IconThemeData(color: _black, size: 22),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),

      // ── Bottom Navigation: limpio, sin splash ────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: _white,
        selectedItemColor: _black,
        unselectedItemColor: _grey500,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.8,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          letterSpacing: 0.8,
        ),
      ),

      // ── Botones: estilo Zara (lleno negro o borde negro) ─
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _black,
          foregroundColor: _white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0), // Esquinas cuadradas
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _black,
          side: const BorderSide(color: _black, width: 1),
          elevation: 0,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          textStyle: _textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _black,
          textStyle: _textTheme.labelMedium?.copyWith(
            decoration: TextDecoration.underline,
          ),
        ),
      ),

      // ── Inputs ───────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: _grey300),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _grey300),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _black, width: 1.5),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: _error),
        ),
        labelStyle: _textTheme.bodyMedium,
        hintStyle: _textTheme.bodyMedium?.copyWith(color: _grey500),
      ),

      // ── Cards: sin sombra, sin elevación ─────────────────
      cardTheme: const CardThemeData(
        color: _white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
      ),

      // ── Dividers ─────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: _grey100,
        thickness: 1,
        space: 0,
      ),

      // ── Chips (para tallas) ──────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: _white,
        selectedColor: _black,
        disabledColor: _grey50,
        labelStyle: _textTheme.labelMedium!,
        secondaryLabelStyle: _textTheme.labelMedium!.copyWith(color: _white),
        side: const BorderSide(color: _grey300),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),

      // ── TabBar ───────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: _black,
        unselectedLabelColor: _grey500,
        indicatorColor: _black,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: _textTheme.labelLarge,
        unselectedLabelStyle: _textTheme.labelMedium,
        dividerColor: Colors.transparent,
      ),

      // ── SnackBar ─────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: _grey900,
        contentTextStyle: _textTheme.bodyMedium?.copyWith(color: _white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
      ),

      // Sin splash en Material 3
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );
  }
}
