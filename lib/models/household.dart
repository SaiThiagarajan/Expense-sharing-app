import 'member.dart';

/// A group of members sharing expenses, e.g. "Green House".
class Household {
  const Household({
    required this.id,
    required this.name,
    required this.members,
  });

  final String id;
  final String name;
  final List<Member> members;

  int get memberCount => members.length;

  /// Pluralized member count for headers, e.g. `1 member`, `4 members`.
  String get memberCountLabel =>
      '$memberCount ${memberCount == 1 ? 'member' : 'members'}';

  bool hasMember(String memberId) => members.any((m) => m.id == memberId);
}
