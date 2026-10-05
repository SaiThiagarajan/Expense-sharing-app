import 'package:flutter/material.dart';

import '../../models/expense.dart';

/// Colored circular badge for an [ExpenseCategory], used consistently in
/// expense rows, the add-expense form and category filters.
class CategoryBadge extends StatelessWidget {
  const CategoryBadge({super.key, required this.category, this.size = 44});

  final ExpenseCategory category;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: category.label,
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.16),
            shape: BoxShape.circle,
          ),
          child: Icon(category.icon, color: category.color, size: size * 0.5),
        ),
      ),
    );
  }
}
