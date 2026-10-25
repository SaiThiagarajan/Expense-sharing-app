import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/member.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/common/interactive_card.dart';
import '../../widgets/common/section_header.dart';
import 'settle_up_screen.dart';

/// Balances broken into "you owe" / "owed to you" / "settled", with a
/// prominent overall figure at the top. Everything is derived from
/// [AppState.netBalanceByMember].
class BalancesScreen extends StatelessWidget {
  const BalancesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final balances = appState.netBalanceByMember;
    final net = appState.netBalance;

    final youOwe = <Member, int>{};
    final owedToYou = <Member, int>{};
    final settled = <Member>[];

    for (final entry in balances.entries) {
      final member = appState.memberById(entry.key);
      if (entry.value > 0) {
        owedToYou[member] = entry.value;
      } else if (entry.value < 0) {
        youOwe[member] = entry.value.abs();
      } else {
        settled.add(member);
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.xxl,
        ),
        children: [
          Text('Balances', style: theme.textTheme.headlineSmall),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Column(
              children: [
                Text(
                  formatCurrency(net.abs()),
                  style: AppTypography.financialLarge(
                    color: net == 0
                        ? theme.colorScheme.onSurface
                        : (net > 0 ? AppColors.primary : AppColors.coral),
                  ).copyWith(fontSize: 40),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  net == 0
                      ? "You're all square overall"
                      : (net > 0 ? 'You are owed overall' : 'You owe overall'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          if (youOwe.isEmpty && owedToYou.isEmpty && settled.isEmpty)
            const EmptyState(
              icon: Icons.celebration_outlined,
              title: "You're all settled 🎉",
              message: 'No balances to show right now.',
            )
          else ...[
            if (youOwe.isNotEmpty) ...[
              const SectionHeader(title: 'You owe'),
              const SizedBox(height: AppSpacing.sm),
              for (final entry in youOwe.entries) ...[
                _BalanceRow(
                  member: entry.key,
                  amount: entry.value,
                  youOwe: true,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
            if (owedToYou.isNotEmpty) ...[
              const SectionHeader(title: 'Owed to you'),
              const SizedBox(height: AppSpacing.sm),
              for (final entry in owedToYou.entries) ...[
                _BalanceRow(
                  member: entry.key,
                  amount: entry.value,
                  youOwe: false,
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              const SizedBox(height: AppSpacing.md),
            ],
            if (settled.isNotEmpty) ...[
              const SectionHeader(title: 'Settled'),
              const SizedBox(height: AppSpacing.sm),
              for (final member in settled) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceIvory,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      AppAvatar(member: member, radius: 18),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          member.name,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const Icon(
                        Icons.check_circle,
                        size: 18,
                        color: AppColors.mint,
                      ),
                      const SizedBox(width: 4),
                      Text('Settled', style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _BalanceRow extends StatelessWidget {
  const _BalanceRow({
    required this.member,
    required this.amount,
    required this.youOwe,
  });

  final Member member;
  final int amount;
  final bool youOwe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = youOwe ? AppColors.coral : AppColors.primary;
    return InteractiveCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => SettleUpScreen(memberId: member.id)),
      ),
      child: Row(
        children: [
          AppAvatar(member: member, radius: 20),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(member.name, style: theme.textTheme.titleSmall),
                Row(
                  children: [
                    Icon(
                      youOwe
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 14,
                      color: color,
                    ),
                    const SizedBox(width: 2),
                    Flexible(
                      child: Text(
                        youOwe ? 'You owe' : 'Owes you',
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
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
                formatCurrency(amount),
                style: AppTypography.financialSmall(color: color),
              ),
              const SizedBox(height: 2),
              Text(
                'Settle Up',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.primary,
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
