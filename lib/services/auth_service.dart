import 'package:firebase_auth/firebase_auth.dart';

/// Service untuk mengatur autentikasi pengguna
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mendapatkan user saat ini
  User? get currentUser => _auth.currentUser;

  /// Stream untuk mendengarkan perubahan state autentikasi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Register dengan email dan password
  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        throw Exception('Password terlalu lemah');
      } else if (e.code == 'email-already-in-use') {
        throw Exception('Email sudah digunakan');
      } else {
        throw Exception('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Login dengan email dan password
  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        throw Exception('Pengguna tidak ditemukan');
      } else if (e.code == 'wrong-password') {
        throw Exception('Password salah');
      } else {
        throw Exception('Terjadi kesalahan: ${e.message}');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception('Terjadi kesalahan: ${e.message}');
    } catch (e) {
      throw Exception('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
