import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/mess.dart';

class MessModel extends Mess {
  const MessModel({
    required super.id,
    required super.name,
    required super.inviteCode,
    required super.createdBy,
    required super.createdAt,
  });

  factory MessModel.fromMap(
    Map<String, dynamic> map,
    String id,
  ) {
    return MessModel(
      id: id,
      name: map['name'],
      inviteCode: map['inviteCode'],
      createdBy: map['createdBy'],
      createdAt:
          (map['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'inviteCode': inviteCode,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}