import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense.dart';
import '../../screens/expenses/expense_details_screen.dart';
import '../../state/app_state.dart';
import '../common/category_badge.dart';
import '../common/interactive_card.dart';

/// A single expense row used on the Dashboard's "Recent Expenses" list and
/// the full Expenses screen. Shows the payer, the amount and this user's
/// balance impact, and opens [ExpenseDetailsScreen] on tap.
class ExpenseTile extends StatelessWidget {
  const ExpenseTile({super.key, required this.expense});

  final Expense expense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final payer = appState.memberById(expense.payerId);
    final meId = appState.currentMember.id;
    final isCurrentUserPayer = payer.id == meId;
    final impact = expense.netImpactFor(meId);

    return InteractiveCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ExpenseDetailsScreen(expenseId: expense.id),
        ),
      ),
      child: Row(
        children: [
          CategoryBadge(category: expense.category),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  expense.description,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Paid by ${isCurrentUserPayer ? 'you' : payer.name} · ${formatRelativeDate(expense.date)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                formatCurrency(expense.amount),
                style: AppTypography.financialSmall(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 2),
              if (impact == 0)
                Text('Settled', style: theme.textTheme.bodySmall)
              else
                Text(
                  impact > 0
                      ? '+${formatCurrency(impact)}'
                      : '-${formatCurrency(impact.abs())}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: impact > 0 ? AppColors.primary : AppColors.coral,
                    fontWeight: FontWeight.w700,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
