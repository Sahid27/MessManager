class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? messId;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.messId,
  });

  bool get hasJoinedMess => messId != null && messId!.isNotEmpty;
}