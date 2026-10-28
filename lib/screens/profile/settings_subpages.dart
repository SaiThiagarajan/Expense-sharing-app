import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/primary_loading_button.dart';

/// Lets the user rename their profile / display email. Updates
/// [AppState] for real (the current member's name + display email), so the
/// change shows up everywhere that member appears.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  ButtonRunState _state = ButtonRunState.idle;

  @override
  void initState() {
    super.initState();
    final appState = context.read<AppState>();
    _nameController = TextEditingController(text: appState.currentMember.name);
    _emailController = TextEditingController(text: appState.profileEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _state = ButtonRunState.loading);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    context.read<AppState>().updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );
    setState(() => _state = ButtonRunState.success);
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                AppTextField(
                  label: 'Name',
                  controller: _nameController,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: 'Email',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryLoadingButton(
                  label: 'Save changes',
                  state: _state,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Local-only notification category toggles.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _expenses = true;
  bool _settlements = true;
  bool _nudges = true;
  bool _household = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Notifications')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                SwitchListTile(
                  title: const Text('New expenses'),
                  subtitle: const Text(
                    'When someone adds an expense you\'re part of',
                  ),
                  value: _expenses,
                  onChanged: (v) => setState(() => _expenses = v),
                ),
                SwitchListTile(
                  title: const Text('Settlements'),
                  subtitle: const Text('When a balance is settled'),
                  value: _settlements,
                  onChanged: (v) => setState(() => _settlements = v),
                ),
                SwitchListTile(
                  title: const Text('Nudges'),
                  subtitle: const Text('Friendly reminders from housemates'),
                  value: _nudges,
                  onChanged: (v) => setState(() => _nudges = v),
                ),
                SwitchListTile(
                  title: const Text('Household updates'),
                  subtitle: const Text('New members and household changes'),
                  value: _household,
                  onChanged: (v) => setState(() => _household = v),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Currency selector. Splitly displays amounts in ₹ throughout; this screen
/// shows the choice as a local selection for now.
class CurrencySettingsScreen extends StatefulWidget {
  const CurrencySettingsScreen({super.key});

  @override
  State<CurrencySettingsScreen> createState() => _CurrencySettingsScreenState();
}

class _CurrencySettingsScreenState extends State<CurrencySettingsScreen> {
  String _selected = 'INR';

  static const _currencies = [
    ('INR', '₹', 'Indian Rupee'),
    ('USD', '\$', 'US Dollar'),
    ('EUR', '€', 'Euro'),
    ('GBP', '£', 'British Pound'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Currency')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final currency in _currencies)
                  ListTile(
                    leading: Icon(
                      _selected == currency.$1
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selected == currency.$1
                          ? AppColors.primary
                          : null,
                    ),
                    title: Text('${currency.$2}  ${currency.$3}'),
                    subtitle: Text(currency.$1),
                    onTap: () => setState(() => _selected = currency.$1),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Appearance/theme selector. Splitly currently ships one warm light theme;
/// this screen previews how the choice would be presented.
class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() =>
      _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  String _selected = 'Light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Appearance')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                for (final mode in ['Light', 'Dark', 'System'])
                  ListTile(
                    leading: Icon(
                      _selected == mode
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _selected == mode ? AppColors.primary : null,
                    ),
                    title: Text(mode),
                    subtitle: mode != 'Light'
                        ? const Text('Coming in a future update')
                        : null,
                    onTap: () => setState(() => _selected = mode),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Generic informational page used for Privacy / Help / About.
class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key, required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(body, style: theme.textTheme.bodyLarge),
            ),
          ),
        ),
      ),
    );
  }
}
