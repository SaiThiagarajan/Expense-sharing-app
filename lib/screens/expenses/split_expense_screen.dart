import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/expense.dart';
import '../../models/member.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/primary_loading_button.dart';
import 'expense_added_screen.dart';

/// Split-configuration screen: pick who was involved and how the amount is
/// divided (equal / exact / percentage / shares), then confirm to create
/// (or, when editing, update) the [Expense].
class SplitExpenseScreen extends StatefulWidget {
  const SplitExpenseScreen({
    super.key,
    required this.description,
    required this.amount,
    required this.payerId,
    required this.category,
    required this.date,
    this.note,
    this.existingExpense,
  });

  final String description;
  final int amount;
  final String payerId;
  final ExpenseCategory category;
  final DateTime date;
  final String? note;
  final Expense? existingExpense;

  bool get isEditing => existingExpense != null;

  @override
  State<SplitExpenseScreen> createState() => _SplitExpenseScreenState();
}

/// Splits [amount] across [count] shares as evenly as possible, handing the
/// leftover rupee(s) to the first entries so the parts always sum exactly.
List<int> distributeEqually(int amount, int count) {
  if (count <= 0) return const [];
  final base = amount ~/ count;
  final remainder = amount % count;
  return [for (var i = 0; i < count; i++) base + (i < remainder ? 1 : 0)];
}

class _SplitExpenseScreenState extends State<SplitExpenseScreen> {
  late Set<String> _selectedIds;
  SplitMethod _method = SplitMethod.equal;
  final Map<String, TextEditingController> _exactControllers = {};
  final Map<String, TextEditingController> _percentControllers = {};
  final Map<String, int> _shareCounts = {};
  ButtonRunState _state = ButtonRunState.idle;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    final existing = widget.existingExpense;
    _selectedIds = existing != null
        ? existing.participants.map((p) => p.memberId).toSet()
        : appState.members.map((m) => m.id).toSet();

    for (final member in appState.members) {
      _exactControllers[member.id] = TextEditingController();
      _percentControllers[member.id] = TextEditingController();
      _shareCounts[member.id] = 1;
    }
  }

  @override
  void dispose() {
    for (final c in _exactControllers.values) {
      c.dispose();
    }
    for (final c in _percentControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<Member> get _selectedMembers {
    final appState = context.read<AppState>();
    return appState.members.where((m) => _selectedIds.contains(m.id)).toList();
  }

  int get _exactTotal => _selectedMembers.fold(
    0,
    (sum, m) => sum + (int.tryParse(_exactControllers[m.id]!.text) ?? 0),
  );

  int get _percentTotal => _selectedMembers.fold(
    0,
    (sum, m) => sum + (int.tryParse(_percentControllers[m.id]!.text) ?? 0),
  );

  int get _totalShares =>
      _selectedMembers.fold(0, (sum, m) => sum + (_shareCounts[m.id] ?? 0));

  Map<String, int> _resolveShares() {
    final selected = _selectedMembers;
    switch (_method) {
      case SplitMethod.equal:
        final parts = distributeEqually(widget.amount, selected.length);
        return {
          for (var i = 0; i < selected.length; i++) selected[i].id: parts[i],
        };
      case SplitMethod.exact:
        return {
          for (final m in selected)
            m.id: int.tryParse(_exactControllers[m.id]!.text) ?? 0,
        };
      case SplitMethod.percentage:
        final pcts = {
          for (final m in selected)
            m.id: int.tryParse(_percentControllers[m.id]!.text) ?? 0,
        };
        final resolved = <String, int>{};
        var allocated = 0;
        for (var i = 0; i < selected.length; i++) {
          final m = selected[i];
          if (i == selected.length - 1) {
            resolved[m.id] = widget.amount - allocated;
          } else {
            final share = (widget.amount * (pcts[m.id] ?? 0) / 100).round();
            resolved[m.id] = share;
            allocated += share;
          }
        }
        return resolved;
      case SplitMethod.shares:
        final total = _totalShares;
        if (total == 0) return {for (final m in selected) m.id: 0};
        final resolved = <String, int>{};
        var allocated = 0;
        for (var i = 0; i < selected.length; i++) {
          final m = selected[i];
          if (i == selected.length - 1) {
            resolved[m.id] = widget.amount - allocated;
          } else {
            final share = (widget.amount * (_shareCounts[m.id] ?? 0) / total)
                .round();
            resolved[m.id] = share;
            allocated += share;
          }
        }
        return resolved;
    }
  }

  bool get _isValid {
    if (_selectedIds.isEmpty) return false;
    switch (_method) {
      case SplitMethod.equal:
        return true;
      case SplitMethod.exact:
        return _exactTotal == widget.amount;
      case SplitMethod.percentage:
        return _percentTotal == 100;
      case SplitMethod.shares:
        return _totalShares > 0;
    }
  }

  Future<void> _confirm() async {
    if (!_isValid) {
      setState(() => _validationError = 'Check the split before continuing.');
      return;
    }
    setState(() {
      _validationError = null;
      _state = ButtonRunState.loading;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;

    final appState = context.read<AppState>();
    final shares = _resolveShares();
    final participants = [
      for (final entry in shares.entries)
        ExpenseParticipant(memberId: entry.key, share: entry.value),
    ];

    final expense = Expense(
      id:
          widget.existingExpense?.id ??
          'e_${DateTime.now().microsecondsSinceEpoch}',
      description: widget.description,
      amount: widget.amount,
      category: widget.category,
      payerId: widget.payerId,
      date: widget.date,
      participants: participants,
      splitMethod: _method,
      note: widget.note,
    );

    setState(() => _state = ButtonRunState.success);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;

    if (widget.isEditing) {
      appState.updateExpense(expense);
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Expense updated successfully')),
      );
    } else {
      appState.addExpense(expense);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ExpenseAddedScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final members = appState.members;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text('Split ${formatCurrency(widget.amount)}')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.xxl,
              ),
              children: [
                Text('Who was there?', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceIvory,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < members.length; i++) ...[
                        if (i != 0) const Divider(height: 1),
                        _ParticipantRow(
                          member: members[i],
                          selected: _selectedIds.contains(members[i].id),
                          onChanged: (v) => setState(() {
                            if (v) {
                              _selectedIds.add(members[i].id);
                            } else {
                              _selectedIds.remove(members[i].id);
                            }
                          }),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text('Split method', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                SegmentedButton<SplitMethod>(
                  segments: const [
                    ButtonSegment(
                      value: SplitMethod.equal,
                      label: Text('Equal'),
                    ),
                    ButtonSegment(
                      value: SplitMethod.exact,
                      label: Text('Exact'),
                    ),
                    ButtonSegment(
                      value: SplitMethod.percentage,
                      label: Text('%'),
                    ),
                    ButtonSegment(
                      value: SplitMethod.shares,
                      label: Text('Shares'),
                    ),
                  ],
                  selected: {_method},
                  onSelectionChanged: (s) => setState(() {
                    _method = s.first;
                    _validationError = null;
                  }),
                ),
                const SizedBox(height: AppSpacing.lg),
                _SplitEditor(
                  method: _method,
                  members: _selectedMembers,
                  amount: widget.amount,
                  exactControllers: _exactControllers,
                  percentControllers: _percentControllers,
                  shareCounts: _shareCounts,
                  onSharesChanged: () => setState(() {}),
                  exactTotal: _exactTotal,
                  percentTotal: _percentTotal,
                ),
                if (_validationError != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _validationError!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                PrimaryLoadingButton(
                  label: widget.isEditing ? 'Save Changes' : 'Confirm Split',
                  state: _state,
                  onPressed: _confirm,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ParticipantRow extends StatelessWidget {
  const _ParticipantRow({
    required this.member,
    required this.selected,
    required this.onChanged,
  });

  final Member member;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!selected),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            Checkbox(value: selected, onChanged: (v) => onChanged(v ?? false)),
            AppAvatar(member: member, radius: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                member.isCurrentUser ? '${member.name} (You)' : member.name,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitEditor extends StatelessWidget {
  const _SplitEditor({
    required this.method,
    required this.members,
    required this.amount,
    required this.exactControllers,
    required this.percentControllers,
    required this.shareCounts,
    required this.onSharesChanged,
    required this.exactTotal,
    required this.percentTotal,
  });

  final SplitMethod method;
  final List<Member> members;
  final int amount;
  final Map<String, TextEditingController> exactControllers;
  final Map<String, TextEditingController> percentControllers;
  final Map<String, int> shareCounts;
  final VoidCallback onSharesChanged;
  final int exactTotal;
  final int percentTotal;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const Text('Select at least one person to split with.');
    }
    switch (method) {
      case SplitMethod.equal:
        final parts = distributeEqually(amount, members.length);
        return Column(
          children: [
            for (var i = 0; i < members.length; i++)
              _AmountRow(
                member: members[i],
                trailing: Text(
                  formatCurrency(parts[i]),
                  style: AppTypography.financialSmall(),
                ),
              ),
          ],
        );
      case SplitMethod.exact:
        final remaining = amount - exactTotal;
        return Column(
          children: [
            for (final m in members)
              _AmountRow(
                member: m,
                trailing: SizedBox(
                  width: 100,
                  child: TextField(
                    controller: exactControllers[m.id],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.end,
                    onChanged: (_) => onSharesChanged(),
                    decoration: const InputDecoration(
                      prefixText: '₹',
                      isDense: true,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            _RemainingBanner(
              isComplete: remaining == 0,
              label: remaining == 0
                  ? 'Fully allocated ✓'
                  : 'Remaining: ${formatCurrency(remaining.abs())}',
            ),
          ],
        );
      case SplitMethod.percentage:
        final remaining = 100 - percentTotal;
        return Column(
          children: [
            for (final m in members)
              _AmountRow(
                member: m,
                trailing: SizedBox(
                  width: 90,
                  child: TextField(
                    controller: percentControllers[m.id],
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.end,
                    onChanged: (_) => onSharesChanged(),
                    decoration: const InputDecoration(
                      suffixText: '%',
                      isDense: true,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            _RemainingBanner(
              isComplete: remaining == 0,
              label: remaining == 0
                  ? 'Fully allocated ✓'
                  : 'Remaining: $remaining%',
            ),
          ],
        );
      case SplitMethod.shares:
        final totalShares = members.fold<int>(
          0,
          (sum, m) => sum + (shareCounts[m.id] ?? 0),
        );
        return Column(
          children: [
            for (final m in members)
              _AmountRow(
                member: m,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: () {
                        if ((shareCounts[m.id] ?? 1) > 0) {
                          shareCounts[m.id] = (shareCounts[m.id] ?? 1) - 1;
                          onSharesChanged();
                        }
                      },
                    ),
                    Text(
                      '${shareCounts[m.id] ?? 1}',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline, size: 20),
                      onPressed: () {
                        shareCounts[m.id] = (shareCounts[m.id] ?? 1) + 1;
                        onSharesChanged();
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '$totalShares total shares',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        );
    }
  }
}

class _AmountRow extends StatelessWidget {
  const _AmountRow({required this.member, required this.trailing});

  final Member member;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          AppAvatar(member: member, radius: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              member.isCurrentUser ? '${member.name} (You)' : member.name,
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _RemainingBanner extends StatelessWidget {
  const _RemainingBanner({required this.isComplete, required this.label});

  final bool isComplete;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isComplete ? AppColors.primary : AppColors.coral;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle_outline : Icons.error_outline,
            size: 18,
            color: color,
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
