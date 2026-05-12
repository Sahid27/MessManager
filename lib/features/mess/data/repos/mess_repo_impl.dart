import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/mess_model.dart';
import '../../domain/entities/mess.dart';
import '../../domain/entities/member.dart';

class MessRepoImpl {
  final _db = FirebaseFirestore.instance;

  Future<Mess> createMess({
    required String name,
    required String creatorUid,
    required String creatorName,
  }) async {
    final messId = const Uuid().v4();
    final code   = _genCode();
    final mess   = MessModel(
      id: messId, name: name, inviteCode: code,
      createdBy: creatorUid, createdAt: DateTime.now());

    final batch = _db.batch();
    batch.set(_db.collection('messes').doc(messId), mess.toMap());
    batch.set(
      _db.collection('messes').doc(messId).collection('members').doc(creatorUid),
      {'name': creatorName, 'role': 'manager', 'joinedAt': Timestamp.now()});
    batch.update(
      _db.collection('users').doc(creatorUid), {'messId': messId});
    await batch.commit();
    return mess;
  }

  Future<Mess> joinMess({
    required String code,
    required String uid,
    required String name,
  }) async {
    final snap = await _db.collection('messes')
      .where('inviteCode', isEqualTo: code.toUpperCase())
      .limit(1).get();

    if (snap.docs.isEmpty) throw 'ভুল কোড! মেস পাওয়া যায়নি';

    final messDoc = snap.docs.first;
    final messId  = messDoc.id;
    final batch   = _db.batch();

    batch.set(
      _db.collection('messes').doc(messId).collection('members').doc(uid),
      {'name': name, 'role': 'member', 'joinedAt': Timestamp.now()});
    batch.update(
      _db.collection('users').doc(uid), {'messId': messId});
    await batch.commit();
    return MessModel.fromMap(messDoc.data(), messId);
  }

  Future<Mess> getMessById(String messId) async {
    final doc = await _db.collection('messes').doc(messId).get();
    if (!doc.exists) throw 'মেস খুঁজে পাওয়া যায়নি';
    return MessModel.fromMap(doc.data()!, messId);
  }

  Stream<List<MessMember>> getMembers(String messId) {
    return _db
      .collection('messes').doc(messId).collection('members')
      .snapshots()
      .map((snap) => snap.docs.map((d) {
        final data = d.data();
        return MessMember(
          uid:  d.id, name: data['name'],
          role: data['role'] == 'manager' ? UserRole.manager : UserRole.member,
          joinedAt: (data['joinedAt'] as Timestamp).toDate());
      }).toList());
  }

  Future<void> handoverManager(
      String messId, String oldUid, String newUid) async {
    final batch = _db.batch();
    final ref = _db.collection('messes').doc(messId).collection('members');
    batch.update(ref.doc(oldUid), {'role': 'member'});
    batch.update(ref.doc(newUid), {'role': 'manager'});
    await batch.commit();
  }

  String _genCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand  = Random();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}