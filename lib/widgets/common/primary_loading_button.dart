import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

enum ButtonRunState { idle, loading, success }

/// A [FilledButton] that can show a loading spinner and a brief success
/// checkmark, used for actions that simulate network latency (login,
/// confirming an expense, recording a settlement, ...).
class PrimaryLoadingButton extends StatelessWidget {
  const PrimaryLoadingButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.state = ButtonRunState.idle,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonRunState state;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBusy = state != ButtonRunState.idle;

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: switch (state) {
        ButtonRunState.loading => SizedBox(
          key: const ValueKey('loading'),
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: theme.colorScheme.onPrimary,
          ),
        ),
        ButtonRunState.success => Row(
          key: const ValueKey('success'),
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_rounded,
              size: 20,
              color: theme.colorScheme.onPrimary,
            ),
            const SizedBox(width: AppSpacing.sm),
            const Text('Done'),
          ],
        ),
        ButtonRunState.idle => Row(
          key: const ValueKey('idle'),
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.sm),
            ],
            Text(label),
          ],
        ),
      },
    );

    // The spinner and checkmark carry no text of their own, so give screen
    // readers a label and announce state changes via a live region.
    final semanticsLabel = switch (state) {
      ButtonRunState.loading => '$label, loading',
      ButtonRunState.success => '$label, done',
      ButtonRunState.idle => null,
    };

    final button = Semantics(
      liveRegion: isBusy,
      label: semanticsLabel,
      child: FilledButton(
        onPressed: isBusy ? null : onPressed,
        style: FilledButton.styleFrom(
          disabledBackgroundColor: theme.colorScheme.primary,
          disabledForegroundColor: theme.colorScheme.onPrimary,
        ),
        child: child,
      ),
    );

    if (!expand) return button;
    return SizedBox(width: double.infinity, height: 52, child: button);
  }
}
