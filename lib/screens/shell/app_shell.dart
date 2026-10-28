import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import '../../core/constants/app_constants.dart';
import '../../core/responsive/breakpoints.dart';
import '../../widgets/navigation/app_bottom_nav.dart';
import '../../widgets/navigation/app_nav_rail.dart';
import '../../widgets/navigation/app_sidebar.dart';
import '../activity/activity_screen.dart';
import '../balances/balances_screen.dart';
import '../dashboard/add_expense_flow.dart';
import '../dashboard/dashboard_screen.dart';
import '../expenses/expenses_screen.dart';
import '../people/people_screen.dart';
import '../profile/profile_screen.dart';

/// The app's responsive navigation shell: bottom nav on mobile, a nav rail
/// on tablet, a persistent sidebar on desktop. Hosts the five primary
/// destinations (Home, Expenses, People, Balances, Activity) as an
/// [IndexedStack] so switching tabs never rebuilds/loses scroll state.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  void _onDestinationSelected(int index) =>
      setState(() => _selectedIndex = index);

  void _onAddExpenseTap() => startAddExpenseFlow(context);

  void _onProfileTap() => Navigator.of(
    context,
  ).push(MaterialPageRoute(builder: (_) => const ProfileScreen()));

  @override
  Widget build(BuildContext context) {
    final pages = _buildPages();

    return ResponsiveScaffold(
      selectedIndex: _selectedIndex,
      onSelected: _onDestinationSelected,
      onAddExpense: _onAddExpenseTap,
      onProfileTap: _onProfileTap,
      pages: pages,
    );
  }

  List<Widget> _buildPages() {
    return [
      DashboardScreen(onNavigateTab: _onDestinationSelected),
      const ExpensesScreen(),
      const PeopleScreen(),
      const BalancesScreen(),
      const ActivityScreen(),
    ];
  }
}

/// Switches between the mobile/tablet/desktop nav chrome based on the
/// available width, keeping [pages] identical across all three.
class ResponsiveScaffold extends StatelessWidget {
  const ResponsiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAddExpense,
    required this.onProfileTap,
    required this.pages,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAddExpense;
  final VoidCallback onProfileTap;
  final List<Widget> pages;

  @override
  Widget build(BuildContext context) {
    switch (context.screenSize) {
      case ScreenSize.mobile:
        return Scaffold(
          body: IndexedStack(index: selectedIndex, children: pages),
          bottomNavigationBar: AppBottomNav(
            selectedIndex: selectedIndex,
            onSelected: onSelected,
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: onAddExpense,
            icon: const Icon(Icons.add),
            label: const Text('Add Expense'),
          ),
        );
      case ScreenSize.tablet:
        return Scaffold(
          body: Row(
            children: [
              AppNavRail(
                selectedIndex: selectedIndex,
                onSelected: onSelected,
                onAddExpense: onAddExpense,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: IndexedStack(index: selectedIndex, children: pages),
              ),
            ],
          ),
        );
      case ScreenSize.desktop:
        return Scaffold(
          body: Row(
            children: [
              AppSidebar(
                selectedIndex: selectedIndex,
                onSelected: onSelected,
                onAddExpense: onAddExpense,
                onProfileTap: onProfileTap,
              ),
              const VerticalDivider(width: 1),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.desktopContentMaxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      child: IndexedStack(
                        index: selectedIndex,
                        children: pages,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}
