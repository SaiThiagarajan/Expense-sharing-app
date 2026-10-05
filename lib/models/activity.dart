enum ActivityType { expense, settlement, nudge }

/// A single entry in the activity feed. [amount] is signed from the
/// current user's perspective: positive means money owed to them, negative
/// means money they owe, zero for a fully settled entry.
class ActivityItem {
  const ActivityItem({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.timestamp,
    this.relatedExpenseId,
  });

  final String id;
  final ActivityType type;
  final String title;
  final String subtitle;
  final int amount;
  final DateTime timestamp;
  final String? relatedExpenseId;

  /// True when this entry leaves money owed to the current user.
  bool get isOwedToYou => amount > 0;

  /// True when this entry leaves the current user owing money.
  bool get isOwedByYou => amount < 0;

  /// True when this entry has no outstanding balance.
  bool get isSettled => amount == 0;
}
