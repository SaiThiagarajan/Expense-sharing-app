import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';

/// Flat (non-card) section title used to break up long scrolling screens
/// without wrapping every section in a card.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          // Exposed as a heading so screen reader users can jump between
          // sections on long scrolling screens.
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: theme.textTheme.titleLarge,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        // Only show the action when it can actually do something, rather
        // than rendering a disabled button with no callback.
        if (actionLabel != null && onAction != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            ),
            child: Text(actionLabel!),
          ),
      ],
    );
  }
}
