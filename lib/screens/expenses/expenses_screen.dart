import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/responsive/breakpoints.dart';
import '../../models/expense.dart';
import '../../state/app_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/expenses/expense_tile.dart';
import '../dashboard/add_expense_flow.dart';

enum _SortMode { newest, oldest, highest, lowest }

extension on _SortMode {
  String get label {
    switch (this) {
      case _SortMode.newest:
        return 'Newest';
      case _SortMode.oldest:
        return 'Oldest';
      case _SortMode.highest:
        return 'Highest amount';
      case _SortMode.lowest:
        return 'Lowest amount';
    }
  }

  IconData get icon {
    switch (this) {
      case _SortMode.newest:
      case _SortMode.oldest:
        return Icons.schedule_outlined;
      case _SortMode.highest:
      case _SortMode.lowest:
        return Icons.swap_vert_rounded;
    }
  }
}

/// The full expense ledger: search, category filters, sorting and the
/// complete (not just "recent") expense list.
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  ExpenseCategory? _categoryFilter;
  _SortMode _sort = _SortMode.newest;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickSort() async {
    final selected = await showModalBottomSheet<_SortMode>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Sort by'),
              ),
            ),
            for (final mode in _SortMode.values)
              ListTile(
                leading: Icon(mode.icon),
                title: Text(mode.label),
                trailing: mode == _sort
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(mode),
              ),
          ],
        ),
      ),
    );
    if (selected != null) setState(() => _sort = selected);
  }

  List<Expense> _filtered(List<Expense> all) {
    var list = all.where((e) {
      final matchesQuery =
          _query.isEmpty ||
          e.description.toLowerCase().contains(_query.toLowerCase());
      final matchesCategory =
          _categoryFilter == null || e.category == _categoryFilter;
      return matchesQuery && matchesCategory;
    }).toList();

    switch (_sort) {
      case _SortMode.newest:
        list.sort((a, b) => b.date.compareTo(a.date));
        break;
      case _SortMode.oldest:
        list.sort((a, b) => a.date.compareTo(b.date));
        break;
      case _SortMode.highest:
        list.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case _SortMode.lowest:
        list.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final expenses = _filtered(appState.expenses);
    final isDesktop = context.screenSize == ScreenSize.desktop;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Expenses', style: theme.textTheme.headlineSmall),
                ),
                if (isDesktop)
                  FilledButton.icon(
                    onPressed: () => startAddExpenseFlow(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: InputDecoration(
                      hintText: 'Search expenses',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => setState(() {
                                _searchController.clear();
                                _query = '';
                              }),
                            ),
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  onPressed: _pickSort,
                  icon: const Icon(Icons.sort_rounded),
                  tooltip: 'Sort',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _categoryFilter == null,
                  onTap: () => setState(() => _categoryFilter = null),
                ),
                for (final category in ExpenseCategory.values)
                  Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.sm),
                    child: _FilterChip(
                      label: category.label,
                      selected: _categoryFilter == category,
                      onTap: () => setState(() => _categoryFilter = category),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: expenses.isEmpty
                ? EmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: appState.expenses.isEmpty
                        ? 'No expenses yet'
                        : 'No matching expenses',
                    message: appState.expenses.isEmpty
                        ? 'No expenses here yet.\nAdd your first expense to get started.'
                        : 'Try a different search or filter.',
                    actionLabel: appState.expenses.isEmpty
                        ? 'Add Expense'
                        : null,
                    onAction: appState.expenses.isEmpty
                        ? () => startAddExpenseFlow(context)
                        : null,
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        itemCount: expenses.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, i) =>
                            ExpenseTile(expense: expenses[i]),
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? AppColors.primary : AppColors.surfaceIvory,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: selected
                  ? AppColors.surfaceIvory
                  : theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
