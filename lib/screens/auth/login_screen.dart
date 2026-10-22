import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../app/theme/app_colors.dart';
import '../../app/theme/app_spacing.dart';
import '../../core/responsive/breakpoints.dart';
import '../../state/app_state.dart';
import '../../widgets/common/app_snackbar.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/primary_loading_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@example.com');
  final _passwordController = TextEditingController(text: 'password123');

  bool _obscure = true;
  bool _rememberMe = true;
  ButtonRunState _state = ButtonRunState.idle;
  String? _formError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _state = ButtonRunState.loading;
      _formError = null;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    final appState = context.read<AppState>();
    final error = appState.login(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (error != null) {
      setState(() {
        _state = ButtonRunState.idle;
        _formError = error;
      });
      showErrorSnackBar(context, error);
      return;
    }

    setState(() => _state = ButtonRunState.success);
    showSuccessSnackBar(
      context,
      'Login successful — Welcome back, ${appState.currentMember.name}!',
      duration: const Duration(seconds: 2),
    );

    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.shell, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final form = _buildForm(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: switch (context.screenSize) {
          ScreenSize.mobile => _CenteredLoginLayout(
            outerPadding: AppSpacing.md,
            card: _LoginCard(padding: AppSpacing.lg, child: form),
          ),
          ScreenSize.tablet => _CenteredLoginLayout(
            outerPadding: AppSpacing.xxl,
            card: _LoginCard(maxWidth: 460, child: form),
          ),
          ScreenSize.desktop => _DesktopLogin(form: form),
        },
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Center(child: _LoginBrandBadge()),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Text(
              'Welcome back',
              style: theme.textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Center(
            child: Text(
              'Sign in to continue splitting expenses',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.mail_outline),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
          ),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            label: 'Password',
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscure
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
            validator: (v) =>
                (v == null || v.isEmpty) ? 'Enter your password' : null,
            errorText: _formError != null ? ' ' : null,
          ),
          if (_formError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.coralContainer,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 18,
                    color: AppColors.onCoralContainer,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      _formError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.onCoralContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                onTap: () => setState(() => _rememberMe = !_rememberMe),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale: 0.9,
                        child: Checkbox(
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          value: _rememberMe,
                          onChanged: (v) =>
                              setState(() => _rememberMe = v ?? true),
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Text('Remember me'),
                    ],
                  ),
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                ),
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                child: const Text('Forgot password?'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryLoadingButton(
            label: 'Log in',
            state: _state,
            onPressed: _submit,
          ),
          const SizedBox(height: AppSpacing.lg),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                Text(
                  "Don't have an account? ",
                  style: theme.textTheme.bodyMedium,
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.createAccount),
                  child: Text(
                    'Create account',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.mutedText,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Demo login: demo@example.com / password123',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtle circular app-branding badge shown above the "Welcome back"
/// heading, keeping the existing green/ivory identity rather than a large
/// logo.
class _LoginBrandBadge extends StatelessWidget {
  const _LoginBrandBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.pie_chart_rounded,
        color: AppColors.surfaceIvory,
        size: 26,
      ),
    );
  }
}

/// The login form's container: a warm ivory surface with a soft border and
/// shadow, distinct from a generic Material card and from the beige page
/// background behind it.
class _LoginCard extends StatelessWidget {
  const _LoginCard({
    required this.child,
    this.maxWidth = 440,
    this.padding = AppSpacing.xl,
  });

  final Widget child;
  final double maxWidth;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: AppColors.surfaceIvory,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: AppColors.charcoal.withValues(alpha: 0.07),
              blurRadius: 28,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Vertically (and horizontally) centers [card] within the available
/// space, while remaining a [SingleChildScrollView] so the form scrolls
/// naturally instead of overflowing once the keyboard opens.
class _CenteredLoginLayout extends StatelessWidget {
  const _CenteredLoginLayout({required this.card, required this.outerPadding});

  final Widget card;
  final double outerPadding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final minHeight = (constraints.maxHeight - AppSpacing.xl * 2).clamp(
          0.0,
          double.infinity,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: outerPadding,
            vertical: AppSpacing.xl,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Center(child: card),
          ),
        );
      },
    );
  }
}

class _DesktopLogin extends StatelessWidget {
  const _DesktopLogin({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            color: AppColors.primary,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.pie_chart_rounded,
                      color: AppColors.surfaceIvory,
                      size: 40,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Splitting expenses,\nthe simple way.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(color: AppColors.surfaceIvory),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Green House · Sai, Rishi, Eshaan & Uday',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.surfaceIvory.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: _CenteredLoginLayout(
            outerPadding: AppSpacing.xl,
            card: _LoginCard(child: form),
          ),
        ),
      ],
    );
  }
}
