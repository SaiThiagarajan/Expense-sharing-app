import 'package:flutter/material.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';

/// Success screen shown right after an expense is confirmed. Auto-returns
/// to the dashboard shortly after, with a manual "Done" as a fallback.
class ExpenseAddedScreen extends StatefulWidget {
  const ExpenseAddedScreen({super.key});

  @override
  State<ExpenseAddedScreen> createState() => _ExpenseAddedScreenState();
}

class _ExpenseAddedScreenState extends State<ExpenseAddedScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800), _finish);
  }

  void _finish() {
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  builder: (context, value, child) =>
                      Transform.scale(scale: value, child: child),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: const BoxDecoration(
                      color: AppColors.mintContainer,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 52,
                      color: AppColors.onMintContainer,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Expense added', style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Your group balance has been updated.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _finish,
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
