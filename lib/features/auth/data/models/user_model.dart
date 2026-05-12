import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user.dart';

class UserModel extends AppUser {
  const UserModel({
    required super.uid,
    required super.name,
    required super.email,
    super.phone,
    super.messId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid:    uid,
      name:   map['name']   ?? '',
      email:  map['email']  ?? '',
      phone:  map['phone'],
      messId: map['messId'],
    );
  }

  Map<String, dynamic> toMap() => {
    'name':   name,
    'email':  email,
    'phone':  phone,
    'messId': messId,
  };

  UserModel copyWith({String? messId}) => UserModel(
    uid: uid, name: name, email: email,
    phone: phone, messId: messId ?? this.messId,
  );
}