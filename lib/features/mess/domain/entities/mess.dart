class Mess {
  final String id;
  final String name;
  final String inviteCode;   // ৬ ডিজিটের কোড
  final String createdBy;    // uid
  final DateTime createdAt;

  const Mess({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.createdBy,
    required this.createdAt,
  });
}