import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';

class AuthRepoImpl {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email, password: password,
      );
      return await _getUser(cred.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email, password: password,
      );
      final user = UserModel(
        uid: cred.user!.uid, name: name, email: email,
      );
      await _db.collection('users').doc(user.uid).set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  Future<void> logout() => _auth.signOut();

  Future<AppUser?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _getUser(u.uid);
  }

  Future<AppUser> _getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) throw 'ইউজার পাওয়া যায়নি';
    return UserModel.fromMap(doc.data()!, uid);
  }

  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':     return 'এই ইমেইলে কোনো একাউন্ট নেই';
      case 'wrong-password':     return 'পাসওয়ার্ড ভুল হয়েছে';
      case 'email-already-in-use': return 'এই ইমেইল আগেই ব্যবহার হয়েছে';
      case 'invalid-email':      return 'ইমেইল ঠিকানা সঠিক নয়';
      case 'weak-password':      return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষর দাও';
      default:                   return 'সমস্যা হয়েছে, আবার চেষ্টা করো';
    }
  }
}