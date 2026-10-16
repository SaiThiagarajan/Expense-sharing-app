import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';

/// The dashboard's headline balance block: overall net balance plus the
/// "you owe" / "owed to you" split. Deliberately not wrapped as a plain
/// card — it's the visual anchor of the screen.
class BalanceSummaryCard extends StatelessWidget {
  const BalanceSummaryCard({
    super.key,
    required this.netBalance,
    required this.youOwe,
    required this.owedToYou,
  });

  final int netBalance;
  final int youOwe;
  final int owedToYou;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive = netBalance >= 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                color: AppColors.surfaceIvory.withValues(alpha: 0.85),
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  isPositive ? 'You are owed overall' : 'You owe overall',
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.surfaceIvory.withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            formatCurrency(netBalance.abs()),
            style: AppTypography.financialLarge(
              color: AppColors.surfaceIvory,
            ).copyWith(fontSize: 40),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            height: 1,
            color: AppColors.surfaceIvory.withValues(alpha: 0.16),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  icon: Icons.arrow_upward_rounded,
                  iconColor: AppColors.coral,
                  label: 'You owe',
                  amount: youOwe,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.surfaceIvory.withValues(alpha: 0.16),
              ),
              Expanded(
                child: _MiniStat(
                  icon: Icons.arrow_downward_rounded,
                  iconColor: AppColors.mint,
                  label: 'Others owe you',
                  amount: owedToYou,
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    this.alignEnd = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final int amount;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final children = [
      Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.surfaceIvory.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 13, color: iconColor),
          ),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.surfaceIvory.withValues(alpha: 0.75),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      Text(
        formatCurrency(amount),
        style: AppTypography.financialMedium(color: AppColors.surfaceIvory),
      ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: alignEnd ? AppSpacing.md : 0,
        right: alignEnd ? 0 : AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: alignEnd
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
