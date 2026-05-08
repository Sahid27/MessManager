import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../../domain/entities/user.dart';
import '../../domain/repos/auth_repository.dart';

class AuthRepoImpl implements AuthRepository {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  @override
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

  @override
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
      // Firestore এ user save করো
      await _db.collection('users')
               .doc(user.uid)
               .set(user.toMap());
      return user;
    } on FirebaseAuthException catch (e) {
      throw _mapError(e.code);
    }
  }

  @override
  Future<void> logout() => _auth.signOut();

  @override
  Future<AppUser?> getCurrentUser() async {
    final u = _auth.currentUser;
    if (u == null) return null;
    return _getUser(u.uid);
  }

  // Helper: Firestore থেকে user নিয়ে আসো
  Future<AppUser> _getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return UserModel.fromMap(doc.data()!, uid);
  }

  // Helper: Firebase error কে বাংলা message এ রূপান্তর
  String _mapError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'এই ইমেইলে কোনো একাউন্ট নেই';
      case 'wrong-password':
        return 'পাসওয়ার্ড ভুল হয়েছে';
      case 'email-already-in-use':
        return 'এই ইমেইল আগেই ব্যবহার হয়েছে';
      case 'invalid-email':
        return 'ইমেইল ঠিকানা সঠিক নয়';
      case 'weak-password':
        return 'পাসওয়ার্ড কমপক্ষে ৬ অক্ষর দাও';
      default:
        return 'সমস্যা হয়েছে, আবার চেষ্টা করো';
    }
  }
}