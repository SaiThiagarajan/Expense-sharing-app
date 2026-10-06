import '../constants/app_constants.dart';

/// Formats a whole-rupee amount for display, e.g. `1200` -> `₹1,200`.
///
/// Amounts are modeled as whole rupees throughout the app (see
/// `models/expense.dart`), so this always rounds to the nearest integer
/// rather than showing decimals.
String formatCurrency(
  num amount, {
  String symbol = AppConstants.currencySymbol,
}) {
  final rounded = amount.round();
  final sign = rounded < 0 ? '-' : '';
  final grouped = _groupThousands(rounded.abs().toString());
  return '$sign$symbol$grouped';
}

String _groupThousands(String digits) {
  final buffer = StringBuffer();
  final length = digits.length;
  for (var i = 0; i < length; i++) {
    if (i != 0 && (length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
