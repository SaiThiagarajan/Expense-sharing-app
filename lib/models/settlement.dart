/// Direction of a settlement relative to the current user.
enum SettlementDirection { youPaid, theyPaid }

/// A recorded "Settle Up" action between the current user and one other
/// member. Settlements adjust [AppState.netBalanceByMember] on top of the
/// expense ledger rather than mutating any expense.
class Settlement {
  const Settlement({
    required this.id,
    required this.memberId,
    required this.amount,
    required this.direction,
    required this.date,
    this.method = 'UPI',
  });

  final String id;
  final String memberId;
  final int amount;
  final SettlementDirection direction;
  final DateTime date;
  final String method;
}
