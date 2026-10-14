import 'package:flutter/widgets.dart';

/// Width thresholds used to classify the available layout space. These are
/// based on available width, never on device type, so the app adapts to a
/// resized browser window or a split-screen tablet just as it would to a
/// different physical device.
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

enum ScreenSize { mobile, tablet, desktop }

ScreenSize screenSizeFromWidth(double width) {
  if (width < AppBreakpoints.mobile) return ScreenSize.mobile;
  if (width < AppBreakpoints.tablet) return ScreenSize.tablet;
  return ScreenSize.desktop;
}

extension ScreenSizeContext on BuildContext {
  ScreenSize get screenSize =>
      screenSizeFromWidth(MediaQuery.sizeOf(this).width);
  bool get isMobile => screenSize == ScreenSize.mobile;
  bool get isTablet => screenSize == ScreenSize.tablet;
  bool get isDesktop => screenSize == ScreenSize.desktop;
}
