import 'package:flutter/material.dart';

import '../../app/theme/app_spacing.dart';
import 'nav_destination_data.dart';

/// Compact tablet navigation rail with a small leading add-expense button.
class AppNavRail extends StatelessWidget {
  const AppNavRail({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.onAddExpense,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onSelected,
      labelType: NavigationRailLabelType.all,
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: FloatingActionButton.small(
          onPressed: onAddExpense,
          tooltip: 'Add Expense',
          child: const Icon(Icons.add),
        ),
      ),
      destinations: [
        for (final destination in appNavDestinations)
          NavigationRailDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: Text(destination.label),
          ),
      ],
    );
  }
}
