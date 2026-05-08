import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.messId,
  });

  // Firestore থেকে data নিয়ে UserModel বানাও
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid:    uid,
      name:   map['name']   ?? '',
      email:  map['email']  ?? '',
      phone:  map['phone'],
      messId: map['messId'],
    );
  }

  // Firestore এ save করার জন্য Map বানাও
  Map<String, dynamic> toMap() => {
    'name':   name,
    'email':  email,
    'phone':  phone,
    'messId': messId,
  };
}