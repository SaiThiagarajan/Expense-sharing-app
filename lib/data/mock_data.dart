import '../app/theme/app_colors.dart';
import '../models/app_notification.dart';
import '../models/expense.dart';
import '../models/household.dart';
import '../models/member.dart';
import '../models/user.dart';

/// Frontend-only mock data for the team demo. There is no backend, database
/// or API — every screen reads from this (or from [AppState], which is
/// seeded from this) instead.
class MockData {
  MockData._();

  static const memberSai = Member(
    id: 'm1',
    name: 'Sai',
    avatarColor: AppColors.primary,
    isCurrentUser: true,
  );
  static const memberRishi = Member(
    id: 'm2',
    name: 'Rishi',
    avatarColor: AppColors.mint,
  );
  static const memberEshaan = Member(
    id: 'm3',
    name: 'Eshaan',
    avatarColor: AppColors.amber,
  );
  static const memberUday = Member(
    id: 'm4',
    name: 'Uday',
    avatarColor: AppColors.coral,
  );

  static const List<Member> members = [
    memberSai,
    memberRishi,
    memberEshaan,
    memberUday,
  ];

  static const household = Household(
    id: 'h1',
    name: 'Green House',
    members: members,
  );

  static const currentUser = AppUser(
    id: 'u1',
    name: 'Sai',
    email: 'demo@example.com',
    memberId: 'm1',
  );

  /// Built fresh (rather than a top-level const) since expense dates are
  /// relative to "now" so the demo always shows recent activity.
  static List<Expense> buildExpenses() {
    final today = DateTime.now();
    DateTime daysAgo(int days) => DateTime(
      today.year,
      today.month,
      today.day,
    ).subtract(Duration(days: days));

    return [
      Expense(
        id: 'e1',
        description: 'Pizza',
        amount: 600,
        category: ExpenseCategory.food,
        payerId: memberSai.id,
        date: daysAgo(0),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 200),
          ExpenseParticipant(memberId: memberRishi.id, share: 200),
          ExpenseParticipant(memberId: memberEshaan.id, share: 200),
        ],
      ),
      Expense(
        id: 'e2',
        description: 'Groceries',
        amount: 900,
        category: ExpenseCategory.groceries,
        payerId: memberRishi.id,
        date: daysAgo(1),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 225),
          ExpenseParticipant(memberId: memberRishi.id, share: 225),
          ExpenseParticipant(memberId: memberEshaan.id, share: 225),
          ExpenseParticipant(memberId: memberUday.id, share: 225),
        ],
      ),
      Expense(
        id: 'e3',
        description: 'Dinner',
        amount: 800,
        category: ExpenseCategory.food,
        payerId: memberSai.id,
        date: daysAgo(2),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 267),
          ExpenseParticipant(memberId: memberRishi.id, share: 267),
          ExpenseParticipant(memberId: memberEshaan.id, share: 266),
        ],
      ),
      Expense(
        id: 'e4',
        description: 'Coffee',
        amount: 250,
        category: ExpenseCategory.food,
        payerId: memberEshaan.id,
        date: daysAgo(3),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 125),
          ExpenseParticipant(memberId: memberEshaan.id, share: 125),
        ],
      ),
      Expense(
        id: 'e5',
        description: 'Team Lunch',
        amount: 1200,
        category: ExpenseCategory.food,
        payerId: memberSai.id,
        date: daysAgo(5),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 300),
          ExpenseParticipant(memberId: memberRishi.id, share: 300),
          ExpenseParticipant(memberId: memberEshaan.id, share: 300),
          ExpenseParticipant(memberId: memberUday.id, share: 300),
        ],
      ),
      Expense(
        id: 'e6',
        description: 'Cab Ride',
        amount: 480,
        category: ExpenseCategory.transport,
        payerId: memberUday.id,
        date: daysAgo(6),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 240),
          ExpenseParticipant(memberId: memberUday.id, share: 240),
        ],
      ),
      Expense(
        id: 'e7',
        description: 'Electricity',
        amount: 2400,
        category: ExpenseCategory.utilities,
        payerId: memberRishi.id,
        date: daysAgo(10),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 600),
          ExpenseParticipant(memberId: memberRishi.id, share: 600),
          ExpenseParticipant(memberId: memberEshaan.id, share: 600),
          ExpenseParticipant(memberId: memberUday.id, share: 600),
        ],
      ),
      Expense(
        id: 'e8',
        description: 'Internet',
        amount: 999,
        category: ExpenseCategory.utilities,
        payerId: memberUday.id,
        date: daysAgo(12),
        participants: [
          ExpenseParticipant(memberId: memberSai.id, share: 250),
          ExpenseParticipant(memberId: memberRishi.id, share: 250),
          ExpenseParticipant(memberId: memberEshaan.id, share: 250),
          ExpenseParticipant(memberId: memberUday.id, share: 249),
        ],
      ),
    ];
  }

  /// Built fresh (rather than a top-level const) since timestamps are
  /// relative to "now" so the demo always shows a lively notification feed.
  static List<AppNotification> buildNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 'ntf1',
        type: NotificationType.expenseAdded,
        title: 'Rishi added a new expense',
        subtitle: '"Groceries" · ₹900 · split 4 ways',
        timestamp: now.subtract(const Duration(hours: 2)),
        read: false,
      ),
      AppNotification(
        id: 'ntf2',
        type: NotificationType.settlement,
        title: 'Eshaan settled up',
        subtitle: 'Eshaan paid you ₹420 via UPI',
        timestamp: now.subtract(const Duration(hours: 6)),
        read: false,
      ),
      AppNotification(
        id: 'ntf3',
        type: NotificationType.household,
        title: 'You were added to Green House',
        subtitle: 'Welcome to the household! Start splitting expenses.',
        timestamp: now.subtract(const Duration(days: 1)),
        read: true,
      ),
      AppNotification(
        id: 'ntf4',
        type: NotificationType.nudge,
        title: 'Uday nudged you',
        subtitle: 'A friendly reminder about your balance.',
        timestamp: now.subtract(const Duration(days: 2)),
        read: true,
      ),
    ];
  }
}
