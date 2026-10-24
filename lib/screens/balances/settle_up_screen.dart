import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/settlement.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/primary_loading_button.dart';

enum _SettleMethod { upi, cash, other }

extension on _SettleMethod {
  String get label {
    switch (this) {
      case _SettleMethod.upi:
        return 'UPI';
      case _SettleMethod.cash:
        return 'Cash';
      case _SettleMethod.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case _SettleMethod.upi:
        return Icons.qr_code_rounded;
      case _SettleMethod.cash:
        return Icons.payments_outlined;
      case _SettleMethod.other:
        return Icons.more_horiz_rounded;
    }
  }
}

/// Records a settlement between the current user and one member. Frontend
/// only — no real payment is made, this just updates mock app state.
class SettleUpScreen extends StatefulWidget {
  const SettleUpScreen({super.key, required this.memberId});

  final String memberId;

  @override
  State<SettleUpScreen> createState() => _SettleUpScreenState();
}

class _SettleUpScreenState extends State<SettleUpScreen> {
  late TextEditingController _amountController;
  _SettleMethod _method = _SettleMethod.upi;
  ButtonRunState _state = ButtonRunState.idle;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final balance = appState.netBalanceByMember[widget.memberId] ?? 0;
    _amountController = TextEditingController(
      text: balance == 0 ? '' : balance.abs().toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _markSettled(bool youOwe, int outstanding) async {
    final amount = int.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      setState(() => _amountError = 'Enter a valid amount');
      return;
    }
    // Paying more than is owed would silently flip who owes whom.
    if (amount > outstanding) {
      setState(
        () => _amountError =
            'Amount can be at most ${formatCurrency(outstanding)}',
      );
      return;
    }
    setState(() {
      _amountError = null;
      _state = ButtonRunState.loading;
    });
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final appState = context.read<AppState>();
    appState.recordSettlement(
      memberId: widget.memberId,
      amount: amount,
      direction: youOwe
          ? SettlementDirection.youPaid
          : SettlementDirection.theyPaid,
      method: _method.label,
    );

    setState(() => _state = ButtonRunState.success);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(content: Text('Settlement recorded ✓')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final member = appState.memberById(widget.memberId);
    final balance = appState.netBalanceByMember[widget.memberId] ?? 0;
    final youOwe = balance < 0;
    final settledUp = balance == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Settle with ${member.name}')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Center(
                  child: Column(
                    children: [
                      AppAvatar(member: member, radius: 32),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        settledUp
                            ? "You're all settled up"
                            : youOwe
                            ? 'You owe'
                            : '${member.name} owes you',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatCurrency(balance.abs()),
                        style: AppTypography.financialLarge(
                          color: settledUp
                              ? theme.colorScheme.onSurfaceVariant
                              : youOwe
                              ? AppColors.coral
                              : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Amount', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  controller: _amountController,
                  enabled: !settledUp,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onChanged: (_) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    errorText: _amountError,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Choose method', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (final method in _SettleMethod.values) ...[
                      Expanded(
                        child: _MethodCard(
                          method: method,
                          selected: _method == method,
                          onTap: () => setState(() => _method = method),
                        ),
                      ),
                      if (method != _SettleMethod.values.last)
                        const SizedBox(width: AppSpacing.sm),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
                PrimaryLoadingButton(
                  label: 'Mark as Settled',
                  state: _state,
                  // Stay enabled through the success animation, when the
                  // balance has just dropped to zero.
                  onPressed: settledUp && _state == ButtonRunState.idle
                      ? null
                      : () => _markSettled(youOwe, balance.abs()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.method,
    required this.selected,
    required this.onTap,
  });

  final _SettleMethod method;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected ? AppColors.primaryContainer : AppColors.surfaceIvory,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.outline,
            ),
          ),
          child: Column(
            children: [
              Icon(
                method.icon,
                color: selected
                    ? AppColors.onPrimaryContainer
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(method.label, style: theme.textTheme.labelLarge),
            ],
          ),
        ),
      ),
    );
  }
}
