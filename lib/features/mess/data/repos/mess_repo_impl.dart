import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/mess_model.dart';
import '../../domain/entities/mess.dart';
import '../../domain/entities/member.dart';
import 'dart:math';

class MessRepoImpl {
  final _db = FirebaseFirestore.instance;

  // নতুন মেস তৈরি করো
  Future<Mess> createMess({
    required String name,
    required String creatorUid,
    required String creatorName,
  }) async {
    final messId = const Uuid().v4();
    final code   = _genCode(); // ৬ ডিজিট

    final mess = MessModel(
      id: messId, name: name,
      inviteCode: code,
      createdBy: creatorUid,
      createdAt: DateTime.now(),
    );

    final batch = _db.batch();

    // ১. messes collection এ mess save করো
    batch.set(
      _db.collection('messes').doc(messId),
      mess.toMap(),
    );

    // ২. creator কে manager হিসেবে যোগ করো
    batch.set(
      _db.collection('messes')
         .doc(messId)
         .collection('members')
         .doc(creatorUid),
      {
        'name':     creatorName,
        'role':     'manager',
        'joinedAt': Timestamp.now(),
      },
    );

    // ৩. user document এ messId যোগ করো
    batch.update(
      _db.collection('users').doc(creatorUid),
      {'messId': messId},
    );

    await batch.commit();
    return mess;
  }

  // invite code দিয়ে মেসে যোগ দাও
  Future<Mess> joinMess({
    required String code,
    required String uid,
    required String name,
  }) async {
    // code দিয়ে mess খোঁজো
    final snap = await _db
      .collection('messes')
      .where('inviteCode', isEqualTo: code.toUpperCase())
      .limit(1)
      .get();

    if (snap.docs.isEmpty) {
      throw 'ভুল কোড! মেস পাওয়া যায়নি';
    }

    final messDoc = snap.docs.first;
    final messId  = messDoc.id;
    final batch   = _db.batch();

    // member হিসেবে যোগ দাও
    batch.set(
      _db.collection('messes')
         .doc(messId)
         .collection('members')
         .doc(uid),
      {
        'name':     name,
        'role':     'member',
        'joinedAt': Timestamp.now(),
      },
    );
    batch.update(
      _db.collection('users').doc(uid),
      {'messId': messId},
    );

    await batch.commit();
    return MessModel.fromMap(messDoc.data(), messId);
  }

  // সব member লোড করো (real-time stream)
  Stream<List<MessMember>> getMembers(String messId) {
    return _db
      .collection('messes')
      .doc(messId)
      .collection('members')
      .snapshots()
      .map((snap) => snap.docs.map((d) {
        final data = d.data();
        return MessMember(
          uid:      d.id,
          name:     data['name'],
          role:     data['role'] == 'manager'
                      ? UserRole.manager
                      : UserRole.member,
          joinedAt: (data['joinedAt']
                      as Timestamp).toDate(),
        );
      }).toList());
  }

  // ৬ ডিজিটের random invite code
  String _genCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(6,
      (_) => chars[rand.nextInt(chars.length)]).join();
  }
}