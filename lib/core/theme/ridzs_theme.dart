import 'package:flutter/material.dart';

/// Presentation values only; legacy color-scheme roles remain unchanged.
abstract final class RidzsTheme {
  static const radius = BorderRadius.all(Radius.circular(8));

  static Color ink(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xffFFFFFF)
          : const Color(0xff070707);

  static Color paper(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xff1C1C1C)
          : const Color(0xffFFFFFF);

  static Color line(BuildContext context) =>
      ink(context).withValues(alpha: .12);

  static ThemeData refine(ThemeData base) {
    final dark = base.brightness == Brightness.dark;
    final ink = dark ? const Color(0xffFFFFFF) : const Color(0xff070707);
    final paper = dark ? const Color(0xff1C1C1C) : const Color(0xffFFFFFF);
    final muted = ink.withValues(alpha: .65);
    final line = ink.withValues(alpha: .12);
    TextStyle type(double size, FontWeight weight, double height) => TextStyle(
          fontFamily: 'Poppins',
          fontSize: size,
          fontWeight: weight,
          height: height,
          letterSpacing: 0,
          color: ink,
        );
    final text = TextTheme(
      displayLarge: type(40, FontWeight.w600, 1.15),
      displayMedium: type(36, FontWeight.w600, 1.2),
      displaySmall: type(32, FontWeight.w600, 1.2),
      headlineLarge: type(28, FontWeight.w600, 1.25),
      headlineMedium: type(26, FontWeight.w600, 1.25),
      headlineSmall: type(24, FontWeight.w600, 1.3),
      titleLarge: type(20, FontWeight.w600, 1.3),
      titleMedium: type(16, FontWeight.w600, 1.4),
      titleSmall: type(14, FontWeight.w600, 1.4),
      bodyLarge: type(16, FontWeight.w400, 1.5),
      bodyMedium: type(14, FontWeight.w400, 1.5),
      bodySmall: type(12, FontWeight.w400, 1.5),
      labelLarge: type(14, FontWeight.w600, 1.3),
      labelMedium: type(12, FontWeight.w500, 1.3),
      labelSmall: type(11, FontWeight.w500, 1.3),
    );
    const shape = RoundedRectangleBorder(borderRadius: radius);
    final button = ElevatedButton.styleFrom(
      backgroundColor: base.colorScheme.primary,
      foregroundColor: const Color(0xff070707),
      disabledBackgroundColor: ink.withValues(alpha: .08),
      disabledForegroundColor: muted,
      minimumSize: const Size(48, 52),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      textStyle: text.labelLarge,
      shape: shape,
      elevation: 0,
      shadowColor: Colors.transparent,
      animationDuration: const Duration(milliseconds: 160),
    );
    return base.copyWith(
      textTheme: text,
      primaryTextTheme: text,
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 24),
      iconTheme: IconThemeData(color: ink, size: 22),
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleSpacing: 20,
        titleTextStyle: text.titleLarge,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: button),
      filledButtonTheme: FilledButtonThemeData(style: button),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 52),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: shape,
          side: BorderSide(color: line),
          textStyle: text.labelLarge,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ink.withValues(alpha: .03),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: text.bodyMedium?.copyWith(color: muted),
        labelStyle: text.bodyMedium?.copyWith(color: muted),
        border: OutlineInputBorder(
            borderRadius: radius, borderSide: BorderSide(color: line)),
        enabledBorder: OutlineInputBorder(
            borderRadius: radius, borderSide: BorderSide(color: line)),
        focusedBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide:
                BorderSide(color: base.colorScheme.primary, width: 1.5)),
        errorBorder: OutlineInputBorder(
            borderRadius: radius,
            borderSide: BorderSide(color: base.colorScheme.error)),
      ),
      bottomSheetTheme: base.bottomSheetTheme.copyWith(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      cardTheme: base.cardTheme.copyWith(
        color: paper,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: radius, side: BorderSide(color: line)),
      ),
      dialogTheme: base.dialogTheme.copyWith(
        backgroundColor: paper,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: radius),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyMedium,
      ),
      listTileTheme: base.listTileTheme.copyWith(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        iconColor: ink,
        textColor: ink,
        titleTextStyle: text.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        subtitleTextStyle: text.bodySmall?.copyWith(color: muted),
      ),
    );
  }
}
