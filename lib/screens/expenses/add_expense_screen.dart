import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/expense.dart';
import '../../models/member.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/category_badge.dart';
import 'split_expense_screen.dart';

/// Polished expense-entry form: description, amount, payer, category, date
/// and an optional note. "Continue" hands the draft off to
/// [SplitExpenseScreen]. Reused for editing via [existingExpense].
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.existingExpense});

  final Expense? existingExpense;

  bool get isEditing => existingExpense != null;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  late final TextEditingController _descriptionController;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _payerId;
  late ExpenseCategory _category;
  late DateTime _date;
  String? _amountError;
  String? _descriptionError;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingExpense;
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _amountController = TextEditingController(
      text: existing != null ? existing.amount.toString() : '',
    );
    _noteController = TextEditingController(text: existing?.note ?? '');
    _category = existing?.category ?? ExpenseCategory.food;
    _date = existing?.date ?? DateTime.now();
    _payerId = existing?.payerId ?? '';
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int? get _amount => int.tryParse(_amountController.text.trim());

  Future<void> _pickPayer(List<Member> members) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) =>
          _MemberPickerSheet(members: members, selectedId: _payerId),
    );
    if (selected != null) setState(() => _payerId = selected);
  }

  Future<void> _pickCategory() async {
    final selected = await showModalBottomSheet<ExpenseCategory>(
      context: context,
      builder: (context) => _CategoryPickerSheet(selected: _category),
    );
    if (selected != null) setState(() => _category = selected);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _continue() {
    final appState = context.read<AppState>();
    setState(() {
      _descriptionError = _descriptionController.text.trim().isEmpty
          ? 'Add a short description'
          : null;
      _amountError = (_amount == null || _amount! <= 0)
          ? 'Enter a valid amount'
          : null;
    });
    if (_descriptionError != null || _amountError != null) return;

    final payerId = _payerId.isEmpty ? appState.currentMember.id : _payerId;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SplitExpenseScreen(
          description: _descriptionController.text.trim(),
          amount: _amount!,
          payerId: payerId,
          category: _category,
          date: _date,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
          existingExpense: widget.existingExpense,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final members = appState.members;
    final payerId = _payerId.isEmpty ? appState.currentMember.id : _payerId;
    final payer = appState.memberById(payerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit expense' : 'Add expense'),
      ),
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
                Text('What was it?', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Description',
                  controller: _descriptionController,
                  hintText: 'e.g. Dinner at Green House',
                  errorText: _descriptionError,
                  textInputAction: TextInputAction.next,
                  onChanged: (_) {
                    if (_descriptionError != null) {
                      setState(() => _descriptionError = null);
                    }
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Amount', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                TextField(
                  key: const Key('amountField'),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                  ),
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  style: AppTypography.financialLarge(
                    color: theme.colorScheme.onSurface,
                  ),
                  onChanged: (_) {
                    if (_amountError != null) {
                      setState(() => _amountError = null);
                    }
                  },
                  decoration: InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: AppTypography.financialLarge(
                      color: theme.colorScheme.onSurface,
                    ),
                    hintText: '0',
                    errorText: _amountError,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Paid by', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                _FormRow(
                  onTap: () => _pickPayer(members),
                  leading: AppAvatar(member: payer, radius: 16),
                  label: payer.id == appState.currentMember.id
                      ? '${payer.name} (You)'
                      : payer.name,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Category', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                _FormRow(
                  onTap: _pickCategory,
                  leading: CategoryBadge(category: _category, size: 32),
                  label: _category.label,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Date', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                _FormRow(
                  onTap: _pickDate,
                  leading: const Icon(Icons.calendar_today_outlined, size: 20),
                  label: formatRelativeDate(_date),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text('Note (optional)', style: theme.textTheme.titleSmall),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: 'Add a note',
                  controller: _noteController,
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _continue,
                    child: const Text('Continue'),
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

class _FormRow extends StatelessWidget {
  const _FormRow({
    required this.onTap,
    required this.leading,
    required this.label,
  });

  final VoidCallback onTap;
  final Widget leading;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.surfaceIvory,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.outline),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          child: Row(
            children: [
              leading,
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(label, style: theme.textTheme.bodyLarge)),
              Icon(
                Icons.expand_more_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberPickerSheet extends StatelessWidget {
  const _MemberPickerSheet({required this.members, required this.selectedId});

  final List<Member> members;
  final String selectedId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Who paid?', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.sm),
            for (final member in members)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: AppAvatar(member: member, radius: 18),
                title: Text(
                  member.isCurrentUser ? '${member.name} (You)' : member.name,
                ),
                trailing: member.id == selectedId
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => Navigator.of(context).pop(member.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _CategoryPickerSheet extends StatelessWidget {
  const _CategoryPickerSheet({required this.selected});

  final ExpenseCategory selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Category', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final category in ExpenseCategory.values)
                  _CategoryChip(
                    category: category,
                    selected: category == selected,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({required this.category, required this.selected});

  final ExpenseCategory category;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? category.color.withValues(alpha: 0.16)
          : AppColors.background,
      borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
        onTap: () => Navigator.of(context).pop(category),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            border: Border.all(
              color: selected ? category.color : AppColors.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(category.icon, size: 16, color: category.color),
              const SizedBox(width: AppSpacing.xs),
              Text(
                category.label,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
