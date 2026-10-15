import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';

/// A tappable card/row that visibly reacts to interaction: a slight lift +
/// shadow + translate on desktop hover, a scale-down press effect
/// everywhere. Used for anything clickable that isn't a plain button
/// (expense rows, member rows, activity rows, insight cards, ...).
///
/// Honors the platform "reduce motion" setting: the lift and press effects
/// still apply, but snap instantly instead of animating.
class InteractiveCard extends StatefulWidget {
  const InteractiveCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.borderRadius = AppSpacing.radiusLg,
    this.color,
    this.border = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final Color? color;
  final bool border;

  @override
  State<InteractiveCard> createState() => _InteractiveCardState();
}

class _InteractiveCardState extends State<InteractiveCard> {
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);
    final lifted = _hovered && widget.onTap != null;
    final pressed = _pressed && widget.onTap != null;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : AppConstants.shortAnimation;

    final content = AnimatedContainer(
      duration: duration,
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: widget.color ?? AppColors.surfaceIvory,
        borderRadius: radius,
        border: widget.border
            ? Border.all(color: AppColors.outlineVariant)
            : null,
        boxShadow: lifted
            ? [
                BoxShadow(
                  color: AppColors.charcoal.withValues(alpha: 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : const [],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: widget.onTap,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedSlide(
          duration: duration,
          curve: Curves.easeOut,
          offset: Offset(0, lifted ? -0.015 : 0),
          child: AnimatedScale(
            duration: duration,
            curve: Curves.easeOut,
            scale: pressed ? 0.985 : 1.0,
            child: content,
          ),
        ),
      ),
    );
  }
}
