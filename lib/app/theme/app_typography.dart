import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography system built on Manrope.
///
/// Standard UI text should come from [ThemeData.textTheme] (built via
/// [AppTypography.buildTextTheme]). Financial amounts get their own scale
/// via [AppTypography.financialLarge]/[financialMedium]/[financialSmall]
/// since they need to stand out more than the standard type ramp allows.
class AppTypography {
  AppTypography._();

  static TextTheme buildTextTheme(
    TextTheme base,
    Color onSurface,
    Color onSurfaceVariant,
  ) {
    final manrope = GoogleFonts.manropeTextTheme(base);
    return manrope
        .copyWith(
          // Page titles
          headlineLarge: manrope.headlineLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
          headlineMedium: manrope.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
          headlineSmall: manrope.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurface,
          ),
          // Section headings
          titleLarge: manrope.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          titleMedium: manrope.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          titleSmall: manrope.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          // Body text
          bodyLarge: manrope.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
          bodyMedium: manrope.bodyMedium?.copyWith(
            fontWeight: FontWeight.w400,
            color: onSurface,
          ),
          bodySmall: manrope.bodySmall?.copyWith(
            fontWeight: FontWeight.w400,
            color: onSurfaceVariant,
          ),
          // Buttons
          labelLarge: manrope.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: onSurface,
          ),
          // Metadata / labels
          labelMedium: manrope.labelMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          ),
          labelSmall: manrope.labelSmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: onSurfaceVariant,
          ),
        )
        .apply(fontFamily: GoogleFonts.manrope().fontFamily);
  }

  /// Large financial figure, e.g. a dashboard's headline balance.
  static TextStyle financialLarge({Color? color}) => GoogleFonts.manrope(
    fontSize: 36,
    height: 1.15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: color,
  );

  /// Medium financial figure, e.g. an expense amount in a list row.
  static TextStyle financialMedium({Color? color}) => GoogleFonts.manrope(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.25,
    color: color,
  );

  /// Small financial figure, e.g. a per-person share or metadata amount.
  static TextStyle financialSmall({Color? color}) => GoogleFonts.manrope(
    fontSize: 15,
    height: 1.2,
    fontWeight: FontWeight.w600,
    color: color,
  );
}
