import 'package:flutter/material.dart';

import 'wish_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light => _build(WishColors.light, Brightness.light);
  static ThemeData get dark => _build(WishColors.dark, Brightness.dark);

  static ThemeData _build(WishColors c, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: 'Nunito Sans',
    );

    final textTheme = base.textTheme
        .apply(bodyColor: c.ink, displayColor: c.ink)
        .copyWith(
          displayLarge: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 42,
            height: 1.05,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.4,
            color: c.ink,
          ),
          displayMedium: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 34,
            height: 1.08,
            fontWeight: FontWeight.w700,
            letterSpacing: -1.0,
            color: c.ink,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 28,
            height: 1.12,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.7,
            color: c.ink,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 23,
            height: 1.18,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.4,
            color: c.ink,
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 20,
            height: 1.2,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.3,
            color: c.ink,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 18,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.2,
            color: c.ink,
          ),
          titleMedium: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 16,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: c.ink,
          ),
          titleSmall: TextStyle(
            fontFamily: 'Rubik',
            fontSize: 14,
            height: 1.3,
            fontWeight: FontWeight.w600,
            color: c.ink,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 15.5,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: c.ink,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w500,
            color: c.inkSecondary,
          ),
          bodySmall: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 12.5,
            height: 1.4,
            fontWeight: FontWeight.w500,
            color: c.inkTertiary,
          ),
          labelLarge: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 14.5,
            height: 1.2,
            fontWeight: FontWeight.w700,
            color: c.ink,
          ),
          labelMedium: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 12.5,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
            color: c.ink,
          ),
          labelSmall: TextStyle(
            fontFamily: 'Nunito Sans',
            fontSize: 10.5,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: c.inkTertiary,
          ),
        );

    final scheme = ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.tierB,
      onSecondary: c.onAccent,
      error: c.danger,
      onError: const Color(0xFFFFFFFF),
      surface: c.surface,
      onSurface: c.ink,
      surfaceContainerHighest: c.surfaceMuted,
      outline: c.border,
      outlineVariant: c.border,
    );

    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.surface,
      dividerColor: c.border,
      textTheme: textTheme,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        iconTheme: IconThemeData(color: c.ink),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(color: c.inkTertiary),
        labelStyle: textTheme.bodyMedium?.copyWith(color: c.inkSecondary),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(
          color: c.inkSecondary,
          fontWeight: FontWeight.w700,
        ),
        errorStyle: textTheme.bodySmall?.copyWith(
          color: c.danger,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: c.inkTertiary,
        suffixIconColor: c.inkTertiary,
        border: _fieldBorder(c.border),
        enabledBorder: _fieldBorder(c.border),
        disabledBorder: _fieldBorder(c.border.withValues(alpha: 0.6)),
        focusedBorder: _fieldBorder(c.ink, width: 1.6),
        errorBorder: _fieldBorder(c.danger),
        focusedErrorBorder: _fieldBorder(c.danger, width: 1.6),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 54),
          backgroundColor: c.accent,
          foregroundColor: c.onAccent,
          disabledBackgroundColor: c.surfaceMuted,
          disabledForegroundColor: c.inkTertiary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: c.ink,
          side: BorderSide(color: c.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.ink,
          minimumSize: const Size(48, 44),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.ink,
          highlightColor: c.ink.withValues(alpha: 0.06),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        elevation: 0,
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: c.ink.withValues(alpha: 0.07),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 23,
            color: selected ? c.ink : c.inkTertiary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return textTheme.labelSmall?.copyWith(
            fontSize: 11,
            letterSpacing: 0.2,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: selected ? c.ink : c.inkTertiary,
          );
        }),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.accent,
        foregroundColor: c.onAccent,
        elevation: 2,
        focusElevation: 3,
        hoverElevation: 3,
        highlightElevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        extendedTextStyle: textTheme.labelLarge?.copyWith(
          color: c.onAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.accent,
        actionTextColor: c.onAccent,
        closeIconColor: c.onAccent,
        elevation: 4,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: c.onAccent,
          fontWeight: FontWeight.w600,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        dragHandleColor: c.border,
        showDragHandle: false,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: c.border),
        ),
      ),
      dividerTheme: DividerThemeData(color: c.border, thickness: 1, space: 1),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.ink,
        linearTrackColor: c.surfaceMuted,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: c.accent,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: textTheme.bodySmall?.copyWith(color: c.onAccent),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
