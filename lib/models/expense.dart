import 'package:flutter/material.dart';

import '../app/theme/app_colors.dart';

enum ExpenseCategory {
  food,
  groceries,
  transport,
  utilities,
  entertainment,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.groceries:
        return 'Groceries';
      case ExpenseCategory.transport:
        return 'Transport';
      case ExpenseCategory.utilities:
        return 'Utilities';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_outlined;
      case ExpenseCategory.groceries:
        return Icons.shopping_basket_outlined;
      case ExpenseCategory.transport:
        return Icons.directions_car_outlined;
      case ExpenseCategory.utilities:
        return Icons.bolt_outlined;
      case ExpenseCategory.entertainment:
        return Icons.celebration_outlined;
      case ExpenseCategory.other:
        return Icons.receipt_long_outlined;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return AppColors.coral;
      case ExpenseCategory.groceries:
        return AppColors.mint;
      case ExpenseCategory.transport:
        return AppColors.amber;
      case ExpenseCategory.utilities:
        return AppColors.primary;
      case ExpenseCategory.entertainment:
        return const Color(0xFFB07CC6);
      case ExpenseCategory.other:
        return AppColors.mutedText;
    }
  }
}

enum SplitMethod { equal, exact, percentage, shares }

/// One member's share of an [Expense]. [share] is always the resolved
/// rupee amount, regardless of which [SplitMethod] produced it.
class ExpenseParticipant {
  const ExpenseParticipant({required this.memberId, required this.share});

  final String memberId;
  final int share;
}

class Expense {
  const Expense({
    required this.id,
    required this.description,
    required this.amount,
    required this.category,
    required this.payerId,
    required this.date,
    required this.participants,
    this.splitMethod = SplitMethod.equal,
    this.note,
  });

  final String id;
  final String description;
  final int amount;
  final ExpenseCategory category;
  final String payerId;
  final DateTime date;
  final List<ExpenseParticipant> participants;
  final SplitMethod splitMethod;
  final String? note;

  Expense copyWith({
    String? description,
    int? amount,
    ExpenseCategory? category,
    String? payerId,
    DateTime? date,
    List<ExpenseParticipant>? participants,
    SplitMethod? splitMethod,
    String? note,
  }) {
    return Expense(
      id: id,
      description: description ?? this.description,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      payerId: payerId ?? this.payerId,
      date: date ?? this.date,
      participants: participants ?? this.participants,
      splitMethod: splitMethod ?? this.splitMethod,
      note: note ?? this.note,
    );
  }
}
