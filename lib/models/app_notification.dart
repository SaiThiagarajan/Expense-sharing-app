import 'package:flutter/material.dart';

enum NotificationType {
  expenseAdded,
  settlement,
  memberAdded,
  nudge,
  household,
}

extension NotificationTypeX on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.expenseAdded:
        return 'Expense added';
      case NotificationType.settlement:
        return 'Settlement';
      case NotificationType.memberAdded:
        return 'Member added';
      case NotificationType.nudge:
        return 'Nudge';
      case NotificationType.household:
        return 'Household';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.expenseAdded:
        return Icons.receipt_long_outlined;
      case NotificationType.settlement:
        return Icons.check_circle_outline;
      case NotificationType.memberAdded:
        return Icons.person_add_alt_outlined;
      case NotificationType.nudge:
        return Icons.waving_hand_outlined;
      case NotificationType.household:
        return Icons.house_outlined;
    }
  }
}

/// A single entry in the notification center.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    this.read = false,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final bool read;

  AppNotification copyWith({bool? read}) => AppNotification(
    id: id,
    type: type,
    title: title,
    subtitle: subtitle,
    timestamp: timestamp,
    read: read ?? this.read,
  );

  /// Identity is the [id], so a notification still matches itself after
  /// [copyWith] marks it read.
  @override
  bool operator ==(Object other) => other is AppNotification && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
