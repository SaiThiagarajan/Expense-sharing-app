import 'package:flutter/material.dart';

/// Centralized brand palette for the warm, neutral visual system.
///
/// Keep every raw color value here. Screens and widgets should read colors
/// from [ThemeData.colorScheme] (built in `app_theme.dart`) rather than
/// referencing these constants directly, except where a brand accent has no
/// natural [ColorScheme] role (e.g. member avatar colors).
class AppColors {
  AppColors._();

  // Warm neutrals
  static const Color background = Color(0xFFF4F0E6);
  static const Color surfaceIvory = Color(0xFFFFFDF8);
  static const Color charcoal = Color(0xFF2E2D2B);
  static const Color mutedText = Color(0xFF7C7865);

  // Brand accents
  static const Color primary = Color(0xFF205743);
  static const Color primaryDark = Color(0xFF173F31);
  static const Color mint = Color(0xFF63C8B0);
  static const Color coral = Color(0xFFE4572E);
  static const Color amber = Color(0xFFE5A84B);

  // Soft container tints derived from the brand accents, used for chips,
  // selected nav items and status badges.
  static const Color primaryContainer = Color(0xFFDCE7DF);
  static const Color onPrimaryContainer = Color(0xFF10241C);
  static const Color mintContainer = Color(0xFFDCF3EC);
  static const Color onMintContainer = Color(0xFF1F4A40);
  static const Color coralContainer = Color(0xFFFBDCD2);
  static const Color onCoralContainer = Color(0xFF7A2712);
  static const Color amberContainer = Color(0xFFFBEBD3);
  static const Color onAmberContainer = Color(0xFF5C3E10);

  // Structural tones
  static const Color outline = Color(0xFFD8D2C2);
  static const Color outlineVariant = Color(0xFFEAE5D6);

  /// Builds a Material 3 [ColorScheme] seeded from the brand primary, then
  /// overrides the roles that carry explicit brand meaning so the warm
  /// beige/ivory identity survives Material's automatic tone generation.
  static ColorScheme buildColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: primary,
      onPrimary: surfaceIvory,
      primaryContainer: primaryContainer,
      onPrimaryContainer: onPrimaryContainer,
      secondary: mint,
      onSecondary: charcoal,
      secondaryContainer: mintContainer,
      onSecondaryContainer: onMintContainer,
      tertiary: coral,
      onTertiary: surfaceIvory,
      tertiaryContainer: coralContainer,
      onTertiaryContainer: onCoralContainer,
      error: coral,
      onError: surfaceIvory,
      errorContainer: coralContainer,
      onErrorContainer: onCoralContainer,
      surface: background,
      onSurface: charcoal,
      onSurfaceVariant: mutedText,
      outline: outline,
      outlineVariant: outlineVariant,
      surfaceContainerLowest: surfaceIvory,
      surfaceContainerLow: surfaceIvory,
      surfaceContainer: surfaceIvory,
      surfaceContainerHigh: const Color(0xFFEFEADC),
      surfaceContainerHighest: const Color(0xFFE9E3D3),
    );
  }
}
