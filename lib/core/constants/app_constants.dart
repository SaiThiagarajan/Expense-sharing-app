/// App-wide constants that aren't visual tokens (those live in
/// `app/theme/`). Keep this list small — anything derivable from mock data
/// or state does not belong here.
class AppConstants {
  AppConstants._();

  static const String appName = 'Splitly';
  static const String currencySymbol = '₹';

  static const Duration shortAnimation = Duration(milliseconds: 180);
  static const Duration mediumAnimation = Duration(milliseconds: 240);

  /// Max content width for wide desktop layouts so text/cards don't stretch
  /// uncomfortably across ultra-wide windows.
  static const double desktopContentMaxWidth = 1120;
}
