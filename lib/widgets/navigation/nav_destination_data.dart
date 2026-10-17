import 'package:flutter/material.dart';

/// Data for one top-level nav destination, shared by the bottom nav, rail
/// and sidebar so mobile/tablet/desktop always agree on the same items.
class NavDestinationData {
  const NavDestinationData({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const List<NavDestinationData> appNavDestinations = [
  NavDestinationData(
    label: 'Home',
    icon: Icons.home_outlined,
    selectedIcon: Icons.home,
  ),
  NavDestinationData(
    label: 'Expenses',
    icon: Icons.receipt_long_outlined,
    selectedIcon: Icons.receipt_long,
  ),
  NavDestinationData(
    label: 'People',
    icon: Icons.people_outline,
    selectedIcon: Icons.people,
  ),
  NavDestinationData(
    label: 'Balances',
    icon: Icons.account_balance_wallet_outlined,
    selectedIcon: Icons.account_balance_wallet,
  ),
  NavDestinationData(
    label: 'Activity',
    icon: Icons.history_outlined,
    selectedIcon: Icons.history,
  ),
];
