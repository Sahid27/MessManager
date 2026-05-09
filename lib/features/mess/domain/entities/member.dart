enum UserRole { manager, member }

class MessMember {
  final String   uid;
  final String   name;
  final UserRole role;
  final DateTime joinedAt;

  const MessMember({
    required this.uid,
    required this.name,
    required this.role,
    required this.joinedAt,
  });

  // Manager কিনা সহজে check করার জন্য
  bool get isManager => role == UserRole.manager;

  MessMember copyWith({UserRole? role}) {
    return MessMember(
      uid: uid, name: name, joinedAt: joinedAt,
      role: role ?? this.role,
    );
  }
}