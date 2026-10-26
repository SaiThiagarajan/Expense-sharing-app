import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/activity.dart';
import '../../state/app_state.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/interactive_card.dart';
import '../expenses/expense_details_screen.dart';

enum _ActivityFilter { all, expenses, settlements, nudges }

extension on _ActivityFilter {
  String get label {
    switch (this) {
      case _ActivityFilter.all:
        return 'All';
      case _ActivityFilter.expenses:
        return 'Expenses';
      case _ActivityFilter.settlements:
        return 'Settlements';
      case _ActivityFilter.nudges:
        return 'Nudges';
    }
  }

  bool matches(ActivityType type) {
    switch (this) {
      case _ActivityFilter.all:
        return true;
      case _ActivityFilter.expenses:
        return type == ActivityType.expense;
      case _ActivityFilter.settlements:
        return type == ActivityType.settlement;
      case _ActivityFilter.nudges:
        return type == ActivityType.nudge;
    }
  }
}

/// Timeline-style feed of everything that's happened: expenses, settlements
/// and nudges, grouped by day and filterable by type.
class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {
  _ActivityFilter _filter = _ActivityFilter.all;

  IconData _iconFor(ActivityType type) {
    switch (type) {
      case ActivityType.expense:
        return Icons.receipt_long_outlined;
      case ActivityType.settlement:
        return Icons.check_circle_outline;
      case ActivityType.nudge:
        return Icons.waving_hand_outlined;
    }
  }

  Color _colorFor(ActivityType type) {
    switch (type) {
      case ActivityType.expense:
        return AppColors.primary;
      case ActivityType.settlement:
        return AppColors.mint;
      case ActivityType.nudge:
        return AppColors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final items = appState.recentActivity
        .where((i) => _filter.matches(i.type))
        .toList();

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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text('Activity', style: theme.textTheme.headlineSmall),
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              children: [
                for (final filter in _ActivityFilter.values)
                  Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: ChoiceChip(
                      label: Text(filter.label),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.history_outlined,
                    title: 'No activity yet',
                    message: 'Actions in your household will show up here.',
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          0,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final showHeader =
                              i == 0 ||
                              formatRelativeDate(item.timestamp) !=
                                  formatRelativeDate(items[i - 1].timestamp);
                          final tile = InteractiveCard(
                            onTap: item.relatedExpenseId != null
                                ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => ExpenseDetailsScreen(
                                        expenseId: item.relatedExpenseId!,
                                      ),
                                    ),
                                  )
                                : null,
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _colorFor(
                                      item.type,
                                    ).withValues(alpha: 0.14),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    _iconFor(item.type),
                                    size: 18,
                                    color: _colorFor(item.type),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        item.title,
                                        style: theme.textTheme.bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                      Text(
                                        item.subtitle,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (!showHeader) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              child: tile,
                            );
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (i != 0) const SizedBox(height: AppSpacing.md),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: Text(
                                  formatRelativeDate(
                                    item.timestamp,
                                  ).toUpperCase(),
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.sm,
                                ),
                                child: tile,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
