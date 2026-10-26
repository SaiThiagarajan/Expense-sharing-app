import 'package:flutter/material.dart';

import '../expenses/add_expense_screen.dart';

/// Entry point into the Add Expense → Split → Success flow, used by the
/// dashboard CTA, the nav rail/sidebar buttons and the mobile FAB.
void startAddExpenseFlow(BuildContext context) {
  Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const AddExpenseScreen()));
}
