import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/utils/currency_formatter.dart';
import '../../state/app_state.dart';

class _InsightData {
  const _InsightData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}

const _staticInsights = [
  _InsightData(
    icon: Icons.trending_down_rounded,
    title: 'Your group spent 18% less on food this week.',
    subtitle: 'Nice work keeping shared spending in check.',
    color: AppColors.primary,
  ),
  _InsightData(
    icon: Icons.lightbulb_outline_rounded,
    title: 'Quick tip',
    subtitle:
        'Settling smaller balances regularly keeps group expenses simple.',
    color: AppColors.amber,
  ),
];

/// Builds the "Monthly snapshot" card from the live ledger so it tracks
/// added, edited and deleted expenses instead of showing a fixed figure.
_InsightData _monthlySnapshot(AppState appState, DateTime now) {
  final monthTotal = appState.expenses
      .where((e) => e.date.year == now.year && e.date.month == now.month)
      .fold<int>(0, (sum, e) => sum + e.amount);
  return _InsightData(
    icon: Icons.pie_chart_outline_rounded,
    title: 'Monthly snapshot',
    subtitle:
        '${formatCurrency(monthTotal)} shared across '
        '${appState.household.memberCountLabel} this month.',
    color: AppColors.mint,
  );
}

/// Horizontally swipeable insight/promotional cards on the dashboard —
/// in-app product tips, never external ads.
class InsightCarousel extends StatefulWidget {
  const InsightCarousel({super.key});

  @override
  State<InsightCarousel> createState() => _InsightCarouselState();
}

class _InsightCarouselState extends State<InsightCarousel> {
  final _controller = PageController(viewportFraction: 0.92);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insights = [
      ..._staticInsights,
      _monthlySnapshot(context.watch<AppState>(), DateTime.now()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 132,
          child: PageView.builder(
            controller: _controller,
            itemCount: insights.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final data = insights[i];
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: _InsightCard(data: data),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < insights.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 16 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.primary : AppColors.outline,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({required this.data});

  final _InsightData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: data.color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.color.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
