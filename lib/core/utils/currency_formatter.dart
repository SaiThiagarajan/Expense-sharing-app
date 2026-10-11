import '../constants/app_constants.dart';

/// Formats a whole-rupee amount for display using Indian digit grouping,
/// e.g. `1200` -> `₹1,200`, `150000` -> `₹1,50,000`.
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
  final grouped = _groupIndian(rounded.abs().toString());
  return '$sign$symbol$grouped';
}

/// Groups digits the Indian way: the last three digits together, then
/// pairs (thousands, lakhs, crores), e.g. `12345678` -> `1,23,45,678`.
String _groupIndian(String digits) {
  if (digits.length <= 3) return digits;
  final head = digits.substring(0, digits.length - 3);
  final tail = digits.substring(digits.length - 3);
  final buffer = StringBuffer();
  for (var i = 0; i < head.length; i++) {
    if (i != 0 && (head.length - i) % 2 == 0) {
      buffer.write(',');
    }
    buffer.write(head[i]);
  }
  return '$buffer,$tail';
}
