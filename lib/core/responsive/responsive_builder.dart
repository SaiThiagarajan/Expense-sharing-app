import 'package:flutter/widgets.dart';

import 'breakpoints.dart';

typedef ResponsiveWidgetBuilder =
    Widget Function(BuildContext context, ScreenSize screenSize);

/// Rebuilds its subtree whenever the available width crosses a breakpoint,
/// using the layout's own constraints rather than the window's media query
/// (so it also behaves correctly inside a fixed-width panel).
///
/// When the width is unbounded (e.g. inside a horizontal scroll view) it
/// falls back to the window width instead of always reporting desktop.
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final ResponsiveWidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        return builder(context, screenSizeFromWidth(width));
      },
    );
  }
}

/// Picks a value based on the current [ScreenSize], falling back to the
/// next-smaller size when a larger one isn't specified.
class ResponsiveValue<T> {
  const ResponsiveValue({required this.mobile, this.tablet, this.desktop});

  final T mobile;
  final T? tablet;
  final T? desktop;

  T resolve(ScreenSize size) {
    switch (size) {
      case ScreenSize.mobile:
        return mobile;
      case ScreenSize.tablet:
        return tablet ?? mobile;
      case ScreenSize.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}
