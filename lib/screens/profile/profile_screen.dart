import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_avatar.dart';
import 'settings_subpages.dart';

/// The account screen: profile summary plus the settings list, ending in
/// logout (with a confirmation dialog, never an instant sign-out).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.coral),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      context.read<AppState>().logout();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final member = appState.currentMember;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
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
                      AppAvatar(member: member, radius: 40),
                      const SizedBox(height: AppSpacing.md),
                      Text(member.name, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 2),
                      Text(
                        appState.profileEmail,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: Icons.person_outline,
                      label: 'Edit Profile',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.notifications_outlined,
                      label: 'Notifications',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationSettingsScreen(),
                        ),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.currency_rupee_rounded,
                      label: 'Currency',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const CurrencySettingsScreen(),
                        ),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.palette_outlined,
                      label: 'Appearance',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AppearanceSettingsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _SettingsGroup(
                  children: [
                    _SettingsRow(
                      icon: Icons.privacy_tip_outlined,
                      label: 'Privacy',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InfoScreen(
                            title: 'Privacy',
                            body:
                                'Splitly is a frontend prototype — everything you see lives only in this session\'s memory. '
                                'No expense, balance or profile data is sent to a server, stored in a database, or shared with '
                                'anyone outside this demo.',
                          ),
                        ),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.help_outline,
                      label: 'Help',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InfoScreen(
                            title: 'Help',
                            body:
                                'Add an expense from the + button, choose who was involved and how to split it, and Splitly '
                                'keeps everyone\'s balance up to date automatically. Use Settle Up to record a payment, or send a '
                                'Gentle Nudge to remind someone about a balance.',
                          ),
                        ),
                      ),
                    ),
                    _SettingsRow(
                      icon: Icons.info_outline,
                      label: 'About',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InfoScreen(
                            title: 'About',
                            body:
                                'Splitly 1.0.0\nA polished expense-splitting UI/UX prototype built with Flutter & Material 3.\n\n'
                                'Designed for Green House — Sai, Rishi, Eshaan & Uday.',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.coral,
                    ),
                    label: const Text(
                      'Log out',
                      style: TextStyle(color: AppColors.coral),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.coral),
                    ),
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

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppSpacing.radiusLg);
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Material(
        color: AppColors.surfaceIvory,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i != 0) const Divider(height: 1),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
      title: Text(label),
      trailing: Icon(
        Icons.chevron_right_rounded,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
