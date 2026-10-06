import 'package:flutter/material.dart';

import '../../models/member.dart';

/// Circular initials avatar for a household member, colored per-member so
/// people stay visually distinct across lists, the nav sidebar and split
/// pickers.
class AppAvatar extends StatelessWidget {
  const AppAvatar({super.key, required this.member, this.radius = 20});

  final Member member;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = member.initials;

    // Announce the member's name rather than just their initials.
    return Semantics(
      label: member.name,
      child: ExcludeSemantics(
        child: CircleAvatar(
          radius: radius,
          backgroundColor: member.avatarColor,
          child: initials.isEmpty
              ? Icon(Icons.person_outline, color: Colors.white, size: radius)
              : Text(
                  initials,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: radius * 0.7,
                  ),
                ),
        ),
      ),
    );
  }
}
