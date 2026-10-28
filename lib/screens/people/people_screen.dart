import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/member.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/interactive_card.dart';
import '../balances/settle_up_screen.dart';
import '../nudge/gentle_nudge_screen.dart';
import '../profile/profile_screen.dart';

/// The household's member roster with each person's live balance, derived
/// straight from [AppState.netBalanceByMember].
class PeopleScreen extends StatelessWidget {
  const PeopleScreen({super.key});

  void _openMemberActions(BuildContext context, Member member, int balance) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppAvatar(member: member, radius: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          member.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          balance == 0
                              ? 'Settled up'
                              : (balance > 0
                                    ? 'Owes you ${formatCurrency(balance)}'
                                    : 'You owe ${formatCurrency(balance.abs())}'),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              if (balance != 0) ...[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Settle up'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => SettleUpScreen(memberId: member.id),
                      ),
                    );
                  },
                ),
                if (balance > 0)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.waving_hand_outlined),
                    title: const Text('Send a nudge'),
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              GentleNudgeScreen(memberId: member.id),
                        ),
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addMember(BuildContext context, AppState appState) async {
    final controller = TextEditingController();
    final colors = [
      AppColors.primary,
      AppColors.mint,
      AppColors.amber,
      AppColors.coral,
    ];
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add member'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      final color = colors[appState.members.length % colors.length];
      appState.addMember(
        Member(
          id: 'm_${DateTime.now().microsecondsSinceEpoch}',
          name: name,
          avatarColor: color,
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$name added to ${appState.household.name}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final balances = appState.netBalanceByMember;
    final members = appState.members;

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          appState.household.name,
                          style: theme.textTheme.headlineSmall,
                        ),
                        Text(
                          '${members.length} members',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => _addMember(context, appState),
                    icon: const Icon(Icons.person_add_alt_1_outlined),
                    label: const Text('Add Member'),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              0,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            sliver: SliverList.separated(
              itemCount: members.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final member = members[i];
                final isCurrentUser = member.id == appState.currentMember.id;
                final balance = isCurrentUser ? 0 : (balances[member.id] ?? 0);

                return InteractiveCard(
                  onTap: isCurrentUser
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        )
                      : () => _openMemberActions(context, member, balance),
                  child: Row(
                    children: [
                      AppAvatar(member: member, radius: 22),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              isCurrentUser
                                  ? '${member.name} (You)'
                                  : member.name,
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            _BalanceLabel(
                              isCurrentUser: isCurrentUser,
                              balance: balance,
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
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _BalanceLabel extends StatelessWidget {
  const _BalanceLabel({required this.isCurrentUser, required this.balance});

  final bool isCurrentUser;
  final int balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (isCurrentUser) {
      return Text('This is you', style: theme.textTheme.bodySmall);
    }
    if (balance == 0) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle_outline,
            size: 14,
            color: AppColors.mutedText,
          ),
          const SizedBox(width: 4),
          Text('Settled up', style: theme.textTheme.bodySmall),
        ],
      );
    }
    final owesYou = balance > 0;
    return Text(
      owesYou
          ? '${formatCurrency(balance)} → You'
          : 'You owe ${formatCurrency(balance.abs())}',
      style: theme.textTheme.bodySmall?.copyWith(
        color: owesYou ? AppColors.primary : AppColors.coral,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
