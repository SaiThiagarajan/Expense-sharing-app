import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/category_badge.dart';
import 'add_expense_screen.dart';

/// Full detail view for a single expense: who paid, how it was split, this
/// user's share/impact, and edit/delete actions.
class ExpenseDetailsScreen extends StatelessWidget {
  const ExpenseDetailsScreen({super.key, required this.expenseId});

  final String expenseId;

  Future<void> _confirmDelete(
    BuildContext context,
    AppState appState,
    Expense expense,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this expense?'),
        content: Text(
          '"${expense.description}" will be removed and balances will be recalculated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      appState.removeExpense(expense.id);
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Expense deleted')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final expense = appState.expenseById(expenseId);
    final payer = appState.memberById(expense.payerId);
    final isCurrentUserPayer = payer.id == appState.currentMember.id;

    var ownShare = 0;
    for (final p in expense.participants) {
      if (p.memberId == appState.currentMember.id) {
        ownShare = p.share;
        break;
      }
    }
    final impact = isCurrentUserPayer ? expense.amount - ownShare : -ownShare;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Expense details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddExpenseScreen(existingExpense: expense),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () => _confirmDelete(context, appState, expense),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Center(
                  child: Column(
                    children: [
                      CategoryBadge(category: expense.category, size: 56),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        expense.description,
                        style: theme.textTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        formatCurrency(expense.amount),
                        style: AppTypography.financialLarge(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Paid by ${isCurrentUserPayer ? 'you' : payer.name} · ${formatRelativeDate(expense.date)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: impact == 0
                        ? theme.colorScheme.surfaceContainerHigh
                        : (impact > 0
                              ? AppColors.primaryContainer
                              : AppColors.coralContainer),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your share',
                              style: theme.textTheme.bodySmall,
                            ),
                            Text(
                              formatCurrency(ownShare),
                              style: AppTypography.financialSmall(),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Your balance impact',
                            style: theme.textTheme.bodySmall,
                          ),
                          Text(
                            impact == 0
                                ? 'Settled'
                                : (impact > 0
                                      ? '+${formatCurrency(impact)}'
                                      : '-${formatCurrency(impact.abs())}'),
                            style: AppTypography.financialSmall(
                              color: impact == 0
                                  ? theme.colorScheme.onSurface
                                  : (impact > 0
                                        ? AppColors.primary
                                        : AppColors.coral),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Participants', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceIvory,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < expense.participants.length; i++) ...[
                        if (i != 0) const Divider(height: 1),
                        Builder(
                          builder: (context) {
                            final participant = expense.participants[i];
                            final member = appState.memberById(
                              participant.memberId,
                            );
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              child: Row(
                                children: [
                                  AppAvatar(member: member, radius: 16),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      member.isCurrentUser
                                          ? '${member.name} (You)'
                                          : member.name,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(participant.share),
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ],
                  ),
                ),
                if (expense.note != null && expense.note!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text('Note', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(expense.note!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
