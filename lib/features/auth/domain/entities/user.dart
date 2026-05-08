// User entity — pure Dart, Firebase এর উপর নির্ভরশীল না
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String? phone;
  final String? messId; // কোন মেসে আছে

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    this.phone,
    this.messId,
  });

  // messId আছে মানে মেসে যোগ দিয়েছে
  bool get hasJoinedMess => messId != null;
}