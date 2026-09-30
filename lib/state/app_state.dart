import 'package:flutter/material.dart';

import '../core/utils/currency_formatter.dart';
import '../models/activity.dart';
import '../models/app_notification.dart';
import '../models/expense.dart';
import '../models/household.dart';
import '../models/member.dart';
import '../models/settlement.dart';
import '../models/user.dart';

/// Single source of truth for the app's frontend-only state: auth, the
/// logged-in user, the household/members, the expense ledger, settlements
/// and notifications. There is no backend — every mutation just updates
/// in-memory state and notifies listeners.
class AppState extends ChangeNotifier {
  AppState({
    required this.currentUser,
    required Household household,
    required List<Expense> expenses,
    List<AppNotification>? notifications,
  }) : _householdName = household.name,
       _members = List.of(household.members),
       _expenses = List.of(expenses),
       _notifications = List.of(notifications ?? const []),
       _profileEmail = currentUser.email;

  final AppUser currentUser;
  final List<Expense> _expenses;
  final List<Settlement> _settlements = [];
  List<AppNotification> _notifications;

  String _householdName;
  List<Member> _members;
  String _profileEmail;

  /// Starts logged out so the app always opens on the onboarding/login
  /// journey rather than straight into the dashboard.
  bool isLoggedIn = false;

  String get profileEmail => _profileEmail;

  void updateProfile({required String name, required String email}) {
    final current = currentMember;
    _members = [
      for (final m in _members) m.id == current.id ? m.copyWith(name: name) : m,
    ];
    _profileEmail = email;
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Household / members
  // ---------------------------------------------------------------------

  Household get household =>
      Household(id: 'h1', name: _householdName, members: _members);

  List<Member> get members => List.unmodifiable(_members);

  Member get currentMember =>
      _members.firstWhere((m) => m.id == currentUser.memberId);

  Member memberById(String id) => _members.firstWhere((m) => m.id == id);

  void addMember(Member member) {
    _members = List.of(_members)..add(member);
    _pushNotification(
      type: NotificationType.memberAdded,
      title: 'New member added',
      subtitle: '${member.name} joined $_householdName.',
    );
    notifyListeners();
  }

  void createHousehold(String name, List<Member> selectedMembers) {
    _householdName = name;
    _members = List.of(selectedMembers);
    _pushNotification(
      type: NotificationType.household,
      title: 'Household ready',
      subtitle: '"$name" was created with ${selectedMembers.length} members.',
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Expenses
  // ---------------------------------------------------------------------

  /// Expenses sorted most-recent first.
  List<Expense> get expenses {
    final sorted = List<Expense>.of(_expenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    return List.unmodifiable(sorted);
  }

  Expense expenseById(String id) => _expenses.firstWhere((e) => e.id == id);

  /// Net balance per member, from the current user's perspective:
  /// positive means that member owes the current user, negative means the
  /// current user owes that member. Combines the expense ledger with any
  /// recorded settlements.
  Map<String, int> get netBalanceByMember {
    final meId = currentMember.id;
    final net = <String, int>{
      for (final m in _members)
        if (m.id != meId) m.id: 0,
    };

    for (final expense in _expenses) {
      for (final participant in expense.participants) {
        if (participant.memberId == expense.payerId) continue;

        if (expense.payerId == meId && net.containsKey(participant.memberId)) {
          net[participant.memberId] =
              net[participant.memberId]! + participant.share;
        } else if (participant.memberId == meId &&
            net.containsKey(expense.payerId)) {
          net[expense.payerId] = net[expense.payerId]! - participant.share;
        }
      }
    }

    for (final settlement in _settlements) {
      if (!net.containsKey(settlement.memberId)) continue;
      net[settlement.memberId] =
          net[settlement.memberId]! + settlement.balanceDelta;
    }

    return net;
  }

  int get totalOwedToYou => netBalanceByMember.values
      .where((v) => v > 0)
      .fold(0, (sum, v) => sum + v);

  int get totalYouOwe => netBalanceByMember.values
      .where((v) => v < 0)
      .fold(0, (sum, v) => sum + v.abs());

  int get netBalance => totalOwedToYou - totalYouOwe;

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(Expense expense) {
    final index = _expenses.indexWhere((e) => e.id == expense.id);
    if (index == -1) return;
    _expenses[index] = expense;
    notifyListeners();
  }

  void removeExpense(String expenseId) {
    _expenses.removeWhere((e) => e.id == expenseId);
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Settlements
  // ---------------------------------------------------------------------

  void recordSettlement({
    required String memberId,
    required int amount,
    required SettlementDirection direction,
    String method = 'UPI',
  }) {
    final member = memberById(memberId);
    _settlements.add(
      Settlement(
        id: 'st${_settlements.length + 1}_${DateTime.now().microsecondsSinceEpoch}',
        memberId: memberId,
        amount: amount,
        direction: direction,
        date: DateTime.now(),
        method: method,
      ),
    );
    _pushNotification(
      type: NotificationType.settlement,
      title: direction == SettlementDirection.youPaid
          ? 'Settlement sent'
          : 'Settlement received',
      subtitle: direction == SettlementDirection.youPaid
          ? 'You paid ${member.name} ${formatCurrency(amount)}.'
          : '${member.name} settled ${formatCurrency(amount)} with you.',
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Activity feed (derived from expenses + settlements)
  // ---------------------------------------------------------------------

  List<ActivityItem> get recentActivity {
    final items = <ActivityItem>[
      ..._expenses.map(_expenseToActivityItem),
      ..._settlements.map(_settlementToActivityItem),
      ..._notifications
          .where((n) => n.type == NotificationType.nudge)
          .map(_notificationToActivityItem),
    ]..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(items);
  }

  ActivityItem _notificationToActivityItem(AppNotification notification) {
    return ActivityItem(
      id: notification.id,
      type: ActivityType.nudge,
      title: notification.title,
      subtitle: notification.subtitle,
      amount: 0,
      timestamp: notification.timestamp,
    );
  }

  ActivityItem _expenseToActivityItem(Expense expense) {
    final payer = memberById(expense.payerId);
    final meId = currentMember.id;
    final isCurrentUserPayer = expense.payerId == meId;

    final subtitle = isCurrentUserPayer
        ? 'You paid ${formatCurrency(expense.amount)}'
        : '${payer.name} paid ${formatCurrency(expense.amount)}';

    return ActivityItem(
      id: expense.id,
      type: ActivityType.expense,
      title: expense.description,
      subtitle: subtitle,
      amount: expense.netImpactFor(meId),
      timestamp: expense.date,
      relatedExpenseId: expense.id,
    );
  }

  ActivityItem _settlementToActivityItem(Settlement settlement) {
    final member = memberById(settlement.memberId);
    final subtitle = settlement.isYouPaid
        ? 'You paid ${member.name} ${formatCurrency(settlement.amount)}'
        : '${member.name} paid you ${formatCurrency(settlement.amount)}';

    return ActivityItem(
      id: settlement.id,
      type: ActivityType.settlement,
      title: 'Settlement',
      subtitle: subtitle,
      amount: 0,
      timestamp: settlement.date,
    );
  }

  // ---------------------------------------------------------------------
  // Notifications
  // ---------------------------------------------------------------------

  List<AppNotification> get notifications {
    final sorted = List<AppNotification>.of(_notifications);
    sorted.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return List.unmodifiable(sorted);
  }

  int get unreadNotificationCount =>
      _notifications.where((n) => !n.read).length;

  void markAllNotificationsRead() {
    _notifications = [for (final n in _notifications) n.copyWith(read: true)];
    notifyListeners();
  }

  void _pushNotification({
    required NotificationType type,
    required String title,
    required String subtitle,
  }) {
    _notifications = List.of(_notifications)
      ..add(
        AppNotification(
          id: 'ntf_${_notifications.length + 1}_${DateTime.now().microsecondsSinceEpoch}',
          type: type,
          title: title,
          subtitle: subtitle,
          timestamp: DateTime.now(),
        ),
      );
  }

  void sendNudge(String memberId) {
    final member = memberById(memberId);
    _pushNotification(
      type: NotificationType.nudge,
      title: 'Nudge sent',
      subtitle: 'You nudged ${member.name} about their balance.',
    );
    notifyListeners();
  }

  // ---------------------------------------------------------------------
  // Auth
  // ---------------------------------------------------------------------

  static const String demoEmail = 'demo@example.com';
  static const String demoPassword = 'password123';

  /// Returns `null` on success, or an error message on failure.
  String? login({required String email, required String password}) {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail != demoEmail || password != demoPassword) {
      return 'Incorrect email or password. Try demo@example.com / password123.';
    }
    isLoggedIn = true;
    notifyListeners();
    return null;
  }

  void logout() {
    isLoggedIn = false;
    notifyListeners();
  }
}
