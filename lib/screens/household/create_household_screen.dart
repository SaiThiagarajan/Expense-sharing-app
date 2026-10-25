import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../data/mock_data.dart';
import '../../models/member.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/primary_loading_button.dart';

/// Lets the user rename/reconfigure their household and pick which team
/// members belong to it. Frontend-only: updates [AppState.household]
/// directly, no persistence beyond the session.
class CreateHouseholdScreen extends StatefulWidget {
  const CreateHouseholdScreen({super.key});

  @override
  State<CreateHouseholdScreen> createState() => _CreateHouseholdScreenState();
}

class _CreateHouseholdScreenState extends State<CreateHouseholdScreen> {
  late final TextEditingController _nameController;
  late Set<String> _selectedIds;
  late final String _currentMemberId;
  // Current household members first, then any mock members not already in
  // it, so members added in an earlier session aren't silently dropped.
  late final List<Member> _baseCandidates;
  final List<Member> _customMembers = [];
  ButtonRunState _state = ButtonRunState.idle;
  bool _created = false;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _nameController = TextEditingController(text: appState.household.name);
    _selectedIds = appState.members.map((m) => m.id).toSet();
    _currentMemberId = appState.currentMember.id;
    _baseCandidates = [
      ...appState.members,
      ...MockData.members.where((m) => !_selectedIds.contains(m.id)),
    ];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _addCustomMember() async {
    final controller = TextEditingController();
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
    if (name != null && name.isNotEmpty) {
      final colors = [
        AppColors.primary,
        AppColors.mint,
        AppColors.amber,
        AppColors.coral,
      ];
      final member = Member(
        id: 'm_custom_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        avatarColor: colors[_customMembers.length % colors.length],
      );
      setState(() {
        _customMembers.add(member);
        _selectedIds.add(member.id);
      });
    }
  }

  Future<void> _create() async {
    if (_nameController.text.trim().isEmpty || _selectedIds.isEmpty) return;
    setState(() => _state = ButtonRunState.loading);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final allCandidates = [..._baseCandidates, ..._customMembers];
    final selectedMembers = allCandidates
        .where((m) => _selectedIds.contains(m.id))
        .toList();

    context.read<AppState>().createHousehold(
      _nameController.text.trim(),
      selectedMembers,
    );
    setState(() {
      _state = ButtonRunState.success;
      _created = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Household')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              child: _created ? _buildSuccess(theme) : _buildForm(theme),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm(ThemeData theme) {
    final allCandidates = [..._baseCandidates, ..._customMembers];
    return ListView(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Text('Household name', style: theme.textTheme.titleSmall),
        const SizedBox(height: AppSpacing.sm),
        AppTextField(
          label: 'Name',
          controller: _nameController,
          prefixIcon: const Icon(Icons.house_outlined),
        ),
        const SizedBox(height: AppSpacing.xl),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Members', style: theme.textTheme.titleSmall),
            TextButton.icon(
              onPressed: _addCustomMember,
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add member'),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: AppColors.outlineVariant),
          ),
          child: Material(
            color: AppColors.surfaceIvory,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                for (var i = 0; i < allCandidates.length; i++) ...[
                  if (i != 0) const Divider(height: 1),
                  CheckboxListTile(
                    value: _selectedIds.contains(allCandidates[i].id),
                    // The current user always stays in their own household
                    // (see AppState.createHousehold), so their row is locked.
                    onChanged: allCandidates[i].id == _currentMemberId
                        ? null
                        : (v) => setState(() {
                            if (v ?? false) {
                              _selectedIds.add(allCandidates[i].id);
                            } else {
                              _selectedIds.remove(allCandidates[i].id);
                            }
                          }),
                    secondary: AppAvatar(member: allCandidates[i], radius: 16),
                    title: Text(
                      allCandidates[i].id == _currentMemberId
                          ? '${allCandidates[i].name} (You)'
                          : allCandidates[i].name,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryLoadingButton(
          label: 'Create Household',
          state: _state,
          onPressed: _create,
        ),
      ],
    );
  }

  Widget _buildSuccess(ThemeData theme) {
    return Padding(
      key: const ValueKey('success'),
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              color: AppColors.mintContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.house_rounded,
              size: 40,
              color: AppColors.onMintContainer,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            'Your household is ready!',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '"${_nameController.text.trim()}" is set up with ${_selectedIds.length} members.',
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
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }
}
