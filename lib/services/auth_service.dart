import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/app_user.dart' as model;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  User? get currentUser => _auth.currentUser;
  
  // Mendaftar dengan email dan password
  Future<UserCredential> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      // Buat user firebase auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Update display name
      await userCredential.user?.updateDisplayName(displayName);
      
      // Buat user document di firestore
      await _createUserInFirestore(userCredential.user!, displayName);
      
      return userCredential;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }
  
  // Membuat user baru di firestore
  Future<void> _createUserInFirestore(User user, String displayName) async {
    final model.AppUser appUser = model.AppUser(
      id: user.uid,
      email: user.email!,
      displayName: displayName,
      photoUrl: user.photoURL,
      createdAt: DateTime.now(),
    );
    
    await _firestore.collection('users').doc(user.uid).set(appUser.toMap());
  }
  
  // Login dengan email dan password
  Future<UserCredential> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print('Error signing in: $e');
      rethrow;
    }
  }
  
  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }
  
  // Mendapatkan data user dari firestore
  Future<model.AppUser?> getUserData() async {
    if (currentUser == null) return null;
    
    try {
      final docSnapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      
      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        data['id'] = docSnapshot.id; // Pastikan ID terisi
        return model.AppUser.fromMap(data);
      }
      
      return null;
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }
  
  // Update profil user
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    if (currentUser == null) return;
    
    try {
      Map<String, dynamic> updates = {};
      
      if (displayName != null && displayName.isNotEmpty) {
        await currentUser!.updateDisplayName(displayName);
        updates['displayName'] = displayName;
      }
      
      if (photoUrl != null && photoUrl.isNotEmpty) {
        await currentUser!.updatePhotoURL(photoUrl);
        updates['photoUrl'] = photoUrl;
      }
      
      if (updates.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser!.uid).update(updates);
      }
    } catch (e) {
      print('Error updating profile: $e');
      rethrow;
    }
  }
}
