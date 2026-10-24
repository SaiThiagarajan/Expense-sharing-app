import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/responsive/breakpoints.dart';

class _OnboardingPageData {
  const _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.bullets,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final List<(IconData, String)>? bullets;
}

const _pages = [
  _OnboardingPageData(
    title: 'Split expenses.\nKeep things simple.',
    subtitle:
        'Track shared expenses, see who owes what, and settle up without the awkward math.',
    icon: Icons.receipt_long_rounded,
    accent: AppColors.primary,
  ),
  _OnboardingPageData(
    title: 'Everyone stays\non the same page.',
    subtitle: 'A shared, always up-to-date view of your household spending.',
    icon: Icons.groups_rounded,
    accent: AppColors.amber,
    bullets: [
      (Icons.receipt_long_outlined, 'Shared expenses'),
      (Icons.account_balance_wallet_outlined, 'Clear balances'),
      (Icons.check_circle_outline, 'Simple settlements'),
    ],
  ),
  _OnboardingPageData(
    title: 'Ready to split?',
    subtitle:
        'Create a household, add your first expense, and let Splitly handle the math.',
    icon: Icons.celebration_rounded,
    accent: AppColors.coral,
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _pages.length - 1;

  void _next() {
    if (_isLast) {
      _getStarted();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  /// New users go to sign-up; returning users use the "Log in" link.
  void _getStarted() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.createAccount);
  }

  void _login() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = context.screenSize != ScreenSize.mobile;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: isDesktop
            ? _DesktopOnboarding(
                controller: _controller,
                index: _index,
                onPageChanged: (i) => setState(() => _index = i),
                onNext: _next,
                onGetStarted: _getStarted,
                onLogin: _login,
              )
            : _MobileOnboarding(
                controller: _controller,
                index: _index,
                onPageChanged: (i) => setState(() => _index = i),
                onNext: _next,
                onGetStarted: _getStarted,
                onLogin: _login,
              ),
      ),
    );
  }
}

class _MobileOnboarding extends StatelessWidget {
  const _MobileOnboarding({
    required this.controller,
    required this.index,
    required this.onPageChanged,
    required this.onNext,
    required this.onGetStarted,
    required this.onLogin,
  });

  final PageController controller;
  final int index;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isLast = index == _pages.length - 1;
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: TextButton(
              onPressed: onGetStarted,
              child: const Text('Skip'),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: controller,
            itemCount: _pages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, i) =>
                _OnboardingPageContent(data: _pages[i], compact: false),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            0,
            AppSpacing.xl,
            AppSpacing.lg,
          ),
          child: Column(
            children: [
              _PageDots(count: _pages.length, index: index),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: onNext,
                  child: Text(isLast ? 'Get Started' : 'Next'),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              TextButton(
                onPressed: onLogin,
                child: const Text('Already have an account? Log in'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DesktopOnboarding extends StatelessWidget {
  const _DesktopOnboarding({
    required this.controller,
    required this.index,
    required this.onPageChanged,
    required this.onNext,
    required this.onGetStarted,
    required this.onLogin,
  });

  final PageController controller;
  final int index;
  final ValueChanged<int> onPageChanged;
  final VoidCallback onNext;
  final VoidCallback onGetStarted;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final isLast = index == _pages.length - 1;
    final data = _pages[index];

    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: data.accent.withValues(alpha: 0.08),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: _OnboardingIllustration(
                key: ValueKey(index),
                icon: data.icon,
                accent: data.accent,
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xxl,
              vertical: AppSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: _pages.length,
                    onPageChanged: onPageChanged,
                    itemBuilder: (context, i) => Align(
                      alignment: Alignment.centerLeft,
                      child: _OnboardingTextBlock(data: _pages[i]),
                    ),
                  ),
                ),
                _PageDots(count: _pages.length, index: index),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed: onNext,
                          child: Text(isLast ? 'Get Started' : 'Next'),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: TextButton(
                    onPressed: onLogin,
                    child: const Text('Already have an account? Log in'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingPageContent extends StatelessWidget {
  const _OnboardingPageContent({required this.data, required this.compact});

  final _OnboardingPageData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: Center(
              child: _OnboardingIllustration(
                icon: data.icon,
                accent: data.accent,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: SingleChildScrollView(
              child: _OnboardingTextBlock(data: data, centered: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingTextBlock extends StatelessWidget {
  const _OnboardingTextBlock({required this.data, this.centered = false});

  final _OnboardingPageData data;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: centered
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          data.title,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          data.subtitle,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (data.bullets != null) ...[
          const SizedBox(height: AppSpacing.lg),
          for (final bullet in data.bullets!)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(bullet.$1, size: 20, color: data.accent),
                  const SizedBox(width: AppSpacing.sm),
                  Text(bullet.$2, style: theme.textTheme.bodyLarge),
                ],
              ),
            ),
        ],
      ],
    );
  }
}

/// A tasteful abstract illustration built from layered shapes + a single
/// glyph, avoiding any stock imagery.
class _OnboardingIllustration extends StatelessWidget {
  const _OnboardingIllustration({
    super.key,
    required this.icon,
    required this.accent,
  });

  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      height: 260,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: 20,
            left: 10,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.mint.withValues(alpha: 0.35),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 12,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.amber.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          ),
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: AppColors.surfaceIvory,
              shape: BoxShape.circle,
              border: Border.all(
                color: accent.withValues(alpha: 0.25),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.18),
                  blurRadius: 32,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Icon(icon, size: 60, color: accent),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 240),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == index ? 22 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == index ? AppColors.primary : AppColors.outline,
              borderRadius: BorderRadius.circular(AppSpacing.radiusPill),
            ),
          ),
      ],
    );
  }
}
