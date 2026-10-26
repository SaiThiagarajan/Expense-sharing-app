import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/responsive/breakpoints.dart';
import '../../models/activity.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/interactive_card.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/dashboard/balance_summary_card.dart';
import '../../widgets/dashboard/insight_carousel.dart';
import '../../widgets/expenses/expense_tile.dart';
import '../household/create_household_screen.dart';
import '../notifications/notifications_screen.dart';
import '../profile/profile_screen.dart';
import 'add_expense_flow.dart';

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

/// The app's home screen: greeting header, household card, balance summary,
/// primary Add Expense CTA, recent expenses, spending insights and recent
/// activity — everything reads live from [AppState].
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key, required this.onNavigateTab});

  final ValueChanged<int> onNavigateTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final isDesktop = context.screenSize == ScreenSize.desktop;
    final recentExpenses = appState.expenses.take(4).toList();
    final recentActivity = appState.recentActivity.take(3).toList();

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: _Header(appState: appState),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: _HouseholdStrip(appState: appState),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                0,
              ),
              child: BalanceSummaryCard(
                netBalance: appState.netBalance,
                youOwe: appState.totalYouOwe,
                owedToYou: appState.totalOwedToYou,
              ),
            ),
          ),
          if (isDesktop)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  0,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () => startAddExpenseFlow(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Expense'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SectionHeader(
                title: 'Recent Expenses',
                actionLabel: 'See all',
                onAction: () => onNavigateTab(1),
              ),
            ),
          ),
          if (recentExpenses.isEmpty)
            SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'No expenses yet',
                message: 'Add your first expense to get started.',
                actionLabel: 'Add Expense',
                onAction: () => startAddExpenseFlow(context),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList.separated(
                itemCount: recentExpenses.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) =>
                    ExpenseTile(expense: recentExpenses[i]),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: const InsightCarousel(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: SectionHeader(
                title: 'Recent Activity',
                actionLabel: 'See all',
                onAction: () => onNavigateTab(4),
              ),
            ),
          ),
          if (recentActivity.isEmpty)
            const SliverToBoxAdapter(
              child: EmptyState(
                icon: Icons.history_outlined,
                title: 'No activity yet',
                message: 'Your activity feed will show up here.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              sliver: SliverList.separated(
                itemCount: recentActivity.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, i) {
                  final item = recentActivity[i];
                  return InteractiveCard(
                    onTap: item.relatedExpenseId != null
                        ? () => onNavigateTab(4)
                        : null,
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            item.type == ActivityType.settlement
                                ? Icons.check_circle_outline
                                : Icons.receipt_long_outlined,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                item.title,
                                style: theme.textTheme.bodyLarge?.copyWith(
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
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final member = appState.currentMember;
    final unread = appState.unreadNotificationCount;

    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
          onTap: () => Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const ProfileScreen())),
          child: AppAvatar(member: member, radius: 24),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(
            '${_greeting()}, ${member.name} 👋',
            style: theme.textTheme.titleLarge,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              ),
              icon: const Icon(Icons.notifications_outlined),
              style: IconButton.styleFrom(
                backgroundColor: theme.colorScheme.surfaceContainerHigh,
              ),
            ),
            if (unread > 0)
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: const BoxDecoration(
                    color: AppColors.coral,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _HouseholdStrip extends StatelessWidget {
  const _HouseholdStrip({required this.appState});

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InteractiveCard(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const CreateHouseholdScreen())),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.amberContainer,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Icon(
              Icons.house_rounded,
              size: 18,
              color: AppColors.onAmberContainer,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appState.household.name,
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${appState.members.length} members',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
