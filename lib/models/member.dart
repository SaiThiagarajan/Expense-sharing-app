import 'package:flutter/material.dart';

/// A household member. The app's mock team (Sai, Rishi, Eshaan, Uday) is
/// defined as [Member] instances in `data/mock_data.dart`.
class Member {
  const Member({
    required this.id,
    required this.name,
    required this.avatarColor,
    this.isCurrentUser = false,
  });

  final String id;
  final String name;
  final Color avatarColor;
  final bool isCurrentUser;

  Member copyWith({String? name, Color? avatarColor}) {
    return Member(
      id: id,
      name: name ?? this.name,
      avatarColor: avatarColor ?? this.avatarColor,
      isCurrentUser: isCurrentUser,
    );
  }

  /// Up to two initials derived from [name], e.g. `Sai` -> `S`.
  ///
  /// Uses the first user-perceived character of each word rather than the
  /// first UTF-16 code unit, so emoji and Indic names (with combining marks)
  /// don't render as a broken half-glyph in the avatar.
  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '';
    final first = parts.first.characters.first;
    if (parts.length == 1) return first.toUpperCase();
    return (first + parts.last.characters.first).toUpperCase();
  }

  @override
  bool operator ==(Object other) => other is Member && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
