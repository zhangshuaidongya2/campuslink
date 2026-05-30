import 'package:flutter/material.dart';

abstract final class AppColors {
  static const linenCanvas = Color(0xFFFCFCFC);
  static const skyWash = Color(0xFFF0F4FE);
  static const midnightInk = Color(0xFF020520);
  static const graphite = Color(0xFF14141E);
  static const slate = Color(0xFF374151);
  static const ash = Color(0xFF696A72);
  static const fog = Color(0xFF95959B);
  static const outline = Color(0xFFD9E2F4);
  static const signalBlue = Color(0xFF145AFF);
  static const primaryAction = Color(0xFF0F1F3D);
  static const emerald = Color(0xFF16CA2E);
  static const coral = Color(0xFFF26052);
  static const amber = Color(0xFFFFA64D);
}

ThemeData buildAppTheme() {
  const colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.signalBlue,
    onPrimary: Colors.white,
    secondary: AppColors.primaryAction,
    onSecondary: Colors.white,
    error: AppColors.coral,
    onError: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.graphite,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppColors.linenCanvas,
    splashFactory: NoSplash.splashFactory,
  );

  return base.copyWith(
    textTheme: base.textTheme.copyWith(
      displaySmall: const TextStyle(
        fontSize: 38,
        height: 1.08,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.9,
        color: AppColors.midnightInk,
      ),
      headlineMedium: const TextStyle(
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        color: AppColors.midnightInk,
      ),
      titleLarge: const TextStyle(
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.graphite,
      ),
      titleMedium: const TextStyle(
        fontSize: 16,
        height: 1.3,
        fontWeight: FontWeight.w600,
        color: AppColors.graphite,
      ),
      bodyLarge: const TextStyle(
        fontSize: 15,
        height: 1.5,
        color: AppColors.slate,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        height: 1.45,
        color: AppColors.ash,
      ),
      bodySmall: const TextStyle(
        fontSize: 12,
        height: 1.4,
        letterSpacing: 0.15,
        color: AppColors.fog,
      ),
      labelLarge: const TextStyle(
        fontSize: 14,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryAction,
      ),
    ),
    dividerColor: AppColors.outline,
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryAction,
        side: const BorderSide(color: AppColors.primaryAction),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryAction,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.signalBlue),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.linenCanvas,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        return IconThemeData(
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryAction
              : AppColors.ash,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: states.contains(WidgetState.selected)
              ? AppColors.primaryAction
              : AppColors.ash,
        );
      }),
    ),
  );
}

BoxShadow get cardShadow => const BoxShadow(
  color: Color.fromRGBO(0, 0, 0, 0.08),
  blurRadius: 24,
  offset: Offset(0, 12),
  spreadRadius: -18,
);
