import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Centralized snackbar helpers so every confirmation/error in the app
/// looks and feels the same, and nothing ever falls back to a browser
/// `alert()`.
void showAppSnackBar(
  BuildContext context, {
  required String message,
  IconData icon = Icons.check_circle_outline,
  Color? accent,
  Duration duration = const Duration(seconds: 3),
  String? semanticsPrefix,
}) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        duration: duration,
        content: Row(
          children: [
            ExcludeSemantics(
              child: Icon(icon, color: accent ?? AppColors.mint, size: 20),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                message,
                // The icon and accent colour are the only visual cue for
                // success vs error, so spell it out for screen readers.
                semanticsLabel: semanticsPrefix == null
                    ? null
                    : '$semanticsPrefix: $message',
              ),
            ),
          ],
        ),
      ),
    );
}

void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  showAppSnackBar(
    context,
    message: message,
    icon: Icons.check_circle_outline,
    accent: AppColors.mint,
    duration: duration,
    semanticsPrefix: 'Success',
  );
}

void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
}) {
  showAppSnackBar(
    context,
    message: message,
    icon: Icons.error_outline,
    accent: AppColors.coral,
    duration: duration,
    semanticsPrefix: 'Error',
  );
}
