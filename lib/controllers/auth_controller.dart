import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = AuthService();
  
  final Rx<User?> _firebaseUser = Rx<User?>(null);
  final Rx<AppUser?> _appUser = Rx<AppUser?>(null);
  final RxBool isLoading = false.obs;
  
  // Getters
  User? get firebaseUser => _firebaseUser.value;
  AppUser? get appUser => _appUser.value;
  bool get isLoggedIn => firebaseUser != null;
  
  @override
  void onInit() {
    super.onInit();
    _firebaseUser.value = _authService.currentUser;
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _firebaseUser.value = user;
      
      // If user is logged in, fetch the user data
      if (user != null) {
        _fetchUserData();
      }
    });
  }
  
  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    try {
      isLoading.value = true;
      final userData = await _authService.getUserData();
      _appUser.value = userData;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to fetch user data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Register with email and password
  Future<void> registerWithEmailAndPassword(
      String email, String password, String displayName) async {
    try {
      isLoading.value = true;
      await _authService.registerWithEmailAndPassword(
        email, 
        password, 
        displayName,
      );
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Registration failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Login with email and password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      isLoading.value = true;
      await _authService.signInWithEmailAndPassword(email, password);
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Login failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Logout
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(Routes.login);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Logout failed: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  
  // Update profile
  Future<void> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      isLoading.value = true;
      await _authService.updateProfile(
        displayName: displayName,
        photoUrl: photoUrl,
      );
      await _fetchUserData();
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
