import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/primary_loading_button.dart';

/// A friendly, low-pressure reminder flow for a member who owes the current
/// user money.
class GentleNudgeScreen extends StatefulWidget {
  const GentleNudgeScreen({super.key, required this.memberId});

  final String memberId;

  @override
  State<GentleNudgeScreen> createState() => _GentleNudgeScreenState();
}

class _GentleNudgeScreenState extends State<GentleNudgeScreen> {
  ButtonRunState _state = ButtonRunState.idle;

  Future<void> _send() async {
    setState(() => _state = ButtonRunState.loading);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    context.read<AppState>().sendNudge(widget.memberId);
    setState(() => _state = ButtonRunState.success);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nudge sent ✓')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final member = appState.memberById(widget.memberId);
    final balance = appState.netBalanceByMember[widget.memberId] ?? 0;
    // Only a positive balance means this member owes the current user;
    // anything else would make the reminder copy below untrue.
    final owesYou = balance > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Gentle nudge')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppAvatar(member: member, radius: 36),
                  const SizedBox(height: AppSpacing.lg),
                  if (!owesYou) ...[
                    Text(
                      "${member.name} doesn't owe you anything",
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'There is nothing to nudge them about right now.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Back'),
                    ),
                  ] else ...[
                    Text(
                      '${member.name} owes you',
                      style: theme.textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatCurrency(balance.abs()),
                      style: AppTypography.financialLarge(
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Want to give them a little reminder?',
                      style: theme.textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.amberContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusLg,
                        ),
                      ),
                      child: Text(
                        '"Hey! Whenever you get a chance 🙂"',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.onAmberContainer,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    PrimaryLoadingButton(
                      label: 'Send Nudge',
                      state: _state,
                      onPressed: _send,
                      icon: Icons.waving_hand_outlined,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Maybe later'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
